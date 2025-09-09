📝 Prompt para el Agente
========================

Quiero que diseñes y levantes una infraestructura **self-hosted tipo DeepWiki** en mi red local.

### Contexto

-   Ya tengo **Ollama** instalado y corriendo en la máquina host, en los puertos por defecto (11434).

-   Necesito un sistema que me permita:

    1.  Indexar repositorios locales o de GitHub.

    2.  Generar documentación navegable en formato wiki (Markdown/HTML).

    3.  Consultar el código con Ollama en lenguaje natural, usando embeddings y un motor vectorial.

-   Todo debe levantarse con **contenedores Docker** (usa tantos como sean necesarios).

* * * * *

### Requisitos técnicos

1.  **Vector DB**

    -   Usa **ChromaDB** o **Qdrant** como motor de embeddings.

    -   Exponlo en un puerto accesible en red local.

2.  **ETL de repositorios**

    -   Un contenedor con un servicio en Python que:

        -   Clona/actualiza repositorios desde GitHub o rutas locales.

        -   Trocea el código en chunks.

        -   Genera embeddings vía **Ollama embeddings API**.

        -   Inserta embeddings en la base vectorial.

3.  **Wiki frontend**

    -   Usa **MkDocs** (con theme Material) o **Docusaurus** en un contenedor separado.

    -   El servicio debe generar documentación estática a partir de los repos indexados.

    -   Debe exponer un puerto web (ej. 8080) para navegar la wiki.

4.  **Q&A service**

    -   Contenedor en Python (FastAPI o Flask) que:

        -   Reciba preguntas del usuario vía REST API.

        -   Busque contexto en la base vectorial.

        -   Pase el contexto a Ollama (inferencia vía API local en `http://host.docker.internal:11434`).

        -   Devuelva respuestas en JSON.

5.  **Orquestación**

    -   Define un `docker-compose.yml` que levante:

        -   `chroma` (vector DB)

        -   `etl` (pipeline indexador de repos)

        -   `wiki` (frontend documental)

        -   `qa` (API de preguntas y respuestas)

    -   Asegúrate de usar volúmenes persistentes para:

        -   Datos de repositorios.

        -   Datos de embeddings en la DB.

        -   Archivos generados de la wiki.

6.  **Integración**

    -   El **frontend wiki** debe linkear hacia el **servicio Q&A** para permitir consultas en lenguaje natural (botón de "pregunta al código").

    -   El ETL debe poder ejecutarse bajo demanda (ej. `docker-compose run etl <repo_url>`).

* * * * *

### Entregables esperados

1.  Un **`docker-compose.yml`** con todos los servicios definidos.

2.  Un **script de ETL** en Python para clonar, trocear e indexar repositorios.

3.  Configuración básica de MkDocs o Docusaurus lista para servir la wiki.

4.  Un endpoint REST `/ask` en el servicio Q&A que reciba `{ "question": "..." }` y responda con texto generado por Ollama usando contexto vectorial.

* * * * *

### Extra

-   Documenta cómo agregar un nuevo repositorio y regenerar la wiki.

-   Explica cómo hacer consultas al servicio Q&A desde `curl` o Postman.

-   Opcional: añade autenticación básica al servicio Q&A.

* * * * *

👉 Instrucciones finales:\
Construye todo este plan en contenedores Docker de forma modular, asegurándote de que Ollama se use como LLM y que el sistema pueda operar sin depender de servicios externos.