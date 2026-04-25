# Skill: corpus-vectorial — README

> Documentación humana complementaria al `SKILL.md`.

## Para usuarios

### Añadir un proyecto nuevo en 4 pasos

1. **Copia un manifest existente** como base:
   ```bash
   cp .github/skills/corpus-vectorial/examples/manifest.mapas.yml \
      .github/skills/corpus-vectorial/examples/manifest.atlas.yml
   ```

2. **Edita** los campos: `nick`, `proyecto`, `source_root`, `sources`, `palette`, `banner`.
   Dentro de cada `source`, ajusta al menos: `file`, `short_id`, `collection_suffix`, `label`.
   Recomendado: también `bloque`, `tipo` y `summary`.

3. **Invoca el slash command** en VS Code Copilot Chat:
   ```
   /scaffold-corpus .github/skills/corpus-vectorial/manifests/manifest.atlas.yml
   ```

4. **Ejecuta los notebooks generados** en orden:
   - Primero `corpus_ingestor_onfalo_atlas.nnb` (todas las celdas)
   - Después `corpus_visualizer_{banner}_atlas.nnb` (todas las celdas)

El catálogo en `docs/{banner}/cuadernos/` queda actualizado automáticamente.

---

### Banners disponibles

| Banner | Paleta base | Background | Ruta export |
|--------|-------------|------------|-------------|
| azul   | índigos `#c3e0f3` → `#1a3a8f` | `#07101f` | `docs/azul/cuadernos/` |
| negro  | grises oscuros (TBD) | `#000000` | `docs/negro/cuadernos/` |
| rojo   | rojos profundos (TBD) | `#1a0707` | `docs/rojo/cuadernos/` |

---

## Para mantenedores de la skill

### Cuándo modificar las plantillas en `cells/`

Solo si:
- Cambia el contrato de la API de Chroma
- Se añade una nueva visualización canónica (que aplica a TODOS los corpus)
- Se descubre un bug que afecta a todos los notebooks generados

NO modificar para:
- Añadir un nuevo proyecto (eso va en un nuevo manifest)
- Cambiar paleta (eso va en `manifest.palette`)

### Tests manuales tras modificar plantillas

Regenerar el ejemplo y verificar que ejecuta limpio:
```
/scaffold-corpus .github/skills/corpus-vectorial/examples/manifest.mapas.yml --overwrite
```
Luego ejecutar todas las celdas de los dos notebooks resultantes.

---

## Lecciones operativas

Ver `cells/README.md` para notas técnicas sobre:
- Por qué se editan celdas una a una (no JSON completo)
- Cómo se invalidan los embeddings antiguos
- Por qué Plotly va por CDN y no por npm
