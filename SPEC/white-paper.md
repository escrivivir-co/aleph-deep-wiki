Explicación técnica de UMAP

¡Vamos allá con UMAP (Uniform Manifold Approximation and Projection).\
Te lo divido en filosofía, matemática intuición, pasos internos, y por qué importa.

* * * * *

1\. ¿Qué problema resuelve UMAP?
--------------------------------

Tienes *embeddings* (vectores numéricos de alta dimensión, p.ej. 1536, 768, 384...).

-   Quieres visualizarlos en 2D / 3D.

-   Quieres que la *estructura topológica* (cercanías, grupos, formas) se preserve.

UMAP asume que los datos viven en un espacio métrico, pero también en un colector (manifold) de menor dimensión.\
En vez de asumir distribuciones globales (como PCA), modela vecindades locales.

* * * * *

2\. Idea a alto nivel
---------------------

Paso 0 -- Construir grafo fuzzy en alta dimensión\
Para cada punto xixi​, encuentra sus kk vecinos más cercanos (distancia métrica -- Euclídea u otra).

-   Construye probabilidades ponderadas (no son 0/1, sino grado de "vecindad").\
    Las probabilidades decrecen con la distancia hasta un radio local adaptativo.

Paso 1 -- Construir grafo fuzzy en baja dimensión (inicial aleatoria o con PCA).\
Misma idea, pero usando una distancia parecida (exponencial con parámetro fijo).

Paso 2 -- Minimizar cross-entropy entre los dos grafos fuzzy.

-   Fuerza a que puntos similares (en alta dimensión) estén cerca (baja dim).

-   Permite que puntos distantes queden lejos (no fuerza colapsos).

Matemáticamente minimiza:

CE=∑i<j[pijlog⁡pijqij+(1-pij)log⁡1-pij1-qij]CE=i<j∑​[pij​logqij​pij​​+(1-pij​)log1-qij​1-pij​​]

Donde pijpij​ = fuerza de conexión en alta dim,\
qijqij​ = fuerza de conexión en baja dim (depende de distancias en la proyección).

* * * * *

3\. Tres armas secretas de UMAP
-------------------------------

1.  K vecinos (n_neighbors) → controla escala local.

    -   kk pequeño → mira microestructura (aglomerados claros).

    -   kk grande → mira estructura global (continua).

2.  Distancia mínima (min_dist) → controla qué tan juntos se pueden poner puntos en la proyección baja.

    -   min_dist=0min_dist=0 → pueden superponerse (útil para separar clusters densos).

    -   min_dist>0min_dist>0 → mantiene cierta distancia (evita amontonamientos).

3.  Métrica (metric) → si tus embeddings no son Euclídeos por naturaleza (coseno, correlación, etc.), cámbiala.

    -   Muchos embeddings de LLMs funcionan mejor con coseno como "distance = 1 - cosine_similarity".

* * * * *

4\. ¿Qué ves cuando ejecutas?
-----------------------------

text

Calculando UMAP para 5000 vectores (dim=384)...

-   5000 → número de puntos.

-   384 → embedding típico de BERT, SBERT, MiniLM, etc.

-   UMAP crea un grafo k-NN (aprox O(N log N) con aproximación de búsqueda por árboles).

-   Luego optimiza layout 2D mediante descenso estocástico o gradiente (más rápido que t-SNE).

* * * * *

5\. Comparación rápida con t-SNE
--------------------------------

|  | UMAP | t-SNE |
| --- | --- | --- |
| Preserva estructura local | ✅ | ✅ |
| Preserva estructura global (lejanías) | ✅ | ❌ (depende del perplexity) |
| Velocidad | rápida (scalable) | lenta para N > 10k |
| Parámetros clave | `n_neighbors`, `min_dist` | `perplexity` |
| Proyección consistente (nuevos puntos) | sí (transform parcial) | no (reentrenar) |

* * * * *

