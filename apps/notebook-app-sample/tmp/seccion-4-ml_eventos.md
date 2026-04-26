# Sección 4 — `ml_eventos`

## Confirmación de detalle (sí, se puede)
Con `vector-machine mcp` / Chroma se registra el mismo nivel operativo de detalle que en Admin UI:
- `distance`
- `id`
- `document`
- `metadata`

> Nota técnica: menor `distance` = mayor cercanía semántica.

## Configuración de la sección
- **Colección:** `ml_eventos`
- **Etiqueta:** Línea temporal y causalidad
- **Agente sugerido:** `Lector`
- **Hipótesis:** ¿Cuáles son los eventos pivote que vuelven inevitable el conflicto judicial?
- **n_results ejecutado:** 6

## Query pack ejecutado
Colección: `ml_eventos`  
`n_results`: 6 por query

1. "crisis 2008 indignación desahucios y percepción institucional"
2. "institucionalización 15M Podemos FACUA y efectos en cultura digital"
3. "origen Zoowoman amor al cine y problema de loss media"
4. "núcleo de acusación lucro directo indirecto cesante 870000"
5. "juicio 9 abril 2026 demora procesal y veredicto 21 abril"

---

## Resultados detallados (top-6 por query)

### Q1) crisis 2008 indignación desahucios y percepción institucional
1. **0.5920** — `T-01` — [T-01] La indignación. Crisis de 2008, desahucios, experiencia vivida de que las instituciones sirven al acreedor. No u…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-01","tenant":"scriptorium","tipo":"sustrato_historico"}`
2. **1.0939** — `T-02` — [T-02] La institucionalización de la indignación. El 15M (2011) se convierte en Podemos (2014), FACUA gana peso como má…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-02","tenant":"scriptorium","tipo":"sustrato_historico"}`
3. **1.1305** — `T-08` — [T-08] 'Apropiarse' — poner a disposición del público — es el acto jurídico tipificado. Con licencia (legal) o sin ella…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-08","tenant":"scriptorium","tipo":"marco_legal"}`
4. **1.1830** — `T-12` — [T-12] El juicio. Vista oral, 9 de abril de 2026. David Bravo asume la defensa de Feo. El letrado que defendió a Pablo…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2026-04-09","marca":"T-12","tenant":"scriptorium","tipo":"juicio"}`
5. **1.2108** — `T-11` — [T-11] La demora de 4 años. Instrucción larga entre la denuncia y la vista oral. El tiempo procesal es en sí mismo cast…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-11","tenant":"scriptorium","tipo":"procedimiento"}`
6. **1.2439** — `T-13` — [T-13] Las penas solicitadas por la acusación: indemnización 870.000€, pena privativa de libertad 2 años y medio, borra…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2026-04-09","marca":"T-13","tenant":"scriptorium","tipo":"penas"}`

### Q2) institucionalización 15M Podemos FACUA y efectos en cultura digital
1. **1.1437** — `T-05` — [T-05] Loss media. Películas, series, documentales que no están en ninguna plataforma, no se editan en físico, no se pr…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-05","tenant":"scriptorium","tipo":"concepto"}`
2. **1.1549** — `T-01` — [T-01] La indignación. Crisis de 2008, desahucios, experiencia vivida de que las instituciones sirven al acreedor. No u…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-01","tenant":"scriptorium","tipo":"sustrato_historico"}`
3. **1.1849** — `T-09` — [T-09] El lucro. Tres categorías enfrentadas: lucro directo (negado por Feo: sin publicidad, sin suscripciones), lucro…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2022-2026","marca":"T-09","tenant":"scriptorium","tipo":"nucleo_acusacion"}`
4. **1.2837** — `T-13` — [T-13] Las penas solicitadas por la acusación: indemnización 870.000€, pena privativa de libertad 2 años y medio, borra…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2026-04-09","marca":"T-13","tenant":"scriptorium","tipo":"penas"}`
5. **1.2879** — `T-02` — [T-02] La institucionalización de la indignación. El 15M (2011) se convierte en Podemos (2014), FACUA gana peso como má…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-02","tenant":"scriptorium","tipo":"sustrato_historico"}`
6. **1.2897** — `T-11` — [T-11] La demora de 4 años. Instrucción larga entre la denuncia y la vista oral. El tiempo procesal es en sí mismo cast…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-11","tenant":"scriptorium","tipo":"procedimiento"}`

