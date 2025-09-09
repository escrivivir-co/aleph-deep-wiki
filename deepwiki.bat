@echo off
REM Script de utilidad para DeepWiki enecho   logs [servicio]        - Ver logs (opcional: de un servicio especifico)
echo   copy-repo ^<ruta^>        - Copiar repositorio local a carpeta repos (respeta .gitignore)
echo   index ^<repo_url^>       - Indexar un repositorio
echo   test [consulta]          - Probar el sistema Q^&A (opcional: consulta personalizada)
echo   health                 - Verificar salud del sistema
REM Uso: deepwiki.bat [comando] [argumentos]

setlocal enabledelayedexpansion

set COMPOSE_FILE=docker-compose.yml

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="--help" goto help
if "%1"=="-h" goto help

if "%1"=="init" goto init
if "%1"=="start" goto start
if "%1"=="start-external" goto start_external
if "%1"=="start-cpu" goto start_cpu
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="rebuild" goto rebuild
if "%1"=="rebuild-etl" goto rebuild_etl
if "%1"=="rebuild-qa" goto rebuild_qa
if "%1"=="rebuild-all" goto rebuild_all
if "%1"=="prepare" goto prepare
if "%1"=="status" goto status
if "%1"=="logs" goto logs
if "%1"=="index" goto index
if "%1"=="copy-repo" goto copy_repo
if "%1"=="health" goto health
if "%1"=="models" goto models
if "%1"=="pull" goto pull_model
if "%1"=="test" goto test_query
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
echo   start                  - Iniciar todos los servicios (con Ollama dockerizado)
echo   start-external         - Iniciar servicios (usando Ollama externo)
echo   start-cpu              - Iniciar servicios (version CPU)
echo   stop                   - Detener todos los servicios
echo   restart                - Reiniciar todos los servicios
echo   rebuild                - Rebuild y reiniciar servicios (aplica cambios de codigo)
echo   rebuild-etl            - Rebuild solo el servicio ETL (para cambios en etl/etl.py)
echo   rebuild-qa             - Rebuild solo el servicio Q^&A API (para cambios en qa/app.py)
echo   rebuild-all            - Rebuild completo incluyendo ETL
echo   prepare ^<repo_path^>    - Copiar repositorio local a carpeta repos (sin node_modules)
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
echo   deepwiki.bat start-external
echo   deepwiki.bat copy-repo E:\LAB_AGOSTO\ORACLE_HALT_ALEPH_VERSION\socket-gym\as-core
echo   deepwiki.bat index repos\as-core
echo   deepwiki.bat test
echo   deepwiki.bat test "What are the main TypeScript functions?"
echo   deepwiki.bat rebuild-qa
echo   deepwiki.bat logs qa
echo   deepwiki.bat pull codellama
echo   deepwiki.bat backup
goto end

:check_ollama
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, verificar externo
    echo Verificando Ollama externo...
    curl -s http://localhost:11434/api/tags > nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Ollama externo no esta disponible en localhost:11434
        echo Asegurate de que Ollama este corriendo localmente
    ) else (
        echo [OK] Ollama externo esta corriendo
    )
) else (
    REM Hay contenedor de Ollama, verificar dockerizado
    echo Verificando Ollama dockerizado...
    docker-compose exec ollama ollama list > nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Ollama no esta disponible en el contenedor
        echo Usa 'deepwiki.bat init' para inicializar Ollama
    ) else (
        echo [OK] Ollama esta corriendo en Docker
    )
)
goto :eof

:init
echo 🚀 Inicializando DeepWiki...
echo Esto detectará automáticamente tu configuración de Ollama
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

:start_external
echo 🚀 Iniciando DeepWiki (usando Ollama externo)...
echo [INFO] Verificando que Ollama externo esté disponible...

REM Verificar que Ollama externo está corriendo
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No se puede conectar a Ollama en http://localhost:11434
    echo [INFO] Asegurate de que Ollama esté corriendo con: ollama serve
    goto end
)
echo [OK] Ollama externo está disponible

