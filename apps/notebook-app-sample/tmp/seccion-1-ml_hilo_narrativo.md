# Sección 1 — `ml_hilo_narrativo`

## Confirmación de detalle (sí, se puede)
Con `vector-machine mcp` / Chroma se registra el mismo nivel operativo de detalle que en Admin UI:
- `distance`
- `id`
- `document`
- `metadata`

> Nota técnica: menor `distance` = mayor cercanía semántica.

## Configuración de la sección
- **Colección:** `ml_hilo_narrativo`
- **Etiqueta:** Narrativa estructural del caso
- **Agente sugerido:** `Explore`
- **Hipótesis:** ¿Cómo se articula el paso de contexto histórico → caso concreto → desenlace abierto?
- **n_results ejecutado:** 5

## Query pack ejecutado
Colección: `ml_hilo_narrativo`  
`n_results`: 5 por query

1. "transición de indignación a institucionalización en el caso Feo Zoowoman"
2. "hilo narrativo del juicio 2026 propiedad intelectual y preservación"
3. "tensión entre alumbrado y ceremonia de la sala judicial"
4. "del análisis de Cristóbal al salto institucional con Bustinduy"
5. "dato 11007 vs 40 y cambio de marco narrativo"

---

## Resultados detallados (top-5 por query)

### Q1) transición de indignación a institucionalización en el caso Feo Zoowoman
1. **0.9313** — `HN-S2` — [S2] El caso nace. Feo construye un archivo cinematográfico online. Impulso: amor al cine y que obras no desaparezcan.…  
   `{"database":"mod-legislativa","seccion":"2","tenant":"scriptorium","titulo":"El caso nace"}`
2. **1.1659** — `HN-S4e` — [S4e] La cobertura tech-mainstream. N-05: Xataka (16-abr) publica el primer análisis masivo. Nuevo dato: acuerdo de ene…  
   `{"database":"mod-legislativa","seccion":"4e","tenant":"scriptorium","titulo":"La cobertura tech-mainstream"}`
3. **1.1810** — `HN-S4a` — [S4a] El análisis. Cristóbal [P-04] desmenuza el caso en 83 minutos. Identifica fisuras: ánimo vs beneficio, prueba emp…  
   `{"database":"mod-legislativa","seccion":"4a","tenant":"scriptorium","titulo":"El analisis"}`
4. **1.3071** — `HN-S1d` — [S1d] Digitalización contra feudos analógicos. La industria digitaliza cuando abre mercado nuevo y criminaliza cuando p…  
   `{"database":"mod-legislativa","seccion":"1d","tenant":"scriptorium","titulo":"Digitalizacion contra feudos analogicos"}`
5. **1.3646** — `HN-S1a` — [S1a] La indignación y su institucionalización. Crisis 2008, desahucios, 15M, Podemos, FACUA. David Bravo [P-02] se hac…  
   `{"database":"mod-legislativa","seccion":"1a","tenant":"scriptorium","titulo":"La indignacion y su institucionalizacion"}`

### Q2) hilo narrativo del juicio 2026 propiedad intelectual y preservación
1. **0.7833** — `HN-S3` — [S3] El procedimiento. El entramado Cerezo contra Feo. N-01: el demandante tiene su propia relación con la justicia com…  
   `{"database":"mod-legislativa","seccion":"3","tenant":"scriptorium","titulo":"El procedimiento"}`
2. **0.9447** — `HN-S2` — [S2] El caso nace. Feo construye un archivo cinematográfico online. Impulso: amor al cine y que obras no desaparezcan.…  
   `{"database":"mod-legislativa","seccion":"2","tenant":"scriptorium","titulo":"El caso nace"}`
3. **0.9897** — `HN-S1a` — [S1a] La indignación y su institucionalización. Crisis 2008, desahucios, 15M, Podemos, FACUA. David Bravo [P-02] se hac…  
   `{"database":"mod-legislativa","seccion":"1a","tenant":"scriptorium","titulo":"La indignacion y su institucionalizacion"}`
4. **1.0112** — `HN-S4a` — [S4a] El análisis. Cristóbal [P-04] desmenuza el caso en 83 minutos. Identifica fisuras: ánimo vs beneficio, prueba emp…  
   `{"database":"mod-legislativa","seccion":"4a","tenant":"scriptorium","titulo":"El analisis"}`
5. **1.0642** — `HN-S1e` — [S1e] Posesión contra suscripción. Del producto-objeto (posesión) al servicio-flujo (usufructo sin posesión). Lo que no…  
   `{"database":"mod-legislativa","seccion":"1e","tenant":"scriptorium","titulo":"Posesion contra suscripcion"}`

### Q3) tensión entre alumbrado y ceremonia de la sala judicial
1. **0.9287** — `HN-S0` — [S0] Las dos caras de la sala. Antes del caso, dos imágenes de la justicia preexisten como condiciones de posibilidad:…  
   `{"database":"mod-legislativa","seccion":"0","tenant":"scriptorium","titulo":"Las dos caras de la sala"}`
2. **1.0533** — `HN-S4a` — [S4a] El análisis. Cristóbal [P-04] desmenuza el caso en 83 minutos. Identifica fisuras: ánimo vs beneficio, prueba emp…  
   `{"database":"mod-legislativa","seccion":"4a","tenant":"scriptorium","titulo":"El analisis"}`
