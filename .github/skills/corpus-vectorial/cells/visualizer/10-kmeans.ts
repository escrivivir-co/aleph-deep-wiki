// ── Celda 10: KMeans + Silhouette — 100% JS, sin Python ──────────────────────
const rows = globalThis._vmRows;
const BG = '#07101f';

function euclidean(a, b) {
  let s = 0; for (let i = 0; i < a.length; i++) s += (a[i] - b[i]) ** 2; return Math.sqrt(s);
}

function kMeans(X, k, maxIter = 300) {
  const dim = X[0].length;
  const step = Math.floor(X.length / k);
  let centroids = Array.from({ length: k }, (_, i) => [...X[i * step]]);
  let labels = new Array(X.length).fill(0);
  for (let iter = 0; iter < maxIter; iter++) {
    let changed = false;
    for (let i = 0; i < X.length; i++) {
      let best = 0, bestD = Infinity;
      for (let j = 0; j < k; j++) {
        let d = 0; for (let d2 = 0; d2 < dim; d2++) d += (X[i][d2] - centroids[j][d2]) ** 2;
        if (d < bestD) { bestD = d; best = j; }
      }
      if (labels[i] !== best) { labels[i] = best; changed = true; }
    }
    if (!changed) break;
    const sums = Array.from({ length: k }, () => new Array(dim).fill(0));
    const counts = new Array(k).fill(0);
    for (let i = 0; i < X.length; i++) {
      for (let d2 = 0; d2 < dim; d2++) sums[labels[i]][d2] += X[i][d2];
      counts[labels[i]]++;
    }
    for (let j = 0; j < k; j++) {
      if (counts[j] > 0) centroids[j] = sums[j].map(s => s / counts[j]);
    }
  }
  return labels;
}

function silhouetteScore(X, labels) {
  const n = X.length, kk = Math.max(...labels) + 1;
  let total = 0;
  for (let i = 0; i < n; i++) {
    const same = X.filter((_, j) => labels[j] === labels[i] && j !== i);
    const a = same.length ? same.reduce((s, p) => s + euclidean(X[i], p), 0) / same.length : 0;
    let b = Infinity;
    for (let c = 0; c < kk; c++) {
      if (c === labels[i]) continue;
      const other = X.filter((_, j) => labels[j] === c);
      if (other.length) { const avg = other.reduce((s, p) => s + euclidean(X[i], p), 0) / other.length; if (avg < b) b = avg; }
    }
    total += b === Infinity ? 0 : (b - a) / Math.max(a, b);
  }
  return total / n;
}

const embeddings = rows.map(r => r.embedding);
const scores = {};
for (let k = 2; k <= Math.min(5, rows.length - 1); k++) {
  const lbls = kMeans(embeddings, k);
  scores[k] = parseFloat(silhouetteScore(embeddings, lbls).toFixed(4));
}
const bestK = parseInt(Object.entries(scores).sort((a, b) => b[1] - a[1])[0][0]);
const bestLabels = kMeans(embeddings, bestK);

console.log(`Silhouette scores: ${JSON.stringify(scores)}`);
console.log(`K óptimo: ${bestK} (score=${scores[bestK]})`);

const clusterColors = {{PALETTE_LIST}};
const byCluster = {};
for (let i = 0; i < rows.length; i++) {
  const cl = String(bestLabels[i]);
  if (!byCluster[cl]) byCluster[cl] = { x: [], y: [], text: [], cd: [] };
  byCluster[cl].x.push(rows[i].x); byCluster[cl].y.push(rows[i].y);
  byCluster[cl].text.push(rows[i].marca);
  byCluster[cl].cd.push([rows[i].marca, rows[i].coleccion, rows[i].tipo, rows[i].texto]);
}

const tracesCl = Object.entries(byCluster).map(([cl, d]) => ({
  type: 'scatter', mode: 'markers+text', name: `Cluster ${cl}`,
  x: d.x, y: d.y, text: d.text, textposition: 'top center',
  textfont: { size: 9, color: '#c8d8e8' },
  marker: { size: 12, opacity: 0.85, color: clusterColors[parseInt(cl)] ?? '#aaa' },
  customdata: d.cd,
  hovertemplate: '<b>%{customdata[0]}</b><br>col: %{customdata[1]}<br><i>%{customdata[3]}</i><extra></extra>',
}));

const layoutCl = {
  title: { text: `{{PROYECTO}} — Clusters KMeans (k=${bestK}) sobre UMAP 2D`, font: { color: '#c8d8e8', size: 16 } },
  plot_bgcolor: BG, paper_bgcolor: BG, height: 680,
  font: { color: '#c8d8e8' },
  legend: { title: { text: 'Cluster' }, bgcolor: '#0d1a2f', bordercolor: '#2a4a7f' },
  xaxis: { showgrid: false, zeroline: false, showticklabels: false },
  yaxis: { showgrid: false, zeroline: false, showticklabels: false },
  margin: { t: 60, b: 20, l: 20, r: 20 },
};

const idCl = `pltcl_${Math.random().toString(36).slice(2, 7)}`;
const htmlCl = [
  `<script src="https://cdn.plot.ly/plotly-2.35.0.min.js" charset="utf-8"></script>`,
  `<div id="${idCl}" style="width:100%;height:680px;background:${BG};"></div>`,
  `<script>Plotly.newPlot('${idCl}',${JSON.stringify(tracesCl)},${JSON.stringify(layoutCl)},{responsive:true,displayModeBar:true});</script>`,
].join('\n');

globalThis._vmHtmlClusters = htmlCl;
globalThis._vmBestK = bestK;
console.log(`✓ KMeans listo — K=${bestK}, ${rows.length} piezas`);
