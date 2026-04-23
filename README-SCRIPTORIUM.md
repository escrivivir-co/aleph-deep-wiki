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