# Sección 3 — `ml_recursos`

## Confirmación de detalle (sí, se puede)
Con `vector-machine mcp` / Chroma se registra el mismo nivel operativo de detalle que en Admin UI:
- `distance`
- `id`
- `document`
- `metadata`

> Nota técnica: menor `distance` = mayor cercanía semántica.

## Configuración de la sección
- **Colección:** `ml_recursos`
- **Etiqueta:** Marcos conceptuales y legales
- **Agente sugerido:** `Explore`
- **Hipótesis:** ¿Qué marco explica mejor la disputa: derecho positivo, commons digitales o crítica del monopolio?
- **n_results ejecutado:** 5

## Query pack ejecutado
Colección: `ml_recursos`  
`n_results`: 5 por query

1. "sala judicial como espacio de alumbrado en conflictos culturales"
2. "sala judicial como ceremonia del tirano y lawfare"
3. "genealogía FOSS de GNU a Aaron Swartz y cultura de copia"
4. "gradación de licencias GPL BSD MIT Creative Commons copyright"
5. "monopolio como eficiencia Peter Thiel y captura regulatoria"

---

## Resultados detallados (top-5 por query)

### Q1) sala judicial como espacio de alumbrado en conflictos culturales
1. **0.6918** — `R-01` — [R-01] La sala como espacio de alumbrado. Las películas americanas de abogados. La Satyagraha de Gandhi. La desobedienc…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-01","subtipo":"justicia_alumbrado","tenant":"scriptorium","tipo":"marco_conceptual"}`
2. **0.7568** — `R-09` — [R-09] El aparato judicial español opera entre bloqueos institucionales, lawfare, disfunciones operativas y capacidad r…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-09","subtipo":"aparato_judicial_es","tenant":"scriptorium","tipo":"marco_legal"}`
3. **1.0947** — `R-02` — [R-02] La sala como ceremonia del tirano. Habas contadas. El veredicto escrito antes de la vista. El lawfare como forma…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-02","subtipo":"justicia_ceremonia","tenant":"scriptorium","tipo":"marco_conceptual"}`
4. **1.2728** — `R-06` — [R-06] Digitalización contra feudos analógicos. Cronología de tensiones: CD (1982), DMCA (1998), RIAA vs Napster (1999)…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-06","subtipo":"digitalizacion","tenant":"scriptorium","tipo":"contexto_historico"}`
5. **1.2853** — `R-07` — [R-07] Posesión contra suscripción. VHS/DVD (posesión, préstamo, 2ª mano), archivo digital (posesión ambigua, P2P), str…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-07","subtipo":"posesion_suscripcion","tenant":"scriptorium","tipo":"marco_conceptual"}`

### Q2) sala judicial como ceremonia del tirano y lawfare
1. **0.5401** — `R-09` — [R-09] El aparato judicial español opera entre bloqueos institucionales, lawfare, disfunciones operativas y capacidad r…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-09","subtipo":"aparato_judicial_es","tenant":"scriptorium","tipo":"marco_legal"}`
2. **0.7104** — `R-02` — [R-02] La sala como ceremonia del tirano. Habas contadas. El veredicto escrito antes de la vista. El lawfare como forma…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-02","subtipo":"justicia_ceremonia","tenant":"scriptorium","tipo":"marco_conceptual"}`
3. **0.8929** — `R-01` — [R-01] La sala como espacio de alumbrado. Las películas americanas de abogados. La Satyagraha de Gandhi. La desobedienc…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-01","subtipo":"justicia_alumbrado","tenant":"scriptorium","tipo":"marco_conceptual"}`
4. **1.2357** — `R-10` — [R-10] Thiel invertido — closing frame. La configuración de la semana entre el juicio y el veredicto: commons que cuidó…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-10","subtipo":"thiel_invertido","tenant":"scriptorium","tipo":"marco_conceptual"}`
5. **1.2948** — `R-05` — [R-05] Peter Thiel, Zero to One (2014): 'Competition is for losers.' El monopolio no como fallo del mercado sino como s…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-05","subtipo":"monopolio_doctrina","tenant":"scriptorium","tipo":"marco_teorico"}`

