# Plantilla de trabajo — Pack mínimo de Semantic-Queries (`ml_*`)

> Objetivo: definir un **pack mínimo básico** de consultas semánticas (`query_texts`) por colección para usar con Chroma DB.
> Flujo: completar **una sección cada vez** y asignar **un agente distinto** por sección.

---

## 1) `ml_hilo_narrativo` — Narrativa estructural del caso

### Agente asignado
- **Agente sugerido:** `Explore`
- **Responsabilidad:** mapear arcos causales, tensiones y puntos de inflexión del hilo.

### Hipótesis de exploración
- ¿Cómo se articula el paso de contexto histórico → caso concreto → desenlace abierto?

### Pack mínimo básico de `query_texts`
1. "transición de indignación a institucionalización en el caso Feo Zoowoman"
2. "hilo narrativo del juicio 2026 propiedad intelectual y preservación"
3. "tensión entre alumbrado y ceremonia de la sala judicial"
4. "del análisis de Cristóbal al salto institucional con Bustinduy"
5. "dato 11007 vs 40 y cambio de marco narrativo"

### Filtros/ajustes sugeridos
- `n_results`: 5–8
- Priorizar pasajes con referencias cruzadas a `R-*`, `T-*`, `S-*`, `P-*`.

### Notas de síntesis (a completar)
- Hallazgos clave:
- Fragmentos ancla:
- Preguntas abiertas:

---

## 2) `ml_piezas_media` — Piezas públicas y amplificación

### Agente asignado
- **Agente sugerido:** `Lector`
- **Responsabilidad:** extraer secuencia mediática y dinámica de amplificación social/institucional.

### Hipótesis de exploración
- ¿Qué piezas activan el cambio de escala del caso y cuáles consolidan evidencia pública?

### Pack mínimo básico de `query_texts`
1. "publicaciones de Feo antes del veredicto y marco del caso"
2. "análisis de Cristóbal 83 minutos fisuras ánimo beneficio"
3. "clip de Facu con Bustinduy que se estudie se investigue"
4. "hilo David Bizarro datos duros sobre Cerezo"
5. "preservación comunitaria del canal de YouTube con backups"

### Filtros/ajustes sugeridos
- `n_results`: 6–10
- Comparar resultados `S-*` vs `N-*` (social vs noticias).

### Notas de síntesis (a completar)
- Hallazgos clave:
- Fragmentos ancla:
- Preguntas abiertas:

---

## 3) `ml_recursos` — Marcos conceptuales y legales

### Agente asignado
- **Agente sugerido:** `Explore`
- **Responsabilidad:** estabilizar vocabulario conceptual para consultas de alta precisión.

### Hipótesis de exploración
- ¿Qué marco explica mejor la disputa: derecho positivo, commons digitales o crítica del monopolio?

### Pack mínimo básico de `query_texts`
1. "sala judicial como espacio de alumbrado en conflictos culturales"
2. "sala judicial como ceremonia del tirano y lawfare"
3. "genealogía FOSS de GNU a Aaron Swartz y cultura de copia"
4. "gradación de licencias GPL BSD MIT Creative Commons copyright"
5. "monopolio como eficiencia Peter Thiel y captura regulatoria"

### Filtros/ajustes sugeridos
- `n_results`: 5–7
- Aumentar recall con variantes: "propiedad intelectual", "derechos de autor", "acceso al conocimiento".

### Notas de síntesis (a completar)
- Hallazgos clave:
- Fragmentos ancla:
- Preguntas abiertas:

---

## 4) `ml_eventos` — Línea temporal y causalidad

### Agente asignado
- **Agente sugerido:** `Lector`
- **Responsabilidad:** reconstruir cronología mínima verificable (2008 → 2026).

### Hipótesis de exploración
- ¿Cuáles son los eventos pivote que vuelven inevitable el conflicto judicial?

### Pack mínimo básico de `query_texts`
1. "crisis 2008 indignación desahucios y percepción institucional"
2. "institucionalización 15M Podemos FACUA y efectos en cultura digital"
3. "origen Zoowoman amor al cine y problema de loss media"
4. "núcleo de acusación lucro directo indirecto cesante 870000"
5. "juicio 9 abril 2026 demora procesal y veredicto 21 abril"

### Filtros/ajustes sugeridos
- `n_results`: 6–9
- Ordenar síntesis final por `T-01` ... `T-14`.

### Notas de síntesis (a completar)
- Hallazgos clave:
- Fragmentos ancla:
- Preguntas abiertas:

---

## 5) `ml_personajes` — Actores, roles y alianzas

### Agente asignado
- **Agente sugerido:** `Albacea` *(o `Lector` si preferís solo recuperación)*
- **Responsabilidad:** perfilar actores y detectar relaciones funcionales (acusación, defensa, amplificación, comunidad).

### Hipótesis de exploración
- ¿Qué red mínima de actores explica el movimiento del caso en sala, medios y comunidad?

### Pack mínimo básico de `query_texts`
1. "perfil de Feo como acusado y marco de acceso al conocimiento"
2. "trayectoria de David Bravo en defensa de casos digitales"
3. "rol de Enrique Cerezo EGEDA Mercury Films FlixOle en la causa"
4. "función de Cristóbal Facu Rubén Sánchez en amplificación del caso"
5. "el sustrato comunitario y preservación distribuida del archivo"

### Filtros/ajustes sugeridos
- `n_results`: 5–8
- Priorizar documentos con `rol` y `marca` en metadata.

### Notas de síntesis (a completar)
- Hallazgos clave:
- Fragmentos ancla:
- Preguntas abiertas:

---

## Formato de ejecución recomendado (para cada sección)

1. Lanzar consultas con el pack mínimo (`query_texts`).
2. Guardar top resultados (id, distancia, extracto).
3. Refinar 1–2 queries según ruido/precisión.
4. Cerrar sección con:
   - 3 hallazgos verificables
   - 2 tensiones o contradicciones
   - 1 hipótesis operativa para la novela

---

## Plantilla rápida de registro por iteración

- **Colección:**
- **Agente:**
- **Queries ejecutadas:**
- **Resultados más útiles (top 5):**
- **Qué faltó / siguiente ajuste:**
