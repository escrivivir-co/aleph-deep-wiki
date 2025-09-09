Este compose levanta:

chroma → vector DB para embeddings.

etl → servicio en Python para clonar repos y cargar embeddings en Chroma usando Ollama.

qa → servicio FastAPI para consultas Q&A.

wiki → MkDocs con theme Material para mostrar documentación.

```yaml

version: "3.9"

services:
  chroma:
    image: chromadb/chroma:latest
    container_name: deepwiki_chroma
    ports:
      - "8000:8000"
    volumes:
      - ./data/chroma:/chroma/.chroma/index
    restart: unless-stopped

  etl:
    build: ./etl
    container_name: deepwiki_etl
    environment:
      - CHROMA_HOST=chroma
      - CHROMA_PORT=8000
      - OLLAMA_HOST=host.docker.internal
      - OLLAMA_PORT=11434
    volumes:
      - ./repos:/app/repos
    depends_on:
      - chroma

  qa:
    build: ./qa
    container_name: deepwiki_qa
    ports:
      - "5000:5000"
    environment:
      - CHROMA_HOST=chroma
      - CHROMA_PORT=8000
      - OLLAMA_HOST=host.docker.internal
      - OLLAMA_PORT=11434
    depends_on:
      - chroma

  wiki:
    image: squidfunk/mkdocs-material:latest
    container_name: deepwiki_wiki
    ports:
      - "8080:8000"
    volumes:
      - ./wiki:/docs
    restart: unless-stopped
```

### 📂 Estructura de carpetas esperada

```
project-root/
├─ docker-compose.yml
├─ data/
│  └─ chroma/             # volumen persistente de la base vectorial
├─ repos/                 # aquí se clonan los repositorios
├─ etl/
│  ├─ Dockerfile
│  └─ etl.py              # script Python para clonar/indexar repos
├─ qa/
│  ├─ Dockerfile
│  └─ app.py              # servicio FastAPI para Q&A
└─ wiki/
   ├─ mkdocs.yml          # config de MkDocs
   └─ docs/               # documentación generada`
```
* * * * *

### 🛠️ Flujo de uso

1.  **Indexar un repo**

    `docker-compose run etl python etl.py https://github.com/usuario/repo`

    Esto clona el repo → genera embeddings → los guarda en Chroma.

2.  **Levantar servicios**

    `docker-compose up -d`

    Tendrás:

    -   `http://localhost:8080` → Wiki (MkDocs)

    -   `http://localhost:5000/ask` → API Q&A

    -   `http://localhost:8000` → Chroma

3.  **Consultar con Q&A**

```
curl -X POST http://localhost:5000/ask\
         -H "Content-Type: application/json"\
         -d '{"question": "¿Qué hace este repositorio?"}'
```

* * * * *