docker-compose -f docker-compose.external-ollama.yml up -d
if errorlevel 1 (
    echo [ERROR] No se pudieron iniciar los servicios
    goto end
)
echo [OK] Servicios iniciados (usando Ollama externo)
echo.
echo Servicios disponibles:
echo   📖 Wiki: http://localhost:8080
echo   🤖 Q^&A API: http://localhost:5000
echo   🗄️ ChromaDB: http://localhost:8000
echo   🧠 Ollama (externo): http://localhost:11434
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
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar configuración externa
    echo Deteniendo servicios con configuración externa...
    docker-compose -f docker-compose.external-ollama.yml down
) else (
    REM Hay contenedor de Ollama, usar configuración dockerizada
    echo Deteniendo servicios con configuración dockerizada...
    docker-compose down
)
echo [OK] Servicios detenidos
goto end

:restart
echo 🔄 Reiniciando DeepWiki...
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar configuración externa
    echo Reiniciando con configuración externa...
    docker-compose -f docker-compose.external-ollama.yml restart
) else (
    REM Hay contenedor de Ollama, usar configuración dockerizada
    echo Reiniciando con configuración dockerizada...
    docker-compose restart
)
echo [OK] Servicios reiniciados
goto end

:rebuild
echo 🔧 Rebuilding y reiniciando DeepWiki...
echo Esto aplicará cambios de código y reiniciará servicios
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar configuración externa
    echo Rebuilding con configuración externa...
    docker-compose -f docker-compose.external-ollama.yml down
    docker-compose -f docker-compose.external-ollama.yml build --no-cache
    docker-compose -f docker-compose.external-ollama.yml up -d
) else (
    REM Hay contenedor de Ollama, usar configuración dockerizada
    echo Rebuilding con configuración dockerizada...
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
)
echo [OK] Sistema rebuildeado y reiniciado
goto end

:rebuild_etl
echo 🔧 Rebuilding servicio ETL...
echo Esto aplicará cambios en etl/etl.py
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar configuración externa
    echo Rebuilding ETL con configuración externa...
    docker-compose -f docker-compose.external-ollama.yml build --no-cache etl
) else (
    REM Hay contenedor de Ollama, usar configuración dockerizada
    echo Rebuilding ETL con configuración dockerizada...
    docker-compose build --no-cache etl
)
echo [OK] Servicio ETL rebuildeado
goto end

:rebuild_qa
echo [BUILD] Rebuilding servicio Q^&A API...
echo Esto aplicara cambios en qa/app.py
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar configuración externa
    echo Rebuilding Q^&A API con configuracion externa...
    docker-compose -f docker-compose.external-ollama.yml build --no-cache qa
    docker-compose -f docker-compose.external-ollama.yml restart qa
) else (
    REM Hay contenedor de Ollama, usar configuración dockerizada
    echo Rebuilding Q^&A API con configuracion dockerizada...
    docker-compose build --no-cache qa
    docker-compose restart qa
)
echo [OK] Servicio Q^&A API rebuildeado
goto end

:rebuild_all
echo 🔧 Rebuilding completo incluyendo ETL...
echo Esto aplicará cambios de código en todos los servicios
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar configuración externa
    echo Rebuilding completo con configuración externa...
    docker-compose -f docker-compose.external-ollama.yml down
    docker-compose -f docker-compose.external-ollama.yml build --no-cache
    docker-compose -f docker-compose.external-ollama.yml up -d
) else (
    REM Hay contenedor de Ollama, usar configuración dockerizada
    echo Rebuilding completo con configuración dockerizada...
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
)
echo [OK] Sistema completo rebuildeado y reiniciado
goto end

:prepare
if "%2"=="" (
    echo [ERROR] Debes proporcionar la ruta del repositorio local
    echo Uso: deepwiki.bat prepare ^<ruta_del_repositorio^>
    echo Ejemplo: deepwiki.bat prepare E:/LAB_AGOSTO/ORACLE_HALT_ALEPH_VERSION/socket-gym/as-core
    goto end
)

set "source_path=%2"
set "repo_name="
for %%f in ("%source_path%") do set "repo_name=%%~nf"
set "dest_path=repos\%repo_name%"

echo 📁 Preparando repositorio local: %repo_name%
echo    Origen: %source_path%
echo    Destino: %dest_path%

