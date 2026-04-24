# 🌐 DeepWiki con Ollama Externo

Esta guía te explica cómo configurar **DeepWiki** para usar tu propia instalación de **Ollama** (en lugar del Ollama dockerizado).

## 🎯 ¿Cuándo usar esta configuración?

- ✅ Ya tienes Ollama instalado y funcionando en tu sistema
- ✅ Quieres usar modelos específicos que ya tienes descargados
- ✅ Prefieres gestionar Ollama por separado de Docker
- ✅ Necesitas más control sobre la configuración de Ollama

## 📋 Requisitos Previos

1. **Ollama instalado y funcionando** en `localhost:11434`
2. **Docker & Docker Compose** para los demás servicios
3. **Modelos necesarios** en Ollama:
   - `nomic-embed-text` (para embeddings/indexación)
   - Tu modelo de chat preferido (ej: `gpt-oss:20b`, `llama3.1`, `mistral`)

## 🚀 Instalación Rápida

### 1. Verificar Ollama
```bash
# Verificar que Ollama está funcionando
curl http://localhost:11434/api/tags

# Si no funciona, iniciar Ollama
ollama serve
```

### 2. Instalar modelos necesarios
```bash
# Modelo de embeddings (OBLIGATORIO para indexar)
ollama pull nomic-embed-text

# Si no tienes un modelo de chat, descargar uno
ollama pull llama3.1
# o usar el que ya tengas como gpt-oss:20b
```

### 3. Inicializar DeepWiki
```bash
# Usar el script de inicialización
init-external-ollama.bat     # Windows
# o
./init-external-ollama.sh    # Linux/Mac (crear si necesario)
```

### 4. Configuración Manual (alternativa)
```bash
# Levantar servicios manualmente
docker-compose -f docker-compose.external-ollama.yml up -d
```

## 🔧 Configuración Personalizada

### Cambiar el modelo de chat

Edita `docker-compose.external-ollama.yml` en la sección `qa`:

```yaml
qa:
  # ... otras configuraciones ...
  environment:
    - DEFAULT_MODEL=tu-modelo-aqui  # Cambiar por el modelo que quieras
```

Modelos sugeridos:
- `gpt-oss:20b` (si lo tienes instalado)
- `llama3.1`
- `mistral`
- `codellama` (bueno para código)

### Configurar OpenWebUI

1. Ve a http://localhost:3000
2. Crea una cuenta (primera vez)
3. OpenWebUI detectará automáticamente tu Ollama
4. ¡Ya puedes chatear con tus modelos!

## 📂 Indexar Repositorios

### Repositorio desde GitHub
```bash
docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py https://github.com/usuario/repositorio
```

### Repositorio local (como tu as-core)
```bash
# Desde Windows (ajustar ruta según tu sistema)
docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py file://e:/LAB_AGOSTO/ORACLE_HALT_ALEPH_VERSION/socket-gym/as-core

# Desde Linux/Mac
docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py file:///ruta/completa/a/tu/repo
```

### Múltiples repositorios
```bash
# Indexar varios repos de una vez
docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py \
  https://github.com/fastapi/fastapi \
  https://github.com/microsoft/vscode \
  file:///ruta/a/tu/repo/local
```

## 🌐 Servicios Disponibles

Una vez iniciado, tendrás acceso a:

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Open WebUI** | http://localhost:3000 | Interfaz de chat moderna |
| **Wiki** | http://localhost:8080 | Documentación navegable |
| **Q&A API** | http://localhost:5000 | API REST para consultas |
| **ChromaDB** | http://localhost:8000 | Base de datos vectorial |
| **Tu Ollama** | http://localhost:11434 | Tu instalación de Ollama |

## 💬 Usar el Sistema

### 1. Chat Interactivo (Recomendado)
- Ve a http://localhost:3000
- Haz preguntas sobre tus repositorios indexados
- Ejemplo: *"¿Cómo funciona el sistema de threads en as-core?"*

### 2. API REST
```bash
# Consulta básica
curl -X POST http://localhost:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "¿Qué hace este código?"}'

# Consulta filtrada por repositorio
curl -X POST http://localhost:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "¿Cómo se configuran los threads?", "repo_filter": "as-core"}'
```

### 3. Wiki Navegable
- Ve a http://localhost:8080
- Navega por la documentación autogenerada
- Explora la estructura de tus repositorios

## 🛠️ Comandos Útiles

```bash
# Ver logs de servicios
docker-compose -f docker-compose.external-ollama.yml logs -f

# Reiniciar un servicio específico
docker-compose -f docker-compose.external-ollama.yml restart qa

# Parar todos los servicios
docker-compose -f docker-compose.external-ollama.yml down

# Ver repositorios indexados
curl http://localhost:5000/repos | jq

# Ver estado de salud
curl http://localhost:5000/health | jq
```

## 🐛 Troubleshooting

### "No se puede conectar a Ollama"
```bash
# Verificar que Ollama está funcionando
curl http://localhost:11434/api/tags

# Si no responde, iniciar Ollama
ollama serve

# Verificar que el puerto 11434 no esté bloqueado
netstat -an | findstr 11434
```

### "Modelo no encontrado"
```bash
# Ver modelos instalados
ollama list

# Instalar modelo faltante
ollama pull nomic-embed-text
ollama pull llama3.1
```

### "Servicios no se conectan"
```bash
# Verificar red de Docker
docker network ls | findstr deepwiki

# Recrear servicios
docker-compose -f docker-compose.external-ollama.yml down
docker-compose -f docker-compose.external-ollama.yml up -d
```

### OpenWebUI no detecta modelos
1. Ve a Settings en OpenWebUI
2. Verifica que la URL de Ollama sea `http://host.docker.internal:11434`
3. Reinicia OpenWebUI si es necesario

## 🔐 Seguridad

Para usar en producción, cambia la clave secreta en `docker-compose.external-ollama.yml`:

```yaml
openwebui:
  environment:
    - WEBUI_SECRET_KEY=tu-clave-super-secreta-aqui
```

## 🚀 Siguientes Pasos

1. **Indexa tu repositorio as-core**
2. **Prueba hacer preguntas sobre tu código**
3. **Explora la wiki autogenerada**
4. **Configura más repositorios si necesitas**

¡Ya tienes tu DeepWiki funcionando con tu Ollama externo! 🎉
