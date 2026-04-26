# Sección 2 — `ml_piezas_media`

## Confirmación de detalle (sí, se puede)
Con `vector-machine mcp` / Chroma se registra el mismo nivel operativo de detalle que en Admin UI:
- `distance`
- `id`
- `document`
- `metadata`

> Nota técnica: menor `distance` = mayor cercanía semántica.

## Configuración de la sección
- **Colección:** `ml_piezas_media`
- **Etiqueta:** Piezas públicas y amplificación
- **Agente sugerido:** `Lector`
- **Hipótesis:** ¿Qué piezas activan el cambio de escala del caso y cuáles consolidan evidencia pública?
- **n_results ejecutado:** 6

## Query pack ejecutado
Colección: `ml_piezas_media`  
`n_results`: 6 por query

1. "publicaciones de Feo antes del veredicto y marco del caso"
2. "análisis de Cristóbal 83 minutos fisuras ánimo beneficio"
3. "clip de Facu con Bustinduy que se estudie se investigue"
4. "hilo David Bizarro datos duros sobre Cerezo"
5. "preservación comunitaria del canal de YouTube con backups"

---

## Resultados detallados (top-6 por query)

### Q1) publicaciones de Feo antes del veredicto y marco del caso
1. **0.8417** — `S-01` — [S-01] Feo publica 'Os explico mi detención'. No es un comunicado judicial: habla a su audiencia desde lo que acaba de…  
   `{"bloque":"B","database":"mod-legislativa","marca":"S-01","tenant":"scriptorium","tipo":"social_acusado"}`
2. **0.9030** — `N-01` — [N-01] Dato contextual: el propio Cerezo fue condenado en primera instancia como cooperador necesario de apropiación in…  
   `{"bloque":"C","database":"mod-legislativa","marca":"N-01","medio":"contexto","tenant":"scriptorium","tipo":"noticia"}`
3. **0.9602** — `S-03` — [S-03] El programa de Cristóbal [P-04]: 83 minutos analizando el caso ante su audiencia. Nombra el caso 'lore profundo…  
   `{"bloque":"B","database":"mod-legislativa","marca":"S-03","tenant":"scriptorium","tipo":"social_analisis"}`
4. **0.9949** — `S-02` — [S-02] Feo publica 'Algo sobre MI JUICIO' a la espera del veredicto. Enumera lo que le piden: cierre de redes, 2 años y…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-17","marca":"S-02","tenant":"scriptorium","tipo":"social_acusado"}`
5. **1.0445** — `N-03` — [N-03] El 13 de enero de 2022, el Diario de Burgos publica: 'Auge y caída de un piárata burgalés'. Marco: Sucesos, prop…  
   `{"bloque":"C","database":"mod-legislativa","fecha":"2022-01-13","marca":"N-03","medio":"Diario de Burgos","tenant":"scriptorium","tipo":"noticia"}`
6. **1.0448** — `S-09` — [S-09] El 15 de abril, David Bizarro (@DavidBizarro) publica hilo con datos duros de Cerezo que los grandes medios no h…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-15","marca":"S-09","tenant":"scriptorium","tipo":"social_datos"}`

### Q2) análisis de Cristóbal 83 minutos fisuras ánimo beneficio
1. **0.5574** — `N-04` — [N-04] Crónica analítica para escrivivir.co. Extrae del análisis de Cristóbal nueve ejes propositivos: ánimo como eje d…  
   `{"bloque":"C","database":"mod-legislativa","marca":"N-04","medio":"escrivivir.co","tenant":"scriptorium","tipo":"noticia_analitica"}`
2. **0.6610** — `S-03` — [S-03] El programa de Cristóbal [P-04]: 83 minutos analizando el caso ante su audiencia. Nombra el caso 'lore profundo…  
   `{"bloque":"B","database":"mod-legislativa","marca":"S-03","tenant":"scriptorium","tipo":"social_analisis"}`
