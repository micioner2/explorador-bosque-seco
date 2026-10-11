"""Genera los carteles con el QR de cada punto, listos para imprimir (A4):

- docs/demo/qr-puntos.html: ruta de El Angolo y un QR de grupo de prueba.
- docs/demo/qr-puntos/sede.html y sede-*.png: ruta de demostración en la
  sede de la presentación.

Uso (desde la raíz del repositorio):
    pip install segno
    python3 tool/qr_puntos.py

Los puntos deben coincidir con la ruta de la app
(lib/features/mapa/data/ruta_repository_demo.dart). El texto de cada QR
sigue el formato de lib/features/escaneo/domain/lectura_qr.dart.
"""
import html
import pathlib

import segno

RUTA = 'Ruta de las Pozas · Coto de Caza El Angolo'
RUTA_SEDE = 'Ruta de demostración · Cámara de Comercio de Piura'
PUNTOS_SEDE = [
    ('sede-entrada', 'Entrada'),
    ('sede-norte', 'Esquina norte'),
    ('sede-noreste', 'Esquina noreste'),
    ('sede-este', 'Esquina este'),
    ('sede-encuentro', 'Punto de encuentro'),
]
PUNTOS = [
    ('entrada', 'Puesto de control'),
    ('pozas', 'Pozas de agua'),
    ('caida', 'Caída de agua'),
    ('mirador', 'Mirador'),
    ('venados', 'Avistamiento de venados'),
]
# Grupo de prueba para la demostración con un solo celular.
GRUPO_PRUEBA = 'v-demo'


PLANTILLA = '''<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>QR de los puntos</title>
<style>
  @page { size: A4; margin: 12mm; }
  body { font-family: system-ui, sans-serif; margin: 0; color: #1b2a1f; background: #fff; }
  .aviso { padding: 12px 16px; background: #eef4ec; }
  .cartel { box-sizing: border-box; height: 135mm; padding: 6mm; text-align: center;
            border: 2px dashed #9bb59a; margin: 0 auto 6mm; max-width: 180mm;
            page-break-inside: avoid; break-inside: avoid; }
  .cartel:nth-of-type(2n) { page-break-after: always; break-after: page; }
  .orden { margin: 0; font-size: 14pt; color: #4d6b4f; }
  h2 { margin: 2mm 0 4mm; font-size: 24pt; }
  .qr svg { width: 80mm; height: 80mm; }
  .codigo { font-size: 14pt; margin: 2mm 0; }
  .nota { font-size: 11pt; margin: 0 10mm; }
  .ruta { font-size: 9pt; color: #4d6b4f; }
  @media print { .aviso { display: none; } }
</style>
</head>
<body>
<p class="aviso">{aviso}</p>
{carteles}
</body>
</html>
'''

AVISO = ('Imprime esta página (Ctrl + P) en A4: salen dos carteles por hoja. '
         'Generada con <code>tool/qr_puntos.py</code>.')


def svg(texto: str) -> str:
    qr = segno.make(texto, error='m')
    return qr.svg_inline(scale=10, border=2, dark='#000', light='#fff')


def cartel(orden: str, titulo: str, texto: str, codigo: str, nota: str,
           ruta: str = RUTA) -> str:
    return f'''
  <section class="cartel">
    <p class="orden">{html.escape(orden)}</p>
    <h2>{html.escape(titulo)}</h2>
    <div class="qr">{svg(texto)}</div>
    <p class="codigo">Código: <strong>{html.escape(codigo)}</strong></p>
    <p class="nota">{html.escape(nota)}</p>
    <p class="ruta">{html.escape(ruta)}</p>
  </section>'''


def pagina(carteles: list[str], aviso: str) -> str:
    return PLANTILLA.replace('{aviso}', aviso).replace(
        '{carteles}', ''.join(carteles))


def main() -> None:
    carteles = [
        cartel(
            f'Punto {i} de {len(PUNTOS)}',
            nombre,
            f'bosqueseco:punto:{pid}',
            pid,
            'Abre Bosque Seco, toca «Escanear QR» y gana tu sello. '
            'Funciona sin señal.',
        )
        for i, (pid, nombre) in enumerate(PUNTOS, start=1)
    ]
    carteles.append(
        cartel(
            'Solo para la demostración',
            'QR de grupo de prueba',
            f'bosqueseco:visita:{GRUPO_PRUEBA}',
            f'bosqueseco:visita:{GRUPO_PRUEBA}',
            'Vincula el celular a un grupo sin registrarlo antes. En el '
            'bosque, este QR lo muestra el guía al registrar al grupo.',
        )
    )
    destino = pathlib.Path('docs/demo/qr-puntos.html')
    destino.write_text(pagina(carteles, AVISO), encoding='utf-8')
    print(f'Listo: {destino}')

    carpeta = pathlib.Path('docs/demo/qr-puntos')
    carpeta.mkdir(parents=True, exist_ok=True)
    carteles_sede = []
    for i, (pid, nombre) in enumerate(PUNTOS_SEDE, start=1):
        texto = f'bosqueseco:punto:{pid}'
        segno.make(texto, error='m').save(
            carpeta / f'sede-{i}-{pid}.png', scale=12, border=3)
        carteles_sede.append(cartel(
            f'Punto {i} de {len(PUNTOS_SEDE)}', nombre, texto, pid,
            'Abre Bosque Seco, toca «Escanear QR» y gana tu sello. '
            'Funciona sin señal.', ruta=RUTA_SEDE))
    (carpeta / 'sede.html').write_text(
        pagina(carteles_sede, AVISO + ' Elige «Sede de la presentación» en '
               'Ajustes → Ruta de la demo.'), encoding='utf-8')
    print(f'Listo: {carpeta}/sede.html y {len(PUNTOS_SEDE)} PNG')


if __name__ == '__main__':
    main()
