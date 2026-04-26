// ── Celda 16: Exportar a GH Pages — 100% JS (js-yaml + fs, sin Python) ───────
const yaml = require(path.join(NNB_DIR, 'node_modules', 'js-yaml'));

const REPO_ROOT = path.join(
  process.env.HOME || process.env.USERPROFILE,
  'OASIS', 'aleph-scriptorium'
);
const EXPORT_DIR = path.join(REPO_ROOT, '{{EXPORT_BASE_DIR}}');
const DATA_FILE  = path.join(REPO_ROOT, '{{EXPORT_REGISTRY_FILE}}');

fs.mkdirSync(EXPORT_DIR, { recursive: true });
fs.mkdirSync(path.dirname(DATA_FILE), { recursive: true });

const TODAY = new Date().toISOString().slice(0, 10);
const PREFIX = '{{EXPORT_IDS_PREFIX}}';

const exports = [
  {
    id:          `${PREFIX}_2d`,
    filename:    `${PREFIX}_2d.html`,
    title:       '{{PROYECTO}} — Espacio 2D',
    descripcion: 'Proyección UMAP 2D. Paleta {{BANNER}} — mod/{{MOD}}.',
    html:        globalThis._vmHtml2d ?? '',
  },
  {
    id:          `${PREFIX}_3d`,
    filename:    `${PREFIX}_3d.html`,
    title:       '{{PROYECTO}} — Espacio 3D',
    descripcion: 'Proyección UMAP 3D rotable.',
    html:        globalThis._vmHtml3d ?? '',
  },
  {
    id:          `${PREFIX}_clusters`,
    filename:    `${PREFIX}_clusters.html`,
    title:       `{{PROYECTO}} — Clusters semánticos (K=${globalThis._vmBestK ?? '?'})`,
    descripcion: `Agrupación K-means (K=${globalThis._vmBestK ?? '?'}).`,
    html:        globalThis._vmHtmlClusters ?? '',
  },
];

console.log('=== Exportación GH Pages ===');
for (const e of exports) {
  const dest = path.join(EXPORT_DIR, e.filename);
  const fullHtml = `<!DOCTYPE html><html><head><meta charset="UTF-8"/><title>${e.title}</title></head><body style="margin:0;background:#07101f;">${e.html}</body></html>`;
  fs.writeFileSync(dest, fullHtml, 'utf-8');
  const sizeKb = Math.round(fs.statSync(dest).size / 1024);
  console.log(`  ✓ ${e.filename.padEnd(30)} ${sizeKb} KB`);
}

// Actualizar registry YAML (incremental)
let existing = [];
if (fs.existsSync(DATA_FILE)) {
  const noComments = fs.readFileSync(DATA_FILE, 'utf-8')
    .split('\n').filter(l => !l.startsWith('#')).join('\n');
  try { existing = yaml.load(noComments) || []; } catch { existing = []; }
}

const nuevosIds = new Set(exports.map(e => e.id));
const registrosBase = existing.filter(r => !nuevosIds.has(r.id));
const registrosNuevos = exports.map(e => ({
  id:          e.id,
  title:       e.title,
  file:        '{{BANNER}}/cuadernos/' + e.filename,
  descripcion: e.descripcion,
  fecha:       TODAY,
  colecciones: '{{LABELS_JOINED}}',
}));

const registrosFinales = [...registrosBase, ...registrosNuevos];
const header = '# Cuadernos vectoriales — mod/{{MOD}}\n# Generado automáticamente. No editar a mano.\n\n';
fs.writeFileSync(DATA_FILE, header + yaml.dump(registrosFinales, { allowUnicode: true, sortKeys: false }), 'utf-8');

console.log(`\n  ${path.basename(DATA_FILE)} → ${registrosFinales.length} entradas totales`);
console.log(`  Destino: ${EXPORT_DIR}`);
