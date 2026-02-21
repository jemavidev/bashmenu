# 🚀 Bashmenu v3.0 - Quick Start Guide

## ⚡ Inicio Rápido (5 minutos)

### 1. Migrar a v3.0

```bash
# Ejecutar script de migración automatizada
./migrate_to_v3.sh

# Responder 'y' cuando se solicite confirmación
```

### 2. Probar el Sistema

```bash
# Ejecutar Bashmenu
./bashmenu

# Debería funcionar exactamente igual que v2.1
# pero con la nueva arquitectura modular por debajo
```

### 3. Verificar Módulos

```bash
# Listar módulos nuevos
ls -la src/menu_*.sh

# Deberías ver:
# menu_core.sh
# menu_themes.sh
# menu_display.sh
# menu_input.sh
# menu_navigation.sh
# menu_execution.sh
# menu_loop.sh
# menu_validation.sh
# menu_help.sh
# menu_refactored.sh
```

### 4. Ejecutar Tests

```bash
# Ir al directorio de tests
cd tests

# Ejecutar suite de tests
bats test_refactored_modules.bats

# Ver resultados
# ✓ Todos los tests deberían pasar
```

---

## 🔄 Si Algo Sale Mal

### Rollback Inmediato

```bash
# Ejecutar script de rollback
./rollback_migration.sh

# O manualmente:
cd src/
rm menu.sh
mv menu_legacy.sh menu.sh
```

### Restaurar desde Backup

```bash
# Ver ubicación del backup
cat .last_backup

# Restaurar manualmente
BACKUP_DIR=$(cat .last_backup)
cp $BACKUP_DIR/menu.sh.backup src/menu.sh
```

---

## 📊 Verificar Estado

### Comprobar Arquitectura

```bash
# Ver estructura de módulos
tree src/ -P 'menu_*.sh'

# Verificar symlink
ls -la src/menu.sh
# Debería mostrar: menu.sh -> menu_refactored.sh
```

### Validar Sintaxis

```bash
# Verificar todos los módulos
for file in src/menu_*.sh; do
    echo "Checking $file..."
    bash -n "$file" && echo "✓ OK" || echo "✗ ERROR"
done
```

### Ver Logs

```bash
# Ver logs de ejecución
tail -f /tmp/bashmenu.log

# Ver logs con nivel DEBUG
DEBUG_MODE=true ./bashmenu
```

---

## 📚 Documentación Rápida

### Leer Documentación

```bash
# Resumen de refactorización
cat REFACTORING_SUMMARY.md

# Arquitectura detallada
cat ARCHITECTURE.md

# Estado completo
cat REFACTORING_COMPLETE.md

# Notas de migración
cat MIGRATION_NOTES.md
```

### Estructura de Módulos

```
src/
├── menu_core.sh          # Estructuras de datos
├── menu_themes.sh        # Sistema de temas
├── menu_display.sh       # Renderizado
├── menu_input.sh         # Entrada de usuario
├── menu_navigation.sh    # Navegación jerárquica
├── menu_execution.sh     # Ejecución de scripts
├── menu_loop.sh          # Loop principal
├── menu_validation.sh    # Validación de seguridad
├── menu_help.sh          # Sistema de ayuda
└── menu_refactored.sh    # Orquestador principal
```

---

## 🧪 Testing Rápido

### Tests Básicos

```bash
# Test de sintaxis
bash -n src/menu_refactored.sh && echo "✓ Syntax OK"

# Test de carga de módulos
bash -c "source src/menu_refactored.sh && echo '✓ Modules loaded'"

# Test de funciones
bash -c "source src/menu_core.sh && declare -f initialize_menu && echo '✓ Functions OK'"
```

### Tests Completos

```bash
# Ejecutar suite completa
cd tests
bats test_refactored_modules.bats

# Ejecutar con verbose
bats -t test_refactored_modules.bats

# Ejecutar test específico
bats -f "menu_core" test_refactored_modules.bats
```

---

## 🎯 Casos de Uso Comunes

### Desarrollo

```bash
# Editar un módulo
vim src/menu_display.sh

# Verificar sintaxis
bash -n src/menu_display.sh

# Probar cambios
./bashmenu
```

### Agregar Nueva Funcionalidad

```bash
# 1. Crear nuevo módulo
vim src/menu_custom.sh

# 2. Agregar funciones
my_custom_function() {
    echo "Custom functionality"
}
export -f my_custom_function

# 3. Cargar en menu_refactored.sh
# Agregar: source "$MENU_SCRIPT_DIR/menu_custom.sh"

# 4. Usar en menu_loop.sh
# Agregar case para nueva tecla
```

