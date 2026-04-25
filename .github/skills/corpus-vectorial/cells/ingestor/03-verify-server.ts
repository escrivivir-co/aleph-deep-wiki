// ── Celda 3: Verificar servidor Chroma ────────────────────────────────────────
const STORAGE_PATH = path.join(
  process.env.HOME || process.env.USERPROFILE,
  'OASIS', 'aleph-scriptorium', 'ARCHIVO', 'PLUGINS', 'VECTOR_MACHINE', 'STORAGE'
);

async function isChromaRunning() {
  try {
    const ctrl = new AbortController();
    const t = setTimeout(() => ctrl.abort(), 1500);
    const r = await fetch('http://localhost:8000/api/v2/heartbeat', { signal: ctrl.signal });
    clearTimeout(t);
    return r.ok;
  } catch { return false; }
}

const running = await isChromaRunning();

if (running) {
  console.log('✓ Chroma server activo en localhost:8000 — listo para ingestar');
} else {
  console.log('⚠ Chroma no responde en localhost:8000');
  console.log('  Tip: ejecuta la tarea VS Code → VMS: Start [Chroma]');
  console.log('  O desde terminal: cd VectorMachineSDK && bash start.sh');
  console.log('  Intentando arrancar con uvx...');

  const { spawn } = require('child_process');
  const srv = spawn(
    'uvx',
    ['--from', 'chromadb', 'chroma', 'run', '--path', STORAGE_PATH, '--host', '0.0.0.0', '--port', '8000'],
    { cwd: NNB_DIR, detached: true, stdio: 'ignore', shell: true }
  );
  srv.unref();

  let ready = false;
  for (let i = 0; i < 30; i++) {
    await new Promise(r => setTimeout(r, 500));
    if (await isChromaRunning()) { ready = true; break; }
  }
  if (ready) {
    console.log('✓ Chroma server listo  (pid', srv.pid, ')');
  } else {
    console.error('✗ Chroma server no respondió — arranca VMS: Start [Chroma] manualmente');
  }
}

console.log('Storage:', STORAGE_PATH);
