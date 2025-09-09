#!/bin/bash
# Script de inicialización para DeepWiki con Ollama EXTERNO
# Este script configura DeepWiki para usar tu Ollama ya instalado

set -e

echo "🚀 Inicializando DeepWiki con Ollama EXTERNO..."
echo "ℹ️  Este script asume que ya tienes Ollama funcionando en localhost:11434"

# Verificar que Ollama está funcionando
echo "🔍 Verificando conexión con Ollama..."
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "❌ No se puede conectar a Ollama en localhost:11434"
    echo "💡 Asegúrate de que Ollama esté funcionando con: ollama serve"
    exit 1
fi
echo "✅ Ollama está funcionando correctamente"

# Verificar modelo de embeddings
echo "📦 Verificando modelos necesarios..."
if ! curl -s http://localhost:11434/api/tags | grep -q "nomic-embed-text"; then
    echo "📥 Descargando modelo de embeddings: nomic-embed-text"
    if ! ollama pull nomic-embed-text; then
        echo "❌ Error descargando modelo nomic-embed-text"
        exit 1
    fi
    echo "✅ Modelo nomic-embed-text descargado exitosamente"
else
    echo "✅ Modelo nomic-embed-text ya está disponible"
fi

# Verificar modelo principal (gpt-oss:20b)
if ! curl -s http://localhost:11434/api/tags | grep -q "gpt-oss:20b"; then
    echo "❌ No se encuentra el modelo gpt-oss:20b" 
    echo "💡 Asegúrate de tener este modelo instalado con: ollama pull gpt-oss:20b"
    exit 1
else
    echo "✅ Modelo gpt-oss:20b está disponible"
fi

echo ""
echo "🌐 Levantando servicios DeepWiki..."
docker-compose -f docker-compose.external-ollama.yml up -d

echo ""
echo "⏳ Esperando a que los servicios estén listos..."
sleep 10

echo ""
echo "🎉 ¡DeepWiki está listo para usar!"
echo ""
echo "🌐 Servicios disponibles:"
echo "  💬 Open WebUI (Chat): http://localhost:3000"
echo "  📖 Wiki: http://localhost:8080"
echo "  🤖 Q&A API: http://localhost:5000"
echo "  🗄️ ChromaDB: http://localhost:8000"
echo "  🧠 Tu Ollama: http://localhost:11434"
echo ""
echo "📝 Próximos pasos:"
echo "1. Visita http://localhost:3000 para configurar Open WebUI"
echo "2. Indexa tu primer repositorio:"
echo "   docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py https://github.com/usuario/repo"
echo "3. O indexa tu repositorio local as-core:"
echo "   docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py file://$(pwd)/../socket-gym/as-core"
echo "4. ¡Disfruta de tu DeepWiki!"
echo ""
echo "💡 Para parar todos los servicios:"
echo "   docker-compose -f docker-compose.external-ollama.yml down"
