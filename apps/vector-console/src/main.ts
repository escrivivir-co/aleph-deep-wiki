/**
 * vector-console — non-interactive console app
 *
 * Connects to Chroma, runs heartbeat, lists collections matching a prefix
 * and prints a single JSON result to stdout, then exits.
 *
 * Usage:  bun run src/main.ts [--pretty] [--help]
 *
 * Env vars (all optional — fall back to SDK defaults):
 *   VECTOR_MACHINE_CHROMA_HOST         default: localhost
 *   VECTOR_MACHINE_CHROMA_PORT         default: 8000
 *   VECTOR_MACHINE_CHROMA_SSL          default: false
 *   VECTOR_MACHINE_CHROMA_PATH         overrides host/port when set
 *   VECTOR_MACHINE_CHROMA_TENANT       default: default_tenant
 *   VECTOR_MACHINE_CHROMA_DATABASE     default: default_database
 *   VECTOR_MACHINE_COLLECTION_PREFIX   default: mo_mapas_
 */

import { BasicVectorMachine } from '@alephscript/mcp-core-sdk/vector-db';

// ── flags ──────────────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const pretty = args.includes('--pretty');

if (args.includes('--help')) {
    console.log(
        [
            'Usage: bun run src/main.ts [--pretty] [--help]',
            '',
            'Env vars (all optional):',
            '  VECTOR_MACHINE_CHROMA_HOST        default: localhost',
            '  VECTOR_MACHINE_CHROMA_PORT        default: 8000',
            '  VECTOR_MACHINE_CHROMA_SSL         default: false',
            '  VECTOR_MACHINE_CHROMA_PATH        overrides host/port when set',
            '  VECTOR_MACHINE_CHROMA_TENANT      default: default_tenant',
            '  VECTOR_MACHINE_CHROMA_DATABASE    default: default_database',
            '  VECTOR_MACHINE_COLLECTION_PREFIX  default: mo_mapas_',
            '',
            'Output (stdout): single JSON line — { ok, heartbeatMs, prefix, collections, config }',
            'On error  (stderr): single JSON line — { ok: false, error, code }',
        ].join('\n'),
    );
    process.exit(0);
}

// ── run ────────────────────────────────────────────────────────────────────

const prefix =
    (process.env['VECTOR_MACHINE_COLLECTION_PREFIX'] ?? '').trim() || 'mo_mapas_';

const vm = new BasicVectorMachine();

vm.start();

try {
    const heartbeatMs = await vm.connectChroma();
    const collections = await vm.listCollectionNames(prefix);

    vm.stop();

    const result = {
        ok: true,
        heartbeatMs,
        prefix,
        collections,
        config: vm.getConfig(),
    };

    const output = pretty ? JSON.stringify(result, null, 2) : JSON.stringify(result);
    console.log(output);
    process.exit(0);
} catch (err) {
    vm.stop();

    const message = err instanceof Error ? err.message : String(err);
    const code: string =
        typeof (err as Record<string, unknown>)['code'] === 'string'
            ? String((err as Record<string, unknown>)['code'])
            : 'UNKNOWN';

    process.stderr.write(JSON.stringify({ ok: false, error: message, code }) + '\n');
    process.exit(1);
}