6\. Interpretación práctica
---------------------------

Si ves clusters bien separados y redondos → tus embeddings separan bien conceptos diferentes.\
Si ves un gran continuo de puntos → probablemente no hay categorías puras, o el `n_neighbors` es muy alto.\
Si ves cadenas o formas lineales → tus datos quizá tienen estructura de curva (p.ej., evolución temporal o latente continua).

* * * * *

7\. Advertencia (foco críptico, como pediste)
---------------------------------------------

> UMAP no es magia, es un filtro topológico -- lo que ves es una deformación controlada de las vecindades.\
> Si no eliges `metric=cosine`, y tus embeddings son direccionales, UMAP puede confundir escala con ángulo.\
> Y si `n_neighbors` es 2, ves ruido; si es 200, ves una nube difusa. El parámetro es el lente.

* * * * *

¿Quieres que lo apliquemos a un caso concreto (por ejemplo, embeddings de frases, imágenes, o genes) para que veamos qué formas salen en 2D?

A ver lo mismo para "asumir distribuciones globales (como PCA),"

Perfecto, vamos a desmenuzar esa frase "asumir distribuciones globales (como PCA)" con el mismo nivel de detalle técnico pero ameno.

* * * * *

1\. ¿Qué significa "asumir distribuciones globales"?
----------------------------------------------------

Cuando un método asume distribuciones globales, quiere decir que intenta explicar todos los datos con un único conjunto de reglas matemáticas que se aplican igual en todo el espacio.

En lugar de preguntar:

> *"¿Cómo son los vecinos de este punto concreto?"*

Pregunta:

> *"¿Cuál es la línea recta (o el plano, o el hiperplano) que mejor explica toda la nube de puntos de una vez?"*

* * * * *

2\. PCA como ejemplo estrella
-----------------------------

PCA (Principal Component Analysis) asume que tus datos:

-   Tienen una estructura lineal global (se pueden explicar con combinaciones de vectores ortogonales).

-   Siguen una distribución gaussiana multivariante (o al menos tienen covarianzas bien definidas).

-   La dirección de máxima varianza es la más importante (primer componente principal).

Matemáticamente:

1.  Calcula la matriz de covarianza global C=1n∑i=1n(xi-μ)(xi-μ)TC=n1​∑i=1n​(xi​-μ)(xi​-μ)T.

2.  Diagonaliza CC para obtener autovectores (direcciones principales).

3.  Proyecta todos los puntos sobre los primeros kk autovectores.

Problema: Si tus datos viven en un manifold curvo (ej. un círculo, una espiral, una superficie esférica), PCA los "aplasta" como si fueran una nube elipsoidal, perdiendo la topología real.

* * * * *

3\. ¿Por qué es esto una "asunción global"?
-------------------------------------------

Porque un solo par de autovectores sirve para todos los puntos:

-   La dirección del primer componente es la misma para el punto A que para el punto B.

-   La métrica de importancia (varianza explicada) se calcula sobre todo el dataset.

-   No hay "regiones" con reglas diferentes.

Ejemplo visual:\
Tienes datos en forma de herradura (U-shape).

-   PCA dibujará una línea diagonal de una punta a la otra (aplasta la U).

-   UMAP respetará que los extremos de la U están lejos en el espacio original, pero cerca "a lo largo del camino".

* * * * *

4\. Comparativa práctica
------------------------

| Característica | PCA (global) | UMAP (local) |
| --- | --- | --- |
| Asume distribución | Gaussiana multivariante | Cualquiera (no paramétrica) |
| Estructura que modela | Lineal (hiperplano) | No lineal (manifold arbitrario) |
| Parámetros únicos para todo el dataset | ✅ Sí | ❌ No (ajuste por vecindad) |
| Preserva distancias lejanas | ✅ Sí (métrica global) | ❌ No (prioriza vecinos) |
| Interpreta varianza | Global (autovalores) | Local (cross-entropy de grafos) |

