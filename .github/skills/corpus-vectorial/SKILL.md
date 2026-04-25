---
name: corpus-vectorial
description: |
  Use this skill when the user asks to "create a vector ingestor", "create a corpus
  visualizer", "scaffold corpus notebooks", "add a new project to VectorMachineSDK",
  or needs to add a new corpus (ingest + UMAP/Plotly visualization + GH-Pages export)
  following the canonical pattern of mod/onfalo. Generates two coordinated `.nnb`
  notebooks (Node.js, 100% JS — no Python subprocess) from a declarative YAML manifest.
applyTo: "VectorMachineSDK/**/*.nnb, VectorMachineSDK/**/*.yml"
---

# Skill: corpus-vectorial

> **Propósito**: Cristalizar el patrón canónico de ingesta + visualización vectorial
> en un proceso declarativo. El usuario describe el corpus en un manifest YAML;
> el agente genera dos notebooks `.nnb` ensamblando plantillas reutilizables.

---

## Cuándo aplica

Esta skill se activa cuando el usuario pide:

- "Crear un ingestor para el proyecto X"
- "Visualizar el corpus Y en el banner azul/negro/rojo"
- "Añadir el proyecto Z a VectorMachineSDK"
- "Refactorizar este notebook al patrón canónico"

NO se activa para:

- Edición ad-hoc de un notebook existente sin plantilla
- Operaciones de Chroma fuera del flujo ingest/visualize

---

## Arquitectura del patrón

```
manifest.yml ──┐
               │
               ├──▶ ingestor.{nick}.nnb        (escribe a Chroma localhost:8000)
               │       └─ chunking MD por H2/H3
               │       └─ embeddings via chromadb-default-embed (Xenova/all-MiniLM-L6-v2)
               │       └─ idempotente (skip IDs existentes)
               │
               └──▶ visualizer.{banner}.{nick}.nnb  (lee Chroma + exporta HTML)
                       └─ UMAP 2D+3D via umap-js
                       └─ Plotly CDN (HTML embebido)
                       └─ KMeans + Silhouette en JS puro
                       └─ Divergencia coseno corpus↔geometría
                       └─ Query semántica con embedding JS
                       └─ Export a docs/{banner}/cuadernos/ + js-yaml registry
```

**Stack canónico (cero Python en runtime):**

| Función | Paquete npm |
|---------|-------------|
| HTTP client a Chroma | `chromadb` |
| Embeddings JS | `chromadb-default-embed` |
| UMAP | `umap-js` |
| Visualización | Plotly CDN (sin npm install) |
| YAML | `js-yaml` |
| KMeans, silhouette, coseno | implementación inline en JS |

---

## Contrato del manifest

El usuario crea (o el agente le ayuda a crear) un archivo `manifest.{nick}.yml`:

```yaml
# === Identidad del corpus ===
nick: mapas               # prefijo corto (lowercase, sin espacios)
proyecto: MAPAS_DE_SINGULARIDAD
mod: onfalo               # tenant/database lógico
banner: azul              # azul | negro | rojo (paleta + ruta export)

# === Fuentes ===
source_root: onfalo-asesor-sdk/PROYECTOS/MAPAS_DE_SINGULARIDAD
sources:
  - file: 01_el_mapa_de_tres_dimensiones.md
    short_id: mco-01
    collection_suffix: corpus
    label: "Corpus [MS]"
    bloque: doc-01
    tipo: ensayo-fundacional
    summary: "Ensayo fundacional: lengua × geopolítica × arquitectura."
  - file: 02_tres_puertas.md
    short_id: mge-02
    collection_suffix: geopolitica
    label: "Geopolítica [MS]"
    bloque: doc-02
    tipo: puertas-condiciones
    summary: "Las condiciones de posibilidad del mapa: contaminación, multimodalidad y espejo."
  - file: 03_abstract_tecnico_arquitecturas.md
    short_id: mar-03
    collection_suffix: arquitectura
    label: "Arquitectura [MS]"
    bloque: doc-03
    tipo: abstract-tecnico
    summary: "Transformer, Mamba y Jamba como epistemología."
  - file: 04_la_dimension_conciencia.md
    short_id: mab-04
    collection_suffix: abstract
    label: "Abstract [MS]"
    bloque: doc-04
    tipo: dimension-conciencia
    summary: "Cuarta dimensión: el modelo que no sabe que no ve."

# === Paleta (4 tonos del banner) ===
palette:
  - "#c3e0f3"
  - "#8cbedd"
  - "#5596c4"
  - "#2b6fa3"

# === Export GH Pages ===
export:
  base_dir: DocumentMachineSDK/docs/{banner}/cuadernos
  registry_file: DocumentMachineSDK/docs/_data/cuadernos_{mod}.yml
  ids_prefix: "{nick}"   # genera {nick}_2d, {nick}_3d, {nick}_clusters

# === Query de ejemplo (opcional) ===
example_query: "¿Cuál es la cuarta dimensión del mapa de singularidad?"
```

