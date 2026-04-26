// ── Celda 8: Scatter 3D — Plotly JS CDN (100% JS, sin Python) ────────────────
const rows = globalThis._vmRows;
const BG = '#07101f';

const COLOR_MAP = {{COLOR_MAP}};

const byCol3d = {};
for (const r of rows) {
  if (!byCol3d[r.coleccion]) byCol3d[r.coleccion] = { x: [], y: [], z: [], text: [], cd: [] };
  byCol3d[r.coleccion].x.push(r.x3);
  byCol3d[r.coleccion].y.push(r.y3);
  byCol3d[r.coleccion].z.push(r.z3);
  byCol3d[r.coleccion].text.push(r.marca);
  byCol3d[r.coleccion].cd.push([r.marca, r.tipo, r.bloque, r.texto]);
}

const traces3d = Object.entries(byCol3d).map(([col, d]) => ({
  type: 'scatter3d', mode: 'markers+text',
  name: col,
  x: d.x, y: d.y, z: d.z, text: d.text,
  textposition: 'top center',
  textfont: { size: 8, color: '#c8d8e8' },
  marker: { size: 6, opacity: 0.92, color: COLOR_MAP[col] ?? '#aaaaaa' },
  customdata: d.cd,
  hovertemplate: '<b>%{customdata[0]}</b><br>tipo: %{customdata[1]}<br>bloque: %{customdata[2]}<br><i>%{customdata[3]}</i><extra></extra>',
}));

const layout3d = {
  title: { text: '{{PROYECTO}} — Embeddings 3D (UMAP)', font: { color: '#c8d8e8', size: 16 } },
  paper_bgcolor: BG, height: 720, font: { color: '#c8d8e8' },
  legend: { title: { text: 'Colección' }, bgcolor: '#0d1a2f', bordercolor: '#2a4a7f' },
  scene: {
    bgcolor: BG,
    xaxis: { showgrid: false, zeroline: false, showticklabels: false },
    yaxis: { showgrid: false, zeroline: false, showticklabels: false },
    zaxis: { showgrid: false, zeroline: false, showticklabels: false },
  },
  margin: { t: 60, b: 0, l: 0, r: 0 },
};

const id3d = `plt3d_${Math.random().toString(36).slice(2, 7)}`;
const html3d = [
  `<script src="https://cdn.plot.ly/plotly-2.35.0.min.js" charset="utf-8"></script>`,
  `<div id="${id3d}" style="width:100%;height:720px;background:${BG};"></div>`,
  `<script>Plotly.newPlot('${id3d}',${JSON.stringify(traces3d)},${JSON.stringify(layout3d)},{responsive:true,displayModeBar:true});</script>`,
].join('\n');

globalThis._vmHtml3d = html3d;
console.log(`✓ Figura 3D generada — ${rows.length} piezas, ${Object.keys(byCol3d).length} colecciones`);
