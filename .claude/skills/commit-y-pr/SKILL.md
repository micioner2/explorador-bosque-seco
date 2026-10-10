---
name: commit-y-pr
description: Prepara commits y pull requests con las convenciones del equipo (autor único, mensaje convencional en español, sin atribución de IA, rama feature hacia develop). Úsala cuando pidan hacer commit, subir cambios o abrir un PR.
disable-model-invocation: true
allowed-tools: Bash(git status) Bash(git diff *) Bash(git add *) Bash(git commit *) Bash(git log *) Bash(git switch *) Bash(git push *)
---

# Commit y pull request

## Antes de commitear

1. Ejecuta `/verificar-calidad`. No se commitea con formato, análisis o
   pruebas en rojo.
2. Revisa `git status` y `git diff`. No incluyas `build/`, `.dart_tool/`,
   credenciales, `.env` ni `google-services.json`.

## Autoría

- El autor es el integrante que trabaja en la máquina. En la laptop de
  Mauricio: `Mauricio Zapata Pella <38358253+micioner2@users.noreply.github.com>`
  (ya está en la configuración local del repositorio).
- **No agregues** `Co-Authored-By`, `Generated with`, enlaces de sesión ni
  ninguna mención a herramientas de IA en commits ni en PR.

## Mensaje

Formato: `<tipo>: <qué cambia, en español, en minúsculas>`.

| Tipo | Cuándo |
|---|---|
| `feat` | Funcionalidad nueva |
| `fix` | Corrección de error |
| `test` | Solo pruebas |
| `refactor` | Cambio interno sin cambiar comportamiento |
| `style` | Formato |
| `docs` | Documentación |
| `ci` | Workflows |
| `chore` | Configuración, dependencias |

Ejemplo: `feat: escaneo de QR de puntos con sello pendiente`.
Un commit por cambio lógico.

## Ramas y PR

1. Trabaja en `feature/<nombre>` creada desde `develop`.
2. Sube la rama y abre el PR hacia `develop` con la plantilla
   `.github/pull_request_template.md`.
3. Espera el CI en verde antes de mergear.
4. `main` recibe merges de `develop` solo cuando hay una versión estable para
   presentar.
5. Nunca `git push --force` sobre `main` ni `develop`.
