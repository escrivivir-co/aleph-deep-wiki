# Integración con ALEPH Scriptorium

## Arquitectura del Submódulo

`VectorMachineSDK` integra una stack self-hosted de indexación y consulta semántica de repositorios.

Superficies principales detectadas:

- `etl/`: proceso de ingestión e indexación de repositorios hacia ChromaDB;
- `qa/`: API FastAPI para preguntas/respuestas sobre repos indexados;
- `wiki/`: wiki MkDocs para navegación documental;
- `docker-compose*.yml`: orquestación local con Ollama, ChromaDB, Q&A API, wiki y Open WebUI;
- scripts `init*`, `health*`, `logs*`, `inspect_qa.sh`: operación local y validación rápida.

## Tecnologías

- Docker Compose
- Python
- FastAPI
- ChromaDB
- Ollama
- MkDocs
- Open WebUI

## Mapeo Ontológico

| Submódulo | Scriptorium |
|-----------|-------------|
| Stack vectorial DeepWiki | `@ox` para diseño de integración y puente DRY |
| Estructura y puntos de entrada del repo | `@indice` para mapa técnico/funcional |
| Diseño de plugin mínimo y proxy markdown | `@aleph` + `@cristalizador` |
| Generalización de lore-db a “proyecto indexable” | `@cristalizador` de `DocumentMachineSDK` |

## Dependencias Externas

- Docker Desktop / Docker Compose;
- Ollama local o dockerizado;
- modelo de embeddings `nomic-embed-text`;
- modelo generativo en Ollama para Q&A;
- recursos de CPU/RAM suficientes para ChromaDB + Ollama.

## Supuestos y Gaps

- El remoto actual expone una aplicación operativa, no una infra agentica nativa ya preparada para Scriptorium.
- La rama remota visible en origen es `dev/001`; la rama local de integración se ha creado como `integration/beta/scriptorium` sobre esa base.
- No se detecta todavía una carpeta `.github/` propia en el submódulo para reutilizar agentes/prompts remotos vía proxy markdown.
- El plugin mínimo previsto en Scriptorium deberá probablemente modelar primero servicios, comandos y flujos del stack antes que delegar a agentes remotos.
- El encaje con el “tuétano v1” pasa por decidir si este submódulo sirve solo para lore-db o como base general de “proyecto indexable” para ONFALO, Novelist y `ARCHIVO/PROYECTOS`.

## Fase 3 — Encaje con instrucciones del usuario

### Decisión de shape para el tuétano v1

El encaje con el plan ya no se modela como simple proxy markdown a una supuesta infra agentica remota. La decisión de Fase 3 es otra:

- `VectorMachineSDK` aporta la stack vectorial base;
- Scriptorium aporta la agentización y la fachada MCP;
- `MCPGallery/mcp-mesh-sdk` será la superficie de entrada operativa como un servidor MCP más de la mesh.

### Lectura técnica resultante

- La operativa de indexación y consulta vive hoy en Python y Docker (`etl/`, `qa/`, Chroma, Ollama, wiki);
- el acceso agentico desde Scriptorium debe pasar por un servidor MCP propio, no por acceso directo al repo;
- ese servidor MCP deberá encapsular interfaces y servicios Node.js/Python para:
	- lanzar y parar la stack;
	- indexar repos o rutas locales;
	- consultar repos indexados;
	- inspeccionar estado de Chroma/Ollama/QA;
	- exponer control suficiente para integrarse con flujos de `DocumentMachineSDK`, ONFALO, Novelist o `ARCHIVO/PROYECTOS`.

### Consecuencia para el plugin mínimo

El plugin `vector-machine` de Scriptorium, en su v1, no debería prometer agentes remotos inexistentes. Su primer cometido razonable es:

- registrar la codebase del submódulo y sus superficies;
- documentar el contrato de la futura fachada MCP;
- conectar el bridge agéntico del plugin con ese servidor MCP de la mesh cuando exista.

### Conflicto resuelto respecto al plan original

La cláusula del plan que hablaba de "agregar un proxy markdown a la propia infra agéntica del repo remoto" queda reinterpretada así:

- si en fases futuras aparece una `.github/` reutilizable en `VectorMachineSDK`, se podrá enlazar DRY;
- mientras no exista, el proxy DRY correcto no es hacia agentes remotos, sino hacia una fachada MCP propia alojada en la mesh de `MCPGallery`.

# FRIDAY APRIL 2026