### Debugging

```bash
# Modo debug
DEBUG_MODE=true LOG_LEVEL=0 ./bashmenu

# Ver funciones cargadas
bash -c "source src/menu_refactored.sh && declare -F | grep menu"

# Verificar variables
bash -c "source src/menu_themes.sh && initialize_themes && echo \$default_frame_top"
```

---

## 🔍 Troubleshooting

### Problema: Menu no carga

```bash
# Verificar symlink
ls -la src/menu.sh

# Recrear symlink si es necesario
cd src/
rm menu.sh
ln -s menu_refactored.sh menu.sh
```

### Problema: Funciones no encontradas

```bash
# Verificar exports
grep "export -f" src/menu_*.sh

# Verificar orden de carga
grep "source.*menu_" src/menu_refactored.sh
```

### Problema: Tests fallan

```bash
# Verificar BATS instalado
which bats

# Instalar BATS si es necesario
cd bats-testing
sudo ./install.sh /usr/local

# Verificar permisos
chmod +x tests/test_refactored_modules.bats
```

---

## 📈 Métricas de Éxito

### Verificar Mejoras

```bash
# Contar líneas por módulo
wc -l src/menu_*.sh

# Verificar funciones por módulo
for file in src/menu_*.sh; do
    echo "$file:"
    grep -c "^[a-z_]*() {" "$file"
done

# Verificar tests
bats -c tests/test_refactored_modules.bats
```

### Comparar con v2.1

```bash
# Líneas en v2.1
wc -l src/menu_legacy.sh

# Líneas en v3.0 (total)
wc -l src/menu_*.sh | tail -1

# Funciones en v2.1
grep -c "^[a-z_]*() {" src/menu_legacy.sh

# Funciones en v3.0 (total)
grep "^[a-z_]*() {" src/menu_*.sh | wc -l
```

---

## 🎓 Recursos Adicionales

### Documentación

- **REFACTORING_SUMMARY.md** - Resumen completo
- **ARCHITECTURE.md** - Arquitectura detallada
- **REFACTORING_COMPLETE.md** - Estado final
- **PRD-Bashmenu-v3.0.md** - Requisitos del producto

### Scripts Útiles

- **migrate_to_v3.sh** - Migración automatizada
- **rollback_migration.sh** - Rollback (generado)
- **tests/test_refactored_modules.bats** - Suite de tests

### Comandos Útiles

```bash
# Ver estructura del proyecto
tree -L 2 -I 'bats-testing|AgentX'

# Buscar función específica
grep -r "function_name" src/

# Ver dependencias de módulo
grep "source.*menu_" src/menu_refactored.sh

# Contar tests
grep -c "@test" tests/test_refactored_modules.bats
```

---

## ✅ Checklist de Verificación

### Post-Migración

- [ ] Backup creado exitosamente
- [ ] Symlink menu.sh → menu_refactored.sh existe
- [ ] Todos los módulos tienen sintaxis correcta
- [ ] Bashmenu ejecuta sin errores
- [ ] Tests pasan (al menos los básicos)
- [ ] Documentación revisada

### Pre-Producción

- [ ] Tests completos ejecutados
- [ ] Performance verificado
- [ ] Logs revisados
- [ ] Rollback script probado
- [ ] Documentación actualizada
- [ ] Equipo notificado

---

## 🚀 Siguiente Nivel

### Fase 2: Testing

```bash
# Aumentar cobertura de tests
# Agregar más tests en test_refactored_modules.bats

# Ejecutar con coverage
# (Requiere herramientas adicionales)
```

### Fase 3: CI/CD

```bash
# Configurar GitHub Actions
# Ver .github/workflows/ (próximamente)

# Integrar ShellCheck
shellcheck src/menu_*.sh
```

### Fase 4: Features

```bash
# Implementar caching
# Agregar búsqueda mejorada
# Sistema de favoritos
# Ver PRD para más detalles
```

---

## 📞 Soporte

### Obtener Ayuda

- **GitHub Issues**: Reportar problemas
- **Documentación**: Leer ARCHITECTURE.md
- **Tests**: Ejecutar suite de tests
- **Logs**: Revisar /tmp/bashmenu.log

### Contribuir

1. Fork del repositorio
2. Crear feature branch
3. Hacer cambios
4. Agregar tests
5. Submit PR

---

**🎉 ¡Listo para usar Bashmenu v3.0!**

*Arquitectura modular, código limpio, futuro brillante.*

---

**Versión**: 3.0.0-alpha  
**Fecha**: 2026-01-26  
**Autor**: JESUS MARIA VILLALOBOS
