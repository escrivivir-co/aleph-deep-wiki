Identifiqué que aún hay trabajo útil (ya corregí un glitch menor en [deepwiki.bat]() al inicio del archivo). Backlog sugerido:

1.  Limpieza / Bugs menores

-   [.agents.md]() tiene secciones duplicadas (estado repetido varias veces, copy/paste con artefactos "DO ACTUAL..." y un carácter raro en "## � **Resumen..."). Depurar y reducir a una sola versión canonical.
-   [deepwiki.bat](): varias rutas de ejemplo mezclan [index repos\as-core]() vs `index as-core`; normalizar mensaje de ayuda. Revisar uso de `errorlevel` (en batch `if errorlevel 1` captura ≥1; quizá quieres `if %errorlevel% neq 0` en algunos casos).
-   Validar que comandos `rebuild` y `rebuild-all` realmente se diferencien (hoy parecen casi iguales; quizá `rebuild` podría no forzar `--no-cache`).
-   Añadir `setlocal EnableExtensions EnableDelayedExpansion` (ya usas delayed) cerca del inicio para claridad.

1.  Configuración / Build

-   Crear `requirements.txt` (ETL y QA) con versiones fijas para reproducibilidad; ahora se instalan paquetes sin pin.
-   Multi-stage o al menos limpieza de capa apt (ya haces rm -rf, ok) y considerar `PYTHONDONTWRITEBYTECODE=1`, `PYTHONUNBUFFERED=1`.
-   Unificar dependencias compartidas (requests, chromadb) en ambos servicios para evitar drift.

1.  ETL (etl/etl.py)

-   Evitar re-embeddings si re-indexas el mismo repo sin cambios: almacenar hash (SHA256) por archivo y saltar si no cambió.
-   Batch insert en Chroma (agregar varios chunks por llamada) para reducir latencia.
-   Concurrencia controlada (ThreadPoolExecutor) para embeddings, con límite (p.ej. 4--6) y cola.
-   Manejo de rate limiting / backoff exponencial en [embed_text]().
-   Parametrizar extensiones y tamaños de chunk vía variables de entorno o archivo de config.
-   Añadir exclusiones configurables (`.deepwikiignore` similar a .gitignore).
-   Registrar métricas (tiempo por archivo, fallos, tamaño promedio de chunk).

1.  Q&A API (qa/app.py)

-   Limitar CORS dinámicamente (config de allowed origins) para prod; ahora `*`.
-   Endpoint streaming (`/ask/stream`) usando `EventSourceResponse` o `iter_bytes` para respuestas largas.
-   Cache de embeddings de preguntas frecuentes (LRU in-memory) para queries repetidas.
-   Sanitizar [repo_filter]() (whitelist de repos existentes).
-   Health extendido: incluir latencia de embedding y último éxito.
-   Normalizar relevancia: ahora `1 - distance` asume métrica; documentar si es cosine / L2.
-   Añadir timeout y fallback si generación supera X segundos.

1.  Datos / Vector Store

-   Estrategia de reindex: antes de agregar, borrar chunks previos del repo (evitar duplicados) o usar IDs determinísticos por hash de contenido (si ya existen, skip).
-   Guardar longitud de tokens estimada (para mejor ranking posterior).
-   Explorar namespace por repo en lugar de single collection (facilita borrados selectivos).

1.  Observabilidad

-   Logging estructurado (JSON) + correlación request id.
-   Contadores simples (Prometheus / /metrics) para: preguntas, fallos, tiempo medio.
-   Script `validate` podría incluir prueba de round-trip (index -> ask -> assert fuente devuelta).

1.  Seguridad / Hardening

-   Revisar exposición directa de Chroma (8000) si no es necesaria públicamente.
-   Limitar tamaño máximo de pregunta y número de resultados ([max_results]() bound).
-   Validar input contra inyección prompt (prefijo claro y separar contexto vs pregunta).

1.  Documentación

-   Consolidar [.agents.md]() + [prompt_para_siguiente_agente.md]() en un README internal ops reducido (estado, comandos clave, flujo index→consulta).
-   Añadir sección "Cómo añadir un segundo repositorio" con ejemplo y resultado esperado.
-   Tabla de tiempos estimados (index de repo pequeño vs grande).

1.  DX / Automatización

-   Makefile o script cross‑platform (PowerShell) que replique funcionalidades del `.bat`.
-   GitHub Actions (lint + build imágenes + prueba mínima).
-   Pre-commit hooks (ruff/flake8 + formatting + detect secrets).

1.  Features futuras (opcionales)

-   Filtro adicional por archivo / extensión.
-   Búsqueda híbrida (semantic + keyword) usando ranking combinado.
-   Respuestas citando líneas (incluir número de línea al indexar).
-   Modo resumen de repo (agregar embedding de overview generado).

Quick wins (recomiendo hacer primero):

1.  Deduplicar y limpiar [.agents.md]().
2.  Añadir `requirements.txt` con versiones y actualizar Dockerfiles.
3.  Implementar borrado previo o dedup por hash antes de reindex.
4.  Añadir batch insertion + file hash skip para acelerar ETL.
5.  Cerrar CORS (lista configurable) y añadir límite [max_results <= 10]().