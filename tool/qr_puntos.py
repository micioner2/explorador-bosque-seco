"""Genera docs/demo/qr-puntos.html: los carteles con el QR de cada punto de
la ruta y un QR de grupo de prueba, listos para imprimir (A4).

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
PUNTOS = [
    ('entrada', 'Puesto de control'),
    ('pozas', 'Pozas de agua'),
    ('caida', 'Caída de agua'),
    ('mirador', 'Mirador'),
    ('venados', 'Avistamiento de venados'),
]
# Grupo de prueba para la demostración con un solo celular.
GRUPO_PRUEBA = 'v-demo'


def svg(texto: str) -> str:
    qr = segno.make(texto, error='m')
    return qr.svg_inline(scale=10, border=2, dark='#000', light='#fff')


def cartel(orden: str, titulo: str, texto: str, codigo: str, nota: str) -> str:
    return f'''
  <section class="cartel">
    <p class="orden">{html.escape(orden)}</p>
    <h2>{html.escape(titulo)}</h2>
    <div class="qr">{svg(texto)}</div>
    <p class="codigo">Código: <strong>{html.escape(codigo)}</strong></p>
    <p class="nota">{html.escape(nota)}</p>
    <p class="ruta">{html.escape(RUTA)}</p>
  </section>'''


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
    pagina = f'''<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>QR de los puntos</title>
<style>
  @page {{ size: A4; margin: 12mm; }}
  body {{ font-family: system-ui, sans-serif; margin: 0; color: #1b2a1f; background: #fff; }}
  .aviso {{ padding: 12px 16px; background: #eef4ec; }}
  .cartel {{ box-sizing: border-box; height: 135mm; padding: 6mm; text-align: center;
            border: 2px dashed #9bb59a; margin: 0 auto 6mm; max-width: 180mm;
            page-break-inside: avoid; break-inside: avoid; }}
  .cartel:nth-of-type(2n) {{ page-break-after: always; break-after: page; }}
  .orden {{ margin: 0; font-size: 14pt; color: #4d6b4f; }}
  h2 {{ margin: 2mm 0 4mm; font-size: 24pt; }}
  .qr svg {{ width: 80mm; height: 80mm; }}
  .codigo {{ font-size: 14pt; margin: 2mm 0; }}
  .nota {{ font-size: 11pt; margin: 0 10mm; }}
  .ruta {{ font-size: 9pt; color: #4d6b4f; }}
  @media print {{ .aviso {{ display: none; }} }}
</style>
</head>
<body>
<p class="aviso">Imprime esta página (Ctrl + P) en A4: salen dos carteles por hoja.
Generada con <code>tool/qr_puntos.py</code>.</p>
{''.join(carteles)}
</body>
</html>
'''
    destino = pathlib.Path('docs/demo/qr-puntos.html')
    destino.write_text(pagina, encoding='utf-8')
    print(f'Listo: {destino}')


if __name__ == '__main__':
    main()