3. **1.0754** — `S-02` — [S-02] Feo publica 'Algo sobre MI JUICIO' a la espera del veredicto. Enumera lo que le piden: cierre de redes, 2 años y…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-17","marca":"S-02","tenant":"scriptorium","tipo":"social_acusado"}`
4. **1.0790** — `S-10` — [S-10] Feo revela en redes el dato que invierte el relato: EGEDA reclama 11.007 películas pero tiene derechos acreditad…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-15","marca":"S-10","tenant":"scriptorium","tipo":"social_datos"}`
5. **1.0821** — `S-12` — [S-12] Pieza que permite leer la idea feliz de Cristóbal también como forma operativa de una segunda ola, no solo como…  
   `{"bloque":"B","database":"mod-legislativa","marca":"S-12","tenant":"scriptorium","tipo":"social_soporte"}`
6. **1.0904** — `S-04` — [S-04] La idea feliz (+). Surge del análisis de Cristóbal y de la interacción con su audiencia. Un prototipo que crista…  
   `{"bloque":"B","database":"mod-legislativa","emergencia":"true","marca":"S-04","tenant":"scriptorium","tipo":"social_idea"}`

### Q3) clip de Facu con Bustinduy que se estudie se investigue
1. **0.7906** — `S-05` — [S-05] Facu [P-05] eleva el caso a Bustinduy [P-08] en directo. Transcripción completa (4 minutos, GPU) preservada. Bus…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-09","marca":"S-05","tenant":"scriptorium","tipo":"social_institucional"}`
2. **0.8528** — `S-02` — [S-02] Feo publica 'Algo sobre MI JUICIO' a la espera del veredicto. Enumera lo que le piden: cierre de redes, 2 años y…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-17","marca":"S-02","tenant":"scriptorium","tipo":"social_acusado"}`
3. **1.0252** — `N-02` — [N-02] El 9 de abril de 2026, el Diario Socialista publica: 'El capital cinematográfico pide cárcel y 870.000 euros con…  
   `{"bloque":"C","database":"mod-legislativa","fecha":"2026-04-09","marca":"N-02","medio":"Diario Socialista","tenant":"scriptorium","tipo":"noticia"}`
4. **1.1141** — `N-03` — [N-03] El 13 de enero de 2022, el Diario de Burgos publica: 'Auge y caída de un piárata burgalés'. Marco: Sucesos, prop…  
   `{"bloque":"C","database":"mod-legislativa","fecha":"2022-01-13","marca":"N-03","medio":"Diario de Burgos","tenant":"scriptorium","tipo":"noticia"}`
5. **1.1164** — `S-11` — [S-11] Entre el 14 y 15 de abril, cuatro personas de la comunidad actúan de forma independiente para preservar el canal…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-14","marca":"S-11","tenant":"scriptorium","tipo":"social_preservacion"}`
6. **1.1223** — `S-09` — [S-09] El 15 de abril, David Bizarro (@DavidBizarro) publica hilo con datos duros de Cerezo que los grandes medios no h…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-15","marca":"S-09","tenant":"scriptorium","tipo":"social_datos"}`

### Q4) hilo David Bizarro datos duros sobre Cerezo
1. **1.0744** — `S-09` — [S-09] El 15 de abril, David Bizarro (@DavidBizarro) publica hilo con datos duros de Cerezo que los grandes medios no h…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-15","marca":"S-09","tenant":"scriptorium","tipo":"social_datos"}`
2. **1.1188** — `N-01` — [N-01] Dato contextual: el propio Cerezo fue condenado en primera instancia como cooperador necesario de apropiación in…  
   `{"bloque":"C","database":"mod-legislativa","marca":"N-01","medio":"contexto","tenant":"scriptorium","tipo":"noticia"}`
