---
name: reglas-negocio
description: Reglas del dominio del explorador del bosque seco (puntos, sellos, canje, visitas, alerta "sigue dentro", reporte diario), actores (AIDER, SERNANP, asociaciones) y glosario. Úsala al implementar o cambiar lógica de negocio, al escribir pruebas de dominio o cuando haya dudas sobre cómo debe comportarse la app.
user-invocable: true
---

# Reglas de negocio

La fuente completa es `docs/PRODUCTO.md` (secciones 1, 4 y 6). Este resumen es
lo que no se puede romper.

## Puntos y canje (`lib/features/puntos/domain/`)

- **R1.** Cada punto turístico da **1 punto por visita**. La clave es
  `visitaId::puntoId`. Escanear de nuevo o recibir duplicados al sincronizar no
  suma.
- **R2.** Un escaneo nace **pendiente** (sin señal) y pasa a **confirmado**
  cuando el servidor lo acepta. **Solo los confirmados se canjean.**
- **R3.** Canjear descuenta `puntosRequeridos`; sin puntos suficientes lanza
  `CanjeInvalido` con un mensaje para el turista.
- **R4.** Un producto exige más de 0 puntos y un descuento entre 1 % y 100 %.
- El id de cada escaneo se genera en el celular para que reenviarlo no lo
  duplique (idempotencia).

- **R18.** Canjear entrega un `Cupon` con QR
  (`bosqueseco:cupon:<id>:<producto>:<porcentaje>`). En el puesto,
  `CuponesUsados.validar` lo acepta una sola vez (sin señal; se guarda en
  el celular del puesto).

## Visitas (`lib/features/visitas/domain/`)

- **R5.** Protocolo del SERNANP (seguridad y rescate): cada integrante
  (`Visitante`) se identifica con nombre no vacío, documento, edad entre 0 y
  120 y procedencia. Peruanos: DNI de 8 dígitos. Extranjeros: pasaporte o
  carné de extranjería (5 a 15 letras o números) y país. No hay registro
  simplificado para grupos. Cada visita: al menos un integrante, al menos
  una actividad, fecha de ingreso y salida prevista posterior a la entrada
  (8 h por defecto; si acampan, el guía elige otro día).
- **R6.** "Sigue dentro" = sin salida marcada y ya pasó la salida prevista.
- **R7.** La salida se marca una sola vez y no puede ser antes de la entrada.
- **R9.** Una visita es un grupo que entra junto y hace **las mismas
  actividades** (una o varias). Cada integrante se registra por separado,
  pero todo el grupo comparte **un solo QR** (`Visita.codigoQr`). El primer
  integrante es el responsable. Quien haga otras actividades se registra en
  otra visita, con otro QR.
- Como el QR es del grupo, los puntos también: R1 da 1 punto por visita y
  punto turístico, no por persona.
- Procedencias: Piura, Lima, Otra región, Extranjero (de cada integrante).
- Actividades: Senderismo, Avistamiento de aves, Fotografía, Campamento.

## Sesión del puesto de control (`lib/features/sesion/domain/`)

- **R11.** Al modo asociación solo se entra con la cuenta de una asociación
  activa (Supabase Auth + `profiles.association_id`). La cuenta queda
  guardada en el celular: **nunca se cierra por falta de señal**, solo si el
  servidor la rechaza o alguien sale de ella. Entrar sí necesita señal.
- **R12.** Sin guía elegido no se registran visitas (`Sesion.quienRegistra`
  lanza `StateError`). El guía debe ser de la asociación de la cuenta. Cada
  visita guarda `asociacionId`, `guiaId` y `nombreGuia`. El guía se elige de
  nuevo al abrir la app porque varios guías comparten el celular.
- El router aplica las dos reglas (`redirigirSegunSesion`): sin cuenta lleva
  al acceso; sin guía, a "¿Quién eres?".

## Reservas (`lib/features/reservas/domain/`)

- **R13.** Una reserva (`Reserva.nueva`): nombre de quien reserva, entre 1 y
  `Reserva.maxPersonas` (99) personas y un día y hora que no hayan pasado
  (se compara al minuto). Guarda la asociación y el guía que la anotó. Su id
  se genera en el celular (`core/id.dart`, UUID v4).