Las **convenciones derivadas** del manifest:
- Tenant Chroma: `scriptorium`, database: `mod-{mod}`
- Nombre de colección: `m{primera_letra_mod}_{nick}_{collection_suffix}`
  - Ej: `mod=onfalo`, `nick=mapas`, `suffix=corpus` → `mo_mapas_corpus`
- Notebooks generados:
  - `corpus_ingestor_{mod}_{nick}.nnb`
  - `corpus_visualizer_{banner}_{nick}.nnb`
- Background HTML: `#07101f` (todos los banners)

---

## Algoritmo de generación

Cuando se invoca esta skill, el agente:

1. **Lee el manifest** indicado por el usuario.
2. **Valida** que existan: `source_root`, todas las fuentes en `sources`, longitud de `palette ≥ len(sources)`.
3. **Lee las plantillas** de `cells/ingestor/` y `cells/visualizer/`.
4. **Sustituye variables** `{{VAR}}` con valores del manifest.
5. **Crea** los dos `.nnb` celda por celda usando `edit_notebook_file` (formato Don Jayamanne):
   - Crea archivo vacío con `create_file` y JSON mínimo (16 celdas vacías).
   - Para cada celda: `edit_notebook_file` con el contenido sustituido y el lenguaje correcto.
   - Lenguajes: `markdown` para headers, `typescript` para código.
6. **Verifica** ejecutando la celda 1 (setup) del ingestor.
7. **Reporta** al usuario los archivos creados y el siguiente paso (ingestar fuentes).

> ⚠️ **No usar `create_file` con el JSON completo de las 16 celdas a la vez**:
> el formato `.nnb` ignora el contenido inicial y crea celdas vacías. Lección
> documentada en `cells/README.md`.

---

## Estructura de plantillas

```
.github/skills/corpus-vectorial/
├── SKILL.md                          # este archivo
├── README.md                         # docs humanas
├── manifest.schema.yml               # esquema JSON-schema del manifest
├── examples/
│   └── manifest.mapas.yml            # ejemplo real (MAPAS_DE_SINGULARIDAD)
└── cells/
    ├── README.md                     # notas operativas (por qué edit cell-by-cell)
    ├── ingestor/                     # 8 cells: 4 markdown + 4 typescript
    │   ├── 01-header.md
    │   ├── 02-setup.ts
    │   ├── 03-verify-server.ts
    │   ├── 04-connect.ts
    │   ├── 05-h-functions.md
    │   ├── 06-functions.ts
    │   ├── 07-h-source.md            # se replica N veces (una por source)
    │   ├── 08-source-template.ts     # se replica N veces (una por source)
    │   ├── 09-h-verify.md
    │   └── 10-verify.ts
    └── visualizer/                   # 16 cells: 8 markdown + 8 typescript
        ├── 01-header.md
        ├── 02-setup.ts
        ├── 03-load.ts
        ├── 04-umap.ts
        ├── 05-h-2d.md
        ├── 06-scatter2d.ts
        ├── 07-h-3d.md
        ├── 08-scatter3d.ts
        ├── 09-h-clusters.md
        ├── 10-kmeans.ts
        ├── 11-h-divergence.md
        ├── 12-divergence.ts
        ├── 13-h-query.md
        ├── 14-query.ts
        ├── 15-h-export.md
        └── 16-export.ts
```

---

## Variables `{{VAR}}` reconocidas en plantillas

