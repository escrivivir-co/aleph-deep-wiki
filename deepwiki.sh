#!/bin/bash

# Script de utilidad para DeepWiki
# Uso: ./deepwiki.sh [comando] [argumentos]

set -e

COMPOSE_FILE="docker-compose.yml"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_help() {
    echo -e "${BLUE}DeepWiki - Gestión de la plataforma${NC}"
    echo ""
    echo "Uso: ./deepwiki.sh [comando] [argumentos]"
    echo ""
    echo "Comandos disponibles:"
    echo "  init                   - Inicializar con modelos de Ollama"
    echo "  start                  - Iniciar todos los servicios (con Ollama dockerizado)"
    echo "  start-external         - Iniciar servicios (usando Ollama externo)"
    echo "  start-cpu              - Iniciar servicios (versión CPU)"
    echo "  stop                   - Detener todos los servicios"
    echo "  restart                - Reiniciar todos los servicios"
    echo "  status                 - Ver estado de los servicios"
    echo "  logs [servicio]        - Ver logs (opcional: de un servicio específico)"
    echo "  copy-repo <ruta>       - Copiar repositorio local a carpeta repos (respeta .gitignore)"
    echo "  index <repo_url>       - Indexar un repositorio"
    echo "  test [consulta]        - Probar el sistema Q&A (opcional: consulta personalizada)"
    echo "  health                 - Verificar salud del sistema"
    echo "  models                 - Listar modelos de Ollama"
    echo "  pull <modelo>          - Descargar un modelo específico"
    echo "  backup                 - Crear backup de datos"
    echo "  restore <backup_file>  - Restaurar desde backup"
    echo "  clean                  - Limpiar datos y rebuild"
    echo "  update                 - Actualizar imágenes Docker"
    echo ""
    echo "Ejemplos:"
    echo "  ./deepwiki.sh start-external"
    echo "  ./deepwiki.sh copy-repo /path/to/my-repo"
    echo "  ./deepwiki.sh index https://github.com/fastapi/fastapi"
    echo "  ./deepwiki.sh test"
    echo "  ./deepwiki.sh test \"What are the main TypeScript functions?\""
    echo "  ./deepwiki.sh logs qa"
    echo "  ./deepwiki.sh pull codellama"
    echo "  ./deepwiki.sh backup"
}

check_ollama() {
    # Detectar si estamos usando Ollama externo o dockerizado
    if docker ps --format "table {{.Names}}" | grep -q "deepwiki_ollama"; then
        # Hay contenedor de Ollama, verificar dockerizado
        echo -n "Verificando Ollama dockerizado... "
        if docker-compose exec ollama ollama list > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Ollama está corriendo en Docker${NC}"
        else
            echo -e "${RED}✗ Ollama no está disponible en el contenedor${NC}"
            echo -e "${YELLOW}Usa './deepwiki.sh init' para inicializar Ollama${NC}"
        fi
    else
        # No hay contenedor de Ollama, verificar externo
        echo -n "Verificando Ollama externo... "
        if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Ollama externo está corriendo${NC}"
        else
            echo -e "${RED}✗ Ollama externo no está disponible en localhost:11434${NC}"
            echo -e "${YELLOW}Asegúrate de que Ollama esté corriendo localmente: ollama serve${NC}"
        fi
    fi
}

check_models() {
    echo -n "Verificando modelos de Ollama... "
    if ollama list 2>/dev/null | grep -q "nomic-embed-text"; then
        echo -e "${GREEN}✓ nomic-embed-text${NC}"
    else
        echo -e "${RED}✗ nomic-embed-text${NC}"
        echo "Instala el modelo: ollama pull nomic-embed-text"
    fi
    
    if ollama list 2>/dev/null | grep -q "llama3"; then
        echo -e "${GREEN}✓ llama3${NC}"
    else
        echo -e "${YELLOW}! llama3 no encontrado${NC}"
        echo "Instala el modelo: ollama pull llama3"
    fi
}

cmd_start_external() {
    echo -e "${BLUE}🚀 Iniciando DeepWiki (usando Ollama externo)...${NC}"
    echo -e "${YELLOW}[INFO] Verificando que Ollama externo esté disponible...${NC}"
    
    # Verificar que Ollama externo está corriendo
    if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "${RED}[ERROR] No se puede conectar a Ollama en http://localhost:11434${NC}"
        echo -e "${YELLOW}[INFO] Asegúrate de que Ollama esté corriendo con: ollama serve${NC}"
        exit 1
    fi
    echo -e "${GREEN}[OK] Ollama externo está disponible${NC}"
    
    docker-compose -f docker-compose.external-ollama.yml up -d
    echo -e "${GREEN}✓ Servicios iniciados (usando Ollama externo)${NC}"
    echo ""
    echo "Servicios disponibles:"
    echo "  📖 Wiki: http://localhost:8080"
    echo "  🤖 Q&A API: http://localhost:5000"
    echo "  � Open WebUI: http://localhost:3000"
    echo "  �🗄️ ChromaDB: http://localhost:8000"
    echo "  🧠 Ollama (externo): http://localhost:11434"
}

