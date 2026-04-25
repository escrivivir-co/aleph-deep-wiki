// ── Celda 12: Divergencia corpus ↔ geometría — 100% JS, sin Python ───────────
const rows = globalThis._vmRows;

function cosineSim(a, b) {
  let dot = 0, na = 0, nb = 0;
  for (let i = 0; i < a.length; i++) { dot += a[i] * b[i]; na += a[i] * a[i]; nb += b[i] * b[i]; }
  return dot / (Math.sqrt(na) * Math.sqrt(nb));
}

const embeddings = rows.map(r => r.embedding);
const n = rows.length;
const K_NEIGHBORS = 3;
const divergencias = [];

for (let i = 0; i < n; i++) {
  const sims = rows
    .map((r, j) => ({ j, sim: j === i ? -Infinity : cosineSim(embeddings[i], embeddings[j]) }))
    .sort((a, b) => b.sim - a.sim)
    .slice(0, K_NEIGHBORS);

  const vecinos = sims.map(s => rows[s.j]);
  const distMedia = parseFloat(
    (sims.reduce((acc, s) => acc + (1 - s.sim), 0) / K_NEIGHBORS).toFixed(4)
  );

  const colCounts = {};
  for (const v of vecinos) colCounts[v.col_raw] = (colCounts[v.col_raw] ?? 0) + 1;
  const [colMayoritaria, cnt] = Object.entries(colCounts).sort((a, b) => b[1] - a[1])[0];

  if (colMayoritaria !== rows[i].col_raw && cnt >= 2) {
    divergencias.push({
      marca:          rows[i].marca,
      col_asignada:   rows[i].coleccion,
      col_geometrica: colMayoritaria,
      vecinos:        vecinos.map(v => v.marca),
      dist_media:     distMedia,
    });
  }
}

if (divergencias.length) {
  console.log(`Piezas con divergencia corpus ↔ geometría (${divergencias.length}):`);
  for (const d of divergencias) {
    console.log(`\n  ${d.marca}`);
    console.log(`    Asignada:   ${d.col_asignada}`);
    console.log(`    Geometría:  ${d.col_geometrica}`);
    console.log(`    Vecinos:    ${d.vecinos.join(', ')}`);
    console.log(`    Dist media: ${d.dist_media}`);
  }
} else {
  console.log('Sin divergencias — la taxonomía del Archivero coincide con la geometría.');
}
