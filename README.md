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

### 1. Inicialización rápida (recomendado)

```bash
# Descargar e inicializar todo automáticamente
./init.sh         # Linux/Mac
# o
init.bat          # Windows

# Esto descargará los modelos necesarios y levantará todos los servicios
```

### 2. Instalación manual

```bash
# Para sistemas con GPU
docker-compose up -d

# Para sistemas solo CPU
docker-compose -f docker-compose.cpu.yml up -d

# Descargar modelos manualmente
docker-compose exec ollama ollama pull nomic-embed-text
docker-compose exec ollama ollama pull llama3.1
```

### 3. Indexar repositorios

```bash
# Indexar un repositorio desde GitHub
docker-compose run etl python etl.py https://github.com/usuario/repositorio

# Ejemplos:
docker-compose run etl python etl.py https://github.com/fastapi/fastapi
docker-compose run etl python etl.py https://github.com/microsoft/vscode
```

### 4. Usar la plataforma

- **💬 Chat interactivo:** http://localhost:3000 (Open WebUI)
- **📖 Wiki navegable:** http://localhost:8080
- **🤖 API Q&A:** http://localhost:5000 (Docs en `/docs`)
- **🧠 Ollama directo:** http://localhost:11434
- **🗄️ ChromaDB:** http://localhost:8000

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
