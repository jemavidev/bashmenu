# 🔧 Bashmenu - Troubleshooting Guide

## Problemas Comunes y Soluciones

---

## ❌ Error: "Permiso denegado" al ejecutar bashmenu

### Síntoma
```bash
bash bashmenu
bashmenu: línea 16: /path/to/src/main.sh: Permiso denegado
bashmenu: línea 16: exec: /path/to/src/main.sh: no se puede ejecutar: Permiso denegado
```

### Causa
Los scripts no tienen permisos de ejecución.

### Solución Rápida ✅

```bash
# Opción 1: Usar el script de corrección automática
./fix_permissions.sh

# Opción 2: Corregir manualmente
chmod +x bashmenu
chmod +x src/*.sh
chmod +x plugins/**/*.sh
```

### Solución Permanente

Agregar al `.gitattributes` para preservar permisos:
```bash
echo "*.sh text eol=lf" >> .gitattributes
git add .gitattributes
git commit -m "Preserve shell script permissions"
```

---

## ❌ Error: "command not found: bashmenu"

### Síntoma
```bash
bashmenu
bash: bashmenu: command not found
```

### Causa
El script no está en el PATH o no se ejecuta desde el directorio correcto.

### Solución ✅

```bash
# Opción 1: Ejecutar desde el directorio del proyecto
cd /path/to/Bashmenu
./bashmenu

# Opción 2: Instalar system-wide
sudo ./install.sh

# Opción 3: Agregar al PATH
echo 'export PATH="$HOME/path/to/Bashmenu:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## ❌ Error: "No such file or directory" en módulos

### Síntoma
```bash
./bashmenu
src/menu_refactored.sh: line 15: src/menu_core.sh: No such file or directory
```

### Causa
Los módulos refactorizados no existen o la migración no se completó.

### Solución ✅

```bash
# Verificar que los módulos existen
ls -la src/menu_*.sh

# Si no existen, ejecutar migración
./migrate_to_v3.sh

# Si la migración falla, hacer rollback
./rollback_migration.sh
```

---

## ❌ Error: "Syntax error" en scripts

### Síntoma
```bash
./bashmenu
src/menu_core.sh: line 42: syntax error near unexpected token `}'
```

### Causa
Error de sintaxis en algún módulo.

### Solución ✅

```bash
# Verificar sintaxis de todos los módulos
for file in src/menu_*.sh; do
    echo "Checking $file..."
    bash -n "$file" || echo "ERROR in $file"
done

# Si hay errores, revisar el archivo específico
vim src/menu_core.sh +42
```

---

## ❌ Error: "Function not found"

### Síntoma
```bash
./bashmenu
bash: initialize_menu: command not found
```

### Causa
Las funciones no están siendo exportadas correctamente.

### Solución ✅

```bash
# Verificar que las funciones están exportadas
grep "export -f" src/menu_*.sh

# Verificar orden de carga en menu_refactored.sh
cat src/menu_refactored.sh | grep "source"

# Recargar módulos
source src/menu_refactored.sh
```

---

## ❌ Error: "Unbound variable"

### Síntoma
```bash
./bashmenu
src/menu_core.sh: line 25: AUTO_SCRIPTS: unbound variable
```

### Causa
Variable no inicializada debido a `set -u` (strict mode).

### Solución ✅

```bash
# Verificar inicialización de variables
grep "declare.*AUTO_SCRIPTS" src/menu_*.sh

# Asegurar que las variables se inicializan antes de usar
# En menu_core.sh:
declare -gA AUTO_SCRIPTS=()
```

---

## ❌ Error: Tests fallan

### Síntoma
```bash
cd tests
bats test_refactored_modules.bats
✗ menu_core.sh: add_menu_item adds item successfully
```

### Causa
BATS no instalado o tests desactualizados.

### Solución ✅

```bash
# Verificar BATS instalado
which bats

# Instalar BATS si es necesario
cd bats-testing
sudo ./install.sh /usr/local

# Ejecutar tests con verbose para ver detalles
bats -t test_refactored_modules.bats
```

---

## ❌ Error: "Menu vacío" (solo opción Exit)

### Síntoma
El menú se muestra pero solo tiene la opción "Exit".

### Causa
- `scripts.conf` vacío o mal configurado
- Auto-scan deshabilitado
- No hay scripts en plugins/

### Solución ✅

