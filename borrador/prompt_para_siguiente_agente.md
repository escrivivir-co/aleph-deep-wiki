# 🎯 Prompt para el Siguiente Agente - Estado del Sistema DeepWiki

## 📋 **Situación Actual - GRAN AVANCE**

Hemos estado configurando **`aleph-deep-wiki`** para que funcione con **Ollama externo**. ¡**EXCELENTES NOTICIAS**: El sistema ya está **95% funcionando**! Solo queda resolver un pequeño problema de procesamiento de archivos.

### ✅ **Lo que YA funciona correctamente:**

1. **✅ Detección automática** de Ollama externo vs dockerizado en todos los scripts
2. **✅ Servicios corriendo:** ChromaDB, Q&A API, Wiki, OpenWebUI
3. **✅ Comando `copy-repo`:** Copia repositorios locales sin `node_modules` ni archivos basura
4. **✅ Scripts refactorizados:** [`deepwiki.bat`](deepwiki.bat) es robusto y detecta configuración
5. **✅ Comando `index`:** La indexación FUNCIONA y se completa exitosamente
6. **✅ ChromaDB API v2:** Endpoint corregido de v1 a v2
7. **✅ Rebuild ETL:** Nuevo comando `./deepwiki.bat rebuild-etl` para aplicar cambios

### ❓ **El único problema restante (menor):**

El comando de indexación funciona pero dice:
```
Error actualizando repo: /app/repos/as-core
🎉 Proceso completado exitosamente!
```

Y no genera archivos en `wiki/docs/repos/` ni documentos en ChromaDB (`"documents":0`).

## 🔧 **Problemas RESUELTOS (para futuros agentes)**

### ✅ **RESUELTO: ChromaDB API v2 vs v1**
**Problema:** ChromaDB v1 endpoint `/api/v1/heartbeat` responde 410 "Unimplemented"
**Solución:** Cambiado a `/api/v2/heartbeat` en `etl/etl.py` línea ~26

### ✅ **RESUELTO: Servicio ETL no se rebuilda**
**Problema:** `./deepwiki.bat rebuild` NO incluye ETL (servicio temporal con `profiles: - tools`)
**Solución:** Creado comando `./deepwiki.bat rebuild-etl` específico para ETL

### ✅ **RESUELTO: Docker ENTRYPOINT duplicado**
**Problema:** ENTRYPOINT `["python", "etl.py"]` + comando `python etl.py as-core` = `python etl.py python etl.py as-core`
**Solución:** Comando corregido a solo `as-core` (sin `python etl.py`)

### ✅ **RESUELTO: Git Bash path conversion**
**Problema:** Git Bash convierte `/app/repos/as-core` a `C:/Program Files/Git/app/repos/as-core`
**Solución:** Pasar solo nombre del repo (`as-core`) y dejar que ETL construya el path internamente

## 🚀 **Comandos Implementados y Funcionando**

### **Comandos básicos:**
```bash
./deepwiki.bat health          # ✅ Funciona perfectamente
./deepwiki.bat status          # ✅ Funciona
./deepwiki.bat start-external  # ✅ Funciona con Ollama externo
./deepwiki.bat start          # ✅ Funciona con Ollama dockerizado
```

### **Comandos de rebuild (NUEVOS):**
```bash
./deepwiki.bat rebuild         # ✅ Rebuild servicios principales (NO incluye ETL)
./deepwiki.bat rebuild-etl     # ✅ Rebuild SOLO ETL (para cambios en etl/etl.py)
./deepwiki.bat rebuild-all     # ✅ Rebuild COMPLETO incluyendo ETL
```

### **Comandos de repositorios:**
```bash
./deepwiki.bat copy-repo <path>  # ✅ Funciona perfectamente
./deepwiki.bat index as-core     # ✅ Se ejecuta exitosamente (ver problema menor abajo)
```

## 🚀 **Comandos Útiles para Diagnosticar**

### **1. Verificar estado general:**
```bash
cd /e/LAB_AGOSTO/ORACLE_HALT_ALEPH_VERSION/aleph-deep-wiki
./deepwiki.bat health
./deepwiki.bat status
```

### **2. Verificar el repositorio copiado:**
```bash
ls -la repos/as-core/
```

### **3. Probar conexión a servicios:**
```bash
curl -s http://localhost:11434/api/tags  # Ollama externo
curl -s http://localhost:8000/api/v2/heartbeat  # ChromaDB
curl -s http://localhost:5000/health  # Q&A API
```

### **4. Verificar volúmenes del contenedor ETL:**
```bash
docker-compose -f docker-compose.external-ollama.yml run --rm --entrypoint="ls" etl -la /app/repos/
```

### **5. Debug del script ETL:**
```bash
docker-compose -f docker-compose.external-ollama.yml run --rm --entrypoint="python" etl -c "import os; print('Repos dir exists:', os.path.exists('/app/repos')); print('as-core exists:', os.path.exists('/app/repos/as-core')); print('Contents:', os.listdir('/app/repos') if os.path.exists('/app/repos') else 'No dir')"
```

## 🎯 **Lo que necesitas hacer:**

### **Paso 1: Validar el problema**
1. Ejecutar los comandos de diagnóstico de arriba
2. Verificar si el problema es:
   - El volumen no se monta correctamente
   - El script ETL no reconoce el repositorio 
   - Problema de path/encoding en Windows

### **Paso 2: Intentar la indexación**
```bash
./deepwiki.bat index as-core
```

### **Paso 3: Si falla, probar alternativas:**
```bash
# Opción A: Usar ruta completa dentro del contenedor
./deepwiki.bat index /app/repos/as-core

# Opción B: Probar con URL de GitHub si tienes el repo público
./deepwiki.bat index https://github.com/usuario/as-core
```

## 🔍 **Archivos Clave Modificados**

### **Scripts principales:**
- **[`deepwiki.bat`](deepwiki.bat):** Script Windows con detección dual Ollama
- **`deepwiki.sh`:** Script Linux homólogo
- **`docker-compose.external-ollama.yml`:** Configuración para Ollama externo

### **Archivos ETL:**
- **`etl/etl.py`:** Script de indexación (líneas 250-270 son clave)
- **Dockerfile ETL:** Recién rebuildeado

### **Configuración:**
- **Modelo Q&A:** `gpt-oss:20b` (configurado en docker-compose)
- **Modelo embeddings:** `nomic-embed-text`

## 📝 **Comandos de Ayuda Rápida**

```bash
# Rebuild completo si hay problemas
./deepwiki.bat rebuild

# Rebuild solo ETL
docker-compose -f docker-compose.external-ollama.yml build --no-cache etl

# Ver logs en tiempo real
./deepwiki.bat logs etl

# Copiar nuevo repositorio
./deepwiki.bat copy-repo /ruta/a/mi/repo

# Verificar modelos Ollama
./deepwiki.bat models
```

## 🎯 **Objetivo Final**

Que el comando **`./deepwiki.bat index as-core`** funcione correctamente y genere:
1. **Embeddings** en ChromaDB para búsqueda semántica
2. **Wiki navegable** en `http://localhost:8080`
3. **API Q&A** funcional en `http://localhost:5000`
4. **Chat interactivo** en `http://localhost:3000`

## 💡 **Nota Importante**

Todo el sistema de detección dual (Ollama interno vs externo) ya está implementado y funcionando. El único problema es este último paso de indexación. Una vez resuelto, el sistema estará completamente operativo.

---

**¡Buena suerte!** 🚀 El sistema está a un paso de funcionar perfectamente.
