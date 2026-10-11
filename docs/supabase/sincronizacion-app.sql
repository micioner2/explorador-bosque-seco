-- Tablas para sincronizar lo que la app móvil registra sin señal.
-- Para el equipo web: revisar y ejecutar en Supabase (SQL Editor) con la
-- cuenta del panel. Nombres en inglés, como el resto del portal.
--
-- Reglas que respeta (ver .claude/skills/reglas-negocio/SKILL.md):
-- * Cada registro llega con su id (UUID) generado en el celular: la app
--   hace upsert por id, así reenviar no duplica (offline-first).
-- * R1: un punto suma una sola vez por visita -> unique (visit_id, point_id).
-- * R5: cada visitante con nombre, documento, edad y procedencia; país si
--   es extranjero (protocolo del SERNANP). El documento es dato personal:
--   solo lo lee la asociación dueña (RLS).
-- * R14/R15: una reserva solo avanza de pending a cancelled o checked_in.
-- * R17: un cierre por asociación y día.
--
-- Supone las tablas del portal: associations(id) y profiles(id,
-- association_id), con profiles.id = auth.users.id.

-- Asociación de quien hace la consulta (cuenta compartida por sus guías).
create or replace function public.current_association_id()
returns uuid
language sql stable security definer set search_path = public
as $$
  select association_id from profiles where id = auth.uid()
$$;

-- Guías que eligen su nombre en "¿Quién eres?".
create table if not exists public.guides (
  id uuid primary key default gen_random_uuid(),
  association_id uuid not null references associations(id),
  name text not null check (length(trim(name)) > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Visita = grupo que entra junto con las mismas actividades (R9).
create table if not exists public.visits (
  id uuid primary key,                         -- generado en el celular
  association_id uuid not null references associations(id),
  guide_id uuid references guides(id),
  guide_name text,                             -- nombre al registrar
  reservation_id uuid,
  activities text[] not null
    check (array_length(activities, 1) > 0
           and activities <@ array['senderismo','aves','fotografia','campamento']),
  entered_at timestamptz not null,
  expected_exit_at timestamptz not null,
  exited_at timestamptz,
  synced_at timestamptz not null default now(),
  check (expected_exit_at > entered_at),
  check (exited_at is null or exited_at >= entered_at)
);

create table if not exists public.visitors (
  visit_id uuid not null references visits(id) on delete cascade,
  position smallint not null check (position >= 1),   -- 1 = responsable
  full_name text not null check (length(trim(full_name)) > 0),
  document_number text not null,
  age smallint not null check (age between 0 and 120),
  origin text not null check (origin in ('piura','lima','otraRegion','extranjero')),
  country text,
  primary key (visit_id, position),
  check (origin <> 'extranjero' or coalesce(trim(country), '') <> ''),
  check (origin = 'extranjero' or document_number ~ '^[0-9]{8}$')
);

create table if not exists public.reservations (
  id uuid primary key,                         -- generado en el celular
  association_id uuid not null references associations(id),
  contact_name text not null,
  phone text,
  scheduled_at timestamptz not null,
  people smallint not null check (people between 1 and 99),
  status text not null default 'pending'
    check (status in ('pending','cancelled','checked_in')),
  reschedules smallint not null default 0,
  visit_id uuid references visits(id),
  guide_id uuid references guides(id),
  guide_name text,
  synced_at timestamptz not null default now()
);

alter table public.visits
  drop constraint if exists visits_reservation_id_fkey,
  add constraint visits_reservation_id_fkey
    foreign key (reservation_id) references reservations(id);

-- Sellos del pasaporte (lo envía el celular del turista).
create table if not exists public.scans (
  id uuid primary key,                         -- generado en el celular
  visit_id uuid not null references visits(id),
  point_id text not null,
  scanned_at timestamptz not null,
  synced_at timestamptz not null default now(),
  unique (visit_id, point_id)                  -- R1
);

create table if not exists public.day_closings (
  association_id uuid not null references associations(id),
  day date not null,
  closed_at timestamptz not null,
  closed_by text not null,                     -- nombre del guía
  groups integer not null,
  visitors integer not null,
  groups_without_exit integer not null,
  by_guide jsonb not null default '[]',        -- [{guide, groups, people}]
  primary key (association_id, day)
);

-- Una reserva no retrocede de estado (R14).
create or replace function public.reservations_status_forward()
returns trigger language plpgsql as $$
begin
  if old.status <> 'pending' and new.status <> old.status then
    raise exception 'La reserva % ya está %', old.id, old.status;
  end if;
  return new;
end $$;

drop trigger if exists reservations_status_forward on public.reservations;
create trigger reservations_status_forward
  before update on public.reservations
  for each row execute function public.reservations_status_forward();

-- Seguridad: cada asociación ve y escribe solo lo suyo.
alter table public.guides       enable row level security;
alter table public.visits       enable row level security;
alter table public.visitors     enable row level security;
alter table public.reservations enable row level security;
alter table public.scans        enable row level security;
alter table public.day_closings enable row level security;

create policy guides_own on public.guides for all to authenticated
  using (association_id = current_association_id())
  with check (association_id = current_association_id());

create policy visits_own on public.visits for all to authenticated
  using (association_id = current_association_id())
  with check (association_id = current_association_id());

create policy visitors_own on public.visitors for all to authenticated
  using (exists (select 1 from visits v where v.id = visit_id
                 and v.association_id = current_association_id()))
  with check (exists (select 1 from visits v where v.id = visit_id
                      and v.association_id = current_association_id()));

create policy reservations_own on public.reservations for all to authenticated
  using (association_id = current_association_id())
  with check (association_id = current_association_id());

create policy day_closings_own on public.day_closings for all to authenticated
  using (association_id = current_association_id())
  with check (association_id = current_association_id());

-- La asociación lee los sellos de sus visitas (puntos más visitados).
create policy scans_read_own on public.scans for select to authenticated
  using (exists (select 1 from visits v where v.id = visit_id
                 and v.association_id = current_association_id()));

-- El turista no tiene cuenta: su celular envía el sello con la clave
-- pública. Solo puede insertar si la visita existe (conoce su id por el QR
-- del grupo), y nunca leer ni cambiar sellos ajenos.
-- (visits tiene RLS: la comprobación usa una función que no expone datos.)
create or replace function public.visit_exists(p_visit_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (select 1 from visits where id = p_visit_id)
$$;

create policy scans_insert_tourist on public.scans
  for insert to anon, authenticated
  with check (visit_exists(visit_id));
