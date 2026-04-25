// ── Celda 4: UMAP 2D + 3D — umap-js (100% JS, sin Python) ────────────────────
const { UMAP } = require(path.join(NNB_DIR, 'node_modules', 'umap-js'));
const rows = globalThis._vmRows;
const embeddings = rows.map(r => r.embedding);

console.log(`Calculando UMAP para ${embeddings.length} vectores (dim=${embeddings[0].length})...`);

const umapParams = { nNeighbors: 4, minDist: 0.25, spread: 1.0 };

const umap2d = new UMAP({ nComponents: 2, ...umapParams });
const proj2d = umap2d.fit(embeddings);

const umap3d = new UMAP({ nComponents: 3, ...umapParams });
const proj3d = umap3d.fit(embeddings);

for (let i = 0; i < rows.length; i++) {
  rows[i].x  = proj2d[i][0];  rows[i].y  = proj2d[i][1];
  rows[i].x3 = proj3d[i][0];  rows[i].y3 = proj3d[i][1];  rows[i].z3 = proj3d[i][2];
}
globalThis._vmRows = rows;

console.log(`✓ UMAP 2D: ${proj2d.length} × 2`);
console.log(`✓ UMAP 3D: ${proj3d.length} × 3`);
