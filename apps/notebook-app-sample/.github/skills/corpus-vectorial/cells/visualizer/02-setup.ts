// ── Celda 2: Setup + conexión — 100% JS, sin Python ──────────────────────────
const path = require('path');
const fs   = require('fs');
const { execSync } = require('child_process');

const NNB_DIR = path.join(
  process.env.HOME || process.env.USERPROFILE,
  'OASIS', 'aleph-scriptorium', 'VectorMachineSDK'
);

// Auto-instalar deps si faltan (umap-js, js-yaml)
const needed = ['umap-js', 'js-yaml'];
const missing = needed.filter(p => !fs.existsSync(path.join(NNB_DIR, 'node_modules', p)));
if (missing.length) {
  console.log('📦 Instalando:', missing.join(', '));
  execSync(`npm install ${missing.join(' ')}`, { cwd: NNB_DIR, stdio: 'pipe' });
  console.log('✓ Instalado');
}

// ChromaClient HTTP (server en :8000)
const { ChromaClient } = require(path.join(NNB_DIR, 'node_modules', 'chromadb'));
const client = new ChromaClient({ host: 'localhost', port: 8000, database: 'default_database' });
await client.heartbeat();

const allCols = await client.listCollections();
const getName = c => typeof c === 'string' ? c : c.name;
const cols = allCols.map(getName).filter(n => n.startsWith('{{MOD_PREFIX}}_{{NICK}}_'));

console.log('✓ Chroma HTTP server activo en localhost:8000');
console.log('Colecciones {{MOD_PREFIX}}_{{NICK}}_* disponibles:', cols);
console.log('umap-js:', fs.existsSync(path.join(NNB_DIR, 'node_modules', 'umap-js')) ? '✓' : '✗');
console.log('js-yaml:', fs.existsSync(path.join(NNB_DIR, 'node_modules', 'js-yaml')) ? '✓' : '✗');