cmd_init() {
    echo -e "${BLUE}🚀 Inicializando DeepWiki...${NC}"
    echo "Esto descargará los modelos necesarios (puede tomar varios minutos)"
    ./init.sh
}

cmd_start_cpu() {
    echo -e "${BLUE}🚀 Iniciando DeepWiki (versión CPU)...${NC}"
    docker-compose -f docker-compose.cpu.yml up -d
    echo -e "${GREEN}✓ Servicios iniciados (versión CPU)${NC}"
    echo ""
    echo "Servicios disponibles:"
    echo "  📖 Wiki: http://localhost:8080"
    echo "  🤖 Q&A API: http://localhost:5000"
    echo "  💬 Open WebUI: http://localhost:3000"
    echo "  🗄️ ChromaDB: http://localhost:8000"
    echo "  🧠 Ollama: http://localhost:11434"
}

cmd_models() {
    echo -e "${BLUE}📋 Modelos disponibles en Ollama:${NC}"
    if docker ps --format "table {{.Names}}" | grep -q "deepwiki_ollama"; then
        docker-compose exec ollama ollama list
    else
        echo -e "${YELLOW}Usando Ollama externo...${NC}"
        ollama list
    fi
}

cmd_pull() {
    local model=$1
    if [ -z "$model" ]; then
        echo -e "${RED}Error: Debes especificar un modelo${NC}"
        echo "Uso: ./deepwiki.sh pull <modelo>"
        echo "Ejemplo: ./deepwiki.sh pull codellama"
        exit 1
    fi
    
    echo -e "${BLUE}📥 Descargando modelo: $model${NC}"
    if docker ps --format "table {{.Names}}" | grep -q "deepwiki_ollama"; then
        docker-compose exec ollama ollama pull "$model"
    else
        echo -e "${YELLOW}Usando Ollama externo...${NC}"
        ollama pull "$model"
    fi
    echo -e "${GREEN}✓ Modelo $model descargado${NC}"
}

cmd_start() {
    echo -e "${BLUE}🚀 Iniciando DeepWiki...${NC}"
    check_ollama
    check_models
    docker-compose up -d
    echo -e "${GREEN}✓ Servicios iniciados${NC}"
    echo ""
    echo "Servicios disponibles:"
    echo "  📖 Wiki: http://localhost:8080"
    echo "  🤖 Q&A API: http://localhost:5000"
    echo "  🗄️ ChromaDB: http://localhost:8000"
}

cmd_stop() {
    echo -e "${BLUE}🛑 Deteniendo DeepWiki...${NC}"
    docker-compose down
    echo -e "${GREEN}✓ Servicios detenidos${NC}"
}

cmd_restart() {
    echo -e "${BLUE}🔄 Reiniciando DeepWiki...${NC}"
    docker-compose restart
    echo -e "${GREEN}✓ Servicios reiniciados${NC}"
}

cmd_status() {
    echo -e "${BLUE}📊 Estado de los servicios:${NC}"
    docker-compose ps
}

cmd_logs() {
    local service=$1
    if [ -n "$service" ]; then
        echo -e "${BLUE}📝 Logs de $service:${NC}"
        docker-compose logs -f "$service"
    else
        echo -e "${BLUE}📝 Logs de todos los servicios:${NC}"
        docker-compose logs -f
    fi
}

cmd_index() {
    local repo_url=$1
    if [ -z "$repo_url" ]; then
        echo -e "${RED}Error: Debes proporcionar una URL de repositorio${NC}"
        echo "Uso: ./deepwiki.sh index https://github.com/usuario/repo"
        exit 1
    fi
    
    echo -e "${BLUE}📂 Indexando repositorio: $repo_url${NC}"
    # Detectar si estamos usando Ollama externo o dockerizado
    if docker ps --format "table {{.Names}}" | grep -q "deepwiki_ollama"; then
        # Hay contenedor de Ollama, usar configuración dockerizada
        echo -e "${YELLOW}Usando configuración de Ollama dockerizado...${NC}"
        docker-compose run --rm etl python etl.py "$repo_url"
    else
        # No hay contenedor de Ollama, usar configuración externa
        echo -e "${YELLOW}Usando configuración de Ollama externo...${NC}"
        docker-compose -f docker-compose.external-ollama.yml run --rm etl python etl.py "$repo_url"
    fi
    echo -e "${GREEN}✓ Repositorio indexado${NC}"
}

