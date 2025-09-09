#!/bin/bash

# Script de inicialización para DeepWiki
# Este script descarga los modelos necesarios de Ollama

set -e

echo "🚀 Inicializando DeepWiki con Ollama dockerizado..."

# Función para esperar a que Ollama esté listo
wait_for_ollama() {
    echo "⏳ Esperando a que Ollama esté listo..."
    for i in {1..60}; do
        if docker-compose exec ollama ollama list >/dev/null 2>&1; then
            echo "✅ Ollama está listo"
            return 0
        fi
        echo "   Intento $i/60..."
        sleep 5
    done
    echo "❌ Timeout esperando a Ollama"
    exit 1
}

# Función para descargar modelo
download_model() {
    local model=$1
    echo "📥 Descargando modelo: $model"
    docker-compose exec ollama ollama pull $model
    if [ $? -eq 0 ]; then
        echo "✅ Modelo $model descargado exitosamente"
    else
        echo "❌ Error descargando modelo $model"
        return 1
    fi
}

# Levantar servicios
echo "🐳 Levantando servicios Docker..."
docker-compose up -d ollama

# Esperar a que Ollama esté listo
wait_for_ollama

echo "📦 Descargando modelos necesarios..."

# Descargar modelo de embeddings (necesario para ETL)
download_model "nomic-embed-text"

# Descargar modelo principal para Q&A
download_model "llama3.1"

# Opcional: descargar otros modelos útiles
echo "📦 Descargando modelos adicionales (opcional)..."
download_model "codellama" || echo "⚠️  Modelo codellama no disponible, continuando..."
download_model "mistral" || echo "⚠️  Modelo mistral no disponible, continuando..."

echo ""
echo "🎉 ¡Inicialización completada!"
echo ""
echo "📋 Modelos descargados:"
docker-compose exec ollama ollama list

echo ""
echo "🌐 Servicios disponibles:"
echo "  📖 Wiki: http://localhost:8080"
echo "  🤖 Q&A API: http://localhost:5000"
echo "  💬 Open WebUI: http://localhost:3000"
echo "  🗄️ ChromaDB: http://localhost:8000"
echo "  🧠 Ollama: http://localhost:11434"
echo ""
echo "🚀 Levantando todos los servicios..."
docker-compose up -d

echo ""
echo "✅ DeepWiki está listo para usar!"
echo ""
echo "📝 Próximos pasos:"
echo "1. Visita http://localhost:3000 para configurar Open WebUI"
echo "2. Indexa tu primer repositorio:"
echo "   docker-compose run etl python etl.py https://github.com/usuario/repo"
echo "3. ¡Disfruta de tu DeepWiki!"
