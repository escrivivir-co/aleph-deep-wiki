// ── Celda 2: Setup — instalar deps si no están disponibles ───────────────────
// chromadb-default-embed = fork oficial de Chroma de @xenova/transformers.
// Misma API, mismo modelo all-MiniLM-L6-v2 (~30MB descarga en runtime, 1ª vez).
// 100% compatible con los embeddings del ingestor Python.
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const NNB_DIR = path.join(
  process.env.HOME || process.env.USERPROFILE,
  'OASIS', 'aleph-scriptorium', 'VectorMachineSDK'
);

const chromaInstalled = fs.existsSync(path.join(NNB_DIR, 'node_modules', 'chromadb'));
const embedInstalled  = fs.existsSync(path.join(NNB_DIR, 'node_modules', 'chromadb-default-embed'));

if (!chromaInstalled || !embedInstalled) {
  console.log('📦 Instalando deps (chromadb + chromadb-default-embed)...');
  execSync('npm install', { cwd: NNB_DIR, stdio: 'pipe' });
  console.log('✓ Deps instaladas');
} else {
  console.log('✓ chromadb             :', path.join(NNB_DIR, 'node_modules', 'chromadb'));
  console.log('✓ chromadb-default-embed:', path.join(NNB_DIR, 'node_modules', 'chromadb-default-embed'));
}
