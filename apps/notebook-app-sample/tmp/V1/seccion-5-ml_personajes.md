# Sección 5 — `ml_personajes`

## Confirmación de detalle (sí, se puede)
Con `vector-machine mcp` / Chroma se registra el mismo nivel operativo de detalle que en Admin UI:
- `distance`
- `id`
- `document`
- `metadata`

> Nota técnica: menor `distance` = mayor cercanía semántica.

## Configuración de la sección
- **Colección:** `ml_personajes`
- **Etiqueta:** Actores, roles y alianzas
- **Agente sugerido:** `Albacea`
- **Hipótesis:** ¿Qué red mínima de actores explica el movimiento del caso en sala, medios y comunidad?
- **n_results ejecutado:** 5

## Query pack ejecutado
Colección: `ml_personajes`  
`n_results`: 5 por query

1. "perfil de Feo como acusado y marco de acceso al conocimiento"
2. "trayectoria de David Bravo en defensa de casos digitales"
3. "rol de Enrique Cerezo EGEDA Mercury Films FlixOle en la causa"
4. "función de Cristóbal Facu Rubén Sánchez en amplificación del caso"
5. "el sustrato comunitario y preservación distribuida del archivo"

---

## Resultados detallados (top-5 por query)

### Q1) perfil de Feo como acusado y marco de acceso al conocimiento
1. **0.8384** — `P-01` — [P-01] Feo — diplomado licenciado en historia, social y antropología. Divulgador cinematográfico. Constructor del archi…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-01","nombre":"Feo","rol":"acusado","tenant":"scriptorium"}`
2. **0.9407** — `P-08` — [P-08] Bustinduy — Ministro de Derechos Sociales, Consumo y Agenda 2030. Recibe el caso de Facu en directo. No conoce e…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-08","nombre":"Bustinduy","rol":"institucional","tenant":"scriptorium"}`
3. **0.9539** — `P-05` — [P-05] Facu — eleva el caso a Bustinduy en directo durante un stream. Presenta a Zoowoman como proyecto de recuperación…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-05","nombre":"Facu","rol":"amplificador","tenant":"scriptorium"}`
4. **1.0274** — `P-07` — [P-07] Rubén Sánchez — portavoz de FACUA. Defendido en su día por Bravo contra AUSBANC. Posible amplificador de segundo…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-07","nombre":"Rubén Sánchez","rol":"amplificador_potencial","tenant":"scriptorium"}`
5. **1.0287** — `P-02` — [P-02] David Bravo — abogado, ex diputado de Podemos por Almería en la XI legislatura. Autor de 'Copia este libro' (Cre…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-02","nombre":"David Bravo","rol":"defensa","tenant":"scriptorium"}`

### Q2) trayectoria de David Bravo en defensa de casos digitales
1. **1.1883** — `P-04` — [P-04] Cristóbal — dedica 83 minutos de su programa a desmenuzar el caso ante su audiencia. Lo nombra como 'lore profun…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-04","nombre":"Cristóbal","rol":"analista","tenant":"scriptorium"}`
2. **1.2240** — `P-05` — [P-05] Facu — eleva el caso a Bustinduy en directo durante un stream. Presenta a Zoowoman como proyecto de recuperación…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-05","nombre":"Facu","rol":"amplificador","tenant":"scriptorium"}`
3. **1.2542** — `P-08` — [P-08] Bustinduy — Ministro de Derechos Sociales, Consumo y Agenda 2030. Recibe el caso de Facu en directo. No conoce e…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-08","nombre":"Bustinduy","rol":"institucional","tenant":"scriptorium"}`
4. **1.2581** — `P-01` — [P-01] Feo — diplomado licenciado en historia, social y antropología. Divulgador cinematográfico. Constructor del archi…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-01","nombre":"Feo","rol":"acusado","tenant":"scriptorium"}`
5. **1.3375** — `P-06` — [P-06] El sustrato — los consumidores como colectivo. Público de FACUA, seguidores de Facu, suscriptores de La Filmotec…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-06","nombre":"El sustrato","rol":"comunidad","tenant":"scriptorium"}`

### Q3) rol de Enrique Cerezo EGEDA Mercury Films FlixOle en la causa
1. **0.3718** — `P-09` — [P-09] Enrique Cerezo — presidente de EGEDA (entidad de gestión de productores audiovisuales), propietario de Mercury F…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-09","nombre":"Enrique Cerezo","rol":"acusador","tenant":"scriptorium"}`
2. **1.2142** — `P-01` — [P-01] Feo — diplomado licenciado en historia, social y antropología. Divulgador cinematográfico. Constructor del archi…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-01","nombre":"Feo","rol":"acusado","tenant":"scriptorium"}`
3. **1.2753** — `P-03` — [P-03] El juez — aún no ha hablado al corte temporal de esta mitad (17 de abril 2026). El veredicto es el lunes 21 de a…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-03","nombre":"El juez","rol":"tribunal","tenant":"scriptorium"}`
4. **1.2801** — `P-06` — [P-06] El sustrato — los consumidores como colectivo. Público de FACUA, seguidores de Facu, suscriptores de La Filmotec…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-06","nombre":"El sustrato","rol":"comunidad","tenant":"scriptorium"}`
5. **1.4055** — `P-07` — [P-07] Rubén Sánchez — portavoz de FACUA. Defendido en su día por Bravo contra AUSBANC. Posible amplificador de segundo…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-07","nombre":"Rubén Sánchez","rol":"amplificador_potencial","tenant":"scriptorium"}`

### Q4) función de Cristóbal Facu Rubén Sánchez en amplificación del caso
1. **0.9276** — `P-07` — [P-07] Rubén Sánchez — portavoz de FACUA. Defendido en su día por Bravo contra AUSBANC. Posible amplificador de segundo…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-07","nombre":"Rubén Sánchez","rol":"amplificador_potencial","tenant":"scriptorium"}`
2. **0.9368** — `P-02` — [P-02] David Bravo — abogado, ex diputado de Podemos por Almería en la XI legislatura. Autor de 'Copia este libro' (Cre…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-02","nombre":"David Bravo","rol":"defensa","tenant":"scriptorium"}`
3. **1.0530** — `P-08` — [P-08] Bustinduy — Ministro de Derechos Sociales, Consumo y Agenda 2030. Recibe el caso de Facu en directo. No conoce e…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-08","nombre":"Bustinduy","rol":"institucional","tenant":"scriptorium"}`
4. **1.1718** — `P-05` — [P-05] Facu — eleva el caso a Bustinduy en directo durante un stream. Presenta a Zoowoman como proyecto de recuperación…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-05","nombre":"Facu","rol":"amplificador","tenant":"scriptorium"}`
5. **1.1976** — `P-04` — [P-04] Cristóbal — dedica 83 minutos de su programa a desmenuzar el caso ante su audiencia. Lo nombra como 'lore profun…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-04","nombre":"Cristóbal","rol":"analista","tenant":"scriptorium"}`

### Q5) el sustrato comunitario y preservación distribuida del archivo
1. **0.9165** — `P-06` — [P-06] El sustrato — los consumidores como colectivo. Público de FACUA, seguidores de Facu, suscriptores de La Filmotec…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-06","nombre":"El sustrato","rol":"comunidad","tenant":"scriptorium"}`
2. **0.9899** — `P-08` — [P-08] Bustinduy — Ministro de Derechos Sociales, Consumo y Agenda 2030. Recibe el caso de Facu en directo. No conoce e…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-08","nombre":"Bustinduy","rol":"institucional","tenant":"scriptorium"}`
3. **0.9995** — `P-01` — [P-01] Feo — diplomado licenciado en historia, social y antropología. Divulgador cinematográfico. Constructor del archi…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-01","nombre":"Feo","rol":"acusado","tenant":"scriptorium"}`
4. **1.0611** — `P-05` — [P-05] Facu — eleva el caso a Bustinduy en directo durante un stream. Presenta a Zoowoman como proyecto de recuperación…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-05","nombre":"Facu","rol":"amplificador","tenant":"scriptorium"}`
5. **1.1086** — `P-04` — [P-04] Cristóbal — dedica 83 minutos de su programa a desmenuzar el caso ante su audiencia. Lo nombra como 'lore profun…  
   `{"bloque":"A","database":"mod-legislativa","marca":"P-04","nombre":"Cristóbal","rol":"analista","tenant":"scriptorium"}`

---

## Cierre de sección (síntesis automática)
### Hallazgos clave
- La pieza más recurrente del pack es `P-01` (4 apariciones en resultados top).
- La mejor coincidencia global llega con `P-09` para la query «rol de Enrique Cerezo EGEDA Mercury Films FlixOle en la causa» (distance 0.3718).
- La cobertura de `metadata.seccion` recorre `?`.

### Tensiones o contradicciones
- Los resultados tienden a concentrarse en una misma zona narrativa del corpus.
- Los hits alternan entre `P-01` y `P-08`, señal de pluralidad semántica.

### Hipótesis operativa
- Hipótesis operativa: Qué red mínima de actores explica el movimiento del caso en sala, medios y comunidad.
