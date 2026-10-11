# Producto: app móvil del explorador ecoturístico del bosque seco

Documento de referencia sobre **qué** construimos y **por qué**. El **cómo**
está en [`ARQUITECTURA.md`](ARQUITECTURA.md) y en [`../CLAUDE.md`](../CLAUDE.md).

## 1. Contexto del reto

**Reto 12 · AIDER · Hackathon Piura Innova (octubre 2026).**

AIDER es una ONG que trabaja en conservación y aprovechamiento sostenible del
bosque seco del norte del Perú, con comunidades campesinas y asociaciones de
productores. Su tesis: **si la población gana más con el turismo que con la
tala o las quemas, conserva el bosque.**

Actores reales (según el mentor de AIDER):

- **SERNANP** administra las áreas naturales protegidas y tiene los puestos de
  control, donde hoy se registra a los visitantes en un **cuaderno**.
- **Asociaciones turísticas** de las comunidades: firman convenio con SERNANP;
  sus socios ofrecen guiado, comida, hospedaje y transporte.
- **AIDER** brinda asistencia técnica a las asociaciones; no opera el turismo.

### Problemas que resolvemos

1. **Difusión.** No hay catálogo, web ni redes. Para contratar un guía, el
   turista pregunta a SERNANP, que lo deriva al presidente de la asociación,
   que le pasa el celular de un guía. Tampoco sabe antes de ir si aceptan
   Yape, si hay señal o cuánto cuesta.
2. **Registro.** El cuaderno es ilegible, se llena a la carrera en temporada
   alta y no produce estadísticas. Las asociaciones necesitan esos datos para
   postular a fondos (por ejemplo, Procompite).
3. **Conectividad.** Hay señal en el pueblo y en el puesto de control, pero
   **no dentro del bosque**.
4. **Escala.** Son varias comunidades (Piura y Tumbes) con el mismo modelo:
   rutas, servicios y registro. La solución debe ser **reutilizable por
   comunidad**.

### Criterios de éxito definidos por AIDER

| # | Criterio | Cómo lo cumple la solución |
|---|---|---|
| C1 | Usable en celulares de gama media y alta | Flutter, interfaz liviana, Android e iOS |
| C2 | Ver circuitos, distancias, tiempos y puntos de interés **offline** una vez descargados | Paquete del espacio descargado en el pueblo; mapa y ruta locales |
| C3 | Reporte diario en PDF con procedencia, edades y visitantes | Datos del registro → reporte (PDF en el panel web) |
| C4 | Contacto directo con guías y servicios (alojamiento, alimentación, transporte) | Ficha de servicios con botón de WhatsApp |

## 2. Propósito de la app móvil

> Ser la guía del turista en el bosque seco, **aunque no haya señal**, y
> convertir cada visita en datos y ventas para la comunidad.

## 3. Usuarios

| Usuario | Situación | Lo que necesita |
|---|---|---|
| **Turista** | Planifica con internet; en el bosque, sin señal. | Saber qué hay, cuánto cuesta, cómo llegar, orientarse sin señal. |
| **Encargado del puesto / asociación** | Puesto de control con señal; persona de campo, poca experiencia digital. | Registrar rápido, saber quién sigue dentro, canjear cupones. |
| **Guía local** | Celular de gama media, sin señal en la ruta. | Recibir contactos y que su servicio sea visible. |
| **AIDER** (vía panel web) | Oficina. | Estadísticas consolidadas de las asociaciones. |

## 4. Alcance

### Dentro del alcance de la app móvil

**Modo turista** (prioridad principal)