REM Verificar que el directorio origen existe
if not exist "%source_path%" (
    echo [ERROR] El directorio no existe: %source_path%
    goto end
)

REM Crear directorio destino si no existe
if not exist "repos" mkdir repos
if exist "%dest_path%" (
    echo [INFO] Eliminando copia anterior...
    rmdir /s /q "%dest_path%"
)

echo [INFO] Copiando archivos (excluyendo node_modules, .git, dist, build, etc.)...

REM Usar robocopy para copiar excluyendo directorios comunes que no queremos
robocopy "%source_path%" "%dest_path%" /E /XD node_modules .git dist build target .next .nuxt out coverage .nyc_output logs tmp temp .tmp .temp __pycache__ .pytest_cache .vscode .idea .DS_Store /XF *.log *.tmp .env .env.local .env.production package-lock.json yarn.lock /NFL /NDL /NJH /NJS /nc /ns /np

if errorlevel 8 (
    echo [ERROR] Error copiando archivos
    goto end
)

echo [OK] Repositorio preparado en: %dest_path%
echo [INFO] Ahora puedes indexarlo con: deepwiki.bat index %repo_name%
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
    echo [ERROR] Debes proporcionar una URL de repositorio o nombre de repo local
    echo Uso: deepwiki.bat index https://github.com/usuario/repo
    echo    o: deepwiki.bat index nombre-repo-local
    goto end
)

REM Detectar si es una URL o un nombre de repositorio local
echo %2 | findstr /C:"http" > nul
if errorlevel 1 (
    REM No es una URL, asumir que es un repo local
    set "repo_arg=%2"
    echo 📂 Indexando repositorio local: %2
) else (
    REM Es una URL
    set "repo_arg=%2"
    echo 📂 Indexando repositorio remoto: %2
)

REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar configuración externa
    echo Usando configuración de Ollama externo...
    docker-compose -f docker-compose.external-ollama.yml run --rm etl !repo_arg!
) else (
    REM Hay contenedor de Ollama, usar configuración dockerizada
    echo Usando configuración de Ollama dockerizado...
    docker-compose run --rm etl !repo_arg!
)
if errorlevel 1 (
    echo [ERROR] Error indexando repositorio
    goto end
)
echo [OK] Repositorio indexado
goto end

:copy_repo
if "%2"=="" (
    echo [ERROR] Debes proporcionar la ruta del repositorio local
    echo Uso: deepwiki.bat copy-repo ^<ruta_local^>
    echo Ejemplo: deepwiki.bat copy-repo E:\MI_PROYECTO\mi-repo
    goto end
)

echo 📁 Copiando repositorio local: %2
set "source_path=%2"
set "repo_name="

REM Extraer nombre del repositorio de la ruta
for %%i in ("%source_path%") do set "repo_name=%%~ni"
set "dest_path=repos\%repo_name%"

echo Copiando a: %dest_path%

REM Verificar que el directorio fuente existe
if not exist "%source_path%" (
    echo [ERROR] El directorio fuente no existe: %source_path%
    goto end
)

REM Crear directorio destino si no existe
if not exist "repos" mkdir repos
if exist "%dest_path%" (
    echo [INFO] Directorio destino ya existe, eliminando...
    rmdir /s /q "%dest_path%"
)

REM Copiar respetando .gitignore
echo [INFO] Copiando archivos (excluyendo patrones comunes)...
robocopy "%source_path%" "%dest_path%" /E /XD node_modules .git .vscode .idea dist build target __pycache__ .pytest_cache .coverage htmlcov .tox .venv venv env .env bower_components .sass-cache .cache .parcel-cache .next .nuxt coverage logs tmp temp *.tmp *.log /XF *.pyc *.pyo *.pyd __pycache__ .DS_Store Thumbs.db desktop.ini .env .env.local .env.production .env.development *.key *.pem *.p12 *.pfx /NP /NDL /NJH > nul

if errorlevel 8 (
    echo [ERROR] Error copiando repositorio
    goto end
) else if errorlevel 4 (
    echo [WARNING] Algunos archivos no se pudieron copiar, pero continúo...
) else if errorlevel 1 (
    echo [INFO] Copia completada con algunos archivos adicionales copiados
)

