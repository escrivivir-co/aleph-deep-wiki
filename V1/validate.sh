#!/bin/bash
# Script de validación completa para DeepWiki en Linux/macOS
# Verifica que todos los servicios estén funcionando correctamente

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Símbolos
CHECK_MARK="✓"
CROSS_MARK="✗"
INFO_MARK="ℹ"

# Variable de control
ALL_OK=true

echo -e "${CYAN}🔍 VALIDACIÓN COMPLETA DE DEEPWIKI${NC}"
echo "==================================="
echo

echo -e "${BLUE}📋 1. VERIFICANDO CONTENEDORES DOCKER...${NC}"
echo "-----------------------------------------"
CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep deepwiki)
if [ -z "$CONTAINERS" ]; then
    echo -e "${RED}${CROSS_MARK} No se encontraron contenedores de DeepWiki corriendo${NC}"
    ALL_OK=false
else
    echo -e "${GREEN}${CHECK_MARK} Contenedores encontrados:${NC}"
    echo "$CONTAINERS"
fi
echo

echo -e "${BLUE}📋 2. VERIFICANDO CHROMADB (Puerto 8000)...${NC}"
echo "---------------------------------------------"
if curl -s -w "%{http_code}" http://localhost:8000/api/v2/heartbeat -o /dev/null | grep -q "200"; then
    echo -e "${GREEN}${CHECK_MARK} ChromaDB funcionando correctamente${NC}"
    echo "    • API v2 disponible"
    
    # Obtener versión
    CHROMA_VERSION=$(curl -s http://localhost:8000/api/v2/version 2>/dev/null | tr -d '"')
    echo "    • Versión: $CHROMA_VERSION"
    
    # Verificar heartbeat
    HEARTBEAT=$(curl -s http://localhost:8000/api/v2/heartbeat 2>/dev/null)
    if echo "$HEARTBEAT" | grep -q "nanosecond heartbeat"; then
        echo "    • Heartbeat activo"
    fi
else
    echo -e "${RED}${CROSS_MARK} ChromaDB no responde en puerto 8000${NC}"
    ALL_OK=false
fi
echo

echo -e "${BLUE}📋 3. VERIFICANDO WIKI (Puerto 8080)...${NC}"
echo "-----------------------------------------"
if curl -s -I http://localhost:8080 2>/dev/null | grep -q "200 OK"; then
    echo -e "${GREEN}${CHECK_MARK} Wiki (MkDocs) funcionando correctamente${NC}"
    echo "    • Interfaz web accesible"
    
    # Verificar contenido
    CONTENT_LENGTH=$(curl -s -I http://localhost:8080 2>/dev/null | grep -i "content-length" | cut -d' ' -f2 | tr -d '\r')
    if [ ! -z "$CONTENT_LENGTH" ] && [ "$CONTENT_LENGTH" -gt 1000 ]; then
        echo "    • Contenido cargado (${CONTENT_LENGTH} bytes)"
    fi
else
    echo -e "${RED}${CROSS_MARK} Wiki no responde en puerto 8080${NC}"
    ALL_OK=false
fi
echo

echo -e "${BLUE}📋 4. VERIFICANDO QA SERVICE (Puerto 5000)...${NC}"
echo "-----------------------------------------------"
if curl -s -I http://localhost:5000 2>/dev/null | grep -q "200 OK"; then
    echo -e "${GREEN}${CHECK_MARK} QA Service (FastAPI) funcionando correctamente${NC}"
    echo "    • API REST disponible"
    echo "    • Documentación: http://localhost:5000/docs"
    
    # Verificar si es FastAPI
    if curl -s -I http://localhost:5000/docs 2>/dev/null | grep -q "200 OK"; then
        echo "    • Documentación Swagger accesible"
    fi
else
    echo -e "${RED}${CROSS_MARK} QA Service no responde en puerto 5000${NC}"
    ALL_OK=false
fi
echo

echo -e "${BLUE}📋 5. VERIFICANDO OLLAMA EXTERNO (Puerto 11434)...${NC}"
echo "---------------------------------------------------"
if curl -s http://localhost:11434/api/tags 2>/dev/null | grep -q "models"; then
    echo -e "${GREEN}${CHECK_MARK} Ollama funcionando correctamente${NC}"
    
    # Contar modelos
    MODEL_COUNT=$(curl -s http://localhost:11434/api/tags 2>/dev/null | grep -o '"name"' | wc -l)
    echo "    • $MODEL_COUNT modelos disponibles"
    
    # Mostrar algunos modelos
    echo "    • Modelos detectados:"
    curl -s http://localhost:11434/api/tags 2>/dev/null | grep '"name"' | head -3 | sed 's/.*"name":"\([^"]*\)".*/      - \1/'
    
    # Verificar versión de Ollama
    OLLAMA_VERSION=$(curl -s http://localhost:11434/api/version 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    if [ ! -z "$OLLAMA_VERSION" ]; then
        echo "    • Versión Ollama: $OLLAMA_VERSION"
    fi
else
    echo -e "${RED}${CROSS_MARK} Ollama no responde en puerto 11434${NC}"
    ALL_OK=false
fi
echo

echo -e "${BLUE}📋 6. VERIFICANDO CONECTIVIDAD INTERNA...${NC}"
echo "------------------------------------------"
echo "Revisando logs del QA Service para conexiones..."

# Verificar conexión a ChromaDB
if docker logs deepwiki_qa --tail 10 2>/dev/null | grep -q "Chroma está listo"; then
    echo -e "${GREEN}${CHECK_MARK} QA Service conectado a ChromaDB${NC}"
else
    echo -e "${RED}${CROSS_MARK} Problema de conectividad QA ↔ ChromaDB${NC}"
    ALL_OK=false
fi

# Verificar conexión a Ollama  
if docker logs deepwiki_qa --tail 10 2>/dev/null | grep -q "Ollama está listo"; then
    echo -e "${GREEN}${CHECK_MARK} QA Service conectado a Ollama${NC}"
else
    echo -e "${RED}${CROSS_MARK} Problema de conectividad QA ↔ Ollama${NC}"
    ALL_OK=false
fi

# Verificar inicialización completa
if docker logs deepwiki_qa --tail 5 2>/dev/null | grep -q "Application startup complete"; then
    echo -e "${GREEN}${CHECK_MARK} QA Service completamente inicializado${NC}"
else
    echo -e "${YELLOW}⚠ QA Service podría estar iniciando...${NC}"
fi
echo

echo -e "${BLUE}📋 7. VERIFICANDO PUERTOS...${NC}"
echo "------------------------------"
# Verificar puertos usando diferentes métodos según el SO
if command -v ss &> /dev/null; then
    # Usar ss si está disponible (más moderno)
    PORT_CHECK_CMD="ss -ln"
elif command -v netstat &> /dev/null; then
    # Usar netstat como fallback
    PORT_CHECK_CMD="netstat -ln"
else
    echo -e "${YELLOW}⚠ No se puede verificar puertos (ss/netstat no disponibles)${NC}"
    PORT_CHECK_CMD=""
fi

if [ ! -z "$PORT_CHECK_CMD" ]; then
    if $PORT_CHECK_CMD | grep -q ":5000.*LISTEN\|:5000 "; then
        echo -e "${GREEN}${CHECK_MARK} Puerto 5000 (QA API) abierto${NC}"
    fi
    
    if $PORT_CHECK_CMD | grep -q ":8000.*LISTEN\|:8000 "; then
        echo -e "${GREEN}${CHECK_MARK} Puerto 8000 (ChromaDB) abierto${NC}"
    fi
    
    if $PORT_CHECK_CMD | grep -q ":8080.*LISTEN\|:8080 "; then
        echo -e "${GREEN}${CHECK_MARK} Puerto 8080 (Wiki) abierto${NC}"
    fi
    
    if $PORT_CHECK_CMD | grep -q ":11434.*LISTEN\|:11434 "; then
        echo -e "${GREEN}${CHECK_MARK} Puerto 11434 (Ollama) abierto${NC}"
    fi
fi
echo

# Verificación adicional de red Docker
echo -e "${BLUE}📋 8. VERIFICANDO RED DOCKER...${NC}"
echo "--------------------------------"
NETWORK_NAME=$(docker network ls | grep deepwiki | awk '{print $2}')
if [ ! -z "$NETWORK_NAME" ]; then
    echo -e "${GREEN}${CHECK_MARK} Red Docker: $NETWORK_NAME${NC}"
    CONTAINERS_IN_NET=$(docker network inspect "$NETWORK_NAME" --format='{{range .Containers}}{{.Name}} {{end}}')
    echo "    • Contenedores en la red: $CONTAINERS_IN_NET"
else
    echo -e "${YELLOW}⚠ Red Docker no encontrada${NC}"
fi
echo

echo -e "${PURPLE}🎯 RESUMEN DE VALIDACIÓN${NC}"
echo "========================"
if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}${CHECK_MARK} TODOS LOS SERVICIOS FUNCIONANDO CORRECTAMENTE${NC}"
    echo
    echo -e "${CYAN}🌐 Servicios disponibles:${NC}"
    echo "  • Wiki:        http://localhost:8080"
    echo "  • QA API:      http://localhost:5000"  
    echo "  • QA API Docs: http://localhost:5000/docs"
    echo "  • ChromaDB:    http://localhost:8000"
    echo "  • Ollama:      http://localhost:11434"
    echo
    echo -e "${YELLOW}🚀 Sistema listo para:${NC}"
    echo "  • Indexar repositorios: ./deepwiki.sh index <repo_url>"
    echo "  • Hacer consultas via API"
    echo "  • Explorar documentación"
    echo
    exit 0
else
    echo -e "${RED}${CROSS_MARK} SE ENCONTRARON PROBLEMAS EN EL SISTEMA${NC}"
    echo
    echo -e "${YELLOW}🔧 Posibles soluciones:${NC}"
    echo "  • Reiniciar servicios: ./deepwiki.sh restart"
    echo "  • Verificar logs: ./deepwiki.sh logs"
    echo "  • Revisar configuración: ./deepwiki.sh status"
    echo "  • Reiniciar desde cero: ./deepwiki.sh stop && ./deepwiki.sh start-external"
    echo
    exit 1
fi
