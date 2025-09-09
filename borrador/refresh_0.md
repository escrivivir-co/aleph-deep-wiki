Perfecto 🚀\
Vamos a añadir una capa extra: que el **ETL** no solo indexe en Chroma, sino que también genere **páginas Markdown para la Wiki** (en `wiki/docs/`) cada vez que procesas un repo.

Así MkDocs mostrará automáticamente cada repositorio con una página navegable.

* * * * *

🔧 Cambios en el ETL
====================

### 1\. Modificar `etl.py` para generar docs

`import os
import sys
import git
import requests
from chromadb import HttpClient

# Config
CHROMA_HOST = os.getenv("CHROMA_HOST", "localhost")
CHROMA_PORT = int(os.getenv("CHROMA_PORT", "8000"))
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "localhost")
OLLAMA_PORT = int(os.getenv("OLLAMA_PORT", "11434"))

CHROMA_URL = f"http://{CHROMA_HOST}:{CHROMA_PORT}"
OLLAMA_URL = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/embeddings"

client = HttpClient(host=CHROMA_HOST, port=CHROMA_PORT)
collection = client.get_or_create_collection("repos")

WIKI_PATH = "/app/wiki/docs"

def embed_text(text: str):
    resp = requests.post(OLLAMA_URL, json={"model": "nomic-embed-text", "input": text})
    resp.raise_for_status()
    return resp.json()["embedding"]

def process_repo(repo_url):
    repo_name = repo_url.split("/")[-1].replace(".git", "")
    repo_path = os.path.join("/app/repos", repo_name)

    if os.path.exists(repo_path):
        print(f"Actualizando {repo_name}...")
        repo = git.Repo(repo_path)
        repo.remotes.origin.pull()
    else:
        print(f"Clonando {repo_name}...")
        git.Repo.clone_from(repo_url, repo_path)

    print("Procesando archivos...")
    doc_content = [f"# {repo_name}\n\nRepositorio: {repo_url}\n\n## Archivos documentados\n"]

    for root, _, files in os.walk(repo_path):
        for f in files:
            if f.endswith((".py", ".md", ".js", ".ts", ".java", ".go")):
                path = os.path.join(root, f)
                with open(path, "r", errors="ignore") as file:
                    content = file.read()

                chunks = [content[i:i+500] for i in range(0, len(content), 500)]
                for idx, chunk in enumerate(chunks):
                    emb = embed_text(chunk)
                    collection.add(
                        documents=[chunk],
                        embeddings=[emb],
                        ids=[f"{repo_name}-{f}-{idx}"]
                    )

                # Agregar al doc
                rel_path = os.path.relpath(path, repo_path)
                doc_content.append(f"- `{rel_path}`")

    # Guardar Markdown en la wiki
    os.makedirs(WIKI_PATH, exist_ok=True)
    with open(os.path.join(WIKI_PATH, f"{repo_name}.md"), "w") as f:
        f.write("\n".join(doc_content))

    print(f"Repo {repo_name} indexado y documentado con éxito.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python etl.py <repo_url>")
        sys.exit(1)

    process_repo(sys.argv[1])`

* * * * *

### 2\. Ajustar `etl/Dockerfile`

Agregamos la carpeta de la wiki como volumen compartido:

`FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir requests chromadb gitpython

COPY etl.py /app/etl.py

# La wiki estará montada como volumen
VOLUME ["/app/wiki"]

ENTRYPOINT ["python", "etl.py"]`

* * * * *

### 3\. Ajustar `docker-compose.yml`

Montamos la carpeta `wiki/` dentro del ETL:

 `etl:
    build: ./etl
    container_name: deepwiki_etl
    environment:
      - CHROMA_HOST=chroma
      - CHROMA_PORT=8000
      - OLLAMA_HOST=host.docker.internal
      - OLLAMA_PORT=11434
    volumes:
      - ./repos:/app/repos
      - ./wiki:/app/wiki   # para generar docs directamente
    depends_on:
      - chroma`

* * * * *

### 4\. Actualizar navegación de MkDocs (`wiki/mkdocs.yml`)

