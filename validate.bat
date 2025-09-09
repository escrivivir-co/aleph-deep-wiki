@echo off
REM Script de validación completa para DeepWiki en Windows
REM Verifica que todos los servicios estén funcionando correctamente

setlocal enabledelayedexpansion

echo 🔍 VALIDACIÓN COMPLETA DE DEEPWIKI
echo ===================================
echo.

REM Función para mostrar estado
set "CHECK_MARK=✓"
set "CROSS_MARK=✗"

REM Variables de control
set "ALL_OK=true"

echo 📋 1. VERIFICANDO CONTENEDORES DOCKER...
echo -----------------------------------------
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | findstr deepwiki
if errorlevel 1 (
    echo %CROSS_MARK% No se encontraron contenedores de DeepWiki corriendo
    set "ALL_OK=false"
    goto :end_check
) else (
    echo %CHECK_MARK% Contenedores encontrados
)
echo.

echo 📋 2. VERIFICANDO CHROMADB (Puerto 8000)...
echo ---------------------------------------------
curl -s -w "HTTP Status: %%{http_code}" http://localhost:8000/api/v2/heartbeat -o nul 2>nul
if errorlevel 1 (
    echo %CROSS_MARK% ChromaDB no responde en puerto 8000
    set "ALL_OK=false"
) else (
    echo %CHECK_MARK% ChromaDB funcionando correctamente
    echo     • API v2 disponible
    REM Obtener versión
    for /f %%i in ('curl -s http://localhost:8000/api/v2/version 2^>nul') do set "CHROMA_VERSION=%%i"
    echo     • Versión: !CHROMA_VERSION!
)
echo.

echo 📋 3. VERIFICANDO WIKI (Puerto 8080)...
echo -----------------------------------------
curl -s -I http://localhost:8080 2>nul | findstr "200 OK" >nul
if errorlevel 1 (
    echo %CROSS_MARK% Wiki no responde en puerto 8080
    set "ALL_OK=false"
) else (
    echo %CHECK_MARK% Wiki (MkDocs) funcionando correctamente
    echo     • Interfaz web accesible
)
echo.

echo 📋 4. VERIFICANDO QA SERVICE (Puerto 5000)...
echo -----------------------------------------------
curl -s -I http://localhost:5000 2>nul | findstr "200 OK" >nul
if errorlevel 1 (
    echo %CROSS_MARK% QA Service no responde en puerto 5000
    set "ALL_OK=false"
) else (
    echo %CHECK_MARK% QA Service (FastAPI) funcionando correctamente
    echo     • API REST disponible
    echo     • Documentación: http://localhost:5000/docs
)
echo.

echo 📋 5. VERIFICANDO OLLAMA EXTERNO (Puerto 11434)...
echo ---------------------------------------------------
curl -s http://localhost:11434/api/tags 2>nul | findstr "models" >nul
if errorlevel 1 (
    echo %CROSS_MARK% Ollama no responde en puerto 11434
    set "ALL_OK=false"
) else (
    echo %CHECK_MARK% Ollama funcionando correctamente
    echo     • Modelos disponibles:
    REM Mostrar algunos modelos (simplificado para Windows)
    curl -s http://localhost:11434/api/tags 2>nul | findstr "name" | head -3
)
echo.

echo 📋 6. VERIFICANDO CONECTIVIDAD INTERNA...
echo ------------------------------------------
echo Revisando logs del QA Service para conexiones...
docker logs deepwiki_qa --tail 5 | findstr "Chroma está listo"
if not errorlevel 1 (
    echo %CHECK_MARK% QA Service conectado a ChromaDB
) else (
    echo %CROSS_MARK% Problema de conectividad QA ↔ ChromaDB
    set "ALL_OK=false"
)

docker logs deepwiki_qa --tail 5 | findstr "Ollama está listo"
if not errorlevel 1 (
    echo %CHECK_MARK% QA Service conectado a Ollama
) else (
    echo %CROSS_MARK% Problema de conectividad QA ↔ Ollama  
    set "ALL_OK=false"
)
echo.

echo 📋 7. VERIFICANDO PUERTOS...
echo ------------------------------
netstat -an | findstr ":5000.*LISTENING" >nul
if not errorlevel 1 echo %CHECK_MARK% Puerto 5000 (QA API) abierto

netstat -an | findstr ":8000.*LISTENING" >nul  
if not errorlevel 1 echo %CHECK_MARK% Puerto 8000 (ChromaDB) abierto

netstat -an | findstr ":8080.*LISTENING" >nul
if not errorlevel 1 echo %CHECK_MARK% Puerto 8080 (Wiki) abierto

netstat -an | findstr ":11434.*LISTENING" >nul
if not errorlevel 1 echo %CHECK_MARK% Puerto 11434 (Ollama) abierto

echo.

:end_check
echo 🎯 RESUMEN DE VALIDACIÓN
echo ========================
if "%ALL_OK%"=="true" (
    echo %CHECK_MARK% TODOS LOS SERVICIOS FUNCIONANDO CORRECTAMENTE
    echo.
    echo 🌐 Servicios disponibles:
    echo   • Wiki:        http://localhost:8080
    echo   • QA API:      http://localhost:5000
    echo   • QA API Docs: http://localhost:5000/docs  
    echo   • ChromaDB:    http://localhost:8000
    echo   • Ollama:      http://localhost:11434
    echo.
    echo 🚀 Sistema listo para:
    echo   • Indexar repositorios: deepwiki.bat index ^<repo_url^>
    echo   • Hacer consultas via API
    echo   • Explorar documentación
    echo.
    exit /b 0
) else (
    echo %CROSS_MARK% SE ENCONTRARON PROBLEMAS EN EL SISTEMA
    echo.
    echo 🔧 Posibles soluciones:
    echo   • Reiniciar servicios: deepwiki.bat restart
    echo   • Verificar logs: deepwiki.bat logs
    echo   • Revisar configuración: deepwiki.bat status
    echo.
    exit /b 1
)
