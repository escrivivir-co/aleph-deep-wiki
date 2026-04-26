# Corpus Ingestor — mod/{{MOD}} · {{PROYECTO}}

**Stack**: Node.js / TypeScript · `chromadb` + `chromadb-default-embed` (fork oficial Chroma) · Chroma HTTP server
**Embeddings**: `Xenova/all-MiniLM-L6-v2` ONNX — 100% compatible con `DefaultEmbeddingFunction` Python
**Puerto Chroma**: `8000`

Ingesta los documentos de {{PROYECTO}} en colecciones `{{MOD_PREFIX}}_{{NICK}}_*`.

{{COLLECTIONS_TABLE}}

---

> ⚠️ **PRERREQUISITO — Chroma HTTP Server en puerto 8000**
>
> **Opción A — tarea VS Code:** `Ctrl+Shift+P` → *Tasks: Run Task* → **`VMS: Install|Start [Chroma]`**
>
> **Opción B — terminal:** `cd VectorMachineSDK && npm i && bash start.sh`
>
> La **celda 3** verifica la conexión e intenta arrancar el servidor automáticamente si no responde.

> ℹ️ **Primera ejecución**: `chromadb-default-embed` descarga el modelo ONNX (~30MB) en `.model-cache/` al generar los primeros embeddings. Las ejecuciones siguientes son instantáneas.
