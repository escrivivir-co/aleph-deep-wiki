# DeepWiki - Infraestructura Self-Hosted

🚀 **DeepWiki** es una plataforma completa para indexar, documentar y consultar repositorios de código usando embeddings y Ollama.

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   MkDocs Wiki   │    │    FastAPI Q&A   │    │   ChromaDB      │
│   (Puerto 8080) │    │   (Puerto 5000)  │    │  (Puerto 8000)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                         ┌──────────────────┐
                         │   Ollama Docker  │
                         │  (Puerto 11434)  │
                         └──────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
           ┌──────────────────┐         ┌──────────────────┐
           │   ETL Service    │         │   Open WebUI     │
           │   (On-demand)    │         │  (Puerto 3000)   │
           └──────────────────┘         └──────────────────┘
```

## 🚦 Requisitos Previos

1. **Docker & Docker Compose** instalados
2. **GPU (opcional):** Para mejor rendimiento con Ollama
   - NVIDIA GPU con drivers actualizados
   - NVIDIA Container Toolkit
3. **Al menos 8GB RAM** (16GB recomendados)
4. **20GB espacio libre** (para modelos de Ollama)

## 🚀 Instalación y Uso

### 🌟 Opción A: Con Ollama Externo (Recomendado si ya tienes Ollama)

Si ya tienes **Ollama instalado y funcionando** en tu sistema:

```bash
# Usar tu Ollama externo (más eficiente)
init-external-ollama.bat     # Windows
# o  
./init-external-ollama.sh    # Linux/Mac

# Esto usará tu instalación existente de Ollama
```

📖 **[Ver guía completa de Ollama Externo](EXTERNAL-OLLAMA-SETUP.md)**

### 🐳 Opción B: Con Ollama Dockerizado

```bash
# Descargar e inicializar todo automáticamente con Ollama en Docker
./init.sh         # Linux/Mac
# o
init.bat          # Windows

# Esto descargará los modelos necesarios y levantará todos los servicios
```

### 3. Instalación manual

#### Con Ollama Externo
```bash
# Asegúrate de que Ollama esté funcionando
ollama serve

# Instalar modelo de embeddings si no lo tienes
ollama pull nomic-embed-text

# Levantar servicios DeepWiki
docker-compose -f docker-compose.external-ollama.yml up -d
```

#### Con Ollama Dockerizado
```bash
# Para sistemas con GPU
docker-compose up -d

# Para sistemas solo CPU
docker-compose -f docker-compose.cpu.yml up -d

# Descargar modelos manualmente
docker-compose exec ollama ollama pull nomic-embed-text
docker-compose exec ollama ollama pull llama3.1
```

### 4. Indexar repositorios

#### Con Ollama Externo
```bash
# Indexar repositorio desde GitHub
docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py https://github.com/usuario/repositorio

# Indexar repositorio local (como tu as-core)
docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py file://e:/LAB_AGOSTO/ORACLE_HALT_ALEPH_VERSION/socket-gym/as-core

# Ejemplos adicionales:
docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py https://github.com/fastapi/fastapi
```

#### Con Ollama Dockerizado
```bash
# Indexar un repositorio desde GitHub
docker-compose run etl python etl.py https://github.com/usuario/repositorio

# Ejemplos:
docker-compose run etl python etl.py https://github.com/fastapi/fastapi
docker-compose run etl python etl.py https://github.com/microsoft/vscode
```

### 5. Usar la plataforma

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **💬 Open WebUI** | http://localhost:3000 | Chat interactivo (incluido con Ollama externo) |
| **📖 Wiki** | http://localhost:8080 | Documentación navegable |
| **🤖 Q&A API** | http://localhost:5000 | API REST (docs en `/docs`) |
| **🗄️ ChromaDB** | http://localhost:8000 | Base de datos vectorial |
| **🧠 Ollama** | http://localhost:11434 | Tu Ollama (externo) o dockerizado |

## 🎯 Ejemplo: Indexar tu repositorio as-core

```bash
# 1. Inicializar DeepWiki con Ollama externo
init-external-ollama.bat

# 2. Indexar tu repositorio as-core
docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py file://e:/LAB_AGOSTO/ORACLE_HALT_ALEPH_VERSION/socket-gym/as-core

