import os
import sys
import git
from git import InvalidGitRepositoryError
import requests
import time
from chromadb import HttpClient
from pathlib import Path
import chardet

# Config
CHROMA_HOST = os.getenv("CHROMA_HOST", "localhost")
CHROMA_PORT = int(os.getenv("CHROMA_PORT", "8000"))
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "localhost")
OLLAMA_PORT = int(os.getenv("OLLAMA_PORT", "11434"))

CHROMA_URL = f"http://{CHROMA_HOST}:{CHROMA_PORT}"
OLLAMA_URL = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/embeddings"

WIKI_PATH = "/app/wiki/docs"

def wait_for_services():
    """Esperar a que Chroma y Ollama estén disponibles"""
    print("Esperando a que los servicios estén listos...")
    
    # Esperar Chroma
    for i in range(30):
        try:
            resp = requests.get(f"{CHROMA_URL}/api/v2/heartbeat", timeout=5)
            if resp.status_code == 200:
                print("✓ Chroma está listo")
                break
        except Exception as e:
            print(f"Intento {i+1}/30: Error Chroma: {e}")
        time.sleep(2)
    else:
        print("❌ No se pudo conectar a Chroma")
        sys.exit(1)
    
    # Esperar Ollama
    for i in range(30):
        try:
            resp = requests.get(f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/tags", timeout=5)
            if resp.status_code == 200:
                print("✓ Ollama está listo")
                break
        except Exception as e:
            print(f"Intento {i+1}/30: Error Ollama: {e}")
        time.sleep(2)
    else:
        print("❌ No se pudo conectar a Ollama")
        sys.exit(1)

def get_chroma_client():
    """Crear cliente ChromaDB"""
    try:
        client = HttpClient(host=CHROMA_HOST, port=CHROMA_PORT)
        collection = client.get_or_create_collection("repos")
        return client, collection
    except Exception as e:
        print(f"Error conectando a ChromaDB: {e}")
        sys.exit(1)

def embed_text(text: str, max_retries=3):
    """Generar embedding usando Ollama"""
    for attempt in range(max_retries):
        try:
            payload = {
                "model": "nomic-embed-text",
                "prompt": text
            }
            resp = requests.post(OLLAMA_URL, json=payload, timeout=30)
            resp.raise_for_status()
            return resp.json()["embedding"]
        except Exception as e:
            print(f"Error generando embedding (intento {attempt + 1}): {e}")
            if attempt < max_retries - 1:
                time.sleep(2)
            else:
                raise

def detect_encoding(file_path):
    """Detectar encoding del archivo"""
    try:
        with open(file_path, 'rb') as f:
            raw_data = f.read(10000)  # Leer primeros 10KB
            result = chardet.detect(raw_data)
            return result['encoding'] if result['confidence'] > 0.7 else 'utf-8'
    except:
        return 'utf-8'

def read_file_safely(file_path):
    """Leer archivo de forma segura"""
    encoding = detect_encoding(file_path)
    try:
        with open(file_path, "r", encoding=encoding, errors="ignore") as file:
            return file.read()
    except Exception as e:
        print(f"Error leyendo {file_path}: {e}")
        return ""

def chunk_text(text, chunk_size=500, overlap=50):
    """Dividir texto en chunks con overlap"""
    chunks = []
    for i in range(0, len(text), chunk_size - overlap):
        chunk = text[i:i + chunk_size]
        if chunk.strip():
            chunks.append(chunk)
    return chunks

def is_code_file(file_path):
    """Verificar si es un archivo de código relevante"""
    code_extensions = {
        '.py', '.js', '.ts', '.java', '.go', '.rs', '.cpp', '.c', '.h', 
        '.cs', '.php', '.rb', '.swift', '.kt', '.scala', '.r', '.m',
        '.md', '.rst', '.txt', '.yml', '.yaml', '.json', '.xml',
        '.sql', '.sh', '.bat', '.ps1', '.dockerfile'
    }
    return Path(file_path).suffix.lower() in code_extensions

def process_repo(repo_url):
    """Procesar repositorio completo"""
    wait_for_services()
    client, collection = get_chroma_client()
    
    repo_name = repo_url.split("/")[-1].replace(".git", "")
    repo_path = os.path.join("/app/repos", repo_name)

    print(f"Procesando repositorio: {repo_name}")
    
    # Clonar o actualizar repositorio
    if os.path.exists(repo_path):
        print(f"Actualizando {repo_name}...")
        try:
            repo = git.Repo(repo_path)
            if repo.remotes:  # Solo hacer pull si hay remotes configurados
                repo.remotes.origin.pull()
                print(f"✓ Repositorio {repo_name} actualizado desde remote")
            else:
                print(f"✓ Repositorio local {repo_name} sin remote - usando archivos existentes")
        except git.InvalidGitRepositoryError:
            # No es un repositorio git válido, probablemente copiado con copy-repo
            print(f"✓ Repositorio local {repo_name} (copia de archivos) - procesando directamente")
        except Exception as e:
            print(f"Error actualizando repo: {repo_path}")
            print(f"Detalle del error: {e}")
            print("Continuando con el procesamiento de archivos...")
    else:
        print(f"Clonando {repo_name}...")
        try:
            git.Repo.clone_from(repo_url, repo_path)
        except Exception as e:
            print(f"Error clonando repo: {e}")
            return

    print("Procesando archivos...")
    doc_content = [
        f"# {repo_name}\n",
        f"**Repositorio:** {repo_url}\n",
        f"**Fecha de indexación:** {time.strftime('%Y-%m-%d %H:%M:%S')}\n",
        "## Archivos indexados\n"
    ]
    
    processed_files = 0
    total_chunks = 0

    for root, _, files in os.walk(repo_path):
        # Ignorar directorios comunes que no queremos indexar
        if any(ignore in root for ignore in ['.git', 'node_modules', '__pycache__', '.venv', 'venv']):
            continue
            
        for f in files:
            file_path = os.path.join(root, f)
            
            if not is_code_file(file_path):
                continue
                
            try:
                content = read_file_safely(file_path)
                if not content.strip():
                    continue

                # Generar chunks
                chunks = chunk_text(content, chunk_size=800, overlap=100)
                
                for idx, chunk in enumerate(chunks):
                    try:
                        embedding = embed_text(chunk)
                        
                        # Información adicional para el chunk
                        rel_path = os.path.relpath(file_path, repo_path)
                        metadata = {
                            "repo": repo_name,
                            "file": rel_path,
                            "chunk_id": idx,
                            "file_type": Path(file_path).suffix,
                            "repo_url": repo_url
                        }
                        
                        # Crear chunk_id sin backslashes en f-string
                        path_clean = rel_path.replace('/', '_').replace('\\', '_')
                        chunk_id = f"{repo_name}-{path_clean}-{idx}"
                        
                        collection.add(
                            documents=[chunk],
                            embeddings=[embedding],
                            metadatas=[metadata],
                            ids=[chunk_id]
                        )
                        total_chunks += 1
                        
                    except Exception as e:
                        print(f"Error procesando chunk {idx} de {rel_path}: {e}")
                        continue

                # Agregar archivo a la documentación
                rel_path = os.path.relpath(file_path, repo_path)
                file_size = os.path.getsize(file_path)
                doc_content.append(f"- `{rel_path}` ({len(chunks)} chunks, {file_size} bytes)")
                processed_files += 1

            except Exception as e:
                print(f"Error procesando archivo {f}: {e}")
                continue

    # Generar página de documentación
    os.makedirs(WIKI_PATH, exist_ok=True)
    doc_content.extend([
        f"\n## Estadísticas",
        f"- **Archivos procesados:** {processed_files}",
        f"- **Chunks totales:** {total_chunks}",
        f"- **Última actualización:** {time.strftime('%Y-%m-%d %H:%M:%S')}",
        f"\n## Consultar este repositorio",
        f"Puedes hacer preguntas sobre este código usando el endpoint Q&A:",
        f"```bash",
        f"curl -X POST http://localhost:5000/ask \\",
        f'  -H "Content-Type: application/json" \\',
        f'  -d \'{{"question": "¿Qué hace este repositorio?", "repo_filter": "{repo_name}"}}\'',
        f"```"
    ])
    
    wiki_file = os.path.join(WIKI_PATH, f"{repo_name}.md")
    with open(wiki_file, "w", encoding="utf-8") as f:
        f.write("\n".join(doc_content))

    print(f"✓ Repositorio {repo_name} indexado exitosamente:")
    print(f"  - {processed_files} archivos procesados")
    print(f"  - {total_chunks} chunks indexados")
    print(f"  - Documentación guardada en: {wiki_file}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python etl.py <repo_url>")
        print("Ejemplo: python etl.py https://github.com/usuario/mi-repo")
        sys.exit(1)

    repo_url = sys.argv[1]
    
    print(f"DEBUG - repo_url recibido: {repr(repo_url)}")
    
    # Validar URL o ruta local
    is_url = repo_url.startswith("http://") or repo_url.startswith("https://")
    print(f"DEBUG - is_url: {is_url}")
    is_local_path = os.path.exists(repo_url)
    print(f"DEBUG - is_local_path: {is_local_path}")
    
    # Verificar si es un nombre de repo en /app/repos/
    repo_in_container = f"/app/repos/{repo_url}"
    print(f"DEBUG - repo_in_container: {repr(repo_in_container)}")
    is_repo_name = os.path.exists(repo_in_container)
    print(f"DEBUG - is_repo_name: {is_repo_name}")
    
    print(f"DEBUG - Validación final: {is_url or is_local_path or is_repo_name}")
    
    if not (is_url or is_local_path or is_repo_name):
        print("Error: Debe ser una URL válida (http/https), una ruta local existente o un nombre de repo en /app/repos/")
        print("Ejemplos:")
        print("  python etl.py https://github.com/usuario/mi-repo")
        print("  python etl.py /path/to/local/repo")
        print("  python etl.py C:\\path\\to\\local\\repo")
        print("  python etl.py as-core  # Si existe /app/repos/as-core")
        sys.exit(1)
    
    # Si es solo un nombre, convertir a ruta completa
    if is_repo_name and not is_local_path:
        repo_url = repo_in_container
        print(f"Usando repositorio local: {repo_url}")
    
    if not (is_url or os.path.exists(repo_url)):
        print(f"Error: La ruta {repo_url} no existe")
        sys.exit(1)

    try:
        process_repo(repo_url)
        print("🎉 Proceso completado exitosamente!")
    except KeyboardInterrupt:
        print("\n❌ Proceso interrumpido por el usuario")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error fatal: {e}")
        sys.exit(1)
