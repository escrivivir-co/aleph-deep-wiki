# Integración con ALEPH Scriptorium

## Arquitectura del Submódulo

`VectorMachineSDK` integra una stack self-hosted de indexación y consulta semántica de repositorios.

## Handoff operativo — corpus vectorial

Si otro agente retoma este submódulo, ya tiene lo necesario para scaffoldar y ejecutar un corpus vectorial siguiendo el patrón canónico de `VectorMachineSDK`.

### Artefactos ya preparados

- Skill: `VectorMachineSDK/.github/skills/corpus-vectorial/SKILL.md`
- Prompt invocable: `VectorMachineSDK/.github/prompts/scaffold-corpus.prompt.md`
- Manifest listo para DECOHERENCIA: `VectorMachineSDK/.github/skills/corpus-vectorial/examples/manifest.decoherencia.yml`
- Manifest de referencia ya validado: `VectorMachineSDK/.github/skills/corpus-vectorial/examples/manifest.mapas.yml`

### Tasks VS Code a usar

En `#file:.vscode/tasks.json`, sección **`VMS: VECTOR MACHINE SDK`**:

- `VMS: Install [Deps]` → instala dependencias npm del SDK (`chromadb`, `chromadb-default-embed`, `umap-js`, `js-yaml`)
- `VMS: Start [Chroma]` → arranca el servidor HTTP de Chroma en `http://localhost:8000`

### Secuencia recomendada para el siguiente agente

1. (opcional, primera vez) Ejecutar la task **`VMS: Install [Deps]`**.
2. Ejecutar la task **`VMS: Start [Chroma]`**.
3. Invocar el prompt:

	`/Scaffold-Corpus .github/skills/corpus-vectorial/examples/manifest.decoherencia.yml`

4. Verificar que el scaffolder genere estos notebooks en `VectorMachineSDK/`:
	- `corpus_ingestor_onfalo_decoherencia.nnb`
	- `corpus_visualizer_azul_decoherencia.nnb`
5. Ejecutar primero el ingestor completo y luego el visualizador completo.
6. Confirmar que el visualizador exporta HTMLs y actualiza el registro GH Pages correspondiente.

### Colecciones esperadas para DECOHERENCIA

El manifest `manifest.decoherencia.yml` está diseñado para derivar estas colecciones Chroma:

- `mo_decoherencia_corpus`
- `mo_decoherencia_base`
- `mo_decoherencia_ratio`
- `mo_decoherencia_sesiones`

### Otros proyectos candidatos

### Candidatos propuestos

| # | Proyecto | Colecciones Chroma (propuestas) | Por qué es Chromable |
| --- | --- | --- | --- |
| 1 | ATLAS | `at_geografia`, `at_historia`, `at_soberania`, `at_personajes`, `at_cronica` | El más rico: 6 docs + ATLAS_2 + PERIODICO. Realismo mágico geopolítico → clusters semánticamente muy separados |
| 2 | MAPAS_DE_SINGULARIDAD | `ms_corpus`, `ms_geopolitica`, `ms_arquitectura`, `ms_abstract` | Tres dimensiones explícitas (lengua × geopolítica × arquitectura) → clusters naturales predefinidos |
| 3 | REGULACION | `rg_articulos`, `rg_cartas`, `rg_informes`, `rg_fichas` | El mayor volumen crudo: 13 documentos. Densidad de embeddings garantizada |
| 4 | ESCANO_SINTETICO | `es_whitepaper`, `es_transcripcion`, `es_diagnostico`, `es_delta` | Único artefacto reflexivo: audita sus propios sesgos. Contraste whitepaper/transcripción = cluster muy interesante |
| 5 | PROYECTO_DECOHERENCIA | `dc_corpus`, `dc_base`, `dc_ratio`, `dc_sesiones` | Más conceptualmente singular: quantum→cognición→política. Genera el cluster más aislado del espacio vectorial |

* * * * *

### Estructura propuesta

GitHub DRY: el catálogo enlaza a [onfalo-asesor-sdk](./) (repo separado), igual que negro enlaza a `para-la-voz-sdk/blob/mod/legislativa/`.

### Nota importante

La skill `corpus-vectorial` ya cristaliza el patrón completo:

- cuaderno de ingesta `.nnb` (TypeScript, 100% JS)
- cuaderno de visualización `.nnb` con UMAP, Plotly, KMeans, query semántica y export a GH Pages

Con las tasks VMS anteriores + el manifest recién creado, el siguiente agente **ya tiene todo lo necesario** para continuar sin redescubrir la operativa.
