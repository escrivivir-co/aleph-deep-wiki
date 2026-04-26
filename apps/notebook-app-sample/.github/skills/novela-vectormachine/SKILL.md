---
name: novela-vectormachine
description: |
  Use this skill when the user wants to write a novel in assisted mode (writer-in-the-loop)
  using AlephAlpha + VectorMachineSDK as retrieval memory. The agent must not ghostwrite
  final prose: it should orchestrate tools, surface evidence, propose structure, and let the
  author decide and write.
applyTo: "ARCHIVO/DISCO/TALLER/**/*.yaml, VectorMachineSDK/**/*.nnb, ARCHIVO/PLUGINS/VECTOR_MACHINE/**/*.md"
---

# Skill: novela-vectormachine

> **Propósito**: abrir un flujo de novela asistida por recuperación vectorial, donde el autor escribe y el agente opera infraestructura, consulta memoria y propone andamiaje narrativo.

---

## Regla principal de esta skill

- **NO** redactar la versión final literaria por el usuario.
- **SÍ** ayudar con: descubrimiento de material, síntesis, fichas de personajes, hipótesis de escenas/capítulos, consistencia y continuidad.

---

## Diferencia crítica de infraestructura

Esta skill distingue explícitamente dos planos que comparten storage:

1. **MCP de VectorMachine** (`vector-machine-mcp` en `.vscode/mcp.json`)
   - Vía `uvx chroma-mcp --client-type persistent --data-dir ...`
   - Uso: consultas operativas desde el agente (chat/tools).

2. **Servidor HTTP de Chroma para notebooks** (`VectorMachineSDK/start.sh`)
   - Expone `http://localhost:8000`
   - Uso: clientes notebook/SDK JS (exploración, scripts de apoyo).

**Storage compartido (fuente de verdad):**
`ARCHIVO/PLUGINS/VECTOR_MACHINE/STORAGE`

> Tener el MCP activo **no sustituye** al servidor HTTP de notebooks, y viceversa.

---

## Cuándo aplica

Activar cuando el usuario pide cosas como:

- "Quiero escribir novela asistida con mi base vectorial"
- "Busquemos material por colecciones/prefijos"
- "No escribas tú la novela; acompáñame con contexto"
- "Crear novela desde VectorMachineSDK"

---

## Flujo operativo recomendado (paso a paso)

1. **Verificación mínima de servicios**
   - Confirmar AlephAlpha responde (sistema/listado de novelas).
   - Confirmar `vector-machine-mcp` responde (aunque falle por colección inexistente).
   - Si habrá notebooks: confirmar Chroma HTTP en `localhost:8000` (vía `start.sh`).

2. **Contrato de trabajo con el autor (writer-in-the-loop)**
   - Acordar: tono, límites, rol del agente (asistente, no ghostwriter).
   - Pedir tema central, título provisional y objetivo de la sesión.

3. **Selección por prefijos (metadata-first)**
   - Pedir uno o varios prefijos de trabajo (ej. `nov_`, `mito_`, `ensayo_`).
   - Filtrar/organizar la exploración por esos prefijos antes de abrir todo el storage.

4. **Descubrimiento de colecciones**
   - Si existe herramienta de listado de colecciones, usarla.
   - Si no existe, abrir notebook de apoyo o script SDK JS contra `localhost:8000` para enumerar colecciones y metadatos.
   - Presentar catálogo resumido al autor (nombre, tamaño, pista temática).

5. **Rondas de recuperación guiada**
   - Ejecutar consultas por intención narrativa:
     - personaje
   - escena
     - conflicto
     - tono
     - mundo
   - Entregar resultados en formato de trabajo (bullet points y citas breves), no en prosa final.

6. **Cristalización estructural**
   - Construir, iterativamente con el autor:
     - fichas de personaje
     - mapa de escenas
     - esqueleto de capítulos
   - Guardar decisiones y preguntas abiertas para la siguiente sesión.

---

## Plantilla de invocación (prompt de arranque)

Esta skill se materializa como una **plantilla AlephAlpha** registrada con id
`crear-novela-vectormachine` en `NovelistEditor/src/resources/novel-data.json`.
Importante: AlephAlpha NO expone tool MCP para crear plantillas; añadir/editar
plantillas requiere editar `novel-data.json` y reiniciar el servidor MCP.

Vocabulario Chroma esperado en las variables:

| Variable | Significado Chroma |
|----------|--------------------|
| `tenant` | Tenant de Chroma (por defecto `default_tenant`). |
| `database` | Database lógica dentro del tenant. |
| `collectionNamePrefix` | Prefijo para filtrar colecciones (sobre nombre de colección). |
| `collectionNames` | Lista explícita de colecciones a usar. |
| `whereFilter` | Filtro `where` Chroma sobre metadata de los documentos. |
| `embeddingFunction` | Embedding function esperada (ej. `default`, `openai`). |
| `queryTexts` | Lista de textos para `query_documents`. |
| `nResults` | `n_results` por colección. |

Aplicar la plantilla:

```
alephAlpha_applyNovelistPromptTemplate(
  templateId = "crear-novela-vectormachine",
  variables = {
    novelTitle: "...",
    theme: "...",
    genre: "...",
    setting: "...",
    protagonist: "...",
    tenant: "default_tenant",
    database: "default_database",
    collectionNamePrefix: "nov_",
    collectionNames: "[]",
    whereFilter: "{}",
    embeddingFunction: "default",
    queryTexts: "[\"motivo central\", \"voz narrativa\"]",
    nResults: "5"
  }
)
```

---

## Formato de entrega recomendado en cada ronda

- **Entrada del autor**: objetivo puntual de la ronda.
- **Consulta aplicada**: qué se buscó y por qué.
- **Hallazgos útiles**: 5-12 puntos concretos.
- **Vacíos**: qué falta investigar.
- **Siguiente micro-paso**: una acción clara para continuar.

---

## Notas de implementación

- Priorizar evidencia y rastreabilidad sobre creatividad automática.
- En caso de conflicto entre colecciones, mostrar alternativas y pedir criterio al autor.
- Si no hay colección objetivo, empezar por descubrimiento (prefijos → catálogo → primera consulta).
