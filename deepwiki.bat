@echo off
REM Script de utilidad para DeepWiki en Windows
REM Uso: deepwiki.bat [comando] [argumentos]

setlocal enabledelayedexpansion

set COMPOSE_FILE=docker-compose.yml

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="--help" goto help
if "%1"=="-h" goto help

if "%1"=="init" goto init
if "%1"=="start" goto start
if "%1"=="start-cpu" goto start_cpu
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="status" goto status
if "%1"=="logs" goto logs
if "%1"=="index" goto index
if "%1"=="health" goto health
if "%1"=="models" goto models
if "%1"=="pull" goto pull_model
if "%1"=="backup" goto backup
if "%1"=="clean" goto clean
if "%1"=="update" goto update

echo Comando desconocido: %1
echo.
goto help

:help
echo DeepWiki - Gestion de la plataforma
echo.
echo Uso: deepwiki.bat [comando] [argumentos]
echo.
echo Comandos disponibles:
echo   init                   - Inicializar con modelos de Ollama
echo   start                  - Iniciar todos los servicios
echo   start-cpu              - Iniciar servicios (version CPU)
echo   stop                   - Detener todos los servicios
echo   restart                - Reiniciar todos los servicios
echo   status                 - Ver estado de los servicios
echo   logs [servicio]        - Ver logs (opcional: de un servicio especifico)
echo   index ^<repo_url^>       - Indexar un repositorio
echo   health                 - Verificar salud del sistema
echo   models                 - Listar modelos de Ollama
echo   pull ^<model^>           - Descargar modelo de Ollama
echo   backup                 - Crear backup de datos
echo   clean                  - Limpiar datos y rebuild
echo   update                 - Actualizar imagenes Docker
echo.
echo Ejemplos:
echo   deepwiki.bat init
echo   deepwiki.bat start-cpu
echo   deepwiki.bat index https://github.com/fastapi/fastapi
echo   deepwiki.bat logs qa
echo   deepwiki.bat pull codellama
echo   deepwiki.bat backup
goto end

:check_ollama
echo Verificando Ollama dockerizado...
docker-compose exec ollama ollama list > nul 2>&1
if errorlevel 1 (
    echo [WARNING] Ollama no esta disponible en el contenedor
    echo Usa 'deepwiki.bat init' para inicializar Ollama
) else (
    echo [OK] Ollama esta corriendo en Docker
)
goto :eof

:init
echo 🚀 Inicializando DeepWiki...
echo Esto descargara los modelos necesarios (puede tomar varios minutos)
call init.bat
goto end

:start
echo 🚀 Iniciando DeepWiki...
call :check_ollama
docker-compose up -d
if errorlevel 1 (
    echo [ERROR] No se pudieron iniciar los servicios
    goto end
)
echo [OK] Servicios iniciados
echo.
echo Servicios disponibles:
echo   📖 Wiki: http://localhost:8080
echo   🤖 Q^&A API: http://localhost:5000
echo   💬 Open WebUI: http://localhost:3000
echo   🗄️ ChromaDB: http://localhost:8000
echo   🧠 Ollama: http://localhost:11434
goto end

:start_cpu
echo 🚀 Iniciando DeepWiki (version CPU)...
docker-compose -f docker-compose.cpu.yml up -d
if errorlevel 1 (
    echo [ERROR] No se pudieron iniciar los servicios
    goto end
)
echo [OK] Servicios iniciados (CPU)
echo.
echo Servicios disponibles:
echo   📖 Wiki: http://localhost:8080
echo   🤖 Q^&A API: http://localhost:5000
echo   💬 Open WebUI: http://localhost:3000
echo   🗄️ ChromaDB: http://localhost:8000
echo   🧠 Ollama: http://localhost:11434
goto end

:stop
echo 🛑 Deteniendo DeepWiki...
docker-compose down
echo [OK] Servicios detenidos
goto end

:restart
echo 🔄 Reiniciando DeepWiki...
docker-compose restart
echo [OK] Servicios reiniciados
goto end

:status
echo 📊 Estado de los servicios:
docker-compose ps
goto end

:logs
if "%2"=="" (
    echo 📝 Logs de todos los servicios:
    docker-compose logs -f
) else (
    echo 📝 Logs de %2:
    docker-compose logs -f %2
)
goto end

:index
if "%2"=="" (
    echo [ERROR] Debes proporcionar una URL de repositorio
    echo Uso: deepwiki.bat index https://github.com/usuario/repo
    goto end
)
echo 📂 Indexando repositorio: %2
docker-compose run --rm etl python etl.py %2
if errorlevel 1 (
    echo [ERROR] Error indexando repositorio
    goto end
)
echo [OK] Repositorio indexado
goto end

:health
echo 🏥 Verificando salud del sistema...
call :check_ollama

echo Verificando API Q^&A...
curl -s http://localhost:5000/health > nul 2>&1
if errorlevel 1 (
    echo [ERROR] API Q^&A no responde
) else (
    echo [OK] API Q^&A operativa
    curl -s http://localhost:5000/health
)

echo Verificando Open WebUI...
curl -s http://localhost:3000 > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Open WebUI no responde
) else (
    echo [OK] Open WebUI operativa
)
goto end

:models
echo 📋 Modelos disponibles en Ollama:
docker-compose exec ollama ollama list
goto end

:pull_model
if "%2"=="" (
    echo [ERROR] Debes especificar un modelo
    echo Uso: deepwiki.bat pull ^<modelo^>
    echo Ejemplo: deepwiki.bat pull codellama
    goto end
)
echo 📥 Descargando modelo: %2
docker-compose exec ollama ollama pull %2
if errorlevel 1 (
    echo [ERROR] Error descargando modelo %2
    goto end
)
echo [OK] Modelo %2 descargado
goto end

:backup
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
set backup_file=deepwiki_backup_%timestamp%.zip

echo 💾 Creando backup...
powershell -command "Compress-Archive -Path 'data', 'repos', 'wiki\docs' -DestinationPath '%backup_file%'"
if errorlevel 1 (
    echo [ERROR] Error creando backup
    goto end
)
echo [OK] Backup creado: %backup_file%
dir %backup_file%
goto end

:clean
echo 🧹 Limpiando y rebuilding...
echo [WARNING] Esto eliminara todos los datos. Continuar? (S/N)
set /p confirmation=
if /i not "%confirmation%"=="s" (
    echo Operacion cancelada
    goto end
)
docker-compose down -v
docker-compose build --no-cache
if exist "data\chroma" rmdir /s /q "data\chroma" > nul 2>&1
if exist "repos" for /d %%i in (repos\*) do rmdir /s /q "%%i" > nul 2>&1
if exist "wiki\docs" del /q "wiki\docs\*.md" > nul 2>&1
docker-compose up -d
echo [OK] Sistema limpio y rebuildeado
goto end

:update
echo 📦 Actualizando imagenes...
docker-compose pull
docker-compose up -d
echo [OK] Imagenes actualizadas
goto end

:end
endlocal
