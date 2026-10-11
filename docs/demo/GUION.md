# Guion de la demostración (5 minutos)

La promesa: **funciona sin señal y reemplaza el cuaderno del puesto de
control.** La demo se hace en **modo avión** y al final vuelve la señal para
sincronizar y compartir el PDF.

## Antes de presentar

- [ ] APK del CI instalado (artefacto `explorador-bosque-seco-apk`),
      compilado **sin** `config/supabase.json` → "Usar cuenta de prueba"
      entra con un toque.
- [ ] **Dos celulares**: el del guía (puesto) y el del turista. Con uno solo,
      usa el QR impreso "grupo de prueba".
- [ ] Carteles impresos o en una laptop:
      [`qr-puntos/sede.html`](qr-puntos/sede.html) (5 puntos de la sede) y
      [`qr-puntos.html`](qr-puntos.html) (bosque + grupo de prueba).
- [ ] En el celular del turista, **dentro de la sede**: Ajustes → "Ruta de la
      demo" → "Centrar la ruta de la sede aquí". Así el GPS lo muestra sobre
      la ruta.
- [ ] En `EspacioRepositoryDemo.whatsappDemo`, el celular de alguien del
      equipo: el jurado verá abrirse el chat.
- [ ] Permisos de cámara y ubicación ya concedidos (ábrelos una vez antes).
- [ ] Los grupos y reservas de ejemplo se calculan con la hora del celular:
      siempre habrá un grupo atrasado 30 minutos y una reserva por llegar.
      Para empezar desde cero: Ajustes del celular → Apps → Bosque Seco →
      Borrar datos.

## 1. QR del grupo — 1 min

Celular del guía. Activar **modo avión** en los dos celulares.

1. Ícono de tienda → **Usar cuenta de prueba** → "María Quispe". *"La
   próxima vez solo toca «Continuar como María Quispe»."*
2. **Registrar**: nombre, DNI, edad y procedencia (lo que exige el SERNANP).
   Actividad → **Registrar grupo y generar QR**.
3. Celular del turista: **Escanear QR** → QR del grupo → "Tu celular quedó
   vinculado". *"Sin cuentas, sin contraseñas, sin señal."*

## 2. Modo avión en el mapa, con GPS en la ruta — 1 min

1. Turista → **Mapa**: el aviso dice "Sin señal · todo guardado en el
   celular". La ruta de la sede, el siguiente punto y "estás a X m del
   siguiente punto" con el GPS.

## 3. Escaneo de un punto — 30 s

1. **Escanear QR** → cartel "Entrada" → "¡Sello de Entrada! +1 punto ·
   pendiente de sincronizar". Otra vez → no suma de nuevo.
   *Plan B si la cámara no lee:* "¿No lee? Escribe el código" →
   `sede-entrada`.
2. **Pasaporte**: el sello aparece pendiente.

## 4. Alerta "sigue dentro" — 30 s

1. Celular del guía → **Hoy**: el grupo Ramírez debió salir hace 30 minutos.
   *"Antes nadie se enteraba; ahora el puesto lo ve al instante."*
2. **Marcar salida** (pide confirmación) y la alerta se va.

## 5. Vuelve la señal y se sincroniza — 30 s

1. Quitar el **modo avión**: el aviso pasa a "Con señal · N pendientes por
   sincronizar".
2. Con servidor configurado, se envía solo (o "Sincronizar ahora") y pasa a
   "Todo sincronizado"; el sello queda **confirmado**. *"Si se corta a la
   mitad, reenviar no duplica nada."*
   Con el APK de demostración (sin servidor) el botón no aparece: se explica
   que las tablas ya están listas para el equipo web.

## 6. PDF del día compartido por WhatsApp — 1 min

1. **Reporte**: visitantes por procedencia, edades y **por guía**.
2. **Cerrar el día**: avisa si hay grupos sin salida y deja constancia de
   quién cerró y a qué hora.
3. **Descargar PDF** → menú del celular → **WhatsApp**. *"El PDF se generó
   sin conexión en el puesto: es el dato que AIDER necesita (C3)."*

## Si sobra tiempo

- **Canje**: en Pasaporte (grupo de prueba, con puntos confirmados) →
  Canjear → sale el **cupón con QR**. En el puesto, Hoy → ícono de cupón →
  escanearlo: "Cupón válido"; otra vez: "Este cupón ya se usó".
- **WhatsApp** desde Explorar → Servicios: el chat se abre con el mensaje
  escrito.

## Preguntas probables

- **¿Y Supabase?** El acceso de la asociación ya usa Supabase Auth y la app
  ya sabe sincronizar visitas, sellos y cierres. Las tablas están listas
  para el equipo web (`docs/supabase/sincronizacion-app.sql`); cada registro
  lleva su id generado en el celular, así reenviar no duplica.
- **¿Datos personales?** DNI y edad solo los lee la asociación dueña (RLS).
- **¿Las imágenes?** Ilustraciones de demostración; la asociación sube sus
  fotos desde el portal.
