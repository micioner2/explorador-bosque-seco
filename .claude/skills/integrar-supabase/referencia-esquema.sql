-- Esquema de referencia para Supabase (Postgres). PROPUESTA: revisar con el
-- equipo antes de ejecutar. Refleja las reglas de docs/PRODUCTO.md.

create extension if not exists "pgcrypto";

-- Catálogo (lectura pública) -------------------------------------------------

create table asociaciones (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  comunidad text not null,
  departamento text not null,
  whatsapp text
);

create table espacios (
  id text primary key,                         -- ej. 'el-angolo'
  asociacion_id uuid not null references asociaciones(id),
  nombre text not null,
  ubicacion text not null,
  medios_pago text[] not null default '{}',
  senal text,
  acceso text
);

create table rutas (
  id uuid primary key default gen_random_uuid(),
  espacio_id text not null references espacios(id),
  nombre text not null,
  trazo_geojson jsonb not null,
  distancia_km numeric(5,2),
  tiempo_min int,
  dificultad text
);

create table puntos (
  id text primary key,                         -- ej. 'pozas'; va en el QR
  ruta_id uuid not null references rutas(id),
  nombre text not null,
  descripcion text,
  lat double precision,
  lng double precision,
  fotos text[] not null default '{}',
  audio_url text,
  orden int not null default 0
);

create table servicios (
  id uuid primary key default gen_random_uuid(),
  asociacion_id uuid not null references asociaciones(id),
  tipo text not null check (tipo in ('guiado','alimentacion','hospedaje','transporte')),
  nombre text not null,
  whatsapp text not null,
  tarifa_referencial text
);

create table productos (
  id uuid primary key default gen_random_uuid(),
  asociacion_id uuid not null references asociaciones(id),
  nombre text not null,
  puntos_requeridos int not null check (puntos_requeridos > 0),        -- R4
  porcentaje_descuento int not null check (porcentaje_descuento between 1 and 100)
);

-- Operación (datos personales: RLS estricto) --------------------------------

-- Una visita es un grupo que entra junto y hace las mismas actividades (R9).
create table visitas (
  id uuid primary key default gen_random_uuid(),
  token uuid not null unique default gen_random_uuid(),  -- va en el QR único del grupo
  asociacion_id uuid not null references asociaciones(id),
  espacio_id text not null references espacios(id),
  actividades text[] not null                                          -- R9: una o varias
    check (cardinality(actividades) >= 1
      and actividades <@ array['senderismo','aves','fotografia','campamento']),
  guia text,
  fecha_entrada timestamptz not null default now(),
  salida_prevista timestamptz not null,
  fecha_salida timestamptz,
  check (salida_prevista > fecha_entrada),
  check (fecha_salida is null or fecha_salida >= fecha_entrada)        -- R7
);

-- Cada integrante del grupo, registrado por separado (R5). El reporte cuenta
-- la edad y la procedencia de cada uno (R8). Una visita debe tener al menos
-- un integrante: se valida al registrar (visita e integrantes en una sola
-- transacción).
create table visitantes (
  id uuid primary key default gen_random_uuid(),
  visita_id uuid not null references visitas(id) on delete cascade,
  orden int not null default 0,                -- 0 = responsable del grupo
  nombre text not null check (length(trim(nombre)) > 0),
  dni text,
  edad int not null check (edad between 0 and 120),                    -- R5
  procedencia text not null check (procedencia in ('piura','lima','otraRegion','extranjero')),
  unique (visita_id, orden)
);

create table escaneos (
  id uuid primary key,                         -- generado en el celular
  visita_id uuid not null references visitas(id),
  punto_id text not null references puntos(id),
  fecha timestamptz not null,
  recibido_en timestamptz not null default now(),
  unique (visita_id, punto_id)                 -- R1: un punto por visita
);

create table canjes (
  id uuid primary key default gen_random_uuid(),
  visita_id uuid not null references visitas(id),
  producto_id uuid not null references productos(id),
  puntos_usados int not null,
  codigo text not null unique default encode(gen_random_bytes(6), 'hex'),
  estado text not null default 'emitido' check (estado in ('emitido','validado')),
  creado_en timestamptz not null default now()
);

-- Canje en una transacción (R2, R3) ------------------------------------------

create or replace function canjear_producto(p_visita_token uuid, p_producto_id uuid)
returns canjes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_visita visitas;
  v_producto productos;
  v_disponibles int;
  v_canje canjes;
begin
  select * into v_visita from visitas where token = p_visita_token;
  if not found then raise exception 'Visita no encontrada'; end if;

  select * into v_producto from productos where id = p_producto_id;
  if not found then raise exception 'Producto no encontrado'; end if;

  select count(*) - coalesce((select sum(puntos_usados) from canjes where visita_id = v_visita.id), 0)
    into v_disponibles
    from escaneos where visita_id = v_visita.id;

  if v_disponibles < v_producto.puntos_requeridos then
    raise exception 'Faltan % puntos', v_producto.puntos_requeridos - v_disponibles;
  end if;

  insert into canjes (visita_id, producto_id, puntos_usados)
  values (v_visita.id, v_producto.id, v_producto.puntos_requeridos)
  returning * into v_canje;

  return v_canje;
end;
$$;

-- Seguridad (RLS) ------------------------------------------------------------

alter table asociaciones enable row level security;
alter table espacios     enable row level security;
alter table rutas        enable row level security;
alter table puntos       enable row level security;
alter table servicios    enable row level security;
alter table productos    enable row level security;
alter table visitas      enable row level security;
alter table visitantes   enable row level security;
alter table escaneos     enable row level security;
alter table canjes       enable row level security;

create policy "catalogo publico" on asociaciones for select using (true);
create policy "catalogo publico" on espacios     for select using (true);
create policy "catalogo publico" on rutas        for select using (true);
create policy "catalogo publico" on puntos       for select using (true);
create policy "catalogo publico" on servicios    for select using (true);
create policy "catalogo publico" on productos    for select using (true);

-- Visitas, visitantes, escaneos y canjes: definir con el equipo según cómo se autentica la
-- asociación (Supabase Auth) y cómo el turista presenta el token de su visita
-- (por ejemplo, funciones RPC que reciben el token). No crear políticas
-- abiertas para estas tablas.
