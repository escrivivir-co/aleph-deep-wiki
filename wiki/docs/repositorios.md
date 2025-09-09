# Repositorios

Esta página muestra información sobre todos los repositorios que han sido indexados en DeepWiki.

## 🎉 Repositorios Indexados (391 documentos)

### ✅ [as-core](repos/as-core.md) - FIA AI Framework Core

**Estado:** ✅ Completamente indexado (54 archivos, 391 chunks)  
**Descripción:** Librería central del FIA AI Framework (@fia/core) que contiene las interfaces, tipos y estructuras básicas para el ecosistema.

**Archivos principales:**
- `package.json` - Configuración del paquete npm
- `packages/core/` - Módulo principal con tipos TypeScript
- Interfaces y tipos base del framework

**Consulta de ejemplo:**
```bash
curl -X POST http://localhost:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "What does as-core do?", "model": "gpt-oss:20b"}'
```

---

## Agregar Nuevos Repositorios

### Desde repositorio local:
```bash
# 1. Copiar repositorio
./deepwiki.bat copy-repo E:\ruta\a\tu\repositorio

# 2. Indexar
./deepwiki.bat index nombre-repo
```

### Desde GitHub:
```bash
docker-compose run etl python etl.py https://github.com/usuario/repo
```

## API de Repositorios

Consulta información detallada vía API:

```bash
curl http://localhost:5000/repos | jq
```

Esto te dará información detallada sobre:
- Nombre del repositorio
- URL original
- Archivos indexados
- Número de chunks generados

---

!!! tip "Integración con Q&A"
    Cada repositorio indexado puede ser consultado específicamente usando el parámetro `repo_filter` en la API Q&A.
    
    ```bash
    curl -X POST http://localhost:5000/ask \
      -H "Content-Type: application/json" \
      -d '{"question": "¿Cómo funciona la autenticación?", "repo_filter": "nombre-del-repo"}'
    ```
