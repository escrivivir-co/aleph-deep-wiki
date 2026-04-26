// ── Celda final: Verificación ─────────────────────────────────────────────────
const allCols = await client.listCollections();
// listCollections puede devolver string[] o {name:string}[] según versión chromadb
const getName = (c) => typeof c === 'string' ? c : c.name;
const corpusCols = allCols.filter(c => getName(c).startsWith('{{MOD_PREFIX}}_{{NICK}}_'));
const modTotalCols = allCols.filter(c => getName(c).startsWith('{{MOD_PREFIX}}_'));

console.log('=== mod-{{MOD}} / {{PROYECTO}} ===');
let corpusTot = 0;
for (const c of corpusCols.sort((a, b) => getName(a).localeCompare(getName(b)))) {
  const col = await client.getCollection({ name: getName(c) });
  const n = await col.count();
  corpusTot += n;
  console.log(`  ${getName(c).padEnd(35)}  ${String(n).padStart(4)} chunks`);
}
console.log(`  ${'CORPUS TOTAL'.padEnd(35)}  ${String(corpusTot).padStart(4)} chunks`);

console.log('');
console.log('=== mod-{{MOD}} / ACUMULADO ===');
let globalTot = 0;
for (const c of modTotalCols.sort((a, b) => getName(a).localeCompare(getName(b)))) {
  const col = await client.getCollection({ name: getName(c) });
  const n = await col.count();
  globalTot += n;
  console.log(`  ${getName(c).padEnd(35)}  ${String(n).padStart(4)} chunks`);
}
console.log(`  ${'TOTAL {{MOD_PREFIX}}_*'.padEnd(35)}  ${String(globalTot).padStart(4)} chunks`);
