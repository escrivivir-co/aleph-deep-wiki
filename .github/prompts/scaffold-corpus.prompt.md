---
description: "Scaffold ingestor + visualizer notebooks from a corpus manifest YAML"
name: "Scaffold Corpus"
argument-hint: "path/to/manifest.yml"
agent: "agent"
---
Read the manifest YAML provided in the argument path and scaffold the canonical VectorMachineSDK corpus pair:

1. Load [SKILL.md](../skills/corpus-vectorial/SKILL.md), [manifest.schema.yml](../skills/corpus-vectorial/manifest.schema.yml), and [cells/README.md](../skills/corpus-vectorial/cells/README.md).
2. Validate the manifest structure and confirm all source files exist.
3. Derive canonical values:
   - collection names `m{mod[0]}_{nick}_{collection_suffix}`
   - `COLLECTIONS_TABLE`, `COLLECTIONS_LIST`, `LABELS_MAP`, `COLOR_MAP`, `PALETTE_LIST`, `LABELS_JOINED`
   - `SOURCE_ROOT_PATH_SEGMENTS` for JS-safe `path.join(...)`
   - source variables for each source (`SOURCE_*`)
   - export ids `{ids_prefix}_2d`, `{ids_prefix}_3d`, `{ids_prefix}_clusters`
4. Create two notebooks in `VectorMachineSDK/`:
   - `corpus_ingestor_{mod}_{nick}.nnb`
   - `corpus_visualizer_{banner}_{nick}.nnb`
5. IMPORTANT: do **not** write the full `.nnb` JSON with final contents in one shot. Create the notebook shell first, then populate cells one by one with `edit_notebook_file`, using the template files under `.github/skills/corpus-vectorial/cells/`.
6. Use `markdown` for heading cells and `typescript` for code cells.
7. Do not execute the notebooks unless the user explicitly asks.
8. Report back with:
   - files created
   - collections derived
   - next step to run ingestion/visualization

If the manifest is invalid or files are missing, stop and report the exact issue instead of guessing.
