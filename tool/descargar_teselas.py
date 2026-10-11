"""Descarga las teselas de OpenStreetMap del área de la ruta y las deja en
assets/teselas/ (z-x-y.png) para que el mapa se vea sin señal.

Uso (desde la raíz del repositorio, con internet; solo Python 3):
    python3 tool/descargar_teselas.py

Son unas 185 teselas (~4 MB). Respeta la política de uso de OpenStreetMap:
pocas teselas, una a la vez y con un User-Agent que identifica la app. Si
cambia el trazado real de la ruta, actualiza LIMITES y vuelve a correrlo.
El mapa muestra «© OpenStreetMap» como exige su licencia.
"""
import math
import pathlib
import time
import urllib.request

# Área de la ruta (lib/features/mapa/data/ruta_repository_demo.dart) con
# un margen de ~2 km: sur, oeste, norte, este.
LIMITES = (-4.320, -80.880, -4.263, -80.825)
ZOOMS = range(12, 17)
SERVIDOR = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
USER_AGENT = 'explorador-bosque-seco/0.1 (+https://github.com/micioner2/explorador-bosque-seco)'
DESTINO = pathlib.Path('assets/teselas')


def tesela(lat: float, lon: float, z: int) -> tuple[int, int]:
    n = 2 ** z
    x = int((lon + 180) / 360 * n)
    lat_rad = math.radians(lat)
    y = int((1 - math.asinh(math.tan(lat_rad)) / math.pi) / 2 * n)
    return x, y


def main() -> None:
    sur, oeste, norte, este = LIMITES
    DESTINO.mkdir(parents=True, exist_ok=True)
    total = 0
    for z in ZOOMS:
        x0, y0 = tesela(norte, oeste, z)
        x1, y1 = tesela(sur, este, z)
        for x in range(x0, x1 + 1):
            for y in range(y0, y1 + 1):
                archivo = DESTINO / f'{z}-{x}-{y}.png'
                if archivo.exists():
                    continue
                pedido = urllib.request.Request(
                    SERVIDOR.format(z=z, x=x, y=y),
                    headers={'User-Agent': USER_AGENT},
                )
                with urllib.request.urlopen(pedido, timeout=30) as respuesta:
                    archivo.write_bytes(respuesta.read())
                total += 1
                time.sleep(0.3)
        print(f'Zoom {z}: listo')
    print(f'{total} teselas nuevas en {DESTINO}/')


if __name__ == '__main__':
    main()
