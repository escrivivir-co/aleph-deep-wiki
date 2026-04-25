// ── Celda 6: Scatter 2D — Plotly JS CDN (100% JS, sin Python) ────────────────
const rows = globalThis._vmRows;
const BG = '#07101f';

const COLOR_MAP = {{COLOR_MAP}};

const byCol = {};
for (const r of rows) {
  if (!byCol[r.coleccion]) byCol[r.coleccion] = { x: [], y: [], text: [], cd: [] };
  byCol[r.coleccion].x.push(r.x);
  byCol[r.coleccion].y.push(r.y);
  byCol[r.coleccion].text.push(r.marca);
  byCol[r.coleccion].cd.push([r.marca, r.tipo, r.bloque, r.texto]);
}

const traces2d = Object.entries(byCol).map(([col, d]) => ({
  type: 'scatter', mode: 'markers+text',
  name: col,
  x: d.x, y: d.y, text: d.text,
  textposition: 'top center',
  textfont: { size: 9, color: '#c8d8e8' },
  marker: { size: 12, opacity: 0.88, color: COLOR_MAP[col] ?? '#aaaaaa' },
  customdata: d.cd,
  hovertemplate: '<b>%{customdata[0]}</b><br>tipo: %{customdata[1]}<br>bloque: %{customdata[2]}<br><i>%{customdata[3]}</i><extra></extra>',
}));

const layout2d = {
  title: { text: '{{PROYECTO}} — Embeddings 2D (UMAP)', font: { color: '#c8d8e8', size: 16 } },
  plot_bgcolor: BG, paper_bgcolor: BG, height: 680,
  font: { color: '#c8d8e8' },
  legend: { title: { text: 'Colección' }, bgcolor: '#0d1a2f', bordercolor: '#2a4a7f' },
  xaxis: { showgrid: false, zeroline: false, showticklabels: false },
  yaxis: { showgrid: false, zeroline: false, showticklabels: false },
  margin: { t: 60, b: 20, l: 20, r: 20 },
};

const id2d = `plt2d_${Math.random().toString(36).slice(2, 7)}`;
const html2d = [
  `<script src="https://cdn.plot.ly/plotly-2.35.0.min.js" charset="utf-8"></script>`,
  `<div id="${id2d}" style="width:100%;height:680px;background:${BG};"></div>`,
  `<script>Plotly.newPlot('${id2d}',${JSON.stringify(traces2d)},${JSON.stringify(layout2d)},{responsive:true,displayModeBar:true});</script>`,
].join('\n');

globalThis._vmHtml2d = html2d;
console.log(`✓ Figura 2D generada — ${rows.length} piezas, ${Object.keys(byCol).length} colecciones`);