| Variable | Origen | Ejemplo |
|----------|--------|---------|
| `{{NICK}}` | `manifest.nick` | `mapas` |
| `{{NICK_UPPER}}` | derivado | `MAPAS` |
| `{{PROYECTO}}` | `manifest.proyecto` | `MAPAS_DE_SINGULARIDAD` |
| `{{MOD}}` | `manifest.mod` | `onfalo` |
| `{{MOD_PREFIX}}` | primera letra de mod | `mo` |
| `{{BANNER}}` | `manifest.banner` | `azul` |
| `{{SOURCE_ROOT}}` | `manifest.source_root` | `onfalo-asesor-sdk/PROYECTOS/...` |
| `{{COLLECTIONS_TABLE}}` | derivado de `sources` | tabla markdown con colección, archivo y resumen |
| `{{COLLECTIONS_LIST}}` | derivado de `sources` | `['mo_mapas_corpus', ...]` |
| `{{LABELS_MAP}}` | derivado de `sources` | `{ 'mo_mapas_corpus': 'Corpus [MS]', ... }` |
| `{{COLOR_MAP}}` | derivado (`label` + `palette[i]`) | `{ 'Corpus [MS]': '#c3e0f3', ... }` |
| `{{PALETTE_LIST}}` | derivado de `palette` | `['#c3e0f3', '#8cbedd', ...]` |
| `{{LABELS_JOINED}}` | derivado de `sources` | `Corpus [MS] · Geopolítica [MS] · ...` |
| `{{EXAMPLE_QUERY}}` | `manifest.example_query` | `¿Cuál es...?` |
| `{{EXPORT_BASE_DIR}}` | `manifest.export.base_dir` | `DocumentMachineSDK/docs/azul/cuadernos` |
| `{{EXPORT_REGISTRY_FILE}}` | `manifest.export.registry_file` | `.../cuadernos_onfalo.yml` |
| `{{EXPORT_IDS_PREFIX}}` | `manifest.export.ids_prefix` | `mapas` |
| `{{SOURCE_INDEX}}` | índice 1-based de la fuente | `1` |
| `{{SOURCE_FILE}}` | `source.file` | `01_el_mapa_de_tres_dimensiones.md` |
| `{{SOURCE_SHORT_ID}}` | `source.short_id` | `mco-01` |
| `{{SOURCE_COLLECTION_SUFFIX}}` | `source.collection_suffix` | `corpus` |
| `{{SOURCE_COLLECTION}}` | derivado | `mo_mapas_corpus` |
| `{{SOURCE_LABEL}}` | `source.label` | `Corpus [MS]` |
| `{{SOURCE_BLOQUE}}` | `source.bloque` o derivado | `doc-01` |
| `{{SOURCE_TIPO}}` | `source.tipo` o derivado | `ensayo-fundacional` |
| `{{SOURCE_SUMMARY}}` | `source.summary` o fallback | `Ensayo fundacional: ...` |
| `{{SOURCE_CODE_CELL}}` | derivado (numeración visible del notebook) | `8` |
| `{{SOURCE_ROOT_PATH_SEGMENTS}}` | derivado JS-safe | `'onfalo-asesor-sdk', 'PROYECTOS', 'MAPAS_DE_SINGULARIDAD'` |

---

## Slash command

El usuario invoca esta skill con:

```
/scaffold-corpus path/to/manifest.mapas.yml
```

Definido en `.github/prompts/scaffold-corpus.prompt.md`.

---

## Principios de extensión

1. **Cada banner tiene un cuaderno por proyecto**: NO mezclar proyectos en un solo
   visualizador. Mejor 5 visualizadores azul + 5 negro + 5 rojo, que uno enorme.
2. **Idempotencia**: Re-ejecutar el ingestor no duplica chunks. Re-ejecutar el
   visualizador sobreescribe sus 3 HTMLs y actualiza solo sus entradas en el YAML.
3. **Aislamiento por colección**: Una fuente = una colección Chroma.
4. **Sin Python en runtime**: Toda la lógica numérica vive en JS para que los
   notebooks puedan ejecutarse sin venv.
5. **El manifest es la fuente de verdad**: cualquier cambio en el corpus pasa por
   editar el manifest y regenerar.

---

## Ver también

- `examples/manifest.mapas.yml` — manifest real, funciona end-to-end
- `cells/README.md` — notas sobre el formato `.nnb` y limitaciones
- Patrones origen:
  - `corpus_ingestor_onfalo_mapas.nnb` (referencia ingestor)
  - `corpus_visualizer_azul_mapas.nnb` (referencia visualizer)
