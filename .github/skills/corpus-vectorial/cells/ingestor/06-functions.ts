// ── Celda 6: chunkMarkdown + embeddings vía chromadb-default-embed + ingestFile
// chromadb-default-embed = fork oficial Chroma de @xenova/transformers.
// Modelo: Xenova/all-MiniLM-L6-v2 (idéntico al DefaultEmbeddingFunction Python).

const SOURCE_ROOT_PATH = path.join(
  process.env.HOME || process.env.USERPROFILE,
  'OASIS', 'aleph-scriptorium', {{SOURCE_ROOT_PATH_SEGMENTS}}
);

// Carga el pipeline una sola vez y lo reutiliza entre celdas
const { pipeline, env } = require(path.join(NNB_DIR, 'node_modules', 'chromadb-default-embed'));
env.cacheDir = path.join(NNB_DIR, '.model-cache'); // modelo ONNX en disco local

let _embedder = null;
async function getEmbedder() {
  if (!_embedder) {
    console.log('  Cargando modelo all-MiniLM-L6-v2 (1ª vez: ~30MB descarga)...');
    _embedder = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
    console.log('  ✓ Modelo listo');
  }
  return _embedder;
}

async function generateEmbeddings(texts) {
  const pipe = await getEmbedder();
  const out = await pipe(texts, { pooling: 'mean', normalize: true });
  return out.tolist();
}

function chunkMarkdown(text, maxChars = 700) {
  const parts = text.split(/(?=^#{1,3} .+)/m);
  const raw = [];
  for (const part of parts) {
    const headMatch = part.match(/^(#{1,3} [^\n]+)/);
    const title = headMatch ? headMatch[1].trim() : '';
    const body = headMatch ? part.slice(headMatch[0].length).trim() : part.trim();
    if (body) raw.push({ title, text: body });
  }
  const final = [];
  for (const chunk of raw) {
    if (chunk.text.length <= maxChars) {
      final.push(chunk);
    } else {
      const paras = chunk.text.split(/\n\n+/).filter(p => p.trim());
      let buf = '';
      for (const para of paras) {
        if (buf.length + para.length > maxChars && buf) {
          final.push({ title: chunk.title, text: buf.trim() });
          buf = para;
        } else {
          buf += (buf ? '\n\n' : '') + para;
        }
      }
      if (buf.trim()) final.push({ title: chunk.title, text: buf.trim() });
    }
  }
  return final.filter(c => c.text.length >= 50);
}

async function ingestFile(colName, filePath, bloque, tipo, idPrefix) {
  const col = await client.getOrCreateCollection({
    name: colName,
    embeddingFunction: { generate: async () => [] }, // embeddings explícitos
  });
  const existing = await col.get({ include: ['metadatas'] });
  const existingIds = new Set(existing.ids);

  const text = fs.readFileSync(filePath, 'utf-8');
  const chunks = chunkMarkdown(text);

  const ids = [], docs = [], metas = [];
  for (let i = 0; i < chunks.length; i++) {
    const chunk = chunks[i];
    const docId = `${idPrefix}-${String(i + 1).padStart(2, '0')}`;
    if (existingIds.has(docId)) continue;
    const label = chunk.title ? chunk.title.slice(0, 40) : docId;
    ids.push(docId);
    docs.push(chunk.text);
    metas.push({ bloque, tipo, marca: label });
  }

  if (ids.length > 0) {
    console.log(`  Generando ${ids.length} embeddings (chromadb-default-embed)...`);
    const embeddings = await generateEmbeddings(docs);
    await col.add({ ids, documents: docs, metadatas: metas, embeddings });
  }

  const total = await col.count();
  console.log(`  ${colName.padEnd(35)} / ${idPrefix}: +${ids.length} chunks  (total ${total})`);
  return ids.length;
}

console.log('✓ Funciones cargadas. SOURCE_ROOT_PATH:', SOURCE_ROOT_PATH);
console.log('  Archivos disponibles:', fs.readdirSync(SOURCE_ROOT_PATH).join(', '));
