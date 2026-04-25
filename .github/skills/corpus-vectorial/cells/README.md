# Cells/ — Plantillas de celdas

> Notas operativas para mantener las plantillas alineadas con el formato `.nnb`.

## Lección crítica: el formato `.nnb` ignora el contenido inicial

Cuando se invoca `create_file` con un JSON `.nnb` que contiene celdas con código,
el extension Don Jayamanne **descarta el contenido y crea las celdas vacías** con
ids generados automáticamente.

Por eso, el algoritmo de generación es:

1. Crear el archivo con un JSON mínimo que solo declara N celdas vacías.
2. Recuperar los `cellId` reales con `copilot_getNotebookSummary`.
3. Para cada cell, llamar a `edit_notebook_file` con:
   - El `cellId` real
   - El `language` correcto (`markdown` o `typescript`)
   - El `newCode` resultado de sustituir variables `{{VAR}}` en la plantilla

## Estructura de las plantillas

Cada archivo `.ts` o `.md` representa una celda completa. El nombre indica el
orden y el lenguaje:

- `01-header.md` → primera celda, markdown
- `02-setup.ts` → segunda celda, typescript
- `05-source-template.ts` → plantilla a replicar (una vez por source)
- `05-h-2d.md` → header markdown ("h" = heading) antes de un bloque visual

## Convenciones de las plantillas

- Variables `{{VAR}}` en mayúsculas, sustituidas por el agente al ensamblar.
- NO hay lógica condicional en las plantillas (ni `{% if %}` ni similar).
  Si una variante necesita ramificación, se hace en dos plantillas distintas.
- El código TypeScript de las plantillas debe ser ejecutable tal cual una vez
  sustituidas las variables (no contiene placeholders sintácticos).

## Por qué Plotly va por CDN y no por npm

Probado:
- `plotly.js-dist` en npm pesa ~3.5 MB y carga en cada celda → kernel lento.
- Render del HTML inline en VS Code Notebooks NO ejecuta `<script>` por defecto
  cuando viene de un `require('plotly.js')`.
- Plotly desde CDN en `<script src="...">` ejecuta correctamente al renderizar
  el output mime `text/html` y el HTML es portable a GH Pages sin rebuild.

## Por qué KMeans/Silhouette en JS puro

Las únicas alternativas npm (`ml-kmeans`, `density-clustering`) añaden 5+ MB y
no soportan silhouette. La implementación inline en `10-kmeans.ts` ocupa ~50 LOC
y es suficientemente rápida para corpus de hasta ~500 chunks.

## Verificación tras editar plantillas

```bash
# Eliminar el .nnb generado
rm VectorMachineSDK/corpus_visualizer_azul_mapas.nnb

# Regenerar con el slash command
# /scaffold-corpus .github/skills/corpus-vectorial/examples/manifest.mapas.yml

# Ejecutar todas las celdas en orden y verificar:
# - Sin errores
# - 3 HTMLs en docs/azul/cuadernos/
# - cuadernos_onfalo.yml actualizado
```
