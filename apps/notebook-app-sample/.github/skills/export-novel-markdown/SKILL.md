---
name: export-novel-markdown
description: |
	Use this skill when the user wants to export a NovelistEditor novel as a Markdown dossier,
	reuse the MCP structure already stored in AlephAlpha, or generate a deterministic reviewable
	artifact from `novel-data.json`. Preferred path: call `alephAlpha_exportNovelMarkdown` so the
	server persists live state first and then delegates rendering to the script bundled in this skill.
---

# Skill: export-novel-markdown

> **Propósito**: convertir una novela del contenedor AlephAlpha / NovelistEditor en un artefacto Markdown estable, legible y versionable.

---

## Cuándo activar esta skill

- Cuando el usuario pida "exportar la novela a markdown"
- Cuando haga falta revisar una novela fuera del chat o del contenedor MCP
- Cuando se quiera producir un dossier reproducible a partir de `novel-data.json`
- Cuando interese combinar **estado vivo MCP** + **render determinista local**

---

## Regla de operación recomendada

1. **Primero MCP**: validar que la novela existe en AlephAlpha.
2. **Persistir estado vivo**: usar la tool `alephAlpha_exportNovelMarkdown` para que el servidor guarde antes de exportar.
3. **Render local**: la tool delega en `scripts/export-novel-markdown.js`, guardado dentro de esta skill.
4. **Fallback explícito**: si la tool no estuviera disponible, ejecutar el script directamente sobre `src/resources/novel-data.json`.

---

## Contrato del artefacto

El Markdown exportado debe:

- incluir metadatos básicos de la novela;
- listar personajes principales;
- mantener el orden real de capítulos y escenas;
- insertar **contenido completo** cuando la escena ya tenga prosa;
- insertar **resumen estructural** cuando la escena aún no tenga prosa final;
- ser apto para diff, revisión editorial y versionado Git.

---

## Tool preferida

```text
alephAlpha_exportNovelMarkdown({
	novelId: "novel4",
	outputPath: "tmp/exports/novel4-las-palabras-magicas.md",
	overwrite: true
})
```

### Parámetros

| Parámetro | Obligatorio | Descripción |
|-----------|-------------|-------------|
| `novelId` | Sí | ID MCP de la novela a exportar |
| `outputPath` | No | Ruta absoluta o relativa a `NovelistEditor/` |
| `overwrite` | No | Reemplaza un artefacto existente |

---

## Script empaquetado en la skill

Ruta del motor de render:

`NovelistEditor/.github/skills/export-novel-markdown/scripts/export-novel-markdown.js`

Argumentos esperados:

```text
--data <ruta a novel-data.json>
--novelId <id de novela>
--out <ruta de salida>
--overwrite
```

---

## Resultado esperado

- un fichero `.md` en `tmp/exports/` (o en la ruta pedida);
- JSON de salida con `novelId`, `title`, `outputPath`, `counts` y `exportedAt`;
- estructura reproducible para seguir editando, revisar o publicar después.

---

## Notas de diseño

- **Mezcla de dos mundos**: el índice y la validación vienen del contenedor MCP; el render final se hace desde el JSON persistido.
- **Ventaja principal**: no dependemos de respuestas libres del modelo para reconstruir capítulos; la estructura se reusa tal cual está almacenada.
- **Fallback sano**: si aún no hay prosa en una escena, el exportador no inventa texto; deja el resumen estructural visible.
- **Ejemplo de reuso del fichero exportado** NovelistEditor/.github/skills/export-novel-markdown/EXPORT-USE-SAMPLE.md para generar media radiofónico