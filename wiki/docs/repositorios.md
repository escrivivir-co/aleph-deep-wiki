# Repositorios

Esta página muestra información sobre todos los repositorios que han sido indexados en DeepWiki.

## Repositorios Disponibles

Los repositorios indexados aparecerán automáticamente aquí cuando ejecutes el proceso ETL.

### ¿No ves ningún repositorio?

Si aún no has indexado ningún repositorio, puedes empezar con:

```bash
# Ejemplo: indexar el repositorio de FastAPI
docker-compose run etl python etl.py https://github.com/fastapi/fastapi

# O tu propio repositorio
docker-compose run etl python etl.py https://github.com/tu-usuario/tu-repo
```

## API de Repositorios

También puedes consultar la lista de repositorios vía API:

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
