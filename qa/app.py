from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests
import os
import time
from chromadb import HttpClient
from typing import Optional, List, Dict
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="DeepWiki Q&A API",
    description="API para consultar repositorios indexados usando embeddings y Ollama",
    version="1.0.0"
)

# Config
CHROMA_HOST = os.getenv("CHROMA_HOST", "localhost")
CHROMA_PORT = int(os.getenv("CHROMA_PORT", "8000"))
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "localhost")
OLLAMA_PORT = int(os.getenv("OLLAMA_PORT", "11434"))

OLLAMA_EMBED_URL = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/embeddings"
OLLAMA_GENERATE_URL = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/generate"

# Global variables
chroma_client = None
collection = None

class QuestionRequest(BaseModel):
    question: str
    repo_filter: Optional[str] = None
    max_results: Optional[int] = 5
    model: Optional[str] = "llama3"

class QuestionResponse(BaseModel):
    answer: str
    sources: List[Dict[str, str]]
    repo_filter: Optional[str]

def wait_for_services():
    """Esperar a que los servicios estén disponibles"""
    logger.info("Esperando a que los servicios estén listos...")
    
    # Esperar Chroma
    for i in range(30):
        try:
            resp = requests.get(f"http://{CHROMA_HOST}:{CHROMA_PORT}/api/v2/heartbeat")
            if resp.status_code == 200:
                logger.info("✓ Chroma está listo")
                break
        except requests.exceptions.RequestException:
            pass
        time.sleep(2)
    else:
        raise Exception("No se pudo conectar a ChromaDB")
    
    # Esperar Ollama
    for i in range(30):
        try:
            resp = requests.get(f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/tags")
            if resp.status_code == 200:
                logger.info("✓ Ollama está listo")
                break
        except requests.exceptions.RequestException:
            pass
        time.sleep(2)
    else:
        raise Exception("No se pudo conectar a Ollama")

def initialize_chroma():
    """Inicializar cliente ChromaDB"""
    global chroma_client, collection
    try:
        chroma_client = HttpClient(host=CHROMA_HOST, port=CHROMA_PORT)
        collection = chroma_client.get_or_create_collection("repos")
        logger.info("✓ ChromaDB inicializado")
    except Exception as e:
        logger.error(f"Error inicializando ChromaDB: {e}")
        raise

def embed_question(question: str) -> List[float]:
    """Generar embedding de la pregunta"""
    try:
        payload = {
            "model": "nomic-embed-text",
            "prompt": question
        }
        resp = requests.post(OLLAMA_EMBED_URL, json=payload, timeout=30)
        resp.raise_for_status()
        return resp.json()["embedding"]
    except Exception as e:
        logger.error(f"Error generando embedding: {e}")
        raise HTTPException(status_code=500, detail=f"Error generando embedding: {str(e)}")

def search_relevant_chunks(question: str, repo_filter: Optional[str] = None, max_results: int = 5):
    """Buscar chunks relevantes en ChromaDB"""
    try:
        logger.info(f"DEBUG - Generando embedding para: {question[:50]}...")
        embedding = embed_question(question)
        logger.info(f"DEBUG - Embedding generado, dimensiones: {len(embedding)}")
        
        # Preparar filtros
        where_filter = None
        if repo_filter:
            where_filter = {"repo": {"$eq": repo_filter}}
            logger.info(f"DEBUG - Usando filtro: {where_filter}")
        else:
            logger.info("DEBUG - Sin filtro de repositorio")
        
        logger.info(f"DEBUG - Consultando ChromaDB con max_results={max_results}")
        results = collection.query(
            query_embeddings=[embedding],
            n_results=max_results,
            where=where_filter,
            include=["documents", "metadatas", "distances"]
        )
        
        logger.info(f"DEBUG - Resultados encontrados: {len(results.get('documents', [[]])[0]) if results.get('documents') else 0}")
        if results.get('documents') and results['documents'][0]:
            logger.info(f"DEBUG - Distancias: {results.get('distances', [[]])[0][:3] if results.get('distances') else []}")
        
        return results
    except Exception as e:
        logger.error(f"Error buscando chunks: {e}")
        raise HTTPException(status_code=500, detail=f"Error en búsqueda: {str(e)}")

def generate_answer(question: str, context: str, model: str = "llama3") -> str:
    """Generar respuesta usando Ollama"""
    try:
        prompt = f"""Eres un asistente especializado en análisis de código. Responde la pregunta basándote únicamente en el contexto proporcionado del código fuente.

Contexto del código:
{context}

Pregunta: {question}

Respuesta (en español, concisa y útil):"""

        payload = {
            "model": model,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.3,
                "top_p": 0.9,
                "num_predict": 500
            }
        }
        
        resp = requests.post(OLLAMA_GENERATE_URL, json=payload, timeout=60)
        resp.raise_for_status()
        
        return resp.json()["response"].strip()
        
    except Exception as e:
        logger.error(f"Error generando respuesta: {e}")
        raise HTTPException(status_code=500, detail=f"Error generando respuesta: {str(e)}")

