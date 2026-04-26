---
name: semantic-query-notebook
description: |
  Use this skill when the user asks to create, initialize, refactor, or operate a template-driven semantic-query notebook over Chroma collections; to parse a markdown template of section packs (`query_texts`, agent, hypothesis, `n_results`); to generate one markdown result file per section; or to reuse `mcp-core-sdk` / `BasicVectorMachine` inside a `.nnb` notebook.
---

# Skill: semantic-query-notebook

> **Propósito**: convertir un conjunto de consultas semánticas organizado en una plantilla markdown en un flujo reproducible de notebook `.nnb` + salidas markdown por sección, apoyado en Chroma y `mcp-core-sdk`.

---

## Cuándo activar esta skill

Actívala cuando el usuario pida cosas como:

- "crear un cuaderno de semantic-query"
- "inicializar una plantilla de `query_texts` por colección"
- "generar un markdown por sección desde un notebook"
- "usar `mcp-core-sdk` / `BasicVectorMachine` en un `.nnb` para consultar Chroma"
- "refactorizar este notebook para que lea una plantilla y escriba salidas por lote"

No la actives para:

- visualización UMAP/Plotly/GH Pages de corpus (usa `corpus-vectorial`)
- edición literaria o export editorial de novelas
- consultas Chroma puntuales sin necesidad de notebook + plantilla + salidas estructuradas

---

## Idea central del patrón

Este flujo **diverge conscientemente** del patrón `corpus-vectorial`:

- **No** usa manifest YAML como fuente de verdad principal.
- **No** genera visualizadores ni export HTML.
- **Sí** usa una **plantilla markdown** con secciones repetibles.
- **Sí** usa un cuaderno `.nnb` como ejecutor mecánico.
- **Sí** produce un **archivo markdown por sección** con resultados Chroma.

En forma corta:

```text
plantilla-semantic-query.md
        ↓
notebook .nnb con mcp-core-sdk + Chroma
        ↓
seccion-1.md, seccion-2.md, ...
```

---

## Artefactos del patrón

### 1. Plantilla markdown
Fuente de verdad humana que define:
- colección Chroma objetivo
- agente sugerido
- hipótesis de exploración
- pack mínimo de `query_texts`
- rango de `n_results`

### 2. Notebook `.nnb`
Ejecutor mecánico que:
- conecta con Chroma
- parsea la plantilla
- genera embeddings JS
- consulta resultados
- renderiza markdown por sección

### 3. Archivos de salida
Un markdown por sección con:
- detalle compatible con Chroma Admin UI
- distancia, id, documento y metadata
- cierre sintético reutilizable por otros agentes

### 4. Runner lineal de validación (opcional pero recomendado)
Si el entorno del agente no puede ejecutar `.nnb` directamente, crear un runner CJS/Node equivalente para validar la lógica y producir las salidas.

---

## Contrato de la plantilla markdown

La plantilla debe mantener una estructura **estable y parseable**. La forma canónica es:

```md
## 1) `ml_hilo_narrativo` — Narrativa estructural del caso

### Agente asignado
- **Agente sugerido:** `Explore`

### Hipótesis de exploración
- ¿Cómo se articula el paso de contexto histórico → caso concreto → desenlace abierto?

### Pack mínimo básico de `query_texts`
1. "..."
2. "..."
3. "..."
4. "..."
5. "..."

### Filtros/ajustes sugeridos
- `n_results`: 5–8
```

### Reglas del parser

El parser debe asumir:

- encabezado exacto de sección con este patrón:
  - `## <n>) \`<collection>\` — <label>`
- el agente sugerido aparece en una línea con:
  - `**Agente sugerido:** \`<agent>\``
- la hipótesis aparece como bullet único bajo `### Hipótesis de exploración`
- los `query_texts` aparecen como lista numerada entre comillas
- `n_results` puede venir como rango (`5–8`) o valor fijo (`5`)

### Decisión operativa recomendada

Para respetar la idea de **pack mínimo básico**:

- usar el **mínimo** del rango de `n_results`
- ejecutar los `query_texts` **verbatim**
- no introducir refinamientos automáticos en la primera versión

---

## Contrato del notebook `.nnb`

El notebook debe ser pequeño, lineal y explícito. La secuencia recomendada es:

### Celda 1 — Introducción markdown
Explica:
- entradas
- salidas
- flujo
- prerrequisitos

### Celda 2 — Bootstrap vendor-first
Conectar notebook con:
- `BasicVectorMachine`
- `getChromaClient()`
- `connectChroma()`
- `listCollectionNames('ml_')`

Debe resolver:
- home directory
- raíz de Scriptorium
- ruta a `VectorMachineSDK`
- ruta a `MCPGallery/mcp-core-sdk/dist/vector-db`
- ruta a la plantilla markdown

### Celda 3 — Introducción al parser
Markdown breve explicando la fase de parseo.

### Celda 4 — Parser de plantilla
Debe producir una colección normalizada de objetos como:

```ts
{
  sectionNumber,
  collectionName,
  sectionLabel,
  agent,
  hypothesis,
  queryTexts,
  nResults,
  outputPath
}
```

### Celda 5 — Introducción al motor
Markdown breve.

### Celda 6 — Motor de query + render
Debe definir:
- `getEmbedder()` con caché en `globalThis`
- `queryCollection()`
- `stableJson()`
- `buildSnippet()`
- `renderSectionMarkdown()`
- `writeSection()`

### Celda 7 — Introducción a control run
Markdown breve.

### Celda 8 — Ejecución de control
Escribir solo la **sección 1** para validar el contrato de salida.

### Celda 9 — Introducción al lote completo
Markdown breve.