ChromaDB shared vs per microservice

one chromadb quite a big, or one chromadb for each microservice?

Leer 10 páginas web

The short answer is: For a production system, one shared ChromaDB instance is the recommended architecture.

While a "database per microservice" is common for general-purpose SQL databases, it creates significant operational and data consistency problems for vector search. Here is the breakdown of why you should share, and the only two scenarios where you wouldn't.

### The Core Problem: "One Per Service" is Risky

If you give each microservice its own ChromaDB, you lose the ability to search across services. If "Service A" has documents about "Customer X" and "Service B" has different documents about "Customer X," you cannot run a single query to find all relevant information for that customer. You would have to query each database individually and merge the results manually, which is slow and complex.

### 📊 When to use ONE Shared Database (Recommended)

This is the standard pattern for production. It treats ChromaDB as a centralized index, similar to how Elasticsearch or Redis is used.

-   Requirement: You need to search across data owned by different services (e.g., a global search bar) or you want to avoid managing 10 different database containers.

-   How to implement: Run a single Chroma Server Mode instance (or Cloud version). All microservices connect to it via `HttpClient` [](https://cookbook.chromadb.dev/running/deployment-patterns/).

-   Isolation Strategy: Use Chroma's built-in Tenants and Databases.

    -   Create one Tenant per "Team" or "Customer".

    -   Create a Database per microservice inside that tenant [](https://cookbook.chromadb.dev/strategies/multi-tenancy/naive-multi-tenancy/?source=post_page-----d0475a2edf33--------------------------------#__codelineno-0-3)[](https://docs.trychroma.com/reference/architecture/overview).

    -   *Result*: Data is physically isolated but searchable from a single endpoint.

### ⚠️ When to use ONE PER Service (Edge Cases)

You would only deploy separate instances if your "big" database hits a hard technical wall.

-   Requirement: You have massive scale (specifically, > 10 million vectors) or your services are completely unrelated (e.g., a Finance bot and a Weather bot that never need to interact).

-   Why: Single-node ChromaDB has concurrency limits. Benchmarks show that while one query might take 0.3 seconds, running 100 concurrent queries can slow the average response time to 23 seconds due to locking mechanisms [](https://www.newtuple.com/post/speed-and-scalability-in-vector-search).

-   The Fix: You shard the data manually. You spin up three separate ChromaDB servers, split your data between them, and your "Gateway" service has to query all three [](https://edana.ch/en/2026/02/08/pros-and-cons-of-chromadb-for-retrieval-augmented-generation-great-for-getting-started-but-risky/#gototop). (Note: The new "Distributed" Chroma architecture aims to solve this automatically) [](https://docs.trychroma.com/reference/architecture/overview).

### ⚡ The "Shared DB" Performance Trap

You might be worried about performance, but putting a DB in every service makes that worse, not better. Here is the reality of Chroma's architecture:

-   The Bottleneck is RAM and CPU: Chroma keeps vectors in RAM for speed [](https://cookbook.chromadb.dev/core/resources/#cpu). If you run 5 microservices, each with its own DB, you are running 5 separate processes, 5 separate caches, and using 5x the memory compared to one shared instance.

-   Embedded Mode is Dangerous: Do not use `PersistentClient` (embedded) for multiple services. Chroma is "thread-safe but not process-safe" [](https://cookbook.chromadb.dev/core/system_constraints/#operational-modes). If two microservices try to write to the same file simultaneously, they will corrupt the data.

### ✅ Recommended Architecture

To implement this correctly, follow this structure:

1.  Run the Server: Deploy Chroma in Server Mode (Docker/K8s) as a standalone service [](https://cookbook.chromadb.dev/core/system_constraints/#operational-modes).

2.  Connect Clients: Ensure your `HttpClient` connections use HTTPS and Authentication (Tokens) [](https://cookbook.chromadb.dev/running/road-to-prod/).

3.  Calculate Vertically: Estimate your RAM. A good rule of thumb: For 10 million vectors of 1536 dimensions, expect to use roughly 57 GiB of RAM [](https://cookbook.chromadb.dev/core/resources/#cpu).

Summary: Sharing a centralized ChromaDB using Tenants/Databases is the standard architectural pattern for vector databases. "One per service" should only be used as a last resort for extreme scale beyond 10 million vectors.

#
- http://sisap.org
- TODO https://chat.deepseek.com/share/9tqo0ic3piqvz7eqh7