| Id | Funcionalidad | Prioridad | Estado |
|---|---|---|---|
| T1 | Explorar el espacio: ficha práctica (pago, señal, acceso), atractivos y servicios | Obligatoria | Base hecha (datos demo) |
| T2 | Contactar servicios por WhatsApp con mensaje prellenado | Obligatoria | Pendiente (`url_launcher`) |
| T3 | Vincular la visita escaneando el QR del grupo que se muestra en el puesto | Obligatoria | Pendiente (falta `mobile_scanner`) |
| T4 | Descargar el paquete del espacio para uso sin señal | Obligatoria | Pendiente |
| T5 | Mapa offline con la ruta, puntos y ubicación GPS; distancia y tiempo al siguiente punto | Obligatoria | Ruta, distancias, tiempos y avance hechos (datos demo); falta el mapa con teselas y GPS |
| T6 | Escanear el QR de cada punto: fotos, audio y sello (+1 punto) | Diferenciadora | Lógica hecha; falta `mobile_scanner` |
| T7 | Pasaporte: puntos confirmados y pendientes, y sellos de la ruta | Diferenciadora | Hecha (datos demo) |
| T8 | Canje de puntos por descuento en productos de la comunidad (cupón QR) | Diferenciadora | Lógica hecha, con confirmación; falta cupón QR |
| T9 | Opinión al salir e insignia compartible | Opcional | Pendiente |
| T10 | Ajustes: idioma (español o inglés) y apariencia (clara, oscura o la del celular), guardados en el celular | Obligatoria | Hecha |

**Modo puesto de control** (encargado de la asociación)

| Id | Funcionalidad | Prioridad | Estado |
|---|---|---|---|
| A1 | Registrar a un grupo desde una sola pantalla: cada integrante por separado (nombre, edad, procedencia), una o varias actividades para todos y **un único QR** para el grupo | Obligatoria | Hecha (datos demo) |
| A2 | Ver quién está dentro, volver a mostrar el QR de un grupo y marcar su salida (con confirmación) | Obligatoria | Hecha (datos demo) |
| A3 | Alerta "sigue dentro" cuando un grupo pasa su hora de salida | Diferenciadora | Hecha |
| A4 | Resumen del día (visitantes, procedencia, edades) | Obligatoria | Hecha (datos demo) |
| A5 | Validar cupones de canje (escanear QR) | Diferenciadora | Pendiente |

### Fuera del alcance de la app móvil

- **Panel administrativo** (gestión de rutas, servicios, tarifas y productos;
  **PDF oficial del reporte diario**; panel consolidado de AIDER) y **web
  informativa**: proyecto web aparte, con la misma base de datos.
- Pagos en línea o reservas con cobro: el contacto es por WhatsApp.
- Registro de cuentas para turistas: la visita se vincula con un QR, sin
  usuario ni contraseña.
- Navegación giro a giro tipo Google Maps.
- Rastreo GPS en segundo plano.
- Publicación en Play Store / App Store durante el hackathon (se entrega APK).

## 5. Flujo principal

1. **Antes del viaje (con señal):** el turista explora el espacio y contacta a
   un guía por WhatsApp.
2. **En el puesto de control (con señal):** el encargado registra al grupo
   (cada integrante por separado, en una sola pantalla), marca sus actividades
   y muestra **un único QR del grupo**. Cada integrante lo escanea: su app
   queda vinculada a la visita y descarga el paquete del espacio. Si alguien
   hará otras actividades, se registra como otro grupo, con su propio QR.
3. **En el bosque (sin señal):** mapa con GPS y ruta; en cada punto escanea el
   QR, ve fotos y audio y gana un sello **pendiente**.
4. **De vuelta en el pueblo (con señal):** se sincronizan los escaneos; los
   puntos pasan a **confirmados**. Deja su opinión.
5. **Salida:** el encargado marca la salida. Si un grupo se pasa de su hora,
   aparece la alerta "sigue dentro".
6. **Canje:** en la tienda comunal, el turista muestra su cupón y el encargado
   lo valida.
7. **Cierre del día:** el reporte se genera en el panel web.

## 6. Reglas de negocio

