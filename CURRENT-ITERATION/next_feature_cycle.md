Identifico las funcionalidades principales de la codebase y para cada una al menos dos alternativas FOSS equivalentes (todas open source).

1.  Orquestación de servicios (docker-compose)

    -   Podman + podman-compose
    -   Kubernetes ligero (k3s o kind)
    -   HashiCorp Nomad
2.  Servicio de inferencia + gestión local de modelos (Ollama)

    -   llama.cpp (binario + scripts)
    -   vLLM
    -   text-generation-inference (TGI) de Hugging Face
3.  Generación de embeddings (Ollama con nomic-embed-text)

    -   sentence-transformers (Hugging Face Transformers + modelos All-MiniLM / E5 / GTE)
    -   Instructor / FlagEmbedding
    -   Jina Embeddings (jina-embeddings-v2 / jinaai/jina-embeddings)
4.  Base de datos vectorial (ChromaDB)

    -   Qdrant
    -   Weaviate
    -   Milvus
    -   FAISS (embebido) / pgvector (PostgreSQL extensión)
5.  API backend para Q&A (FastAPI)

    -   Litestar (antes Starlite)
    -   Sanic
    -   Flask + Flask-RESTful / Flask-Smorest
    -   Django REST Framework
6.  Pipeline RAG (código artesanal propio)

    -   LangChain
    -   LlamaIndex
    -   Haystack (de deepset)
7.  Chunking manual de texto (función chunk_text)

    -   LangChain RecursiveCharacterTextSplitter
    -   LlamaIndex SimpleNodeParser / SentenceWindowNodeParser
    -   tiktoken + splitters personalizados
8.  Clonado / actualización de repos (GitPython)

    -   dulwich
    -   pygit2
    -   Uso directo de CLI git + subprocess
9.  Detección de encoding (chardet)

    -   charset-normalizer
    -   cchardet (cuando disponible)
    -   ftfy (para reparación complementaria)
10. Filtrado y clasificación de archivos por extensión (lista manual)

    -   github-linguist (Ruby, pero usable vía CLI)
    -   tree-sitter (detección sintáctica)
    -   Pygments (para reconocer lenguajes)
11. Almacenamiento de metadatos + búsqueda semántica (Chroma colección "repos")

    -   Qdrant collections con payload
    -   Weaviate con esquemas + filtros
    -   Milvus + metadata en external store / híbrido
12. Generación de respuestas LLM con contexto (Ollama generate)

    -   vLLM server
    -   text-generation-inference
    -   llama.cpp server (--server)
13. Front-end de chat (Open WebUI)

    -   Chatbot UI (mckaywrigley / open source)
    -   text-generation-webui
    -   AnythingLLM
    -   TabbyUI
14. Wiki estática (MkDocs + Material)

    -   Sphinx
    -   Docusaurus
    -   Hugo
15. Generación de páginas de índice de repos (Markdown autogenerado)

    -   pdoc
    -   Sphinx autodoc / napoleon
    -   Doxygen (para varios lenguajes)
16. Integración documentación + sitio navegable (MkDocs build)

    -   Docusaurus MDX pipeline
    -   MkDocs + plugins (mkdocs-gen-files, mkdocs-literate-nav)
    -   Hugo + render hooks
17. Endpoints de salud / observabilidad básica (health, logs manuales)

    -   FastAPI + Prometheus client (prometheus_client)
    -   OpenTelemetry (OTel SDK + exporters)
    -   Grafana Alloy / Tempo + métricas instrumentadas
18. Logging estándar (logging)

    -   structlog
    -   loguru
    -   Rich logging (rich.logging)
19. CORS y middleware básico (CORSMiddleware)

    -   Starlette Middleware nativo (es lo mismo debajo)
    -   Traefik / Nginx reverse proxy reglas CORS
    -   FastAPI custom middleware
20. Persistencia local de datos vectoriales y repos (volúmenes Docker)

    -   Bind mounts + Podman volumes
    -   MinIO (para blobs y snapshots)
    -   RClone + backend S3 compatible (Ceph / MinIO) para backups
21. Gestión de modelos (pull y cache en Ollama)

    -   Hugging Face Hub + hf_cache local
    -   ModelScope (para algunos modelos)
    -   Text Generation Inference + safetensors repos locales
22. Autenticación básica potencial (ejemplo en README)

    -   FastAPI HTTPBasic / OAuth2PasswordBearer
    -   Auth vía Traefik ForwardAuth (Authelia)
    -   Keycloak (para OAuth2/OpenID)
23. Scripts de inicialización y salud (shell/bat: init, health_*.sh)

    -   Makefile (targets build/run/health)
    -   Taskfile (go-task)
    -   Justfile (just)
24. Estrategia de multi-repo indexing y filtro (repo_filter, metadatos)

    -   LangChain MultiVectorRetriever
    -   LlamaIndex Multi-Index Query Engine
    -   Haystack MultiIndex pipeline
25. Similaridad y ranking (distances de Chroma)

    -   Cosine similarity con FAISS
    -   Qdrant HNSW + payload filtering
    -   Weaviate vector + BM25 hybrid
26. Conversión de contexto en prompt (prompt engineering manual)

    -   LangChain PromptTemplates
    -   LlamaIndex PromptHelper
    -   Guidance (microsoft/guidance)
27. Despliegue self-hosted integral

    -   One Docker Compose (actual) → Alternativas:
        -   Helm charts (K8s)
        -   Docker Swarm
        -   Ansible playbooks orquestrando servicios
28. Front-end Docs + Q&A integración (wiki + JS custom)

    -   MkDocs + plugin mkdocs-jupyter (para notebooks)
    -   Docusaurus + client-side fetch
    -   Static SPA (React/Vue) + API Q&A
29. Manejo de embeddings y documentos en la misma colección

    -   LangChain VectorStore abstractions (FAISS/Qdrant store)
    -   LlamaIndex VectorStoreIndex
    -   Haystack DocumentStore (Qdrant, Weaviate backends)
30. Backup/compresión (tar manual en README)

    -   restic (repos locales y S3)
    -   BorgBackup
    -   Kopia