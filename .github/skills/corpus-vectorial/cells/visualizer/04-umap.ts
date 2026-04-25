// ── Celda 4: UMAP 2D + 3D — umap-js (100% JS, sin Python) ────────────────────
const { UMAP } = require(path.join(NNB_DIR, 'node_modules', 'umap-js'));
const rows = globalThis._vmRows;
const embeddings = rows.map(r => r.embedding);

console.log(`Calculando UMAP para ${embeddings.length} vectores (dim=${embeddings[0].length})...`);

function cosineDistance(a, b) {
  let dot = 0, na = 0, nb = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  const denom = Math.sqrt(na) * Math.sqrt(nb);
  if (!denom) return 1;
  const cosine = dot / denom;
  return 1 - Math.max(-1, Math.min(1, cosine));
}

function chooseNNeighbors(nPoints) {
  if (nPoints <= 3) return Math.max(2, nPoints - 1);
  const base = nPoints <= 10 ? 4 : Math.max(5, Math.round(Math.sqrt(nPoints)));
  return Math.max(2, Math.min(30, Math.min(base, nPoints - 1)));
}

const nNeighbors = chooseNNeighbors(embeddings.length);
const umapParams = {
  nNeighbors,
  minDist: 0.25,
  spread: 1.0,
  distanceFn: cosineDistance,
};

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
console.log(`✓ UMAP metric: cosine · nNeighbors adaptativo=${nNeighbors}`);