3. **1.2660** — `S-02` — [S-02] Feo publica 'Algo sobre MI JUICIO' a la espera del veredicto. Enumera lo que le piden: cierre de redes, 2 años y…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-17","marca":"S-02","tenant":"scriptorium","tipo":"social_acusado"}`
4. **1.2689** — `S-10` — [S-10] Feo revela en redes el dato que invierte el relato: EGEDA reclama 11.007 películas pero tiene derechos acreditad…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-15","marca":"S-10","tenant":"scriptorium","tipo":"social_datos"}`
5. **1.2836** — `N-05` — [N-05] El 16 de abril, Xataka publica el primer análisis desde un medio de alcance masivo: 'La persona más poderosa del…  
   `{"bloque":"C","database":"mod-legislativa","fecha":"2026-04-16","marca":"N-05","medio":"Xataka","tenant":"scriptorium","tipo":"noticia"}`
6. **1.2928** — `N-03` — [N-03] El 13 de enero de 2022, el Diario de Burgos publica: 'Auge y caída de un piárata burgalés'. Marco: Sucesos, prop…  
   `{"bloque":"C","database":"mod-legislativa","fecha":"2022-01-13","marca":"N-03","medio":"Diario de Burgos","tenant":"scriptorium","tipo":"noticia"}`

### Q5) preservación comunitaria del canal de YouTube con backups
1. **0.5334** — `S-11` — [S-11] Entre el 14 y 15 de abril, cuatro personas de la comunidad actúan de forma independiente para preservar el canal…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-14","marca":"S-11","tenant":"scriptorium","tipo":"social_preservacion"}`
2. **1.1264** — `S-02` — [S-02] Feo publica 'Algo sobre MI JUICIO' a la espera del veredicto. Enumera lo que le piden: cierre de redes, 2 años y…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-17","marca":"S-02","tenant":"scriptorium","tipo":"social_acusado"}`
3. **1.1393** — `N-02` — [N-02] El 9 de abril de 2026, el Diario Socialista publica: 'El capital cinematográfico pide cárcel y 870.000 euros con…  
   `{"bloque":"C","database":"mod-legislativa","fecha":"2026-04-09","marca":"N-02","medio":"Diario Socialista","tenant":"scriptorium","tipo":"noticia"}`
4. **1.2180** — `N-05` — [N-05] El 16 de abril, Xataka publica el primer análisis desde un medio de alcance masivo: 'La persona más poderosa del…  
   `{"bloque":"C","database":"mod-legislativa","fecha":"2026-04-16","marca":"N-05","medio":"Xataka","tenant":"scriptorium","tipo":"noticia"}`
5. **1.2724** — `S-01` — [S-01] Feo publica 'Os explico mi detención'. No es un comunicado judicial: habla a su audiencia desde lo que acaba de…  
   `{"bloque":"B","database":"mod-legislativa","marca":"S-01","tenant":"scriptorium","tipo":"social_acusado"}`
6. **1.2894** — `S-05` — [S-05] Facu [P-05] eleva el caso a Bustinduy [P-08] en directo. Transcripción completa (4 minutos, GPU) preservada. Bus…  
   `{"bloque":"B","database":"mod-legislativa","fecha":"2026-04-09","marca":"S-05","tenant":"scriptorium","tipo":"social_institucional"}`

---

## Cierre de sección (síntesis automática)
### Hallazgos clave
- La pieza más recurrente del pack es `S-02` (5 apariciones en resultados top).
- La mejor coincidencia global llega con `S-11` para la query «preservación comunitaria del canal de YouTube con backups» (distance 0.5334).
- La cobertura de `metadata.seccion` recorre `?`.

### Tensiones o contradicciones
- Los resultados tienden a concentrarse en una misma zona narrativa del corpus.
- Los hits alternan entre `S-01` y `N-01`, señal de pluralidad semántica.

### Hipótesis operativa
- Hipótesis operativa: Qué piezas activan el cambio de escala del caso y cuáles consolidan evidencia pública.
