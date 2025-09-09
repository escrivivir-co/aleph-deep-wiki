@echo off
REM Script de inicialización para DeepWiki con Ollama EXTERNO
REM Este script configura DeepWiki para usar tu Ollama ya instalado

setlocal enabledelayedexpansion

echo 🚀 Inicializando DeepWiki con Ollama EXTERNO...
echo ℹ️  Este script asume que ya tienes Ollama funcionando en localhost:11434

REM Verificar que Ollama está funcionando
echo 🔍 Verificando conexión con Ollama...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo ❌ No se puede conectar a Ollama en localhost:11434
    echo 💡 Asegúrate de que Ollama esté funcionando con: ollama serve
    exit /b 1
)
echo ✅ Ollama está funcionando correctamente

REM Verificar modelo de embeddings
echo 📦 Verificando modelos necesarios...
curl -s http://localhost:11434/api/tags | findstr "nomic-embed-text" >nul
if errorlevel 1 (
    echo 📥 Descargando modelo de embeddings: nomic-embed-text
    ollama pull nomic-embed-text
    if errorlevel 1 (
        echo ❌ Error descargando modelo nomic-embed-text
        exit /b 1
    )
    echo ✅ Modelo nomic-embed-text descargado exitosamente
) else (
    echo ✅ Modelo nomic-embed-text ya está disponible
)

REM Verificar modelo principal (gpt-oss:20b)
curl -s http://localhost:11434/api/tags | findstr "gpt-oss:20b" >nul
if errorlevel 1 (
    echo ❌ No se encuentra el modelo gpt-oss:20b
    echo 💡 Asegúrate de tener este modelo instalado con: ollama pull gpt-oss:20b
    exit /b 1
) else (
    echo ✅ Modelo gpt-oss:20b está disponible
)

echo.
echo 🌐 Levantando servicios DeepWiki...
docker-compose -f docker-compose.external-ollama.yml up -d

echo.
echo ⏳ Esperando a que los servicios estén listos...
timeout /t 10 /nobreak >nul

echo.
echo 🎉 ¡DeepWiki está listo para usar!
echo.
echo 🌐 Servicios disponibles:
echo   💬 Open WebUI (Chat): http://localhost:3000
echo   📖 Wiki: http://localhost:8080
echo   🤖 Q^&A API: http://localhost:5000
echo   🗄️ ChromaDB: http://localhost:8000
echo   🧠 Tu Ollama: http://localhost:11434
echo.
echo 📝 Próximos pasos:
echo 1. Visita http://localhost:3000 para configurar Open WebUI
echo 2. Indexa tu primer repositorio:
echo    docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py https://github.com/usuario/repo
echo 3. O indexa tu repositorio local as-core:
echo    docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py file://e:/LAB_AGOSTO/ORACLE_HALT_ALEPH_VERSION/socket-gym/as-core
echo 4. ¡Disfruta de tu DeepWiki!
echo.
echo 💡 Para parar todos los servicios:
echo    docker-compose -f docker-compose.external-ollama.yml down

endlocal