# 3. ¡Ya puedes hacer preguntas!
# Ve a http://localhost:3000 y pregunta:
# - "¿Cómo funciona el sistema de threads en as-core?"
# - "¿Qué hace la clase RuntimeThread?" 
# - "¿Cómo se configuran los paquetes en este proyecto?"
```

## 💬 Consultas Q&A

### Consulta básica
```bash
curl -X POST http://localhost:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "¿Qué hace este código?"}'
```

### Consulta filtrada por repositorio
```bash
curl -X POST http://localhost:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "¿Cómo se configura la autenticación?", "repo_filter": "fastapi"}'
```

### Ver repositorios indexados
```bash
curl http://localhost:5000/repos | jq
```

## 🔧 Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar un servicio específico
docker-compose restart qa

# Limpiar y rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Backup de datos
tar -czf deepwiki-backup.tar.gz data/ repos/

# Ver uso de recursos
docker-compose top
```

## 📂 Estructura del Proyecto

```
deepwiki/
├── docker-compose.yml      # Orquestación de servicios
├── data/
│   └── chroma/            # Datos persistentes de ChromaDB
├── repos/                 # Repositorios clonados
├── etl/
│   ├── Dockerfile
│   └── etl.py            # Script de indexación
├── qa/
│   ├── Dockerfile
│   └── app.py            # API FastAPI
├── wiki/
│   ├── mkdocs.yml        # Configuración MkDocs
│   └── docs/             # Documentación generada
└── README.md             # Este archivo
```

## 🎯 Casos de Uso

1. **Exploración de código:** Navegar documentación autogenerada de repos
2. **Q&A inteligente:** Hacer preguntas en lenguaje natural sobre el código
3. **Onboarding:** Ayudar a nuevos desarrolladores a entender proyectos
4. **Búsqueda semántica:** Encontrar código relevante por funcionalidad
5. **Documentación viva:** Mantener docs actualizadas automáticamente

## 🛠️ Personalización

### Cambiar modelo de Ollama
Editar `docker-compose.yml` y cambiar la variable de entorno en el servicio `qa`:
```yaml
environment:
  - DEFAULT_MODEL=mistral  # o codellama, etc.
```

### Ajustar tamaño de chunks
Modificar `etl/etl.py`, función `chunk_text()`:
```python
chunks = chunk_text(content, chunk_size=1000, overlap=100)
```

### Personalizar theme de MkDocs
Editar `wiki/mkdocs.yml`:
```yaml
theme:
  name: material
  palette:
    primary: indigo  # cambiar color
```

## 🔍 Troubleshooting

### Los servicios no se conectan
```bash
# Verificar que Ollama esté corriendo
curl http://localhost:11434/api/tags

# Verificar red de Docker
docker network ls
docker network inspect deepwiki_deepwiki
```

### ChromaDB no persiste datos
```bash
# Verificar permisos del volumen
ls -la data/chroma/
sudo chown -R 1000:1000 data/
```

### Modelos de Ollama no disponibles
```bash
# Verificar modelos instalados
ollama list

# Instalar modelos necesarios
ollama pull nomic-embed-text
ollama pull llama3
```

## 📈 Monitoreo

### Estado general
```bash
curl http://localhost:5000/health | jq
```

### Métricas de repositorios
```bash
curl http://localhost:5000/repos | jq '.repositories | length'
```

### Logs de servicios
```bash
docker-compose logs chroma
docker-compose logs qa
docker-compose logs wiki
```

## 🔐 Seguridad (Opcional)

Para añadir autenticación básica al API Q&A, editar `qa/app.py`:

```python
from fastapi.security import HTTPBasic, HTTPBasicCredentials
import secrets

security = HTTPBasic()

def verify_credentials(credentials: HTTPBasicCredentials = Depends(security)):
    correct_username = secrets.compare_digest(credentials.username, "admin")
    correct_password = secrets.compare_digest(credentials.password, "secret")
    if not (correct_username and correct_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return credentials.username
```

## 🤝 Contribuir

1. Fork del repositorio
2. Crear branch para tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Commit de cambios: `git commit -am 'Añadir nueva funcionalidad'`
4. Push a la branch: `git push origin feature/nueva-funcionalidad`
5. Crear Pull Request

## 📄 Licencia

MIT License - ver archivo LICENSE para detalles

---

**¡Happy Coding!** 🎉