```bash
# Verificar configuración
cat config/scripts.conf

# Verificar auto-scan
grep "ENABLE_AUTO_SCAN" config/config.conf

# Verificar scripts en plugins
ls -la plugins/

# Habilitar auto-scan si está deshabilitado
sed -i 's/ENABLE_AUTO_SCAN=false/ENABLE_AUTO_SCAN=true/' config/config.conf

# O agregar scripts manualmente a scripts.conf
echo "Test Script|/path/to/script.sh|Description|1|" >> config/scripts.conf
```

---

## ❌ Error: "Theme not found"

### Síntoma
```bash
./bashmenu --theme mytheme
Theme 'mytheme' not found, using default theme
```

### Causa
El tema especificado no existe.

### Solución ✅

```bash
# Ver temas disponibles
./bashmenu --help | grep -A 5 "Available themes"

# Temas válidos:
# - default
# - dark
# - colorful
# - minimal
# - modern

# Usar un tema válido
./bashmenu --theme dark
```

---

## ❌ Error: "Script validation failed"

### Síntoma
```bash
Script validation failed: /path/to/script.sh
Script path not in allowed directories
```

### Causa
El script no está en un directorio permitido por seguridad.

### Solución ✅

```bash
# Ver directorios permitidos
grep "ALLOWED_SCRIPT_DIRS" config/config.conf

# Agregar directorio a la lista
# Editar config/config.conf y agregar el path:
ALLOWED_SCRIPT_DIRS="/opt/bashmenu/plugins:/opt/scripts:/usr/local/bin:/your/new/path"

# O mover el script a un directorio permitido
mv /path/to/script.sh plugins/
```

---

## ❌ Error: "Rollback failed"

### Síntoma
```bash
./rollback_migration.sh
menu_legacy.sh not found
```

### Causa
El archivo de respaldo no existe.

### Solución ✅

```bash
# Verificar ubicación del backup
cat .last_backup

# Restaurar desde backup
BACKUP_DIR=$(cat .last_backup)
cp $BACKUP_DIR/menu.sh.backup src/menu.sh

# O reinstalar desde git
git checkout src/menu.sh
```

---

## 🔍 Diagnóstico General

### Script de Diagnóstico Rápido

```bash
#!/bin/bash
echo "=== Bashmenu Diagnostic ==="
echo ""
echo "1. Checking permissions..."
ls -la bashmenu src/main.sh | grep -E "^-rwx" && echo "✓ OK" || echo "✗ FAIL"
echo ""
echo "2. Checking modules..."
ls src/menu_*.sh | wc -l
echo ""
echo "3. Checking symlink..."
ls -la src/menu.sh
echo ""
echo "4. Checking syntax..."
bash -n src/menu_refactored.sh && echo "✓ OK" || echo "✗ FAIL"
echo ""
echo "5. Checking configuration..."
test -f config/config.conf && echo "✓ OK" || echo "✗ FAIL"
echo ""
echo "6. Checking plugins..."
ls plugins/ | wc -l
echo ""
```

Guardar como `diagnose.sh` y ejecutar:
```bash
chmod +x diagnose.sh
./diagnose.sh
```

---

## 📞 Obtener Ayuda

### Logs

```bash
# Ver logs en tiempo real
tail -f /tmp/bashmenu.log

# Ver últimas 50 líneas
tail -50 /tmp/bashmenu.log

# Buscar errores
grep ERROR /tmp/bashmenu.log
```

### Modo Debug

```bash
# Ejecutar con debug habilitado
DEBUG_MODE=true LOG_LEVEL=0 ./bashmenu

# Ver todas las operaciones
set -x
./bashmenu
set +x
```

### Información del Sistema

```bash
# Ver información completa
./bashmenu --info

# Ver versión
./bashmenu --version

# Ver ayuda
./bashmenu --help
```

---

## 🆘 Solución de Último Recurso

Si nada funciona, reinstalar desde cero:

```bash
# 1. Hacer backup de configuración
cp -r config/ config.backup/
cp -r plugins/ plugins.backup/

# 2. Limpiar instalación
git clean -fdx

# 3. Restaurar desde git
git reset --hard HEAD

# 4. Restaurar configuración
cp -r config.backup/* config/
cp -r plugins.backup/* plugins/

# 5. Corregir permisos
./fix_permissions.sh

# 6. Probar
./bashmenu
```

---

## 📚 Recursos Adicionales

- **Documentación**: `README.md`
- **Arquitectura**: `ARCHITECTURE.md`
- **Migración**: `MIGRATION_NOTES.md`
- **Quick Start**: `QUICK_START_V3.md`
- **Tests**: `tests/test_refactored_modules.bats`

---

**Última actualización**: 2026-01-26  
**Versión**: 3.0.0-alpha
