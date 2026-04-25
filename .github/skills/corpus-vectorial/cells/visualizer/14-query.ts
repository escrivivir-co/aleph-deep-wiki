// ── Celda 14: Query semántica (chromadb-default-embed, 100% JS) ───────────────
const { pipeline, env } = require(path.join(NNB_DIR, 'node_modules', 'chromadb-default-embed'));
env.cacheDir = path.join(NNB_DIR, '.model-cache');

const QUERY = '{{EXAMPLE_QUERY}}';
const N_RESULTADOS = 3;

const pipe = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
const qOut = await pipe([QUERY], { pooling: 'mean', normalize: true });
const qEmb = qOut.tolist()[0];

console.log(`Query: «${QUERY}»\n`);
console.log('='.repeat(70));

const COLLECTIONS = {{COLLECTIONS_LIST}};
const LABELS = {{LABELS_MAP}};

for (const colName of COLLECTIONS) {
  const col = await client.getCollection({
    name: colName,
    embeddingFunction: { generate: async () => [] },
  });
  const result = await col.query({
    queryEmbeddings: [qEmb],
    nResults: N_RESULTADOS,
    include: ['documents', 'metadatas', 'distances'],
  });
  const docs      = result.documents[0];
  const metas     = result.metadatas[0];
  const distances = result.distances[0];

  console.log(`\n▶ ${LABELS[colName] ?? colName}`);
  console.log('-'.repeat(50));
  for (let i = 0; i < docs.length; i++) {
    const etiqueta = metas[i]?.marca ?? metas[i]?.bloque ?? colName;
    console.log(`  [${distances[i].toFixed(3)}]  ${etiqueta}`);
    console.log(`           ${docs[i].slice(0, 120)}…`);
  }
}