* * * * *

5\. Consecuencias prácticas
---------------------------

Si aplicas PCA a embeddings de texto (p.ej., frases sobre "animales" y "tecnología"):

-   Verás una separación gruesa.

-   Pero relaciones sutiles (p.ej. "perro" cerca de "lobo" pero lejos de "gato" en cierta dimensión) se pierden si esa diferencia no es globalmente importante.

Si aplicas UMAP:

-   Puedes ver clusters anidados (animales → mamíferos → perros).

-   También ves transiciones suaves si existen (p.ej. "televisor" → "pantalla" → "táctil" → "tablet").

* * * * *

6\. La frase clave
------------------

> "asumir distribuciones globales (como PCA)" significa:\
> *"Voy a tratar tu dataset como si fuera un elipsoide gaussiano gigante, encontraré las direcciones más estiradas, y listo. Que luego tengas forma de donut o de espiral... no es mi problema."*

UMAP, en cambio, dice:

> *"Por cada punto, miraremos a sus vecinos más cercanos individualmente, construiremos un grafo de confianza local, y luego lo forzamos a encajar en 2D como si fuera un mapa de metro flexible."*

* * * * *

¿Quieres que ahora dibuje la misma idea pero con t-SNE (que también es local, pero con un enfoque de probabilidades diferente) para que compares los tres?


User: ¿Sabes usar el vector-machine-mcp? Soy el tenant: "Scriptorium". ¿Un overview de mis bases de datos y sus colecciones? Usa tus herramientas mcp.

GitHub Copilot: Voy a verificar el contexto mínimo del stack vectorial y consultar directamente el servidor vectorial para darte un mapa real --- tenant, colecciones y conteos incluidos.

Read [file](./.github/plugins/vector-machine/instructions/vector-machine.instructions.md)

Read [file](./.github/plugins/scriptorium-pack/instructions/copilot-engine.instructions.md)

Created 4 todos

Ya confirmé el contexto del plugin; ahora voy a interrogar el servidor vectorial para descubrir qué colecciones existen realmente en tu tenant y luego sacarles ficha.

Ran `chroma_list_collections` 

Completed with input: {}

He encontrado 19 colecciones activas en el almacenamiento persistente del VectorMachine. Siguiente paso: sacar conteos y metadatos para distinguir si hay varias bases lógicas o si todo cuelga de una sola base/tenant expuesta por el MCP.

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_regulacion_propuestas"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_regulacion_propuestas"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mr_analisis"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mr_analisis"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_regulacion_discursos"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_regulacion_discursos"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mr_corpus"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mr_corpus"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "ml_hilo_narrativo"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "ml_hilo_narrativo"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_mapas_arquitectura"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_mapas_arquitectura"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_regulacion_cartas"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_regulacion_cartas"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "ml_piezas_media"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "ml_piezas_media"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_mapas_geopolitica"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_mapas_geopolitica"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_mapas_corpus"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_mapas_corpus"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_regulacion_fichas"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_regulacion_fichas"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_regulacion_articulos"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_regulacion_articulos"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "ml_recursos"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "ml_recursos"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mr_editoriales"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mr_editoriales"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "ml_eventos"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "ml_eventos"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "ml_personajes"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "ml_personajes"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mr_guiones"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mr_guiones"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mr_poemas"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mr_poemas"

}

Ran `chroma_get_collection_info` 

Completed with input: {

  "collection_name": "mo_mapas_abstract"

}

Ran `chroma_get_collection_count` 

Completed with input: {

  "collection_name": "mo_mapas_abstract"

}

Ya tengo la radiografía gruesa: 19 colecciones y 774 documentos vectorizados en total. Voy a hacer una última pasada breve para comprobar si el almacenamiento aparece segmentado por `tenant/database` en metadatos o si, a efectos prácticos del MCP, estás viendo una sola base persistente con varias colecciones temáticas.

