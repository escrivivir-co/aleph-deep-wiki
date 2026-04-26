// ── Celda 4: Conectar ChromaClient y listar colecciones existentes ───────────
const { ChromaClient } = require(path.join(NNB_DIR, 'node_modules', 'chromadb'));

const client = new ChromaClient({
  host: 'localhost',
  port: 8000,
  database: 'default_database',
});

await client.heartbeat();
const existing = await client.listCollections();
const getName = (c) => typeof c === 'string' ? c : c.name;
console.log('✓ Conectado a Chroma HTTP server');
console.log('Colecciones existentes:', existing.map(getName));