@app.on_event("startup")
async def startup_event():
    """Inicializar servicios al arrancar"""
    try:
        wait_for_services()
        initialize_chroma()
    except Exception as e:
        logger.error(f"Error en startup: {e}")
        raise

@app.get("/")
async def root():
    """Endpoint de salud"""
    return {
        "message": "DeepWiki Q&A API",
        "status": "running",
        "endpoints": {
            "ask": "POST /ask - Hacer una pregunta",
            "repos": "GET /repos - Listar repositorios indexados",
            "health": "GET /health - Estado del servicio"
        }
    }

@app.get("/health")
async def health_check():
    """Verificar estado de los servicios"""
    try:
        # Verificar Chroma
        chroma_status = collection.count() if collection else 0
        
        # Verificar Ollama
        ollama_resp = requests.get(f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/tags", timeout=5)
        ollama_status = ollama_resp.status_code == 200
        
        return {
            "status": "healthy" if ollama_status else "degraded",
            "chroma": {
                "connected": collection is not None,
                "documents": chroma_status
            },
            "ollama": {
                "connected": ollama_status
            }
        }
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}

@app.get("/repos")
async def list_repos():
    """Listar repositorios indexados"""
    try:
        if not collection:
            raise HTTPException(status_code=500, detail="ChromaDB no está inicializado")
        
        # Obtener todos los metadatos para extraer repositorios únicos
        results = collection.get(include=["metadatas"])
        
        repos = {}
        for metadata in results["metadatas"]:
            repo_name = metadata.get("repo", "unknown")
            if repo_name not in repos:
                repos[repo_name] = {
                    "name": repo_name,
                    "url": metadata.get("repo_url", ""),
                    "files": set(),
                    "chunks": 0
                }
            repos[repo_name]["files"].add(metadata.get("file", ""))
            repos[repo_name]["chunks"] += 1
        
        # Convertir sets a listas para JSON
        for repo in repos.values():
            repo["files"] = list(repo["files"])
        
        return {"repositories": list(repos.values())}
        
    except Exception as e:
        logger.error(f"Error listando repos: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/ask", response_model=QuestionResponse)
async def ask_question(request: QuestionRequest):
    """Responder pregunta usando RAG (Retrieval-Augmented Generation)"""
    try:
        if not collection:
            raise HTTPException(status_code=500, detail="ChromaDB no está inicializado")
        
        logger.info(f"Pregunta recibida: {request.question}")
        if request.repo_filter:
            logger.info(f"Filtrado por repo: {request.repo_filter}")
        
        # Buscar chunks relevantes
        search_results = search_relevant_chunks(
            request.question, 
            request.repo_filter, 
            request.max_results
        )
        
        if not search_results["documents"] or not search_results["documents"][0]:
            raise HTTPException(
                status_code=404, 
                detail="No se encontró información relevante en los repositorios indexados"
            )
        
        # Construir contexto
        context_parts = []
        sources = []
        
        for i, (doc, metadata, distance) in enumerate(zip(
            search_results["documents"][0],
            search_results["metadatas"][0],
            search_results["distances"][0]
        )):
            context_parts.append(f"--- Fragmento {i+1} (de {metadata['file']}) ---\n{doc}")
            sources.append({
                "file": metadata.get("file", "unknown"),
                "repo": metadata.get("repo", "unknown"),
                "relevance": f"{(1 - distance) * 100:.1f}%"
            })
        
        context = "\n\n".join(context_parts)
        
        # Generar respuesta
        answer = generate_answer(request.question, context, request.model)
        
        return QuestionResponse(
            answer=answer,
            sources=sources,
            repo_filter=request.repo_filter
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error procesando pregunta: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)