cmd_health() {
    echo -e "${BLUE}🏥 Verificando salud del sistema...${NC}"
    
    # Verificar Ollama
    check_ollama
    
    # Verificar API Q&A
    echo -n "Verificando API Q&A... "
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API Q&A operativa${NC}"
        curl -s http://localhost:5000/health | jq '.' 2>/dev/null || curl -s http://localhost:5000/health
    else
        echo -e "${RED}✗ API Q&A no responde${NC}"
    fi
    
    # Verificar Open WebUI
    echo -n "Verificando Open WebUI... "
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Open WebUI operativa${NC}"
    else
        echo -e "${RED}✗ Open WebUI no responde${NC}"
    fi
}

cmd_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="deepwiki_backup_${timestamp}.tar.gz"
    
    echo -e "${BLUE}💾 Creando backup...${NC}"
    tar -czf "$backup_file" data/ repos/ wiki/docs/
    echo -e "${GREEN}✓ Backup creado: $backup_file${NC}"
    ls -lh "$backup_file"
}

cmd_restore() {
    local backup_file=$1
    if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
        echo -e "${RED}Error: Archivo de backup no encontrado${NC}"
        echo "Uso: ./deepwiki.sh restore deepwiki_backup_YYYYMMDD_HHMMSS.tar.gz"
        exit 1
    fi
    
    echo -e "${BLUE}📥 Restaurando desde: $backup_file${NC}"
    echo -e "${YELLOW}¿Estás seguro? Esto sobrescribirá los datos actuales. [y/N]${NC}"
    read -r confirmation
    
    if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
        docker-compose down
        tar -xzf "$backup_file"
        docker-compose up -d
        echo -e "${GREEN}✓ Backup restaurado${NC}"
    else
        echo "Operación cancelada"
    fi
}

cmd_copy_repo() {
    local source_path="$1"
    if [ -z "$source_path" ]; then
        echo -e "${RED}[ERROR] Debes proporcionar la ruta del repositorio local${NC}"
        echo "Uso: ./deepwiki.sh copy-repo <ruta_local>"
        echo "Ejemplo: ./deepwiki.sh copy-repo /path/to/my-repo"
        exit 1
    fi
    
    if [ ! -d "$source_path" ]; then
        echo -e "${RED}[ERROR] El directorio fuente no existe: $source_path${NC}"
        exit 1
    fi
    
    local repo_name=$(basename "$source_path")
    local dest_path="repos/$repo_name"
    
    echo -e "${BLUE}📁 Copiando repositorio local: $repo_name${NC}"
    echo "   Origen: $source_path"
    echo "   Destino: $dest_path"
    
    # Crear directorio destino si no existe
    mkdir -p repos
    
    if [ -d "$dest_path" ]; then
        echo -e "${YELLOW}[INFO] Directorio destino ya existe, eliminando...${NC}"
        rm -rf "$dest_path"
    fi
    
    echo -e "${YELLOW}[INFO] Copiando archivos (excluyendo patrones comunes)...${NC}"
    
    # Copiar respetando .gitignore y excluyendo patrones comunes
    rsync -av \
        --exclude='node_modules/' \
        --exclude='.git/' \
        --exclude='.vscode/' \
        --exclude='.idea/' \
        --exclude='dist/' \
        --exclude='build/' \
        --exclude='target/' \
        --exclude='__pycache__/' \
        --exclude='.pytest_cache/' \
        --exclude='.coverage/' \
        --exclude='htmlcov/' \
        --exclude='.tox/' \
        --exclude='.venv/' \
        --exclude='venv/' \
        --exclude='env/' \
        --exclude='.env' \
        --exclude='bower_components/' \
        --exclude='.sass-cache/' \
        --exclude='.cache/' \
        --exclude='.parcel-cache/' \
        --exclude='.next/' \
        --exclude='.nuxt/' \
        --exclude='coverage/' \
        --exclude='logs/' \
        --exclude='tmp/' \
        --exclude='temp/' \
        --exclude='*.tmp' \
        --exclude='*.log' \
        --exclude='*.pyc' \
        --exclude='*.pyo' \
        --exclude='*.pyd' \
        --exclude='.DS_Store' \
        --exclude='Thumbs.db' \
        --exclude='desktop.ini' \
        --exclude='*.key' \
        --exclude='*.pem' \
        --exclude='*.p12' \
        --exclude='*.pfx' \
        "$source_path/" "$dest_path/"
    
    echo -e "${GREEN}[OK] Repositorio copiado exitosamente${NC}"
    echo -e "${YELLOW}[INFO] Puedes indexarlo ahora con: ./deepwiki.sh index $repo_name${NC}"
}