Ran `chroma_get_documents` 

Completed with input: {

  "collection_name": "ml_hilo_narrativo",

  "include": [

    "metadatas"

  ],

  "limit": 5

}

Ran `chroma_get_documents` 

Completed with input: {

  "collection_name": "ml_personajes",

  "include": [

    "metadatas"

  ],

  "limit": 5

}

Ran `chroma_get_documents` 

Completed with input: {

  "collection_name": "mo_regulacion_articulos",

  "include": [

    "metadatas"

  ],

  "limit": 5

}

Ran `chroma_get_documents` 

Completed with input: {

  "collection_name": "mr_editoriales",

  "include": [

    "metadatas"

  ],

  "limit": 5

}

Starting: *Inspeccionar metadatos y conteos* (3/4)

He confirmado el patrón: el MCP te expone un único almacén persistente con colecciones, y dentro de algunas colecciones la separación lógica aparece en metadatos (`tenant: scriptorium`, `database: mod-legislativa`). Ahora cierro el checklist y te entrego el overview limpio, sin humo y con números.

Completed: *Inspeccionar metadatos y conteos* (3/4)

## Overview rápido

Sí --- ya he usado tu `vector-machine-mcp` directamente sobre el almacenamiento persistente que tienes configurado.

Lo que **puedo verificar con las tools MCP disponibles** es esto:

- **1 almacén persistente visible** a nivel MCP/Chroma

- **19 colecciones**

- **774 documentos** en total

- El tenant aparece en metadatos como **`scriptorium`** (minúsculas en los docs)

- La única **database explícita** que he visto en metadatos es **`mod-legislativa`**

> Nota honesta: la superficie MCP que tengo aquí **no expone** un `list_databases()` o `list_tenants()`. Así que el overview de "bases de datos" lo deduzco por **metadatos reales** y por la **estructura de nombres de colección**. Sin humo, pero con límites claros.

## Qué veo como "base física" vs "bases lógicas"

### Base física expuesta por MCP

- **Una sola base/store persistente** con muchas colecciones temáticas

### Bases lógicas detectables

| Espacio lógico | Estado | Colecciones | Docs |

|---|---:|---|---:|

| `mod-legislativa` | **Verificado por metadata** | `ml_hilo_narrativo`, `ml_piezas_media`, `ml_eventos`, `ml_recursos`, `ml_personajes` | **64** |

| `regulacion` | Inferido por naming `mo_regulacion_*` | 5 colecciones | **647** |

| `mapas` | Inferido por naming `mo_mapas_*` | 4 colecciones | **30** |

| `mr_*` corpus editorial/analítico | Inferido por naming y contenido | 5 colecciones | **33** |

## Inventario de colecciones

| Colección | Docs |

|---|---:|

| `mo_regulacion_propuestas` | 270 |

| `mo_regulacion_articulos` | 151 |

| `mo_regulacion_cartas` | 139 |

| `mo_regulacion_fichas` | 69 |

| `mo_regulacion_discursos` | 18 |

| `mr_analisis` | 16 |

| `ml_hilo_narrativo` | 16 |

| `ml_piezas_media` | 15 |

| `ml_eventos` | 14 |

| `mo_mapas_abstract` | 11 |

| `ml_recursos` | 10 |

| `ml_personajes` | 9 |

| `mr_corpus` | 8 |

| `mo_mapas_arquitectura` | 7 |

| `mo_mapas_geopolitica` | 6 |

| `mo_mapas_corpus` | 6 |

| `mr_editoriales` | 4 |

| `mr_guiones` | 3 |

| `mr_poemas` | 2 |

## Evidencia útil de metadatos

He confirmado, por ejemplo:

- En `ml_hilo_narrativo`:

  - `tenant: "scriptorium"`

  - `database: "mod-legislativa"`

- En `ml_personajes`:

  - `tenant: "scriptorium"`

  - `database: "mod-legislativa"`