### Q3) origen Zoowoman amor al cine y problema de loss media
1. **0.6922** — `T-04` — [T-04] Amor al cine. El impulso de quien ve que obras desaparecen y actúa para que no desaparezcan. Origen de Zoowoman.  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-04","tenant":"scriptorium","tipo":"origen_caso"}`
2. **0.8631** — `T-06` — [T-06] La Filmoteca Maldita / Zoowoman. Repositorio colectivo, sin ánimo de lucro, que rescata lo que el mercado abando…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-06","tenant":"scriptorium","tipo":"origen_caso"}`
3. **0.9654** — `T-05` — [T-05] Loss media. Películas, series, documentales que no están en ninguna plataforma, no se editan en físico, no se pr…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-05","tenant":"scriptorium","tipo":"concepto"}`
4. **0.9983** — `T-09` — [T-09] El lucro. Tres categorías enfrentadas: lucro directo (negado por Feo: sin publicidad, sin suscripciones), lucro…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2022-2026","marca":"T-09","tenant":"scriptorium","tipo":"nucleo_acusacion"}`
5. **1.0932** — `T-13` — [T-13] Las penas solicitadas por la acusación: indemnización 870.000€, pena privativa de libertad 2 años y medio, borra…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2026-04-09","marca":"T-13","tenant":"scriptorium","tipo":"penas"}`
6. **1.2065** — `T-12` — [T-12] El juicio. Vista oral, 9 de abril de 2026. David Bravo asume la defensa de Feo. El letrado que defendió a Pablo…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2026-04-09","marca":"T-12","tenant":"scriptorium","tipo":"juicio"}`

### Q4) núcleo de acusación lucro directo indirecto cesante 870000
1. **1.2414** — `T-10` — [T-10] LA CAUSA. El entramado de Cerezo interpone acción penal contra Feo. EGEDA, Mercury Films, FlixOlé contra un arch…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-10","tenant":"scriptorium","tipo":"procedimiento"}`
2. **1.2572** — `T-01` — [T-01] La indignación. Crisis de 2008, desahucios, experiencia vivida de que las instituciones sirven al acreedor. No u…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-01","tenant":"scriptorium","tipo":"sustrato_historico"}`
3. **1.3467** — `T-13` — [T-13] Las penas solicitadas por la acusación: indemnización 870.000€, pena privativa de libertad 2 años y medio, borra…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2026-04-09","marca":"T-13","tenant":"scriptorium","tipo":"penas"}`
4. **1.3836** — `T-09` — [T-09] El lucro. Tres categorías enfrentadas: lucro directo (negado por Feo: sin publicidad, sin suscripciones), lucro…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2022-2026","marca":"T-09","tenant":"scriptorium","tipo":"nucleo_acusacion"}`
5. **1.4505** — `T-11` — [T-11] La demora de 4 años. Instrucción larga entre la denuncia y la vista oral. El tiempo procesal es en sí mismo cast…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-11","tenant":"scriptorium","tipo":"procedimiento"}`
6. **1.4540** — `T-05` — [T-05] Loss media. Películas, series, documentales que no están en ninguna plataforma, no se editan en físico, no se pr…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-05","tenant":"scriptorium","tipo":"concepto"}`

### Q5) juicio 9 abril 2026 demora procesal y veredicto 21 abril
1. **0.8616** — `T-14` — [T-14] El veredicto. Lunes 21 de abril de 2026. Aún no conocido al corte temporal de la primera mitad del hilo (17-abr-…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2026-04-21","marca":"T-14","tenant":"scriptorium","tipo":"veredicto_pendiente"}`
2. **0.9304** — `T-12` — [T-12] El juicio. Vista oral, 9 de abril de 2026. David Bravo asume la defensa de Feo. El letrado que defendió a Pablo…  
   `{"bloque":"D","database":"mod-legislativa","fecha_aprox":"2026-04-09","marca":"T-12","tenant":"scriptorium","tipo":"juicio"}`
3. **1.0712** — `T-08` — [T-08] 'Apropiarse' — poner a disposición del público — es el acto jurídico tipificado. Con licencia (legal) o sin ella…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-08","tenant":"scriptorium","tipo":"marco_legal"}`
4. **1.0817** — `T-11` — [T-11] La demora de 4 años. Instrucción larga entre la denuncia y la vista oral. El tiempo procesal es en sí mismo cast…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-11","tenant":"scriptorium","tipo":"procedimiento"}`
5. **1.0823** — `T-04` — [T-04] Amor al cine. El impulso de quien ve que obras desaparecen y actúa para que no desaparezcan. Origen de Zoowoman.  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-04","tenant":"scriptorium","tipo":"origen_caso"}`
6. **1.1264** — `T-01` — [T-01] La indignación. Crisis de 2008, desahucios, experiencia vivida de que las instituciones sirven al acreedor. No u…  
   `{"bloque":"D","database":"mod-legislativa","marca":"T-01","tenant":"scriptorium","tipo":"sustrato_historico"}`

---

## Cierre de sección (síntesis automática)
### Hallazgos clave
- La pieza más recurrente del pack es `T-01` (4 apariciones en resultados top).
- La mejor coincidencia global llega con `T-01` para la query «crisis 2008 indignación desahucios y percepción institucional» (distance 0.5920).
- La cobertura de `metadata.seccion` recorre `?`.

### Tensiones o contradicciones
- Los resultados tienden a concentrarse en una misma zona narrativa del corpus.
- Los hits alternan entre `T-01` y `T-02`, señal de pluralidad semántica.

### Hipótesis operativa
- Hipótesis operativa: Cuáles son los eventos pivote que vuelven inevitable el conflicto judicial.
