Perfecto 🙌 Te dejo todo lo necesario para que el `docker-compose.yml` que te pasé antes funcione de verdad.

Tendrás **2 servicios custom**:

-   `etl` → clona repos, genera embeddings con Ollama, y los guarda en Chroma.

-   `qa` → expone un API REST (FastAPI) para hacer preguntas al código usando embeddings + Ollama.

* * * * *

📂 Archivos adicionales
=======================

### `etl/Dockerfile`

```yaml
FROM python:3.11-slim

WORKDIR /app

# Dependencias
RUN pip install --no-cache-dir requests chromadb gitpython

COPY etl.py /app/etl.py

ENTRYPOINT ["python", "etl.py"]`

```

* * * * *

### `etl/etl.py`

```py
import os
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
    print("Repo indexado con éxito.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python etl.py <repo_url>")
        sys.exit(1)

    process_repo(sys.argv[1])`
```
* * * * *

### `qa/Dockerfile`

```yml

FROM python:3.11-slim

WORKDIR /app

# Dependencias
RUN pip install --no-cache-dir fastapi uvicorn requests chromadb

COPY app.py /app/app.py

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]`
```
* * * * *

### `qa/app.py`

```py
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

client = HttpClient(host=CHROMA_HOST, port=CHROMA_PORT)
collection = client.get_or_create_collection("repos")

app = FastAPI()

class Question(BaseModel):
    question: str

@app.post("/ask")
def ask(q: Question):
    # Buscar contexto en la base vectorial
    results = collection.query(query_texts=[q.question], n_results=5)
    context = "\n".join(results["documents"][0]) if results["documents"] else "No se encontró contexto."

    # Llamar a Ollama para generar respuesta
    prompt = f"Pregunta: {q.question}\n\nContexto:\n{context}\n\nRespuesta:"
    resp = requests.post(OLLAMA_URL, json={"model": "llama3", "prompt": prompt})
    resp.raise_for_status()

    answer = ""
    for chunk in resp.iter_lines():
        if chunk:
            data = chunk.decode("utf-8")
            answer += data

    return {"answer": answer}`
```

* * * * *

### `wiki/mkdocs.yml`

```yml
site_name: DeepWiki Self-Hosted
theme:
  name: material
nav:
  - Home: index.md`


```

### `wiki/docs/index.md`
`# Bienvenido a tu DeepWiki Self-Hosted

Aquí aparecerá la documentación de los repositorios indexados.`

* * * * *

🚀 Uso
======

1.  **Construir y levantar**

    `docker-compose build
    docker-compose up -d`

2.  **Indexar un repo**

    `docker-compose run etl https://github.com/usuario/repo.git`

3.  **Consultar Q&A**

    `curl -X POST http://localhost:5000/ask\
         -H "Content-Type: application/json"\
         -d '{"question": "¿Qué hace este repositorio?"}'`

4.  **Abrir la wiki**\
    👉 `http://localhost:8080`

* * * * *

¿Quieres que además te genere un **script para que la wiki se regenere automáticamente** con páginas de cada repo que indexa el ETL?