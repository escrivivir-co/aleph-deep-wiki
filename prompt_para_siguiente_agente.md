# Prompt para Siguiente Agente: DeepWiki Sistema 95% Funcional - Problema CORS

## Estado Actual 🔄
**DeepWiki está 95% operativo - SOLO falta resolver problema CORS para integración Wiki→API**

### Servicios Completamente Funcionales ✅:
- ✅ ChromaDB: 391 documentos indexados desde repositorio as-core
- ✅ Ollama External: gpt-oss:20b (generación) + nomic-embed-text (embeddings)  
- ✅ Q&A API: Responde **PERFECTAMENTE** vía terminal/curl
- ✅ Wiki: Documentación completa con repositorio as-core visible
- ✅ OpenWebUI: Interface de chat funcional en puerto 3000

### ÚNICO PROBLEMA RESTANTE ❌:
**CORS Policy bloquea comunicación Wiki(8080) → Q&A API(5000)**

**Error específico:**
```
Access to fetch at 'http://localhost:5000/ask' from origin 'http://localhost:8080' 
has been blocked by CORS policy: Response to preflight request doesn't pass 
access control check: It does not have HTTP ok status.
```

### Configuraciones CORS Intentadas (SIN ÉXITO):
```python
# Ya probado en qa/app.py:
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.options("/ask")  # También probado
async def options_ask():
    return {"message": "OK"}
```

### Tests que SÍ FUNCIONAN Perfectamente:
```bash
# API FUNCIONA PERFECTAMENTE VIA TERMINAL:
./deepwiki.bat test "What does as-core do?"  

# CURL DIRECTO FUNCIONA:
curl -X POST http://localhost:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "What is as-core repository about?", "model": "gpt-oss:20b"}'

# RESPUESTA TÍPICA:
"El repositorio as-core es la librería central del FIA AI Framework..."
```

### Interfaz Web Actual:
- Wiki: http://localhost:8080 - **Funcional (sin chat integrado por CORS)**
- Q&A API: http://localhost:5000 - **Funcional vía curl/terminal**
- OpenWebUI: http://localhost:3000 - **Funcional como alternativa de chat**

## Soluciones Sugeridas para CORS:

### Opción 1 - Proxy Reverso:
Configurar Wiki para hacer proxy de API bajo mismo puerto

### Opción 2 - Nginx/Apache:
Servir ambos servicios bajo mismo origen

### Opción 3 - Modificar Arquitectura:
Servir interfaz web desde API (puerto 5000 único)

### Opción 4 - WebSocket:
Usar WebSocket para evitar restricciones CORS

## Comandos Principales:
```bash
./deepwiki.bat start          # Iniciar todos los servicios  
./deepwiki.bat rebuild-all    # Reconstruir sistema completo
./deepwiki.bat test "pregunta" # Probar Q&A (FUNCIONA PERFECTO)
./deepwiki.bat rebuild-qa     # Reiniciar API con nuevas config CORS
```

## Contexto para Agente:
El sistema está **TÉCNICAMENTE COMPLETO** - toda la funcionalidad backend funciona perfectamente. Solo necesita resolver el tema de CORS para que el chat integrado en la wiki funcione desde navegador. El usuario puede usar OpenWebUI en puerto 3000 como alternativa inmediata mientras se resuelve CORS.