cmd_test() {
    local question="$1"
    echo -e "${BLUE}🧪 Probando sistema Q&A...${NC}"
    
    # Verificar que la API Q&A esté disponible
    echo -n "[INFO] Verificando que la API Q&A esté disponible... "
    if ! curl -s http://localhost:5000/health > /dev/null 2>&1; then
        echo -e "${RED}✗${NC}"
        echo -e "${RED}[ERROR] La API Q&A no está disponible en http://localhost:5000${NC}"
        echo -e "${YELLOW}[INFO] Asegúrate de que los servicios estén corriendo con: ./deepwiki.sh start-external${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓${NC}"
    
    if [ -z "$question" ]; then
        # Usar consultas de prueba por defecto
        echo -e "${YELLOW}[INFO] Usando consultas de prueba por defecto...${NC}"
        
        echo -e "${BLUE}[TEST 1] Consultando sobre el repositorio as-core...${NC}"
        echo 'Pregunta: "What does as-core repository do? Show me the main files and structure"'
        echo
        curl -X POST http://localhost:5000/ask \
             -H "Content-Type: application/json" \
             -d '{"question": "What does as-core repository do? Show me the main files and structure", "repo_filter": "as-core"}' \
             2>/dev/null
        echo -e "\n"
        
        echo -e "${BLUE}[TEST 2] Consultando sobre dependencias...${NC}"
        echo 'Pregunta: "package.json dependencies"'
        echo
        curl -X POST http://localhost:5000/ask \
             -H "Content-Type: application/json" \
             -d '{"question": "package.json dependencies", "repo_filter": "as-core"}' \
             2>/dev/null
        echo -e "\n"
        
        echo -e "${BLUE}[TEST 3] Consultando sobre archivos TypeScript...${NC}"
        echo 'Pregunta: "TypeScript files and their functions"'
        echo
        curl -X POST http://localhost:5000/ask \
             -H "Content-Type: application/json" \
             -d '{"question": "TypeScript files and their functions", "repo_filter": "as-core"}' \
             2>/dev/null
        echo
        
    else
        # Usar consulta personalizada del usuario
        echo -e "${YELLOW}[INFO] Usando consulta personalizada: $question${NC}"
        echo -e "${BLUE}[TEST] Consultando: \"$question\"${NC}"
        echo
        curl -X POST http://localhost:5000/ask \
             -H "Content-Type: application/json" \
             -d "{\"question\": \"$question\", \"repo_filter\": \"as-core\"}" \
             2>/dev/null
        echo
    fi
    
    echo
    echo -e "${YELLOW}[INFO] Pruebas completadas. Los servicios disponibles son:${NC}"
    echo "  📖 Wiki: http://localhost:8080"
    echo "  🤖 Q&A API: http://localhost:5000"
    echo "  🗄️ ChromaDB: http://localhost:8000"
    echo "  💬 OpenWebUI: http://localhost:3000"
}

cmd_clean() {
    echo -e "${BLUE}🧹 Limpiando y rebuilding...${NC}"
    echo -e "${YELLOW}¿Estás seguro? Esto eliminará todos los datos. [y/N]${NC}"
    read -r confirmation
    
    if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
        docker-compose down -v
        docker-compose build --no-cache
        rm -rf data/chroma/* repos/* wiki/docs/*.md 2>/dev/null || true
        docker-compose up -d
        echo -e "${GREEN}✓ Sistema limpio y rebuildeado${NC}"
    else
        echo "Operación cancelada"
    fi
}

cmd_update() {
    echo -e "${BLUE}📦 Actualizando imágenes...${NC}"
    docker-compose pull
    docker-compose up -d
    echo -e "${GREEN}✓ Imágenes actualizadas${NC}"
}

# Main
case $1 in
    init)
        cmd_init
        ;;
    start)
        cmd_start
        ;;
    start-external)
        cmd_start_external
        ;;
    start-cpu)
        cmd_start_cpu
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    status)
        cmd_status
        ;;
    logs)
        cmd_logs $2
        ;;
    index)
        cmd_index $2
        ;;
    copy-repo)
        cmd_copy_repo "$2"
        ;;
    test)
        cmd_test "$2"
        ;;
    health)
        cmd_health
        ;;
    models)
        cmd_models
        ;;
    pull)
        cmd_pull $2
        ;;
    backup)
        cmd_backup
        ;;
    restore)
        cmd_restore $2
        ;;
    clean)
        cmd_clean
        ;;
    update)
        cmd_update
        ;;
    help|--help|-h|"")
        print_help
        ;;
    *)
        echo -e "${RED}Comando desconocido: $1${NC}"
        echo ""
        print_help
        exit 1
        ;;
esac