### Celda 10 — Batch run
Recorrer todas las secciones y sobrescribir:
- `seccion-1-...md`
- `seccion-2-...md`
- etc.

---

## Motor de query: contrato técnico

### Embeddings
Usar `chromadb-default-embed` en JS puro:

```ts
pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2')
```

Con:

```ts
{ pooling: 'mean', normalize: true }
```

### Cache
Configurar:

```ts
env.cacheDir = path.join(NNB_DIR, '.model-cache')
```

### Consulta Chroma
Recuperar colección con embedding function dummy:

```ts
await client.getCollection({
  name: collectionName,
  embeddingFunction: { generate: async () => [] }
})
```

Luego consultar con:

```ts
include: ['documents', 'metadatas', 'distances']
```

### Orden
Siempre ordenar por:

- `distance` ascendente

### Reglas de serialización
- normalizar whitespace del documento
- truncar extractos de forma determinista
- serializar metadata con claves ordenadas (`stableJson`)

---

## Contrato de salida por sección

El fichero de salida debe llamarse así:

```text
seccion-<n>-<collection>.md
```

Ejemplo:

```text
seccion-1-ml_hilo_narrativo.md
```

### Estructura recomendada

1. Título de sección
2. Confirmación de detalle
3. Configuración de la sección
4. Query pack ejecutado
5. Resultados detallados por query
6. Cierre de sección con síntesis automática

### Campos mínimos por hit
Cada resultado debe mostrar:

- `distance`
- `id`
- snippet de `document`
- `metadata` JSON

### Reglas de escritura
- overwrite idempotente
- nombres deterministas
- no mezclar secciones en un solo markdown

---

## Inicialización recomendada de una nueva plantilla

Cuando el usuario aún no tenga plantilla:

1. **Descubrir colecciones objetivo**
   - listar colecciones Chroma
   - decidir el subconjunto relevante (`ml_*`, `mr_*`, etc.)

2. **Crear una sección por colección**
   - título con colección + etiqueta humana
   - agente sugerido
   - hipótesis concreta
   - 5 `query_texts` iniciales
   - rango `n_results`

3. **Mantener el contrato parseable**
   - no cambiar arbitrariamente encabezados
   - no convertir la lista de queries en prose libre

4. **Usar el notebook para ejecutar**
   - bootstrap
   - parser
   - control run
   - batch run

---

## Flujo operativo recomendado

1. Validar que Chroma responde.
2. Validar que `mcp-core-sdk` está compilado.
3. Ejecutar bootstrap del notebook.
4. Ejecutar parser y comprobar que detecta todas las secciones.
5. Ejecutar la escritura de control de la sección 1.
6. Validar visualmente el archivo generado.
7. Ejecutar el lote completo.
8. Hacer un spot-check manual en una sección adicional.

---

## Fallback cuando el `.nnb` no es ejecutable en el entorno del agente

Si las herramientas del entorno **no pueden ejecutar `.nnb` directamente**:

- mantener el notebook como artefacto principal;
- crear temporalmente un runner lineal (`.cjs` o `.js`) que replique exactamente las celdas de código;
- usar ese runner solo para validar la lógica y producir salidas;
- eliminar runners de depuración sobrantes cuando la validación ya esté hecha;
- conservar, si aporta valor práctico, un runner equivalente estable junto al notebook.

### Importante
Ese fallback **no sustituye** al notebook como artefacto del patrón; solo resuelve la limitación del entorno del agente.

---

## Referencias locales útiles en este workspace

- `tmp/plantilla-semantic-query-ml.md` — ejemplo de plantilla fuente de verdad
- `tmp/semantic-query-ml.nnb` — implementación local del patrón
- `tmp/semantic-query-ml-runner.cjs` — validación lineal equivalente
- `tmp/seccion-1-ml_hilo_narrativo.md` — ejemplo de salida por sección
- `.github/skills/corpus-vectorial/mcp-core-sdk-integration/test.nnb` — referencia vendor-first con `BasicVectorMachine`

---

## Pitfalls frecuentes

### 1. Parser frágil
Si cambias el formato de los encabezados, el parser regex se rompe en silencio o devuelve menos secciones de las esperadas.

### 2. `n_results` ambiguo
Si el documento dice `5–8`, decide explícitamente si tomarás mínimo, máximo o valor medio. La opción recomendada aquí es **mínimo**.

### 3. Falsos positivos del analizador sobre `.nnb`
Algunas herramientas pueden intentar leer el notebook JSON como si fuera TypeScript plano y dar warnings irrelevantes.

### 4. Estado de kernel / notebook obsoleto
Si el notebook cambia, vuelve a obtener el resumen actualizado antes de asumir qué celdas existen o en qué orden están.

### 5. Distancias mal interpretadas
En este flujo, **menor distancia = mayor cercanía**.

### 6. Ruido runtime no fatal
En Windows o entornos mixtos pueden aparecer warnings de librerías nativas del runtime del embedder; si las salidas se generan correctamente, no siempre implican fallo funcional.

---

## Criterios de calidad

La implementación queda bien cuando:

- el notebook parsea exactamente las secciones esperadas;
- todas las colecciones mencionadas existen realmente;
- se genera un markdown por sección;
- el formato de salida es homogéneo;
- el orden por distancia es estable;
- la ejecución es idempotente al re-lanzarse.

---

## Regla final

**No reinventar el flujo en cada tarea.**

Si el usuario pide un notebook de consultas semánticas por secciones:
- primero crear o validar la plantilla markdown,
- luego scaffold del `.nnb`,
- luego ejecución de control,
- luego batch,
- y solo después refinamientos opcionales (TSV, filtros extra, síntesis más rica).
