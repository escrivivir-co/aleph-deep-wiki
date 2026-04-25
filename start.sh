#!/usr/bin/env bash
# VectorMachineSDK/start.sh
# Arranca el servidor Chroma HTTP en puerto 8000.
# Requerido para los notebooks .nnb (SDK JS de chromadb conecta vía HTTP).
# El MCP Tool (chroma-mcp) usa DISABLE_.mcp.json directamente con uvx — no depende de este script.

set -e

STORAGE="C:/Users/aleph/OASIS/aleph-scriptorium/ARCHIVO/PLUGINS/VECTOR_MACHINE/STORAGE"

echo "[VMS] Arrancando Chroma HTTP Server → http://localhost:8000"
echo "[VMS] Storage: $STORAGE"
echo "[VMS] Presiona Ctrl+C para detener."
echo ""

uvx --from chromadb chroma run \
  --path "$STORAGE" \
  --host 0.0.0.0 \
  --port 8000