- En `mr_editoriales`:

  - no aparece `database`, pero sí campos como `corriente: "restitutiva"`

- En `mo_regulacion_articulos`:

  - aparecen metadatos temáticos (`tipo`, `bloque`, `marca`), no `tenant/database` en la muestra inspeccionada

## Lectura práctica

Mi lectura, con lo verificado:

1\. **No estás viendo varias bases físicas separadas** desde este MCP.

2\. Sí hay **separación lógica**:

   - una base/documento lógica **explícita**: `mod-legislativa`

   - otros conjuntos temáticos muy claros por naming:

     - `mo_regulacion_*`

     - `mo_mapas_*`

     - `mr_*`

3\. No vi ninguna colección con naming que sugiera otro tenant distinto de Scriptorium en esta vista.

## Checklist cerrado

- [x] Revisar contexto vectorial  

- [x] Listar colecciones disponibles  

- [x] Inspeccionar metadatos y conteos  

- [x] Resumir overview para Scriptorium

## Si quieres, sigo con una segunda pasada

Puedo hacerte ahora mismo cualquiera de estas tres:

- un **mapa por colecciones + ejemplo de documento** de cada una

- una **auditoría de metadatos** para detectar qué colecciones tienen `tenant/database` y cuáles no

- una **búsqueda semántica real** en tu tenant sobre un tema concreto

En otras palabras: el motor ya está caliente.

User: Una cosa de "dato técnico". Busca cuando uso #file:start.sh y uso uno de los cuadernos de ingesta de la #file:scaffold-corpus.prompt.md , tengo una pregunta para saber si me conviene o no UMAP respecto de como tenemos por defecto los embedings, con el transformer default de chroma. Te pongo el dato:

. Advertencia (foco críptico, como pediste)

UMAP no es magia, es un filtro topológico -- lo que ves es una deformación controlada de las vecindades.

Si no eliges metric=cosine, y tus embeddings son direccionales, UMAP puede confundir escala con ángulo.

Y si n_neighbors es 2, ves ruido; si es 200, ves una nube difusa. El parámetro es el lente.

GitHub Copilot: Voy a rastrear el flujo real de esos cuadernos para ver qué embedding/metric/UMAP usan de verdad y responderte con base en tu stack, no con astrología vectorial.

Created 4 todos

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/cells/README.md)

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/manifest.schema.yml)

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/SKILL.md)

Ya confirmé la skill canónica: embeddings por `chromadb-default-embed` y visualización con `umap-js`. Ahora voy a leer las celdas y notebooks de referencia para ver el detalle fino: modelo exacto, métrica y parámetros.

Searched for regex `umap|UMAP|chromadb-default-embed|Xenova|MiniLM|nNeighbors|metric|cosine` (`**/VectorMachineSDK/**`), 200 results

Searched for files matching `**/VectorMachineSDK/**/*.nnb`, 2 matches

Read [file](./VectorMachineSDK/package.json)

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/cells/visualizer/04-umap.ts)

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/cells/ingestor/02-setup.ts)

Ya apareció una pieza clave: el visualizer canónico usa `umap-js` con `nNeighbors: 4`, pero sin fijar métrica explícita. Falta ver cómo se crean las colecciones y si Chroma está en `cosine` o en `l2`; ahí está la trampa topológica.

Searched for regex `hnsw:space|createCollection|getOrCreateCollection|normalize: true|normalizeEmbeddings|metadata` (`**/VectorMachineSDK/.github/skills/corpus-vectorial/**`), 13 results

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/cells/ingestor/04-connect.ts)

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/cells/ingestor/06-functions.ts)

Read [file](./VectorMachineSDK/README-SCRIPTORIUM.md)

