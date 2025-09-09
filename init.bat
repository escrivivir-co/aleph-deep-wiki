@echo off
REM Script de inicialización para DeepWiki en Windows
REM Este script descarga los modelos necesarios de Ollama

setlocal enabledelayedexpansion

echo 🚀 Inicializando DeepWiki con Ollama dockerizado...

REM Levantar servicios
echo 🐳 Levantando servicios Docker...
docker-compose up -d ollama

REM Esperar a que Ollama esté listo
echo ⏳ Esperando a que Ollama esté listo...
set /a counter=0
:wait_ollama
docker-compose exec ollama ollama list >nul 2>&1
if errorlevel 0 goto ollama_ready
set /a counter+=1
if %counter% geq 60 (
    echo ❌ Timeout esperando a Ollama
    exit /b 1
)
echo    Intento %counter%/60...
timeout /t 5 /nobreak >nul
goto wait_ollama

:ollama_ready
echo ✅ Ollama está listo

echo 📦 Descargando modelos necesarios...

REM Descargar modelo de embeddings (necesario para ETL)
echo 📥 Descargando modelo: nomic-embed-text
docker-compose exec ollama ollama pull nomic-embed-text
if errorlevel 1 (
    echo ❌ Error descargando modelo nomic-embed-text
    goto error
)
echo ✅ Modelo nomic-embed-text descargado exitosamente

REM Descargar modelo principal para Q&A
echo 📥 Descargando modelo: llama3.1
docker-compose exec ollama ollama pull llama3.1
if errorlevel 1 (
    echo ❌ Error descargando modelo llama3.1
    goto error
)
echo ✅ Modelo llama3.1 descargado exitosamente

REM Opcional: descargar otros modelos útiles
echo 📦 Descargando modelos adicionales (opcional)...
docker-compose exec ollama ollama pull codellama
if errorlevel 1 echo ⚠️  Modelo codellama no disponible, continuando...

docker-compose exec ollama ollama pull mistral
if errorlevel 1 echo ⚠️  Modelo mistral no disponible, continuando...

echo.
echo 🎉 ¡Inicialización completada!
echo.
echo 📋 Modelos descargados:
docker-compose exec ollama ollama list

echo.
echo 🌐 Servicios disponibles:
echo   📖 Wiki: http://localhost:8080
echo   🤖 Q^&A API: http://localhost:5000
echo   💬 Open WebUI: http://localhost:3000
echo   🗄️ ChromaDB: http://localhost:8000
echo   🧠 Ollama: http://localhost:11434
echo.
echo 🚀 Levantando todos los servicios...
docker-compose up -d

echo.
echo ✅ DeepWiki está listo para usar!
echo.
echo 📝 Próximos pasos:
echo 1. Visita http://localhost:3000 para configurar Open WebUI
echo 2. Indexa tu primer repositorio:
echo    docker-compose run etl python etl.py https://github.com/usuario/repo
echo 3. ¡Disfruta de tu DeepWiki!
goto end

:error
echo ❌ Error durante la inicialización
exit /b 1

:end
endlocal