MkDocs necesita saber qué páginas mostrar. Podemos hacer que el ETL solo cree los `.md` en `docs/`, y en el `mkdocs.yml` usamos `nav: !include` dinámico.

Ejemplo simple:

`site_name: DeepWiki Self-Hosted
theme:
  name: material
nav:
  - Home: index.md
  - Repositorios:
      - !glob "*.md"`

Esto hará que todos los `.md` generados en `docs/` aparezcan automáticamente en la navegación bajo **Repositorios** 🎉

* * * * *

🚀 Flujo actualizado
====================

1.  **Indexar un repo y generar doc**

    `docker-compose run etl https://github.com/usuario/repo.git`

    👉 Esto clona + indexa en Chroma + genera `wiki/docs/<repo>.md`.

2.  **Levantar servicios**

    `docker-compose up -d`

3.  **Ver en la wiki**

    -   `http://localhost:8080` → ahora verás una sección **Repositorios** con cada repo documentado.



    Buenísimo 👌
Vamos a mejorar el servicio QA para que, cuando devuelva una respuesta, añada (si existe) un link a la página Markdown del repo que generó el ETL en la wiki.

🔧 Cambios en qa/app.py
import os
import requests
from fastapi import FastAPI
from pydantic import BaseModel
from chromadb import HttpClient

# Config
CHROMA_HOST = os.getenv("CHROMA_HOST", "localhost")
CHROMA_PORT = int(os.getenv("CHROMA_PORT", "8000"))
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "localhost")
OLLAMA_PORT = int(os.getenv("OLLAMA_PORT", "11434"))

CHROMA_URL = f"http://{CHROMA_HOST}:{CHROMA_PORT}"
OLLAMA_URL = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/generate"
WIKI_BASE_URL = os.getenv("WIKI_BASE_URL", "http://localhost:8080")

client = HttpClient(host=CHROMA_HOST, port=CHROMA_PORT)
collection = client.get_or_create_collection("repos")

app = FastAPI()

class Question(BaseModel):
    question: str

def guess_repo_from_ids(ids):
    """Intenta deducir el nombre del repo a partir de los IDs en Chroma"""
    if not ids:
        return None
    first_id = ids[0]
    # Los IDs se guardan como repo-archivo-idx
    repo_name = first_id.split("-")[0]
    return repo_name

@app.post("/ask")
def ask(q: Question):
    # Buscar contexto en la base vectorial
    results = collection.query(query_texts=[q.question], n_results=5)
    context = "\n".join(results["documents"][0]) if results["documents"] else "No se encontró contexto."

    # Intentar deducir repo
    repo_name = guess_repo_from_ids(results.get("ids", [[]])[0])
    repo_link = f"{WIKI_BASE_URL}/{repo_name}/" if repo_name else None

    # Llamar a Ollama para generar respuesta
    prompt = f"Pregunta: {q.question}\n\nContexto:\n{context}\n\nRespuesta:"
    resp = requests.post(OLLAMA_URL, json={"model": "llama3", "prompt": prompt}, stream=True)
    resp.raise_for_status()

    answer = ""
    for chunk in resp.iter_lines():
        if chunk:
            data = chunk.decode("utf-8")
            answer += data

    response = {"answer": answer}
    if repo_link:
        response["wiki_page"] = repo_link

    return response

⚙️ Ajustes extra
1. docker-compose.yml (QA)

Agrega la variable para que el QA sepa la URL base de la wiki:

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
      - WIKI_BASE_URL=http://localhost:8080
    depends_on:
      - chroma

🚀 Ejemplo de uso
curl -X POST http://localhost:5000/ask \
     -H "Content-Type: application/json" \
     -d '{"question": "¿Qué hace el archivo main.py?"}'


Respuesta (ejemplo):

{
  "answer": "El archivo `main.py` inicializa la aplicación y gestiona las rutas principales...",
  "wiki_page": "http://localhost:8080/mi-repo/"
}


👉 De esta forma, cada respuesta del QA no solo explica, sino que te da un link directo a la wiki del repo correspondiente.

¿Quieres que también te prepare un botón en la interfaz de MkDocs que consuma este endpoint /ask y muestre las respuestas dentro de la wiki misma (tipo chat lateral)?