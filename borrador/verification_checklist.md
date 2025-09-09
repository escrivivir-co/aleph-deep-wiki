🚀 **Paso a paso: `deepwiki.bat start-external`**
-------------------------------------------------

### **Paso 1: Verificación inicial**

-   **Qué hace**: Hace un ping a `http://localhost:11434` para verificar que tu Ollama externo esté corriendo
-   **Qué mirar**: Debe mostrar "✅ Ollama externo disponible"
-   **Si falla**: Verifica que tu Ollama esté corriendo en puerto 11434

### **Paso 2: Inicio de servicios Docker**

-   **Qué hace**: Ejecuta `docker-compose -f docker-compose.external-ollama.yml up -d`
-   **Servicios que levanta**:
    -   **ChromaDB** (puerto 8000)
    -   **QA Service** (puerto 5000)
    -   **Wiki/MkDocs** (puerto 8080)
    -   **Open WebUI** (puerto 3000)
-   **NO levanta**: Ollama (usa el tuyo externo)

### **Paso 3: Verificaciones de salud**

-   **ChromaDB**: Ping a `http://localhost:8000/api/v1/heartbeat`
-   **QA Service**: Ping a `http://localhost:5000/health`
-   **Wiki**: Ping a `http://localhost:8080`

### **Paso 4: Configuración de conexiones**

-   **QA Service** se conectará a tu Ollama externo en `host.docker.internal:11434`
-   **Open WebUI** se conectará también a tu Ollama externo

### **Paso 5: Confirmación final**

🔍 **Qué debes verificar que se haya cumplido:**
------------------------------------------------

### **1\. Contenedores corriendo**

**Debes ver**:

-   `aleph-deep-wiki-chroma-1` (Running)
-   `aleph-deep-wiki-qa-1` (Running)
-   `aleph-deep-wiki-wiki-1` (Running)
-   `aleph-deep-wiki-open-webui-1` (Running)
-   **NO debes ver** `ollama` (usa el tuyo externo)

### **2\. Puertos ocupados**

**Debes ver puertos ocupados**:

-   `:3000` (Open WebUI)
-   `:5000` (QA API)
-   `:8000` (ChromaDB)
-   `:8080` (Wiki)

### **3\. Servicios respondiendo**

### **4\. Conectividad con Ollama externo**

### **5\. Interfaces web funcionando**

-   **Open WebUI**: [http://localhost:3000]() (debería mostrar la interfaz)
-   **Wiki**: [http://localhost:8080]() (debería mostrar tu wiki)
-   **QA API docs**: [http://localhost:5000/docs]() (documentación Swagger)

⚠️ **Posibles problemas y soluciones:**
---------------------------------------

### **Si no puede conectar a Ollama externo:**

-   Verifica que Ollama esté corriendo: `ollama list`
-   Verifica el puerto: `netstat -an | findstr :11434`

### **Si hay conflictos de puertos:**

-   Modifica los puertos en `docker-compose.external-ollama.yml`

### **Para debugging:**

¿Quieres que ejecute el comando ahora o prefieres verificar algo específico antes?