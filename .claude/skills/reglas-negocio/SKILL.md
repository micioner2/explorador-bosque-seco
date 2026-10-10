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

## Visitas (`lib/features/visitas/domain/`)

- **R5.** Nombre no vacío, edad entre 0 y 120, grupo de al menos 1 y salida
  prevista posterior a la entrada.
- **R6.** "Sigue dentro" = sin salida marcada y ya pasó la salida prevista.
- **R7.** La salida se marca una sola vez y no puede ser antes de la entrada.
- Procedencias: Piura, Lima, Otra región, Extranjero.
- Actividades: Senderismo, Avistamiento de aves, Fotografía, Campamento.

## Reporte (`lib/features/reportes/domain/`)

- **R8.** Visitantes = suma de personas de los grupos del día. Procedencia por
  personas. Edad del responsable en rangos: menos de 18, 18–29, 30–44, 45–59,
  60 o más. Puntos más visitados sin duplicados, de mayor a menor.

## Actores

- **AIDER:** ONG que impulsa a las asociaciones (no opera el turismo). Quiere
  datos para que las comunidades consigan fondos y conserven el bosque.
- **SERNANP:** administra el área protegida y el puesto de control.
- **Asociación turística:** sus socios ofrecen guiado, comida, hospedaje y
  transporte. Las tarifas no son fijas: se muestran como referencia.
- **Turista:** planifica con señal; en el bosque no tiene señal.

## Al cambiar una regla

1. Cambia el dominio y su prueba juntos.
2. Actualiza la tabla de reglas en `docs/PRODUCTO.md` (sección 6) y este archivo.
3. Si la regla también debe cumplirse en la base de datos (restricción o
   función SQL), anótalo en `/integrar-supabase`.