- **R14.** Estados: `pendiente` → `cancelada` o `ingresada`. Solo una
  pendiente se reprograma (nunca al pasado; suma `reprogramaciones`) o se
  cancela. Pendiente pasada su hora = "retrasada"; de un día anterior =
  "no llegó" (`AgendaReservas.sinLlegar`).
- **R15.** Al llegar el grupo, "Llegaron" lleva al registro de siempre con
  la reserva vinculada (`BorradorGrupo.reservaId`). Al registrar, la visita
  guarda `reservaId` y la reserva pasa a `ingresada` con `visitaId`, una
  sola vez. Se registra a quienes vinieron, aunque sean más o menos que los
  reservados. Si la reserva se canceló mientras tanto, el grupo se registra
  sin ella.

## Escaneo (`lib/features/escaneo/domain/`)

- **R16.** Un solo botón "Escanear QR" para todo (`LecturaQr.desde`):
  `bosqueseco:visita:<id>` es el QR del grupo y vincula el celular del
  turista a esa visita (se guarda en el celular); `bosqueseco:punto:<id>`
  es el cartel de un punto. El código del punto también se puede escribir
  a mano ("mirador") si la cámara no lee.
- Sin grupo vinculado, un punto no da sello (`FaltaGrupo`): los puntos son
  del grupo (R1, R9). Un punto que no es de la ruta no da sello.
- Los carteles imprimibles salen de `tool/qr_puntos.py`
  (`docs/demo/qr-puntos.html`).

## Ruta (`lib/features/mapa/domain/`)

- **R10.** Un punto de la ruta cuenta como visitado si tiene sello, pendiente
  o confirmado. El siguiente punto es el primero sin sello en el orden de la
  ruta; con todos visitados, la ruta está completa.
- Una ruta tiene al menos un punto, sin repetir, y cada tramo guarda su
  distancia y su tiempo desde el punto anterior (nunca negativos).

## Reporte (`lib/features/reportes/domain/`)

- **R8.** Visitantes = suma de integrantes de los grupos del día. Cada
  integrante cuenta con **su propia** procedencia y su propio rango de edad:
  menos de 18, 18–29, 30–44, 45–59, 60 o más. Puntos más visitados sin
  duplicados, de mayor a menor.

## Cierre del día (`lib/features/reportes/domain/cierre_dia.dart`)

- **R17.** "Cerrar el día" en Reporte reemplaza la firma del cuaderno:
  guarda en el celular las cifras del día (grupos, visitantes, grupos sin
  salida y detalle por guía), quién cerró y a qué hora. Se puede cerrar con
  grupos sin salida (pueden acampar), pero se advierte. Si después cambia
  algo, el cierre queda desactualizado y se vuelve a cerrar.

## Textos

- Las reglas no guardan textos de interfaz. Los `enum` (procedencia,
  actividad, rango de edad, tipo de servicio) se traducen al español y al
  inglés en `lib/core/l10n/etiquetas_dominio.dart`.

## Actores

- **AIDER:** ONG que impulsa a las asociaciones (no opera el turismo). Quiere
  datos para que las comunidades consigan fondos y conserven el bosque.
- **SERNANP:** administra el área protegida y el puesto de control.
- **Asociación turística:** sus socios ofrecen guiado, comida, hospedaje y
  transporte. Las tarifas no son fijas: se muestran como referencia. Tiene
  una cuenta (creada en el portal web) que comparten sus guías autorizados.
- **Guía:** entra con la cuenta de su asociación, elige su nombre y registra
  a los grupos que acompaña.
- **Turista:** planifica con señal; en el bosque no tiene señal.

## Al cambiar una regla

1. Cambia el dominio y su prueba juntos.
2. Actualiza la tabla de reglas en `docs/PRODUCTO.md` (sección 6) y este archivo.
3. Si la regla también debe cumplirse en la base de datos (restricción o
   función SQL), anótalo en `/integrar-supabase`.
