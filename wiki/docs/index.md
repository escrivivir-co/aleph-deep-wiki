# DeepWiki

¡Bienvenido a **DeepWiki**! 🚀

Esta es tu wiki autogenerada de repositorios de código, potenciada por **embeddings** y **Ollama**.

## ¿Qué es DeepWiki?

DeepWiki es una plataforma que:

- 📁 **Indexa automáticamente** tus repositorios de código
- 🔍 **Genera embeddings** de cada fragmento de código usando Ollama
- 📖 **Crea documentación** navegable en formato wiki
- 💬 **Permite consultas** en lenguaje natural sobre tu código

## Servicios Disponibles

### 🌐 Wiki (Este sitio)
- **URL:** [http://localhost:8080](http://localhost:8080)
- **Descripción:** Interfaz web para navegar la documentación

### 💬 Open WebUI
- **URL:** [http://localhost:3000](http://localhost:3000)  
- **Descripción:** Interfaz web moderna para chatear con Ollama
- **Características:** Chat, historial, modelos múltiples

### 🤖 API Q&A
- **URL:** [http://localhost:5000](http://localhost:5000)
- **Descripción:** API REST para consultar el código usando IA
- **Documentación:** [http://localhost:5000/docs](http://localhost:5000/docs)

### 🧠 Ollama
- **URL:** [http://localhost:11434](http://localhost:11434)
- **Descripción:** Servidor LLM local con múltiples modelos

### 🗄️ ChromaDB
- **URL:** [http://localhost:8000](http://localhost:8000)
- **Descripción:** Base de datos vectorial con embeddings

## Cómo usar DeepWiki

### 1. Indexar un repositorio

```bash
# Indexar repositorio desde GitHub
docker-compose run etl python etl.py https://github.com/usuario/mi-repo

# Ejemplo con un repo real
docker-compose run etl python etl.py https://github.com/fastapi/fastapi
```

### 2. Consultar el código

#### Vía API directa:
```bash
curl -X POST http://localhost:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "¿Cómo funciona la autenticación?"}'
```

#### Con filtro por repositorio:
```bash
curl -X POST http://localhost:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "¿Qué endpoints están disponibles?", "repo_filter": "fastapi"}'
```

### 3. Ver repositorios indexados

```bash
curl http://localhost:5000/repos
```

## 🚀 Primeros Pasos

1. **Inicializa DeepWiki (primera vez):**
   ```bash
   # En Windows
   deepwiki.bat init
   
   # En Linux/Mac  
   ./deepwiki.sh init
   ```
   
   Esto descargará automáticamente los modelos necesarios de Ollama.

2. **O levanta los servicios directamente:**
   ```bash
   # Con GPU (recomendado)
   deepwiki.bat start
   
   # Solo CPU
   deepwiki.bat start-cpu
   ```

3. **Indexa tu primer repo:**
   ```bash
   deepwiki.bat index https://github.com/fastapi/fastapi
   ```

4. **¡Usa DeepWiki!**
   - **Chat directo:** http://localhost:3000 (Open WebUI)
   - **Wiki navegable:** http://localhost:8080  
   - **API programática:** http://localhost:5000

## 📊 Estado del Sistema

<div id="system-status">
  <p>Verificando estado de los servicios...</p>
</div>

<script>
// Verificar estado de la API
fetch('http://localhost:5000/health')
  .then(response => response.json())
  .then(data => {
    const statusDiv = document.getElementById('system-status');
    statusDiv.innerHTML = `
      <div class="admonition ${data.status === 'healthy' ? 'note' : 'warning'}">
        <p class="admonition-title">Estado: ${data.status.toUpperCase()}</p>
        <ul>
          <li>ChromaDB: ${data.chroma.connected ? '✅' : '❌'} (${data.chroma.documents} documentos)</li>
          <li>Ollama: ${data.ollama.connected ? '✅' : '❌'}</li>
        </ul>
      </div>
    `;
  })
  .catch(error => {
    const statusDiv = document.getElementById('system-status');
    statusDiv.innerHTML = `
      <div class="admonition warning">
        <p class="admonition-title">Error</p>
        <p>No se puede conectar con la API Q&A en localhost:5000</p>
      </div>
    `;
  });
</script>

---

## 📚 Repositorios Indexados

Los repositorios que vayas indexando aparecerán automáticamente en la sección **Repositorios** del menú de navegación.