echo [OK] Repositorio copiado exitosamente
echo [INFO] Puedes indexarlo ahora con: deepwiki.bat index repos\%repo_name%
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
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar externo
    echo Usando Ollama externo...
    ollama list
) else (
    REM Hay contenedor de Ollama, usar dockerizado
    docker-compose exec ollama ollama list
)
goto end

:pull_model
if "%2"=="" (
    echo [ERROR] Debes especificar un modelo
    echo Uso: deepwiki.bat pull ^<modelo^>
    echo Ejemplo: deepwiki.bat pull codellama
    goto end
)
echo 📥 Descargando modelo: %2
REM Detectar si estamos usando Ollama externo o dockerizado
docker ps --format "table {{.Names}}" | findstr /C:"deepwiki_ollama" > nul 2>&1
if errorlevel 1 (
    REM No hay contenedor de Ollama, usar externo
    echo Usando Ollama externo...
    ollama pull %2
) else (
    REM Hay contenedor de Ollama, usar dockerizado
    docker-compose exec ollama ollama pull %2
)
if errorlevel 1 (
    echo [ERROR] Error descargando modelo %2
    goto end
)
echo [OK] Modelo %2 descargado
goto end

:test_query
echo [TEST] Probando sistema Q^&A...

REM Verificar que la API Q^&A esté disponible
echo [INFO] Verificando que la API Q^&A esté disponible...
curl -s http://localhost:5000/health >nul 2>&1
if errorlevel 1 (
    echo [ERROR] La API Q&A no está disponible en http://localhost:5000
    echo [INFO] Asegúrate de que los servicios estén corriendo con: deepwiki.bat start-external
    goto end
)

if "%2"=="" (
    REM Usar consulta por defecto
    echo [INFO] Usando consultas de prueba por defecto...
    
    REM Crear archivo temporal con consulta de prueba
    echo {"question": "What does as-core repository do? Show me the main files and structure", "repo_filter": "as-core"} > test_temp.json
    
    echo [TEST 1] Consultando sobre el repositorio as-core...
    echo Pregunta: "What does as-core repository do? Show me the main files and structure"
    echo.
    curl -X POST http://localhost:5000/ask -H "Content-Type: application/json" --data-binary @test_temp.json
    echo.
    echo.
    
    REM Segunda consulta de prueba
    echo {"question": "package.json dependencies", "repo_filter": "as-core"} > test_temp2.json
    
    echo [TEST 2] Consultando sobre dependencias...
    echo Pregunta: "package.json dependencies"
    echo.
    curl -X POST http://localhost:5000/ask -H "Content-Type: application/json" --data-binary @test_temp2.json
    echo.
    echo.
    
    REM Tercera consulta de prueba más específica
    echo {"question": "TypeScript files and their functions", "repo_filter": "as-core"} > test_temp3.json
    
    echo [TEST 3] Consultando sobre archivos TypeScript...
    echo Pregunta: "TypeScript files and their functions"
    echo.
    curl -X POST http://localhost:5000/ask -H "Content-Type: application/json" --data-binary @test_temp3.json
    echo.
    
    REM Limpiar archivos temporales
    del test_temp.json >nul 2>&1
    del test_temp2.json >nul 2>&1
    del test_temp3.json >nul 2>&1
    
) else (
    REM Usar consulta personalizada del usuario
    echo [INFO] Usando consulta personalizada: %2
    
    REM Crear archivo temporal con la consulta del usuario
    echo {"question": "%2", "repo_filter": "as-core"} > test_custom.json
    
    echo [TEST] Consultando: "%2"
    echo.
    curl -X POST http://localhost:5000/ask -H "Content-Type: application/json" --data-binary @test_custom.json
    echo.
    
    REM Limpiar archivo temporal
    del test_custom.json >nul 2>&1
)

echo.
echo [INFO] Pruebas completadas. Los servicios disponibles son:
echo   [WIKI] http://localhost:8080
echo   [API]  http://localhost:5000
echo   [DB]   http://localhost:8000
echo   [CHAT] http://localhost:3000
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