| Id | Regla | Dónde vive |
|---|---|---|
| R1 | Un punto turístico da **1 punto por visita**, aunque se escanee varias veces o llegue duplicado al sincronizar. | `Pasaporte.registrar`, `Pasaporte.sellos` |
| R2 | Solo los puntos **confirmados** por el servidor se pueden canjear. | `Pasaporte.puntosDisponibles` |
| R3 | Un canje descuenta los puntos requeridos; sin puntos suficientes, falla. | `Pasaporte.canjear` |
| R4 | Un producto requiere más de 0 puntos y un descuento entre 1 % y 100 %. | `Producto` |
| R5 | Cada integrante requiere nombre y edad entre 0 y 120. Una visita requiere al menos un integrante, al menos una actividad y salida prevista posterior a la entrada. | `Visitante`, `Visita` |
| R6 | "Sigue dentro" = no marcó salida y ya pasó la hora prevista. | `Visita.sigueDentro` |
| R7 | La salida se marca una sola vez y no puede ser anterior a la entrada. | `Visita.marcarSalida` |
| R8 | El reporte cuenta personas: cada integrante suma con su propia procedencia y su propio rango de edad. Ordena los puntos más visitados sin duplicados. | `ReporteDiario` |
| R9 | Una visita es un grupo que entra junto y hace las mismas actividades (una o varias). Todo el grupo comparte **un solo QR**; el primer integrante es el responsable. Quien haga otras actividades va en otra visita. | `Visita.actividades`, `Visita.codigoQr` |
| R10 | En la ruta, un punto cuenta como visitado si tiene sello (pendiente o confirmado). El siguiente punto es el primero sin sello en el orden de la ruta. | `ProgresoRuta` |

## 7. Requisitos no funcionales

| Id | Requisito |
|---|---|
| N1 | **Offline-first:** todo lo del bosque funciona en modo avión. |
| N2 | Celulares de **gama media**: pantallas livianas, imágenes comprimidas, paquete del espacio de pocos MB. |
| N3 | Android e iOS desde el mismo código (el demo se hace en Android). |
| N4 | Uso al aire libre: contraste AA (4,5:1) en modo claro y oscuro, botones de al menos 48 px, textos cortos, y pantallas que no se rompen con letra grande. Lo verifican las pruebas de accesibilidad. |
| N5 | Datos personales (DNI, edad) solo visibles para la asociación (RLS en Supabase). |
| N6 | Calidad verificable: formato, análisis estricto, pruebas y APK en CI. |
| N7 | Dos idiomas, español e inglés: toda la interfaz se traduce y el idioma se puede cambiar en Ajustes. El contenido que carga cada asociación (nombres de atractivos, servicios, tarifas) se muestra en el idioma en que se cargó. |
| N8 | Modo claro y modo oscuro, a elección de la persona o según el celular. |

## 8. Modelo de datos (resumen)

`Asociacion` → `Espacio` → `Ruta` → `Punto` (con QR) · `Servicio` · `Producto`
· `Visita` (grupo, con su QR) → `Visitante` (cada integrante) · `Escaneo` ·
`Canje` · `Opinion`.

Diagramas UML en PlantUML: [`docs/diagramas/`](diagramas) (flujo de la
visita, secuencia de registro y sincronización, casos de uso y modelo de
datos).

## 9. Demo para el jurado (guion)

1. El problema: foto del cuaderno de visitas y la cadena SERNANP → presidente → guía.
2. Registro del grupo en el puesto (integrante por integrante) → un solo QR
   → el jurado lo escanea.
3. **Modo avión:** mapa, ruta y escaneo de un punto siguen funcionando.
4. Se quita el modo avión → los puntos pasan a confirmados.
5. Canje de un descuento y reporte del día.
6. Cierre: *"Cada turista registrado es un argumento para no talar el bosque."*

## 10. Glosario

| Término | Significado |
|---|---|
| Espacio | Área natural que administra una asociación (por ejemplo, Coto de Caza El Angolo). |
| Punto / atractivo | Lugar de la ruta con su propio QR (pozas, caída de agua, mirador). |
| Visita | Registro de un grupo en el puesto de control (reemplaza al cuaderno). Tiene un solo QR. |
| Integrante / visitante | Cada persona del grupo, registrada con su nombre, edad y procedencia. El primero es el responsable. |
| Escaneo / sello | Registro de que una visita pasó por un punto. |
| Pendiente / confirmado | Estado de sincronización de un escaneo. |
| Pasaporte | Conjunto de sellos y puntos del turista. |
| Canje | Uso de puntos para un descuento en un producto comunal. |
| Puesto de control | Punto de ingreso al área (SERNANP), con señal. |

## 11. Equipo

| Persona | Rol |
|---|---|
| Mauricio | Desarrollo · líder técnico e integración |
| Felipe | Desarrollo · modo turista |
| Kevin | Datos · carga de datos y métricas |
| Isabel | Soluciones · producto, diseño, pitch y QA |