3. **1.0536** — `HN-S4g` — [S4g] La espera. El juez [P-03] aún no ha hablado. El veredicto es el lunes 21 de abril. La sala oscilará entre alumbra…  
   `{"database":"mod-legislativa","seccion":"4g","tenant":"scriptorium","titulo":"La espera"}`
4. **1.0628** — `HN-S3` — [S3] El procedimiento. El entramado Cerezo contra Feo. N-01: el demandante tiene su propia relación con la justicia com…  
   `{"database":"mod-legislativa","seccion":"3","tenant":"scriptorium","titulo":"El procedimiento"}`
5. **1.1776** — `HN-S1a` — [S1a] La indignación y su institucionalización. Crisis 2008, desahucios, 15M, Podemos, FACUA. David Bravo [P-02] se hac…  
   `{"database":"mod-legislativa","seccion":"1a","tenant":"scriptorium","titulo":"La indignacion y su institucionalizacion"}`

### Q4) del análisis de Cristóbal al salto institucional con Bustinduy
1. **0.7715** — `HN-S4c` — [S4c] El salto a lo institucional. Facu [P-05] eleva el caso a Bustinduy [P-08] en directo. La indignación [T-01] que s…  
   `{"database":"mod-legislativa","seccion":"4c","tenant":"scriptorium","titulo":"El salto a lo institucional"}`
2. **1.0129** — `HN-S4b` — [S4b] Las vías no exploradas. N-04 extrae nueve ejes del análisis de Cristóbal: ánimo como eje decisivo, contraataque p…  
   `{"database":"mod-legislativa","seccion":"4b","tenant":"scriptorium","titulo":"Las vias no exploradas"}`
3. **1.0393** — `HN-S0` — [S0] Las dos caras de la sala. Antes del caso, dos imágenes de la justicia preexisten como condiciones de posibilidad:…  
   `{"database":"mod-legislativa","seccion":"0","tenant":"scriptorium","titulo":"Las dos caras de la sala"}`
4. **1.0438** — `HN-S3` — [S3] El procedimiento. El entramado Cerezo contra Feo. N-01: el demandante tiene su propia relación con la justicia com…  
   `{"database":"mod-legislativa","seccion":"3","tenant":"scriptorium","titulo":"El procedimiento"}`
5. **1.0509** — `HN-S4a` — [S4a] El análisis. Cristóbal [P-04] desmenuza el caso en 83 minutos. Identifica fisuras: ánimo vs beneficio, prueba emp…  
   `{"database":"mod-legislativa","seccion":"4a","tenant":"scriptorium","titulo":"El analisis"}`

### Q5) dato 11007 vs 40 y cambio de marco narrativo
1. **0.9261** — `HN-S4d` — [S4d] La segunda cola mediática. Rubén Sánchez como amplificador de segundo orden. Huecos [S-06], [S-07], [S-08] reserv…  
   `{"database":"mod-legislativa","seccion":"4d","tenant":"scriptorium","titulo":"La segunda cola mediatica"}`
2. **1.1043** — `HN-S3` — [S3] El procedimiento. El entramado Cerezo contra Feo. N-01: el demandante tiene su propia relación con la justicia com…  
   `{"database":"mod-legislativa","seccion":"3","tenant":"scriptorium","titulo":"El procedimiento"}`
3. **1.1871** — `HN-S4a` — [S4a] El análisis. Cristóbal [P-04] desmenuza el caso en 83 minutos. Identifica fisuras: ánimo vs beneficio, prueba emp…  
   `{"database":"mod-legislativa","seccion":"4a","tenant":"scriptorium","titulo":"El analisis"}`
4. **1.2312** — `HN-S4b` — [S4b] Las vías no exploradas. N-04 extrae nueve ejes del análisis de Cristóbal: ánimo como eje decisivo, contraataque p…  
   `{"database":"mod-legislativa","seccion":"4b","tenant":"scriptorium","titulo":"Las vias no exploradas"}`
5. **1.2467** — `HN-S4c` — [S4c] El salto a lo institucional. Facu [P-05] eleva el caso a Bustinduy [P-08] en directo. La indignación [T-01] que s…  
   `{"database":"mod-legislativa","seccion":"4c","tenant":"scriptorium","titulo":"El salto a lo institucional"}`

---

## Cierre de sección (síntesis automática)
### Hallazgos clave
- La pieza más recurrente del pack es `HN-S4a` (5 apariciones en resultados top).
- La mejor coincidencia global llega con `HN-S4c` para la query «del análisis de Cristóbal al salto institucional con Bustinduy» (distance 0.7715).
- La cobertura de `metadata.seccion` recorre `2`, `4e`, `4a`, `1d`, `1a`, `3`, `1e`, `0`, `4g`, `4c`, `4b`, `4d`.

### Tensiones o contradicciones
- Conviven materiales de marco/origen (`1d`, `1a`, `1e`, `0`) y materiales de cristalización tardía (`4e`, `4a`, `4g`, `4c`, `4b`, `4d`).
- Los hits alternan entre `El caso nace` y `La cobertura tech-mainstream`, señal de pluralidad semántica.

### Hipótesis operativa
- Hipótesis operativa: Cómo se articula el paso de contexto histórico → caso concreto → desenlace abierto.
