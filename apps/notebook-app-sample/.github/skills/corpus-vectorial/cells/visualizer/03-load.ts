// ── Celda 3: Carga de embeddings ──────────────────────────────────────────────
const COLLECTIONS = {{COLLECTIONS_LIST}};

const LABELS = {{LABELS_MAP}};

const rows = [];
for (const colName of COLLECTIONS) {
  const col = await client.getCollection({
    name: colName,
    embeddingFunction: { generate: async () => [] },
  });
  const result = await col.get({ include: ['embeddings', 'documents', 'metadatas'] });
  for (let i = 0; i < result.ids.length; i++) {
    rows.push({
      id:        result.ids[i],
      coleccion: LABELS[colName] ?? colName,
      col_raw:   colName,
      bloque:    result.metadatas[i]?.bloque ?? '?',
      tipo:      result.metadatas[i]?.tipo   ?? '?',
      marca:     result.metadatas[i]?.marca  ?? result.ids[i],
      texto:     (result.documents[i] ?? '').slice(0, 120) + '...',
      embedding: result.embeddings[i],
    });
  }
}

const byCol = {};
for (const r of rows) byCol[r.coleccion] = (byCol[r.coleccion] ?? 0) + 1;

console.log(`Total piezas cargadas: ${rows.length}`);
console.log('Distribución:', JSON.stringify(byCol, null, 2));

globalThis._vmRows = rows;