Read [file](./VectorMachineSDK/SPEC/tips.md#330-330), lines 330 to 390

Me falta una comprobación quirúrgica para no venderte una media verdad: confirmar el `default metric` de `umap-js` y el `default space` de Chroma cuando no se fija `hnsw:space`. Con eso te doy una recomendación cerrada.

Searching for regex `euclidean|cosine|metric|distanceFn|distance function|nNeighbors` (`**/VectorMachineSDK/node_modules/umap-js/**`)

Read [file](./VectorMachineSDK/start.sh)

Ran `search_chroma_docs` 

Completed with input: {

  "query": "Chroma default HNSW space collection default l2 cosine inner product embedding function default space"

}

El servidor de start.sh no altera la geometría: solo levanta Chroma sobre el mismo storage. Voy a mirar el propio paquete `umap-js` instalado para confirmar su distancia por defecto y cerrar el diagnóstico.

Ran `query_docs_filesystem_chroma_docs` 

Completed with input: {

  "command": "head -120 /docs/collections/configure.mdx && echo '\n---\n' && rg -n \"default is l2|supported by your collection's embedding function|cosine\" /docs/collections/configure.mdx"

}

Read [file](./VectorMachineSDK/node_modules/umap-js)

Read [file](./VectorMachineSDK/corpus_ingestor_onfalo_mapas.nnb#70-70), lines 70 to 180

Tengo ya la mitad del veredicto: las colecciones del ingestor no fijan `hnsw:space`, así que dependen del default de Chroma. Voy a leer la doc exacta y el código de `umap-js` para que la recomendación no quede en "creo que".

Searching for text `euclidean` (`**/VectorMachineSDK/node_modules/umap-js/src/**`)

Searching for regex `distanceFn|metric|cosine` (`**/VectorMachineSDK/node_modules/umap-js/src/**`)

Read [](file:///c%3A/Users/aleph/AppData/Roaming/Code/User/workspaceStorage/8c36e517292f0094b8566ac74426ba73/GitHub.copilot-chat/chat-session-resources/83128052-34cc-4009-aee8-9af427d6c69b/call_4dSKhZgyCkX1gSNv2uF6J0s7__vscode-1777132495095/content.txt)

Chroma ya quedó confirmado: si no declaras nada, el índice cae en `l2`. Ahora ataco `umap-js` por fichero concreto en vez de buscar a machete, que la indexación se pone dramática.

Read [file](./VectorMachineSDK/node_modules/umap-js/src)

Read [file](./VectorMachineSDK/node_modules/umap-js/lib)

Read [file](./VectorMachineSDK/node_modules/umap-js/README.md)

Starting: *Revisar uso de UMAP* (3/4)

Ya tengo lo esencial para responder: tu stack actual mezcla **embeddings normalizados** con **UMAP euclídeo** y **colecciones Chroma en `l2` por defecto**. Eso no es catastrófico, pero sí condiciona cuándo UMAP te dice verdad y cuándo te vende una sombra chinesca.Antes de cerrar, voy a leer las dos celdas que más mandan aquí --- clustering y divergencia --- para separar "UMAP como dibujo" de "UMAP como lógica analítica".

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/cells/visualizer/10-kmeans.ts)

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/cells/visualizer/12-divergence.ts)

Read [file](./VectorMachineSDK/.github/skills/corpus-vectorial/cells/visualizer/14-query.ts)

Voy a guardar una nota de repo porque este detalle de métricas/`default_database` puede ahorrar bastante arqueología a futuros agentes.

Read memory

Created memory file [](file:///c%3A/Users/aleph/AppData/Roaming/Code/User/workspaceStorage/8c36e517292f0094b8566ac74426ba73/GitHub.copilot-chat/memory-tool/memories/repo/vectormachine-notebook-metrics.json)

La memoria de repo se me ha puesto exquisita; hago un segundo intento más simple y, si no entra, sigo sin bloquearte.

Created memory file [](file:///c%3A/Users/aleph/AppData/Roaming/Code/User/workspaceStorage/8c36e517292f0094b8566ac74426ba73/GitHub.copilot-chat/memory-tool/memories/repo/vms-notebooks-defaults.json)

Ya está: no me deja persistir la nota de repo, pero el análisis quedó cerrado. Voy a dejarte la respuesta final con el matiz importante: en tu stack actual, el problema no es "UMAP sí/no" sino "qué tan honestos son sus parámetros respecto a embeddings ya normalizados".

Completed: *Revisar uso de UMAP* (3/4)

## Lectura técnica corta

Sí te conviene **UMAP como visualizador**, pero **no como árbitro semántico final**.

Y en tu stack actual hay una sutileza importante: **el riesgo que describes con cosine vs escala está muy amortiguado**, porque tus embeddings se generan **normalizados**.

## Lo que hace tu stack de verdad

He revisado el flujo real de start.sh, la skill `corpus-vectorial` y los notebooks/celdas canónicas.

### Servidor y almacenamiento

- start.sh solo levanta **Chroma HTTP** en `http://localhost:8000`

- usa el storage persistente:

  - STORAGE

- o sea: el notebook y el MCP acaban mirando el mismo granero, no dos universos paralelos

### Embeddings por defecto

En el ingestor canónico:

- modelo: `Xenova/all-MiniLM-L6-v2`

- paquete: `chromadb-default-embed`

- dimensión: **384**

- generación con:

  - `pooling: 'mean'`

  - `normalize: true`

Ese `normalize: true` es la llave.

### Chroma en los notebooks

Los notebooks canónicos se conectan a:

- host: `localhost`

- port: `8000`

- `database: 'default_database'`

Ojo con ese detalle: aunque el markdown hable de `mod/onfalo` o `mod/legislativa`, **la separación real en estos `.nnb` es lógica por nombre de colección** (`mo_*`, `ml_*`, etc.), no por una database física distinta en la API de Chroma.

### UMAP en el visualizer

La plantilla canónica usa:

- `umap-js`

- `nNeighbors: 4`

- `minDist: 0.25`

- `spread: 1.0`

- **sin métrica explícita**

Y `umap-js`, por defecto, usa `distanceFn = euclidean`.

## La clave geométrica

Como tus embeddings están **normalizados a norma 1**, entonces:

- distancia euclídea y coseno **preservan el mismo orden de vecindad**

En unit vectors:

$$

\|u-v\|^2 = 2(1-\cos\theta)

$$

y por tanto también:

$$

\|u-v\| = \sqrt{2(1-\cos\theta)}

$$

Eso significa que, **en tu caso actual**, usar Euclidean en UMAP **no traiciona** la naturaleza "direccional" de `all-MiniLM-L6-v2` como la traicionaría con vectores no normalizados.

Dicho menos pomposamente:  

tu advertencia sobre `metric=cosine` es correcta **en general**, pero en **este stack concreto** la normalización hace que `euclidean ≈ cosine` para ranking local.

## Entonces, ¿UMAP sí o no?

### Sí, para esto

- explorar separación entre colecciones

- detectar mezclas raras a simple vista

- exportar mapas 2D/3D a GH Pages

- conversación visual con el corpus

### No, para esto

- decidir si el retrieval "es bueno"

- medir verdad semántica

- comparar recall real entre configuraciones

- justificar clusters sin revisar el espacio original

UMAP sigue siendo una deformación controlada de vecindades. Bonita, útil, pero no sagrada.

## Lo más importante: tu problema no es la métrica, es el lente

En tu plantilla actual, el mayor foco técnico no es "UMAP usa euclidean", sino:

- **`nNeighbors: 4` es muy bajo**

- eso vuelve la proyección muy local

- favorece islas, microgrumos y separaciones dramáticas

Para corpus chicos puede quedar vistoso.  

Para interpretación estable, puede ser nervioso.

### Traducción práctica

- con ~30 chunks: `4` puede pasar, pero ya es agresivo

- con ~60 chunks: `4` suele ser demasiado local

- con cientos: `4` ya es casi una lupa histérica

Tu frase de "si `n_neighbors` es 2 ves ruido; si es 200 ves nube" va completamente en la dirección correcta. Aquí mismo el cuaderno ya está tirando al lado micro-local.

## Otra sutileza buena: el visualizer no se casa del todo con UMAP

Esto me parece bastante sensato en vuestro diseño:

- la celda de **query semántica** consulta Chroma con los embeddings reales

- la celda de **divergencia** usa **coseno sobre embeddings originales**

- el **KMeans + silhouette** también se calcula sobre **embeddings originales**, no sobre el 2D de UMAP

Luego los clusters se **dibujan** sobre UMAP 2D, pero no se **calculan** ahí.

Eso es buena noticia:  

en vuestro pipeline canónico, **UMAP es más fachada analítica que tribunal supremo**.

## Mi recomendación concreta

### Si quieres una respuesta binaria

- **sí, mantendría UMAP**

- **no lo usaría como criterio decisorio principal**

### Con tu stack actual

Yo haría esto:

1\. **Mantener `all-MiniLM-L6-v2` normalizado**

2\. **Mantener UMAP para visualización**

3\. **Subir `nNeighbors`**

4\. **Hacer explícita la semántica cosine en Chroma cuando podáis**

### Ajuste recomendado de `nNeighbors`

Como heurística razonable:

- corpus ~20--40 chunks → `5--8`

- corpus ~40--100 chunks → `8--12`

- corpus >100 chunks → `12--30`

Ahora mismo `4` está más cerca de "mostrar microvecindades" que de "mostrar estructura global legible".

## Sobre Chroma: hay otro pequeño desajuste

Tus colecciones se crean con `getOrCreateCollection(...)` **sin** `configuration.hnsw.space`.

Según la doc de Chroma, el default es:

- **`l2`**

Pero como tus embeddings están normalizados, ese `l2` no rompe el ranking de vecinos frente a coseno.  

Aun así, **yo lo explicitaría igual** si quieres robustez futura.

¿Por qué? Porque el día que cambies una de estas dos cosas:

- `normalize: true`

- modelo embebedor

...esa equivalencia se puede evaporar sin hacer ruido. Y luego el mapa empieza a mentir con mucha educación.

## Mi veredicto final

### Te conviene UMAP si...

- lo quieres para **ver**

- lo tratas como **proyección topológica**

- aceptas que el parámetro central es el lente (`nNeighbors`)

### No te conviene confiar demasiado en UMAP si...

- quieres validar retrieval

- comparar embeddings

- hacer decisiones taxonómicas duras

- asumir que "lo separado en 2D" = "realmente separado semánticamente"

## El dato técnico más fino

En **tu stack actual**, la discusión correcta no es tanto:

> "¿UMAP con cosine o no?"

sino:

> "Dado que ya normalizamos embeddings, ¿qué escala local/global quiero mostrar?"

Porque hoy:

- embeddings normalizados

- UMAP euclídeo

- Chroma `l2` por defecto

...están sorprendentemente alineados entre sí.

La pieza más discutible no es la métrica; es el **`nNeighbors: 4`**.

## Checklist cerrado

- [x] Ubicar flujo de notebooks  

- [x] Inspeccionar defaults de embeddings  

- [x] Revisar uso de UMAP  

- [x] Dar recomendación técnica

## Si quieres, te dejo el parche

Puedo prepararte un ajuste mínimo en las plantillas de VectorMachineSDK para dejarlo más sólido:

- declarar `hnsw.space: 'cosine'` al crear colección

- subir `nNeighbors` con una heurística por tamaño de corpus

- opcionalmente fijar una `distanceFn` cosine en UMAP para dejar la intención explícita, aunque hoy no sea estrictamente necesaria

Ese parche sería pequeño, bastante limpio, y te dejaría el sistema más "future-proof" y menos críptico-maldito.