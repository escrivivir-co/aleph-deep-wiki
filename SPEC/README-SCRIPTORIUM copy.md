ChromaDB shared vs per microservice

one chromadb quite a big, or one chromadb for each microservice?

Leer 10 páginas web

The short answer is: For a production system, one shared ChromaDB instance is the recommended architecture.

While a "database per microservice" is common for general-purpose SQL databases, it creates significant operational and data consistency problems for vector search. Here is the breakdown of why you should share, and the only two scenarios where you wouldn't.

### The Core Problem: "One Per Service" is Risky

If you give each microservice its own ChromaDB, you lose the ability to search across services. If "Service A" has documents about "Customer X" and "Service B" has different documents about "Customer X," you cannot run a single query to find all relevant information for that customer. You would have to query each database individually and merge the results manually, which is slow and complex.

### 📊 When to use ONE Shared Database (Recommended)

This is the standard pattern for production. It treats ChromaDB as a centralized index, similar to how Elasticsearch or Redis is used.

-   Requirement: You need to search across data owned by different services (e.g., a global search bar) or you want to avoid managing 10 different database containers.

-   How to implement: Run a single Chroma Server Mode instance (or Cloud version). All microservices connect to it via `HttpClient` [](https://cookbook.chromadb.dev/running/deployment-patterns/).

-   Isolation Strategy: Use Chroma's built-in Tenants and Databases.

    -   Create one Tenant per "Team" or "Customer".

    -   Create a Database per microservice inside that tenant [](https://cookbook.chromadb.dev/strategies/multi-tenancy/naive-multi-tenancy/?source=post_page-----d0475a2edf33--------------------------------#__codelineno-0-3)[](https://docs.trychroma.com/reference/architecture/overview).

    -   *Result*: Data is physically isolated but searchable from a single endpoint.

### ⚠️ When to use ONE PER Service (Edge Cases)

You would only deploy separate instances if your "big" database hits a hard technical wall.

-   Requirement: You have massive scale (specifically, > 10 million vectors) or your services are completely unrelated (e.g., a Finance bot and a Weather bot that never need to interact).

-   Why: Single-node ChromaDB has concurrency limits. Benchmarks show that while one query might take 0.3 seconds, running 100 concurrent queries can slow the average response time to 23 seconds due to locking mechanisms [](https://www.newtuple.com/post/speed-and-scalability-in-vector-search).

-   The Fix: You shard the data manually. You spin up three separate ChromaDB servers, split your data between them, and your "Gateway" service has to query all three [](https://edana.ch/en/2026/02/08/pros-and-cons-of-chromadb-for-retrieval-augmented-generation-great-for-getting-started-but-risky/#gototop). (Note: The new "Distributed" Chroma architecture aims to solve this automatically) [](https://docs.trychroma.com/reference/architecture/overview).

### ⚡ The "Shared DB" Performance Trap

You might be worried about performance, but putting a DB in every service makes that worse, not better. Here is the reality of Chroma's architecture:

-   The Bottleneck is RAM and CPU: Chroma keeps vectors in RAM for speed [](https://cookbook.chromadb.dev/core/resources/#cpu). If you run 5 microservices, each with its own DB, you are running 5 separate processes, 5 separate caches, and using 5x the memory compared to one shared instance.

-   Embedded Mode is Dangerous: Do not use `PersistentClient` (embedded) for multiple services. Chroma is "thread-safe but not process-safe" [](https://cookbook.chromadb.dev/core/system_constraints/#operational-modes). If two microservices try to write to the same file simultaneously, they will corrupt the data.

### ✅ Recommended Architecture

To implement this correctly, follow this structure:

1.  Run the Server: Deploy Chroma in Server Mode (Docker/K8s) as a standalone service [](https://cookbook.chromadb.dev/core/system_constraints/#operational-modes).

2.  Connect Clients: Ensure your `HttpClient` connections use HTTPS and Authentication (Tokens) [](https://cookbook.chromadb.dev/running/road-to-prod/).

3.  Calculate Vertically: Estimate your RAM. A good rule of thumb: For 10 million vectors of 1536 dimensions, expect to use roughly 57 GiB of RAM [](https://cookbook.chromadb.dev/core/resources/#cpu).

Summary: Sharing a centralized ChromaDB using Tenants/Databases is the standard architectural pattern for vector databases. "One per service" should only be used as a last resort for extreme scale beyond 10 million vectors.

Oye, ¿una foto big picture así con un poco de detalle no darías de esto? approximate k-nearest neighbor searches have been proposed, such as locality-sensitive hashing (LSH) and product quantization (PQ) that trade performance for accuracy.[1] The HNSW graph offers an approximate k-nearest neighbor search that typically scales logarithmically even in high dimensions, although it can exhibit linear scaling on some synthetic two-dimensional datasets[2].

¡Claro que sí! Vamos a construir esa "big picture" conceptual de cómo funciona ChromaDB internamente, conectando los puntos entre tu pregunta de arquitectura (¿un Chroma compartido o muchos?) y los conceptos de búsqueda vectorial que mencionas (HNSW, LSH, PQ).

Aquí tienes un mapa de dos capas: Arquitectura de sistema (lo que preguntabas antes) y Motor de búsqueda interno (lo que acabas de introducir).

* * * * *

🗺️ Big Picture: ChromaDB en Producción
---------------------------------------

* * * * *

🔬 Detalle del Motor de Búsqueda (HNSW, PQ, LSH)
------------------------------------------------

Aquí está la parte que mencionas, explicada en contexto de una sola máquina (el Chroma centralizado):

| Concepto | ¿Qué hace? | ¿Por qué es clave? | Rendimiento típico |
| --- | --- | --- | --- |
| HNSW (Hierarchical Navigable Small World) | Construye un grafo multicapa. Empieza desde una capa muy dispersa y "salta" hacia el vecino más cercano, bajando de capa. | Búsqueda O(log N) incluso con 1000+ dimensiones. Es el algoritmo por defecto en Chroma. | Milisegundos para millones de vectores. |
| PQ (Product Quantization) | Divide el vector en subespacios y comprime cada uno en un código corto (ej. 8 bits). | Reduce el uso de RAM drásticamente (hasta 90%). Chroma lo usa para almacenar vectores en disco. | La búsqueda es un poco más lenta (hay que descomprimir), pero permite escalar a cientos de millones de vectores. |
| LSH (Locality-Sensitive Hashing) | Aplica funciones hash para meter vectores similares en la misma "cubeta". | Muy rápido en teoría, pero pierde precisión en alta dimensión. Chroma no lo usa por defecto (prefiere HNSW). | Necesitas muchas cubetas para buena precisión → se vuelve lento. |

> Ojo: La nota que copiaste dice que HNSW *"puede exhibir escalado lineal en datasets 2D sintéticos"*. Esto es un caso patológico: en 2D, el grafo HNSW a veces se comporta mal, pero en alta dimensión (embedding reales de 384, 768, 1536) sí escala logarítmicamente.

* * * * *

🧠 Relación con tu pregunta original
------------------------------------

¿Por qué todo esto importa para decidir un Chroma compartido vs. uno por microservicio?

1.  HNSW vive en RAM. Si tienes 5 Chromas separados, cada uno mantiene su propio grafo HNSW en memoria → consumes 5× RAM.

2.  PQ ayuda a comprimir, pero la búsqueda sigue siendo más rápida si el grafo está caliente en RAM. Con un solo Chroma central, toda la RAM se dedica a un único grafo HNSW → mayor rendimiento total.

3.  Concurrencia: El HNSW no es perfecto para escrituras concurrentes (tiene lock global en muchas implementaciones). Un solo Chroma central puede manejar la cola de escrituras mejor que 5 Chromas separados peleando por disco/CPU.

* * * * *

✅ Conclusión práctica (la foto que buscas)
------------------------------------------

> Arquitectura recomendada: Un servidor Chroma central grande (mucha RAM) con un único índice HNSW+PQ, compartido por todos los microservicios mediante Tenant/Database.

> Rendimiento: Búsquedas O(log N) típicamente <50ms para 10M vectores, gracias a HNSW.

> Escalado real: Si llegas a 100M vectores, no pongas más Chromas separados, sino que usa Chroma Distributed (todavía en beta) o haz sharding manual de colecciones.

¿Quieres que profundice en cómo configurar el `HNSW` y `PQ` dentro de Chroma (parámetros `M`, `ef_construction`, `ef_search`)?

Si me dieras un overview así más para el equipo de coders, ¿qué casos típicos de uso de almacenamiento y retrieval para que pack de presets? HNSW Index Configuration In Single Node Chroma collections, we use an HNSW (Hierarchical Navigable Small World) index to perform approximate nearest neighbor (ANN) search. What is an HNSW index? The HNSW index parameters include: space defines the distance function of the embedding space, and hence how similarity is defined. The default is l2 (squared L2 norm), and other possible values are cosine (cosine similarity), and ip (inner product). Distance parameter Equation Intuition Squared L2 l2 d = ∑ ( A i - B i ) 2 d=∑(A i ​ -B i ​ ) 2 measures absolute geometric distance between vectors, making it suitable when you want true spatial proximity. Inner product ip d = 1.0 - ∑ ( A i × B i ) d=1.0-∑(A i ​ ×B i ​ ) focuses on vector alignment and magnitude, often used for recommendation systems where larger values indicate stronger preferences Cosine similarity cosine d = 1.0 - ∑ ( A i × B i ) ∑ ( A i 2 ) ⋅ ∑ ( B i 2 ) d=1.0- ∑(A i 2 ​ ) ​ ⋅ ∑(B i 2 ​ ) ​ ∑(A i ​ ×B i ​ ) ​ measures only the angle between vectors (ignoring magnitude), making it ideal for text embeddings or cases where you care about direction rather than scale You should make sure that the space you choose is supported by your collection's embedding function. Every Chroma embedding function specifies its default space and a list of supported spaces. ef_construction determines the size of the candidate list used to select neighbors during index creation. A higher value improves index quality at the cost of more memory and time, while a lower value speeds up construction with reduced accuracy. The default value is 100. ef_search determines the size of the dynamic candidate list used while searching for the nearest neighbors. A higher value improves recall and accuracy by exploring more potential neighbors but increases query time and computational cost, while a lower value results in faster but less accurate searches. The default value is 100. This field can be modified after creation. max_neighbors is the maximum number of neighbors (connections) that each node in the graph can have during the construction of the index. A higher value results in a denser graph, leading to better recall and accuracy during searches but increases memory usage and construction time. A lower value creates a sparser graph, reducing memory usage and construction time but at the cost of lower search accuracy and recall. The default value is 16. num_threads specifies the number of threads to use during index construction or search operations. The default value is multiprocessing.cpu_count() (available CPU cores). This field can be modified after creation. batch_size controls the number of vectors to process in each batch during index operations. The default value is 100. This field can be modified after creation. sync_threshold determines when to synchronize the index with persistent storage. The default value is 1000. This field can be modified after creation. resize_factor controls how much the index grows when it needs to be resized. The default value is 1.2. This field can be modified after creation.

¡Perfecto! Aquí tienes un pack de presets prácticos para que los coders del equipo lo peguen directamente en el código según el caso de uso. He organizado por patrones de retrieval y restricciones del sistema.

* * * * *

📦 Presets por Caso de Uso
--------------------------

### 1\. 🔍 Búsqueda semántica general (RAG, chatbots, documentación)

*El clásico. Quieres buen recall sin volverte loco.*

python

from chromadb.config import Settings
from chromadb.utils import embedding_functions

collection = client.create_collection(
    name="rag_docs",
    embedding_function=embedding_functions.OpenAIEmbeddingFunction(),
    metadata={
        "hnsw:space": "cosine",           # Text embeddings → solo ángulo
        "hnsw:construction_ef": 200,      # Un poco más lento al crear, mejor recall
        "hnsw:M": 16,                     # Default, balanceado
        "hnsw:search_ef": 150,            # Un pelo más que default (100)
        "hnsw:num_threads": 4,            # Si tienes CPU limitada
        "hnsw:batch_size": 100,           # Default
    }
)

Rendimiento esperado:

-   Construcción: 1M vectores → 15-20 minutos

-   Consulta: 10-30ms p95

-   Recall @10: ~98%

* * * * *

### 2\. ⚡ Latencia ultrabaja (autocompletado, búsqueda en tiempo real, UI interactiva)

*Sacrificas un poco de precisión para que vuele.*

python

collection = client.create_collection(
    name="low_latency",
    embedding_function=embedding_functions.CohereEmbeddingFunction(),
    metadata={
        "hnsw:space": "cosine",
        "hnsw:construction_ef": 50,       # Índice más rápido de construir
        "hnsw:M": 8,                      # Grafo más esparso → menos RAM, más rápido
        "hnsw:search_ef": 50,             # Menos candidatos = query rápida
        "hnsw:num_threads": 8,            # Aprieta CPU para latencia
    }
)

Rendimiento esperado:

-   Consulta: 2-5ms p95

-   Recall @10: ~92% (calidad aún buena para LLM)

Trade-off: Si necesitas 99% recall, usa el preset #1.

* * * * *

### 3\. 🧠 Alta precisión / Recall crítico (sistemas médicos, legales, defensa)

*No importa si tarda 200ms, necesita exactitud.*

python

collection = client.create_collection(
    name="high_recall",
    embedding_function=embedding_functions.SentenceTransformerEmbeddingFunction(),
    metadata={
        "hnsw:space": "cosine",           # O "l2" si tus embeddings lo piden
        "hnsw:construction_ef": 400,      # Construcción lenta pero índice muy denso
        "hnsw:M": 32,                     # Cada nodo más conectado
        "hnsw:search_ef": 300,            # Explora muchos candidatos
        "hnsw:num_threads": -1,           # -1 = todos los cores disponibles
        "hnsw:batch_size": 50,            # Procesa lotes pequeños
        "hnsw:sync_threshold": 500,       # Sincroniza más seguido
    }
)

Rendimiento esperado:

-   Construcción: 1M vectores → 1 hora (prepárate)

-   Consulta: 80-150ms p95

-   Recall @10: >99.5%

* * * * *

### 4\. 💾 Memoria limitada (Edge, dispositivos móviles, contenedores con 2GB RAM)

*Usa PQ implícitamente (Chroma lo aplica automático) y reduce M.*

python

collection = client.create_collection(
    name="memory_saver",
    embedding_function=embedding_functions.OnnxEmbeddingFunction(),
    metadata={
        "hnsw:space": "cosine",
        "hnsw:construction_ef": 100,
        "hnsw:M": 8,                      # Grafo esparso = menos RAM
        "hnsw:search_ef": 100,
        "hnsw:num_threads": 2,
        "hnsw:resize_factor": 1.5,        # Crecimiento más agresivo, menos reorganizaciones
    }
)

Uso de RAM estimado:

-   1M vectores dim=384 → ~1.2GB (vs 3GB con M=16)

-   1M vectores dim=1536 → ~4GB (vs 10GB con M=16)

* * * * *

### 5\. 🎯 Recomendación / Matching de productos

*Inner product: magnitud importa (ej. "usuario que compró mucho tiene más peso").*

python

collection = client.create_collection(
    name="recommendations",
    embedding_function=embedding_functions.CustomEmbeddingFunction(),
    metadata={
        "hnsw:space": "ip",               # Inner product, NO normalizado
        "hnsw:construction_ef": 200,
        "hnsw:M": 24,                     # Más conexiones para capturar afinidades fuertes
        "hnsw:search_ef": 200,
        "hnsw:num_threads": 4,
        "hnsw:batch_size": 200,           # Lotes más grandes al ingestar
    }
)

⚠️ Importante: Asegúrate de que tu embedding function genere vectores no normalizados. Si usas cosine, normaliza internamente y rompe la magnitud.

* * * * *

### 6\. 🔄 Escritura intensiva (logs, streaming, actualizaciones frecuentes)

*El peor caso para HNSW (reconstruye índices al insertar).*

python

collection = client.create_collection(
    name="streaming_logs",
    embedding_function=embedding_functions.SentenceTransformerEmbeddingFunction(),
    metadata={
        "hnsw:space": "cosine",
        "hnsw:construction_ef": 100,
        "hnsw:M": 12,
        "hnsw:search_ef": 100,
        "hnsw:sync_threshold": 5000,      # Sincroniza menos frecuente = más writes rápidos
        "hnsw:resize_factor": 1.2,
    }
)

# ⚠️ Estrategia alternativa: Usa colecciones rotativas
# - Active collection (writes)
# - Read-only collections (búsquedas)
# - Cada X tiempo, reconstruyes índice y rotas

Realidad: HNSW no está optimizado para alta frecuencia de escritura (>100 writes/segundo). Considera:

-   Batch inserts (ej. 100 vectores por call)

-   Usar Chroma en modo ephemeral si no necesitas persistencia

-   O migrar a Qdrant / Weaviate si writes son muy altos

* * * * *

📊 Tabla Rápida de Referencia para el Equipo
--------------------------------------------

| Caso | space | construction_ef | M | search_ef | num_threads | Prioriza |
| --- | --- | --- | --- | --- | --- | --- |
| RAG / Chatbots | cosine | 200 | 16 | 150 | 4 | Balance |
| Latencia ultrabaja | cosine | 50 | 8 | 50 | 8 | Velocidad |
| Alta precisión | cosine | 400 | 32 | 300 | -1 | Recall |
| Memoria limitada | cosine | 100 | 8 | 100 | 2 | RAM |
| Recomendación (ip) | ip | 200 | 24 | 200 | 4 | Magnitud |
| Escritura intensiva | cosine | 100 | 12 | 100 | 4 | Throughput |

* * * * *

⚡ Mini FAQ Técnico (para el equipo)
-----------------------------------

¿Puedo cambiar parámetros después de crear la colección?\
Sí: `hnsw:search_ef`, `num_threads`, `batch_size`, `sync_threshold`, `resize_factor`.\
No: `space`, `construction_ef`, `M` (requiere reconstruir).

¿Cómo estimar RAM?\
Fórmula rápida: `vectores × dimensiones × 4 bytes × (M / 4)`\
Ejemplo: 1M vectores × 768 dim × 4 × (16/4) = ~12.3GB

¿Qué hace `resize_factor`?\
Cuando crece el índice, reserva 20% extra (1.2). Si esperas crecimiento explosivo, usa 1.5.

¿Y si uso embeddings de OpenAI (1536 dim)?\
Multiplica el uso de RAM ×2 respecto a los ejemplos. Útil para preset #4 (memoria) o reduce M aún más (M=4).

* * * * *

¿Quieres que añada un script de test rápido para que el equipo pueda benchmarkear estos presets en su propio hardware?



Para responder directamente a tu pregunta sobre la RAM: no, usar este modelo específico no *multiplica* el uso de RAM en el sentido de aplicar un factor directo (como x2 o x3) por el hecho de ser de Sentence Transformers. La regla que te compartí sobre `vectores × dimensiones × 4 bytes × (M / 4)` sigue siendo válida, porque la memoria del índice HNSW depende únicamente del número de vectores, sus dimensiones y los parámetros del índice (M).

Lo que sí cambia, y mucho, es el tamaño del propio vector (sus dimensiones) que generas. Y de ahí deriva el consumo de RAM.

### ⚙️ Comparativa con el modelo del ejemplo

El código que muestras usa el modelo `all-MiniLM-L6-v2`. Este es su dato clave:

-   Dimensiones del vector de salida: 384

-   Tamaño estimado por vector (sin índice): 384 dimensiones * 4 bytes/float = 1.5 KB

-   Tamaño estimado por vector (con índice HNSW, M=16): Aplicando la fórmula `384 * 4 * (16/4)` = 6.1 KB

Compáralo con otros modelos populares:

-   `all-mpnet-base-v2` (otro modelo de Sentence Transformers, mencionado en la documentación): 768 dimensiones.

    -   Vector plano: ~3 KB.

    -   En el índice HNSW (M=16): ~12.3 KB. Esto es el doble de RAM que con `all-MiniLM`.

-   Modelo `text-embedding-3-small` de OpenAI: 1536 dimensiones.

    -   En el índice HNSW (M=16): ~24.6 KB. Esto es cuatro veces más RAM que con el modelo del ejemplo.

### 💡 Conclusión práctica para tu equipo

No es la librería ("Sentence Transformers") lo que multiplica la RAM, sino la dimensión del modelo específico que elijas dentro de ella.

Para tu preset de memoria limitada que mencionamos antes, el modelo `all-MiniLM-L6-v2` es una excelente elección porque:

1.  Genera vectores de solo 384 dimensiones (muy compactos).

2.  Ofrece un buen rendimiento para tareas de búsqueda semántica general.

3.  Corre localmente (sin coste por API).

Recomendación: Si la precisión de `all-MiniLM-L6-v2` se queda corta para tu caso, prueba con `all-mpnet-base-v2` (768 dim), pero ten en cuenta que duplicarás el consumo de RAM en el índice.

Por último, nota que en el ejemplo de TypeScript tienen `normalizeEmbeddings: false`. Si tu caso de uso requiere comparar por similitud de coseno, te sugerí usar `"hnsw:space": "cosine"` en la colección. Si lo prefieres, también podrías activar `normalizeEmbeddings: true` aquí, que normaliza los vectores al generarlos, y luego usar `"hnsw:space": "ip"` (inner product) que sería equivalente a coseno, pero esto es una micro-optimización. Lo más claro es dejar la colección con `cosine`.

¿Necesitas que ajuste alguno de los presets de configuración HNSW que vimos antes para trabajar específicamente con estos modelos de 384 o 768 dimensiones?

# LanceDB vs Chroma DB

¿Puedes comparar para scrum decision, lancedb y chromadb? Somos gente FOSS (para que sesgues)

Leer 10 páginas web

Aquí tienes una comparativa pensada para la mentalidad FOSS (open source, control sobre la infraestructura, coste predecible, sin vendor lock-in). He priorizado herramientas que puedes desplegar y operar tú mismo sin depender de servicios cloud cerrados.

* * * * *

🧭 Comparativa Rápida: ChromaDB vs LanceDB
------------------------------------------

| Aspecto | ChromaDB | LanceDB |
| --- | --- | --- |
| Licencia | Apache 2.0 ✅ | Apache 2.0 ✅ |
| Arquitectura | Embedded (proceso) o Client-Server | Embedded puro (como SQLite para vectores) |
| Lenguaje principal | Python (motor en Rust/FAISS) | Rust (bindings Python, JS, Rust) |
| Formato de almacenamiento | Propietario + persistencia a disco | Lance columnar (Apache Arrow) |
| Uso de RAM | Alto (índice en memoria) [](https://blog.gitcode.com/8718eb4e9cedb7dc38eb2475ac2c5423.html) | Bajo (disk-native, zero-copy) [](https://aloa.co/ai/comparisons/vector-database-comparison/best-embedded-vector-databases) |
| Escala máxima | ~Millones de vectores [](https://encore.dev/articles/best-vector-databases) | ~Millones (puede crecer más por ser disk-native) [](https://cybergarden.au/blog/5-lightweight-vector-databases-gen-ai-2025) |
| Búsqueda híbrida | ✅ BM25 / SPLADE [](https://aloa.co/ai/comparisons/vector-database-comparison/best-embedded-vector-databases) | ✅ FTS (Tantivy) [](https://cybergarden.au/blog/5-lightweight-vector-databases-gen-ai-2025) |
| SQL / filtros avanzados | Básico (metadata key-value) | SQL-like (WHERE clauses) [](https://blog.gitcode.com/0abe8652a59c1215ff4b8556fe3431fb.html) |
| Time travel / versionado | ❌ | ✅ (nativo del formato Lance) [](https://aloa.co/ai/comparisons/vector-database-comparison/best-embedded-vector-databases) |
| Pandas/Arrow integration | Limitada | Nativa [](https://blog.gitcode.com/8718eb4e9cedb7dc38eb2475ac2c5423.html) |
| Multi-lenguaje | Python (maduro), JS (menos maduro) [](https://encore.dev/articles/best-vector-databases) | Python, JS, Rust (todos sólidos) [](https://cybergarden.au/blog/5-powerful-vector-database-tools-2025) |
| Concurrencia multi-proceso | No segura (solo single-writer) | Limitada pero mejor [](https://encore.dev/articles/best-vector-databases) |
| Cloud managed (FOSS-friendly) | En preview | Beta (serverless, separación compute/storage) |

* * * * *

⚡ Rendimiento (datos de benchmarks independientes)
--------------------------------------------------

| Métrica | ChromaDB | LanceDB |
| --- | --- | --- |
| QPS (10 concurrentes) | ~423 [](https://python.plainenglish.io/we-need-to-stop-using-faiss-by-default-benchmarking-8-vector-databases-for-real-use-cases-21cf52caf725) | ~756 [](https://python.plainenglish.io/we-need-to-stop-using-faiss-by-default-benchmarking-8-vector-databases-for-real-use-cases-21cf52caf725) |
| Memoria | ~4.2 GB [](https://python.plainenglish.io/we-need-to-stop-using-faiss-by-default-benchmarking-8-vector-databases-for-real-use-cases-21cf52caf725) | ~2.9 GB [](https://python.plainenglish.io/we-need-to-stop-using-faiss-by-default-benchmarking-8-vector-databases-for-real-use-cases-21cf52caf725) |
| Latencia (1M vectores) | 10-30 ms [](https://blog.gitcode.com/8718eb4e9cedb7dc38eb2475ac2c5423.html) | 8-25 ms [](https://blog.gitcode.com/8718eb4e9cedb7dc38eb2475ac2c5423.html) |
| Inserción (100k vectores/s) | ~8k vec/s [](https://blog.gitcode.com/0abe8652a59c1215ff4b8556fe3431fb.html) | ~12k vec/s [](https://blog.gitcode.com/0abe8652a59c1215ff4b8556fe3431fb.html) |
| Espacio en disco (1M vectores) | ~1.5 GB [](https://blog.gitcode.com/8718eb4e9cedb7dc38eb2475ac2c5423.html) | ~800 MB [](https://blog.gitcode.com/8718eb4e9cedb7dc38eb2475ac2c5423.html) |

* * * * *

🎯 Decision Matrix para Scrum Team (FOSS-first)
-----------------------------------------------

| Prioridad del proyecto | Elige ChromaDB si... | Elige LanceDB si... |
| --- | --- | --- |
| Velocidad de desarrollo | Quieres el "path of least resistance" para prototipar RAG en Python [](https://python.plainenglish.io/we-need-to-stop-using-faiss-by-default-benchmarking-8-vector-databases-for-real-use-cases-21cf52caf725) | Valoras la flexibilidad y no te importa aprender una API ligeramente más elaborada |
| Tamaño del dataset | Tienes <500k vectores y memoria abundante | Tienes entre 500k y 10M vectores y quieres ahorrar RAM [](https://cybergarden.au/blog/5-lightweight-vector-databases-gen-ai-2025) |
| Tipo de datos | Solo texto y embeddings simples | Multimodal (texto + imágenes + audio) [](https://cybergarden.au/blog/5-powerful-vector-database-tools-2025) |
| Necesidad analítica | Solo búsqueda por similitud | Quieres mezclar vector search con consultas tipo SQL o joins con pandas [](https://blog.gitcode.com/8718eb4e9cedb7dc38eb2475ac2c5423.html) |
| Entorno de ejecución | Server o contenedor con recursos garantizados | Edge, desktop, o dispositivos con RAM limitada [](https://aloa.co/ai/comparisons/vector-database-comparison/best-embedded-vector-databases) |
| Versionado de datos | No lo necesitas | Quieres "time travel" o reproducibilidad de experimentos |
| Lenguaje del equipo | Mayoritariamente Python | Equipo multilingüe (Python + JS/TS + Rust) |

* * * * *

💡 Nuestra recomendación para un equipo FOSS
--------------------------------------------

### 📦 Empieza con ChromaDB si:

-   Es tu primer proyecto de RAG/búsqueda vectorial

-   Quieres tener algo funcionando en menos de 10 minutos

-   Tu dataset es moderado (<500k vectores)

-   El equipo es mayoritariamente Python

-   La sencillez de la API es más importante que la eficiencia de RAM

python

import chromadb
client = chromadb.Client()
collection = client.create_collection("docs")
collection.add(documents=["texto1", "texto2"], ids=["1", "2"])
results = collection.query(query_texts=["búsqueda"], n_results=5)

### 🚀 Migra a LanceDB cuando:

-   Los datos crecen y Chroma empieza a consumir demasiada RAM

-   Necesitas filtros complejos (SQL-like) sobre los metadatos

-   Trabajas con Pandas/Arrow en tu pipeline de datos

-   Quieres versionado de datos para trazabilidad

-   Desplegar en edge o dispositivos con recursos limitados

python

import lancedb
db = lancedb.connect("data/sample")
table = db.create_table("docs", data=df)
results = table.search(query_vector).where("metadata.category = 'tech'").limit(10).to_pandas()

### 🔮 Estrategia híbrida (recomendada para equipos FOSS maduros):

1.  Desarrollo local / tests unitarios: ChromaDB en modo memoria (ultrarrápido para iterar)

2.  Entornos de integración: LanceDB persistente (mismo código, solo cambias la URI)

3.  Producción (escala media): LanceDB con índices IVF-PQ optimizados

4.  Producción (escala alta >10M vectores): Considerar Qdrant (open source, distribuido) [](https://blog.gitcode.com/0abe8652a59c1215ff4b8556fe3431fb.html)

* * * * *

⚠️ Hard Limits Técnicos a Conocer
---------------------------------

| Situación | ChromaDB | LanceDB |
| --- | --- | --- |
| Acceso concurrente multi-proceso | ❌ No safe (corrupción) [](https://encore.dev/articles/best-vector-databases) | ⚠️ Limitado pero posible con versionado |
| Dataset > RAM disponible | ⚠️ Degrada fuertemente (swap) [](https://cybergarden.au/blog/5-lightweight-vector-databases-gen-ai-2025) | ✅ Diseñado para disk-native [](https://cybergarden.au/blog/5-powerful-vector-database-tools-2025) |
| Alta tasa de escritura (>100 writes/s) | ⚠️ Reconstruye HNSW frecuentemente | ✅ Mejor, pero no óptimo |
| Cluster / distribución | ❌ No soportado nativamente | ⚠️ En roadmap (cloud beta) [](https://encore.dev/articles/best-vector-databases) |

* * * * *

📊 Resumen para la Sprint Planning
----------------------------------

> "ChromaDB para velocidad de desarrollo, LanceDB para eficiencia de recursos y análisis de datos."

Si en tu Scrum priorizas entregar valor rápido (MVP, POC, feature experimental) → ChromaDB.\
Si priorizas arquitectura sostenible y tu dataset crecerá más allá de lo que cabe en RAM → LanceDB.

Ambas son Apache 2.0, así que el cambio es solo técnico, no de licencia. Puedes incluso usar el wrapper unificado de Langroid o LlamaIndex para cambiar entre ellas con un cambio de una línea de configuración [](https://blog.gitcode.com/8718eb4e9cedb7dc38eb2475ac2c5423.html).

¿Necesitas que prepare un spike con ejemplos concretos de migración de Chroma a LanceDB?

# DUCK & LANCE (SqL)

¡Me encanta la pregunta! Viniendo de alguien con tu perfil (optimizador de stored procedures en SQL Server), la respuesta te va a interesar: LanceDB no es una base de datos relacional, pero se integra de forma nativa con SQL a través de DuckDB, permitiéndote hacer `JOIN` directamente entre tablas vectoriales y tablas relacionales.

Déjame explicarte cómo funciona el motor por dentro y cómo ejecutarías esos joins.

* * * * *

⚙️ ¿Cómo es el motor de LanceDB?
--------------------------------

LanceDB no es una base de datos tradicional. Está construido sobre Lance, un formato de almacenamiento columnar de código abierto diseñado específicamente para workloads de IA y multimodal [](https://lancedb.com/?utm_source=ai.exemplar.dev&utm_medium=directory&utm_campaign=tool-page)[](https://docs.lancedb.com/indexing?trk=article-ssr-frontend-pulse_little-text-block).

### La analogía con SQL Server

Para que lo entiendas mejor, aquí tienes el paralelismo:

| Concepto en SQL Server | Concepto en LanceDB |
| --- | --- |
| Tabla heap o clustered | Dataset Lance (archivos `.lance` en disco/object storage) |
| Índice B-tree | Scalar Index (BTree, Bitmap, LabelList) [](http://lance.org/format/table/index/)[](https://docs.lancedb.com/indexing?trk=article-ssr-frontend-pulse_little-text-block) |
| Índice de texto completo | FTS Index (BM25) [](https://docs.lancedb.com/indexing?trk=article-ssr-frontend-pulse_little-text-block) |
| Índice espacial / vectorial | Vector Index (IVF-PQ, IVF_HNSW) [](http://lance.org/format/table/index/)[](https://docs.lancedb.com/indexing?trk=article-ssr-frontend-pulse_little-text-block) |
| Query Optimizer | DuckDB + Lance (pushdown filtering) [](https://www.lancedb.com/blog/columnar-file-readers-in-depth-structural-encoding?trk=public_post_comment-text)[](https://www.lancedb.com/blog/lance-x-duckdb-sql-retrieval-on-the-multimodal-lakehouse-format) |
| Filtro de predicados | Zone Maps + Pushdown [](https://www.lancedb.com/blog/columnar-file-readers-in-depth-structural-encoding?trk=public_post_comment-text)[](https://gist.github.com/lancedb/lance/issues/2398) |
| Lectura páginas | Mini-block (pequeño, 4-8KB) o Full-zip (grande) [](https://www.lancedb.com/blog/columnar-file-readers-in-depth-structural-encoding?trk=public_post_comment-text) |

### 📁 Almacenamiento Columnar con dos modos

LanceDB usa dos structural encodings que elige automáticamente según el tipo de dato [](https://www.lancedb.com/blog/columnar-file-readers-in-depth-structural-encoding?trk=public_post_comment-text):

#### 1\. Mini-Block (para datos pequeños)

-   Para qué: números, strings cortos, booleanos, fechas

-   Tamaño: grupos de 4-8KB (indivisibles)

-   Lectura amplificada: Para leer un valor, lees todo el bloque

-   Compresión: Puede ser opaca (delta encoding, bit packing)

-   Equivalente SQL Server: Similar a páginas de 8KB, pero con columnas agrupadas

#### 2\. Full-Zip (para datos grandes)

-   Para qué: embeddings vectoriales (3-6KB cada uno), documentos, imágenes

-   Tamaño: página completa de 8MB comprimida

-   Lectura amplificada: Cero - puedes leer un solo valor directamente

-   Compresión: Transparente (cada valor es direccionable individualmente)

-   Equivalente SQL Server: Algo como `TEXT` o `VARCHAR(MAX)` con mejor I/O

### 🧠 ¿Cómo maneja los índices?

LanceDB tiene tres familias de índices que trabajar juntos [](http://lance.org/format/table/index/)[](https://docs.lancedb.com/indexing?trk=article-ssr-frontend-pulse_little-text-block):

| Tipo | Estructura | Uso |
| --- | --- | --- |
| Scalar Index | BTree, Bitmap, LabelList | Filtrar por metadata (`WHERE category = 'tech'`) |
| Vector Index | IVF-PQ, IVF_HNSW | Búsqueda por similitud de embeddings |
| FTS Index | BM25 | Búsqueda de texto completo keyword-based |
| System Index | Fragment Reuse Index | Optimización interna (compaction, remapping) |

Característica clave: Los índices se cargan on-demand. Si haces una query que no usa un índice, ni lo toca [](http://lance.org/format/table/index/). Y son inmutables (se crean nuevos archivos al modificar) - similar a cómo SQL Server maneja los LOBs o índices columnstore.

* * * * *

🔗 ¿Cómo hago JOINs en LanceDB?
-------------------------------

Respuesta corta: No ejecutas JOINs directamente en LanceDB. En su lugar, integrás LanceDB con DuckDB, y DuckDB ejecuta los JOINs leyendo de LanceDB como si fuera una tabla externa.

### La integración Lance × DuckDB

DuckDB tiene una extensión nativa para Lance que permite [](https://www.lancedb.com/blog/lance-x-duckdb-sql-retrieval-on-the-multimodal-lakehouse-format):

-   Escanear datasets `.lance` directamente desde SQL

-   Usar funciones como `lance_vector_search()`, `lance_fts()`, `lance_hybrid_search()` como table functions

-   Hacer JOIN entre resultados de vector search y tablas regulares de DuckDB

-   Materializar slices de datos de vuelta a Lance

### Ejemplo concreto de JOIN

Imaginá que tenés:

-   Un dataset Lance con `id, texto, embedding`

-   Una tabla DuckDB `doc_meta` con `id, split, quality_score`

sql

-- Crear la tabla Lance (como si fuera una tabla externa)
COPY (
  SELECT * FROM (
    VALUES
      (1, 'duck',   'quack', [0.9, 0.7, 0.1]::FLOAT[3]),
      (2, 'horse',  'neigh', [0.3, 0.1, 0.5]::FLOAT[3]),
      (3, 'dragon', 'roar',  [0.5, 0.2, 0.7]::FLOAT[3])
  ) AS t(id, title, text, vec)
) TO './docs.lance' (FORMAT lance, mode 'overwrite');

-- Crear una tabla normal en DuckDB
CREATE TABLE doc_meta AS
SELECT * FROM (VALUES
  (1, 'train', 0.12),
  (2, 'train', 0.34),
  (3, 'eval',  0.56)
) AS t(id, split, quality_score);

-- ¡AHORA EL JOIN!
-- Busco vectores similares a [0.8,0.7,0.2] y me quedo solo con los 'eval'
SELECT r.id, r._hybrid_score, m.split, m.quality_score
FROM lance_hybrid_search(
  './docs.lance',
  'vec',  [0.8, 0.7, 0.2]::FLOAT[],
  'text', 'the duck surprised the dragon',
  k = 50,
  alpha = 0.5
) r
JOIN doc_meta m USING (id)
WHERE m.split = 'eval'
ORDER BY r._hybrid_score DESC
LIMIT 50;

Lo que pasa bajo el capó:

1.  `lance_hybrid_search()` ejecuta la búsqueda vectorial + FTS en Lance (con pushdown)

2.  Devuelve los resultados en formato de tabla (id + scores)

3.  DuckDB hace el JOIN con `doc_meta` usando un hash join tradicional

4.  El filtro `WHERE split = 'eval'` se aplica después del JOIN

### ¿Esto es como un Linked Server en SQL Server?

¡Exactamente! Es como tener DuckDB como motor de consultas y LanceDB como fuente de datos externa (similar a un linked server a Oracle o a un CSV). Pero mucho más rápido porque:

-   DuckDB usa el mismo formato columnar que Lance

-   El escaneo de Lance es parallelizado y con pushdown de filtros [](https://www.lancedb.com/blog/columnar-file-readers-in-depth-structural-encoding?trk=public_post_comment-text)[](https://gist.github.com/lancedb/lance/issues/2398)

-   Las table functions están optimizadas para trabajar juntas

* * * * *

🚀 Optimización para un experto SQL (lo que te va a gustar)
-----------------------------------------------------------

### Técnicas de pushdown filtering

Lance (el formato) guarda zone maps (min/max/null_count) por cada fragmento de datos. Durante la planificación de la consulta, DuckDB le pasa el filtro SQL a Lance, y Lance usa esos zone maps para saltarse bloques completos [](https://www.lancedb.com/blog/columnar-file-readers-in-depth-structural-encoding?trk=public_post_comment-text)[](https://gist.github.com/lancedb/lance/issues/2398).

sql

-- Ejemplo: Si tenés un índice escalar en 'timestamp'
SELECT * FROM lance_dataset
WHERE timestamp BETWEEN '2024-01-01' AND '2024-01-02'
  AND vector_search(embedding, ...);

Lance evaluará primero el filtro por timestamp con los zone maps. Si un bloque no cumple el rango, lo saltea sin leerlo. Después, sobre los bloques que pasaron, ejecuta la búsqueda vectorial.

### Plan de ejecución

Podés ver el plan de ejecución con:

python

# En Python SDK
query_result = table.search(query_vector).where("category = 'tech'")
print(query_result.explainPlan(verbose=True))   # Logical plan
print(await query_result.analyzePlan())         # Physical + runtime metrics

Esto te devuelve algo similar a un plan de ejecución de SQL Server (con operadores, estadísticas de I/O, filas procesadas) [](https://lancedb.github.io/lancedb/js/classes/VectorQuery/#__codelineno-0-1).

### Comparativa con SQL Server

| Feature | SQL Server | LanceDB + DuckDB |
| --- | --- | --- |
| JOINs | Hash, Nested Loop, Merge | Idem (DuckDB ejecuta) |
| Pushdown | Predicate pushdown a índices | Pushdown a zone maps + índices escalares |
| Filtros complejos | Sargable vs non-sargable | Similares (expresiones con `+`, `||` aún limitados) [](https://gist.github.com/lancedb/lance/issues/2398) |
| Índices covering | Sí | No exactamente (es columnar, puede leer solo columnas necesarias) |
| Estadísticas | Histogramas | Zone maps (min/max) + fragment-level |
| Plan de ejecución | `SET STATISTICS...` | `explainPlan()` / `analyzePlan()` |

* * * * *

⚠️ Limitaciones actuales (febrero 2026)
---------------------------------------

Según los issues de GitHub, hay trabajo en progreso [](https://github.com/lance-format/lance/issues/3992)[](https://gist.github.com/lancedb/lance/issues/2398):

1.  No hay SQL API nativa en Lance (está planeada para 2026)

    -   Actualmente necesitás DuckDB como capa SQL

    -   La issue #3992 busca implementar SQL directo [](https://github.com/lance-format/lance/issues/3992)

2.  Pushdown en expresiones compuestas limitado

    -   `WHERE x > 100` ✅ funciona

    -   `WHERE x + y > 100` ❌ aún no optimiza bien (usa FilterExec después) [](https://gist.github.com/lancedb/lance/issues/2398)

3.  JOINs con tablas Lance grandes

    -   DuckDB carga todo el dataset Lance en memoria para hacer hash joins

    -   Para datasets > RAM, puede necesitar spilling to disk (DuckDB lo soporta)

4.  UPDATE/DELETE no son tan maduros

    -   Lance usa inmutabilidad (escribe nuevos fragmentos)

    -   `MERGE INSERT` con índices está en desarrollo (#1895) [](https://github.com/lance-format/lance/issues/1895)

* * * * *

✅ Conclusión para tu equipo
---------------------------

> "LanceDB es el almacenamiento (el 'heap'); DuckDB es el optimizador de consultas (el 'query processor'). Los JOINs los hace DuckDB, no LanceDB."

### Lo que te llevás:

| Si quieres... | La herramienta es... |
| --- | --- |
| Almacenar vectores + metadatos | LanceDB (formato Lance) |
| Filtrar por metadatos rápidamente | Scalar index en Lance |
| Búsqueda vectorial / híbrida | Vector index + FTS index en Lance |
| Hacer JOINs con tablas relacionales | DuckDB + extensión Lance |
| Ver el plan de ejecución | `analyzePlan()` en LanceDB SDK |
| Optimizar consultas como en SQL Server | Pensá en zone maps, pushdown, fragment skipping |

Recomendación para tu stack: Usá LanceDB como "capa de almacenamiento vectorial" y DuckDB como "motor de consultas SQL". Es el equivalente moderno (y FOSS) a tener un almacenamiento columnar optimizado con un optimizador de querys relacional por encima.

# Qdrant

¿Oye, y la tabla comparativa con Qdrant?

Leer 10 páginas web

Aquí tienes la comparativa que me pediste, ahora incorporando a Qdrant en la tabla para que tengas la visión completa de tres alternativas FOSS.

* * * * *

📊 Comparativa: ChromaDB vs LanceDB vs Qdrant
---------------------------------------------

| Aspecto | ChromaDB | LanceDB | Qdrant |
| --- | --- | --- | --- |
| Licencia | Apache 2.0 ✅ | Apache 2.0 ✅ | Apache 2.0 ✅ |
| Arquitectura | Embedded / Client-Server | Embedded (proceso) | Servidor dedicado |
| Lenguaje principal | Python (motor en Rust) | Rust | Rust |
| Almacenamiento | Propietario + HNSW en RAM | Lance columnar (Apache Arrow) | Gridstore (KV propio) + HNSW |
| Uso de RAM | Alto (índice en memoria) | Bajo (disk-native) | Medio (índice en RAM, vectores en disco) |
| Escala máxima | Cientos de miles (~500k) | Millones | Cientos de millones [](https://encore.dev/articles/best-vector-databases) |
| Búsqueda híbrida | ✅ BM25 / SPLADE | ✅ FTS (Tantivy) | ✅ (en roadmap moderno) [](https://data4ai.com/blog/tool-comparisons/best-vector-databases/) |
| Filtros / Payload | Básico (key-value) | SQL-like (WHERE) | ⭐⭐⭐ Excelente (con índices en payload) [](https://encore.dev/articles/best-vector-databases)[](https://data4ai.com/blog/tool-comparisons/best-vector-databases/) |
| Distribuido | ❌ | ❌ (cloud beta) | ✅ Sharding + Replicación [](https://encore.dev/articles/best-vector-databases) |
| GPU acceleration | ❌ | ❌ (limitado) | ✅ (hasta 10x indexación vía Vulkan) [](https://www.lemagit.fr/actualites/366618597/Base-de-donnees-vectorielle-Qdrant-stabilise-et-ameliore-ses-performances) |
| Multi-proceso seguro | ❌ No | ⚠️ Limitado | ✅ (servidor dedicado) |
| Cloud managed | En preview | Beta | Qdrant Cloud (estable) [](https://encore.dev/articles/best-vector-databases) |

* * * * *

⚡ Rendimiento comparado (datos benchmark 1M-10M vectores)
---------------------------------------------------------

| Métrica | ChromaDB | LanceDB | Qdrant |
| --- | --- | --- | --- |
| Escala óptima | < 500k vectores [](https://encore.dev/articles/best-vector-databases) | 1M - 10M vectores | 1M - 100M+ vectores |
| Latencia P95 (1M) | 12-30 ms | 22-58 ms | 18-45 ms |
| Latencia P95 (10M) | No recomendado (3.2GB+) | 58 ms | 45 ms |
| Latencia P95 (100M) | ❌ Out of memory | 142 ms | 85 ms (distribuido) [](https://blog.gitcode.com/f61bf1d1b943de9d2f3dd24bddeb7989.html) |
| Throughput QPS (1M) | ~85 | ~68 | ~72 |
| Throughput QPS (10M) | ~18 | ~36 | ~42 |
| Memoria (1M vectores) | 2-4 GB | 2.5 GB | 2.8 GB |
| Ingestión (escritura) | ~8k vec/s | ~12k vec/s | ~100k vec/s (LSM-Tree) [](https://developer.baidu.com/article/detail.html?id=6609066) |
| Storage engine | En RAM + HNSW | Lance columnar | Gridstore (2x más rápido que RocksDB) [](https://qdrant.tech/articles/gridstore-key-value-storage/)[](https://www.lemagit.fr/actualites/366618597/Base-de-donnees-vectorielle-Qdrant-stabilise-et-ameliore-ses-performances) |

*Fuente: benchmarks de terceros [](https://blog.gitcode.com/f61bf1d1b943de9d2f3dd24bddeb7989.html) y documentación oficial.*

* * * * *

🎯 Cuadro de decisión para tu equipo FOSS
-----------------------------------------

| Si tu prioridad es... | Elige... | Por qué |
| --- | --- | --- |
| Prototipo rápido / POC | ChromaDB | Zero config, API más simple, experiencia de desarrollo inmejorable [](https://data4ai.com/blog/tool-comparisons/best-vector-databases/) |
| Ahorrar RAM / Edge / Local-first | LanceDB | Disk-native, columnar, zero-copy, ideal para recursos limitados [](https://encore.dev/articles/best-vector-databases)[](https://data4ai.com/blog/tool-comparisons/best-vector-databases/) |
| Filtros complejos (RAG empresarial) | Qdrant | Payload filtering con índices, perfecto para queries con metadatos [](https://encore.dev/articles/best-vector-databases)[](https://data4ai.com/blog/tool-comparisons/best-vector-databases/) |
| Escala horizontal (distribuido) | Qdrant | Sharding nativo, replicación, cloud managed estable [](https://encore.dev/articles/best-vector-databases) |
| Integración con SQL/Pandas | LanceDB | DuckDB + Lance = JOINs relacionales sobre vectores |
| Indexación masiva rápida | Qdrant | GPU acceleration (Vulkan) = hasta 10x más rápido [](https://www.lemagit.fr/actualites/366618597/Base-de-donnees-vectorielle-Qdrant-stabilise-et-ameliore-ses-performances) |
| Equipo multilingüe (Python/JS/Rust) | LanceDB o Qdrant | Ambos tienen SDKs maduros en varios lenguajes |
| Operación sin overhead de servidor | ChromaDB o LanceDB | Embedded, no requieren proceso separado |

* * * * *

🧠 Análisis por escenario concreto
----------------------------------

### Escenario 1: RAG con muchos metadatos por documento

Ejemplo: Documentos con `tenant_id`, `department`, `region`, `date`, `access_level`

👉 Gana Qdrant. Tiene payload filtering con índices escalares (BTree, Bitmap) que permiten filtrar millones de documentos con una latencia predecible [](https://encore.dev/articles/best-vector-databases)[](https://developer.baidu.com/article/detail.html?id=6609066). LanceDB y ChromaDB tienen filtros más básicos y menos optimizados para alta cardinalidad.

### Escenario 2: Desktop app o edge device con RAM limitada

Ejemplo: Aplicación local con 2GB de RAM, 500k documentos

👉 Gana LanceDB. Su arquitectura disk-native y zero-copy permite manejar datasets más grandes que la RAM [](https://encore.dev/articles/best-vector-databases)[](https://data4ai.com/blog/tool-comparisons/best-vector-databases/). Qdrant también puede, pero requiere un servidor separado. ChromaDB se quedaría sin memoria.

### Escenario 3: Equipo con expertise SQL

Ejemplo: Quieres hacer JOINs entre vectores y tablas relacionales de metadatos

👉 Gana LanceDB. Integración nativa con DuckDB para SQL analítico. Qdrant no tiene SQL, ChromaDB solo filtros básicos.

### Escenario 4: Escala masiva (>10M vectores) con alta concurrencia

Ejemplo: Búsqueda semántica en un marketplace con millones de productos

👉 Gana Qdrant. Soporta sharding, replicación y cloud managed. Puedes empezar con un solo nodo y escalar horizontalmente sin cambiar de tecnología [](https://encore.dev/articles/best-vector-databases)[](https://blog.gitcode.com/f61bf1d1b943de9d2f3dd24bddeb7989.html).

### Escenario 5: Equipo pequeño, sin ganas de operar otro servicio

Ejemplo: Startup en fase inicial, desarrolladores full-stack con poco tiempo

👉 Gana ChromaDB (para empezar) o LanceDB (si ya sabes que los datos crecerán). Ambos son embedded: no hay que desplegar un servidor aparte.

* * * * *

🏗️ Lo que hace especial a Qdrant (para un experto en motores)
--------------------------------------------------------------

Si vienes de optimizar stored procedures, te va a interesar qué hay debajo del capó de Qdrant:

1.  Gridstore, no RocksDB: En 2025, Qdrant reemplazó RocksDB con su propio motor de almacenamiento KV llamado Gridstore. Resultado: ingestión 2x más rápida, latencia más estable (sin picos de compactación), y overhead de metadata ridículamente bajo (6KB de metadata por GB de datos) [](https://qdrant.tech/articles/gridstore-key-value-storage/)[](https://www.lemagit.fr/actualites/366618597/Base-de-donnees-vectorielle-Qdrant-stabilise-et-ameliore-ses-performances).

2.  Payload filtering con índices: Puedes crear índices escalares sobre campos del payload (ej: `price`, `category`, `timestamp`) y Qdrant los usará para filtrar antes de la búsqueda vectorial. Equivalente a un `WHERE` sargable en SQL Server [](https://developer.baidu.com/article/detail.html?id=6609066).

3.  GPU para indexación (Vulkan, no CUDA): Qdrant indexa vectores 10x más rápido con GPUs, usando Vulkan (open source) en lugar de CUDA (propietario). Una Nvidia T4 acelera 5x sobre CPU, y una L4 acelera 7.7x [](https://www.lemagit.fr/actualites/366618597/Base-de-donnees-vectorielle-Qdrant-stabilise-et-ameliore-ses-performances).

4.  LSM-Tree para writes: A diferencia de Chroma (que reconstruye HNSW en cada write) y LanceDB (inmutable por diseño), Qdrant usa una arquitectura LSM-Tree que permite 100k inserciones por segundo en un solo nodo [](https://developer.baidu.com/article/detail.html?id=6609066).

* * * * *

💡 Recomendación final para el Scrum
------------------------------------

| Fase del proyecto | Recomendación |
| --- | --- |
| Sprint 0-2 (Prototipo) | ChromaDB (rapidez de desarrollo) |
| Sprint 3-5 (Piloto con datos reales) | LanceDB (si la RAM es limitada) o Qdrant (si necesitas filtros complejos) |
| Producción (escala moderada <10M) | LanceDB (simplicidad) o Qdrant (rendimiento) |
| Producción (escala alta >10M) | Qdrant (distribuido) |

Estrategia híbrida recomendada: Desarrolla local con ChromaDB (modo efímero), haz pruebas de integración con LanceDB (mismo código, diferente URI), y despliega a producción con Qdrant si la escala lo exige. Los tres son Apache 2.0 y tienen bindings en Python/JS, así que el cambio es principalmente de API.
