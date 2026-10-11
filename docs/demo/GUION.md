# Guion de la demostración (5 minutos)

La promesa: **funciona sin señal y reemplaza el cuaderno del puesto de
control.** Toda la demo se hace en **modo avión** (salvo el paso de WhatsApp).

## Antes de presentar

- [ ] APK del CI instalado (artefacto `explorador-bosque-seco-apk`),
      compilado **sin** `config/supabase.json` → se entra con la cuenta de
      prueba `demo@bosqueseco.pe` / `bosque2026`.
- [ ] Carteles impresos: `docs/demo/qr-puntos.html` (5 puntos + QR de grupo
      de prueba). Si no hay impresora, ábrelos en una laptop.
- [ ] En `EspacioRepositoryDemo.whatsappDemo` va el celular de alguien del
      equipo, para que el jurado vea abrirse el chat.
- [ ] Permisos de cámara y ubicación ya concedidos (ábrelos una vez antes).
- [ ] Mapa base: si se corrió `tool/descargar_teselas.py`, se ven calles y
      relieve; si no, la ruta sobre fondo liso (igual funciona).
- [ ] Para empezar desde cero: Ajustes del celular → Apps → Bosque Seco →
      Borrar datos.

## 1. El turista planifica (con señal) — 1 min

1. **Explorar**: El Angolo, "Antes de ir" (pago, señal, acceso), la ruta y
   los atractivos con imagen.
2. **Servicios** → "Contactar por WhatsApp": abre el chat con el mensaje ya
   escrito. *"Antes había que copiar el número a mano."*

## 2. Puesto de control: el guía reemplaza el cuaderno — 1 min 30 s

Activar **modo avión** aquí.

1. Ícono de tienda → cuenta de prueba → **Entrar** → elige "María Quispe".
   *"La próxima vez solo toca «Continuar como María Quispe»."*
2. **Hoy**: quién está dentro, alerta del grupo que ya debió salir y las
   reservas que llegan hoy.
3. **Registrar**: nombre, DNI, edad y procedencia de cada persona (lo que
   exige el SERNANP); la procedencia se conserva para el siguiente. Si es
   extranjero, pasaporte y país. Actividades → **Registrar grupo y generar
   QR**.
4. Cerrar la app y volver a abrirla: el grupo sigue ahí. *"El celular es la
   fuente de verdad; se sincroniza cuando vuelve la señal."*

## 3. El turista en el bosque, sin señal — 1 min 30 s

1. En el celular del turista (o el mismo): **Escanear QR** → QR del grupo
   (el que muestra el guía, o el impreso "grupo de prueba") → "Tu celular
   quedó vinculado".
2. Escanear el cartel **Mirador** → "¡Sello de Mirador! +1 punto ·
   pendiente de sincronizar". Escanearlo otra vez → no suma de nuevo.
   *Plan B si la cámara no lee:* "¿No lee? Escribe el código" → `mirador`.
3. **Mapa**: la ruta, los puntos con su estado y el siguiente con distancia
   y tiempo. Con GPS, "estás a X m del siguiente punto"; lejos del bosque
   dice que aún no estás en la ruta.
4. **Pasaporte**: sellos y canje de productos de la comunidad.

## 4. Cierre del día y datos para AIDER — 1 min

1. **Reporte**: visitantes por procedencia y edad, y **por guía**.
2. **Cerrar el día**: advierte si hay grupos sin salida (pueden acampar) y
   deja constancia de quién cerró y a qué hora. *"Esta es la firma al pie
   del cuaderno, pero con datos que AIDER puede usar."*

## Preguntas probables

- **¿Y Supabase?** El acceso de la asociación ya usa Supabase Auth. Las
  tablas para sincronizar visitas, reservas, sellos y cierres están listas
  para el equipo web (`docs/supabase/sincronizacion-app.sql`): cada registro
  lleva su id generado en el celular, así reenviar no duplica.
- **¿Datos personales?** DNI y edad solo los lee la asociación dueña (RLS).
- **¿Las imágenes?** Ilustraciones de demostración; la asociación sube sus
  fotos desde el portal.