### Q3) genealogía FOSS de GNU a Aaron Swartz y cultura de copia
1. **1.0672** — `R-03` — [R-03] La escena FOSS/hacker. Hitos: Stallman anuncia GNU (1983), Torvalds publica Linux 0.01 (1991), DeCSS/Johansen (1…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-03","subtipo":"FOSS_hacker","tenant":"scriptorium","tipo":"contexto_historico"}`
2. **1.0683** — `R-01` — [R-01] La sala como espacio de alumbrado. Las películas americanas de abogados. La Satyagraha de Gandhi. La desobedienc…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-01","subtipo":"justicia_alumbrado","tenant":"scriptorium","tipo":"marco_conceptual"}`
3. **1.1621** — `R-06` — [R-06] Digitalización contra feudos analógicos. Cronología de tensiones: CD (1982), DMCA (1998), RIAA vs Napster (1999)…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-06","subtipo":"digitalizacion","tenant":"scriptorium","tipo":"contexto_historico"}`
4. **1.1673** — `R-02` — [R-02] La sala como ceremonia del tirano. Habas contadas. El veredicto escrito antes de la vista. El lawfare como forma…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-02","subtipo":"justicia_ceremonia","tenant":"scriptorium","tipo":"marco_conceptual"}`
5. **1.2299** — `R-09` — [R-09] El aparato judicial español opera entre bloqueos institucionales, lawfare, disfunciones operativas y capacidad r…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-09","subtipo":"aparato_judicial_es","tenant":"scriptorium","tipo":"marco_legal"}`

### Q4) gradación de licencias GPL BSD MIT Creative Commons copyright
1. **0.7010** — `R-04` — [R-04] Las licencias como gradación de derechos y obligaciones. GPL (copyleft viral), BSD/MIT (permisivo), CC BY-NC-SA…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-04","subtipo":"licencias","tenant":"scriptorium","tipo":"marco_legal"}`
2. **1.5064** — `R-03` — [R-03] La escena FOSS/hacker. Hitos: Stallman anuncia GNU (1983), Torvalds publica Linux 0.01 (1991), DeCSS/Johansen (1…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-03","subtipo":"FOSS_hacker","tenant":"scriptorium","tipo":"contexto_historico"}`
3. **1.6383** — `R-06` — [R-06] Digitalización contra feudos analógicos. Cronología de tensiones: CD (1982), DMCA (1998), RIAA vs Napster (1999)…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-06","subtipo":"digitalizacion","tenant":"scriptorium","tipo":"contexto_historico"}`
4. **1.6957** — `R-08` — [R-08] Windows vs Linux como caso paradigmático de guerra sucia. Halloween Documents (1998), Ballmer 'Linux is a cancer…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-08","subtipo":"competencia_sucia","tenant":"scriptorium","tipo":"contexto_historico"}`
5. **1.7173** — `R-09` — [R-09] El aparato judicial español opera entre bloqueos institucionales, lawfare, disfunciones operativas y capacidad r…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-09","subtipo":"aparato_judicial_es","tenant":"scriptorium","tipo":"marco_legal"}`

### Q5) monopolio como eficiencia Peter Thiel y captura regulatoria
1. **0.8447** — `R-05` — [R-05] Peter Thiel, Zero to One (2014): 'Competition is for losers.' El monopolio no como fallo del mercado sino como s…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-05","subtipo":"monopolio_doctrina","tenant":"scriptorium","tipo":"marco_teorico"}`
2. **1.1917** — `R-10` — [R-10] Thiel invertido — closing frame. La configuración de la semana entre el juicio y el veredicto: commons que cuidó…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-10","subtipo":"thiel_invertido","tenant":"scriptorium","tipo":"marco_conceptual"}`
3. **1.2916** — `R-09` — [R-09] El aparato judicial español opera entre bloqueos institucionales, lawfare, disfunciones operativas y capacidad r…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-09","subtipo":"aparato_judicial_es","tenant":"scriptorium","tipo":"marco_legal"}`
4. **1.3347** — `R-02` — [R-02] La sala como ceremonia del tirano. Habas contadas. El veredicto escrito antes de la vista. El lawfare como forma…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-02","subtipo":"justicia_ceremonia","tenant":"scriptorium","tipo":"marco_conceptual"}`
5. **1.3376** — `R-07` — [R-07] Posesión contra suscripción. VHS/DVD (posesión, préstamo, 2ª mano), archivo digital (posesión ambigua, P2P), str…  
   `{"bloque":"E","database":"mod-legislativa","marca":"R-07","subtipo":"posesion_suscripcion","tenant":"scriptorium","tipo":"marco_conceptual"}`

---

## Cierre de sección (síntesis automática)
### Hallazgos clave
- La pieza más recurrente del pack es `R-09` (5 apariciones en resultados top).
- La mejor coincidencia global llega con `R-09` para la query «sala judicial como ceremonia del tirano y lawfare» (distance 0.5401).
- La cobertura de `metadata.seccion` recorre `?`.

### Tensiones o contradicciones
- Los resultados tienden a concentrarse en una misma zona narrativa del corpus.
- Los hits alternan entre `R-01` y `R-09`, señal de pluralidad semántica.

### Hipótesis operativa
- Hipótesis operativa: Qué marco explica mejor la disputa: derecho positivo, commons digitales o crítica del monopolio.
