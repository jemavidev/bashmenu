# 🔒 Guía de Implementación del Sistema de Permisos

## 📋 Pasos para Implementar y Verificar

### Paso 1: Ejecutar el Script de Prueba

```bash
chmod +x test_permissions.sh
./test_permissions.sh
```

### Paso 2: Opciones Disponibles

El script te mostrará 6 opciones:

#### Opción 1: Habilitar Sistema de Permisos
- Modifica `config/config.conf`
- Cambia `ENABLE_PERMISSIONS=false` a `ENABLE_PERMISSIONS=true`
- Después de esto, el menú verificará permisos antes de ejecutar comandos

#### Opción 2: Deshabilitar Sistema de Permisos
- Vuelve a desactivar el sistema
- Todos los usuarios podrán ejecutar todos los comandos

#### Opción 3: Agregar Usuario Actual como Admin
- Agrega tu usuario a la lista de administradores
- Te dará nivel 2 de permisos

#### Opción 4: Probar Permisos con Menú de Prueba
- Muestra un menú simulado con diferentes niveles
- Verás qué comandos puedes ejecutar según tu nivel

#### Opción 5: Ver Estado Detallado
- Muestra información completa de tu usuario
- Configuración actual de permisos
- Scripts externos y sus niveles requeridos

#### Opción 6: Salir

---

## 🧪 Pruebas Manuales Completas

### Prueba 1: Como Usuario Normal (Nivel 1)

```bash
# 1. Asegúrate de NO ser root
whoami  # Debe mostrar tu usuario normal

# 2. Habilita permisos
./test_permissions.sh
# Selecciona opción 1

# 3. Ejecuta bashmenu
./bashmenu

# 4. Observa que algunos comandos tienen 🔒
# Solo podrás ejecutar comandos de nivel 1
```

**Resultado esperado:**
- ✓ System Information (Nivel 1) - Accesible
- 🔒 Backup Database (Nivel 2) - Bloqueado
- 🔒 System Update (Nivel 3) - Bloqueado

---

### Prueba 2: Como Usuario Admin (Nivel 2)

```bash
# 1. Agrega tu usuario como admin
./test_permissions.sh
# Selecciona opción 3

# 2. Ejecuta bashmenu
./bashmenu

# 3. Ahora deberías poder ejecutar comandos de nivel 1 y 2
```

**Resultado esperado:**
- ✓ System Information (Nivel 1) - Accesible
- ✓ Backup Database (Nivel 2) - Accesible
- 🔒 System Update (Nivel 3) - Bloqueado

---

### Prueba 3: Como Root (Nivel 3)

```bash
# 1. Cambia a root
sudo su

# 2. Ejecuta bashmenu
./bashmenu

# 3. Deberías poder ejecutar TODOS los comandos
```

**Resultado esperado:**
- ✓ System Information (Nivel 1) - Accesible
- ✓ Backup Database (Nivel 2) - Accesible
- ✓ System Update (Nivel 3) - Accesible

---

## 🔍 Verificación Visual

### Con Permisos DESHABILITADOS:
```
╭─────────────────────────────────────────────────╮
║     System Administration Menu [12:34:56]      ║
╰─────────────────────────────────────────────────╯

│   1  System Information (Show detailed system information)
│   2  Disk Usage (Show disk space usage)
│   3  Backup Database (Run database backup)
│   4  System Update (Update system packages)
│   5  Exit (Exit the menu)
```

### Con Permisos HABILITADOS (Usuario Nivel 1):
```
╭─────────────────────────────────────────────────╮
║     System Administration Menu [12:34:56]      ║
╰─────────────────────────────────────────────────╯

│   1  System Information (Show detailed system information)
│   2  Disk Usage (Show disk space usage)
│ 🔒 3  Backup Database (Run database backup)
│ 🔒 4  System Update (Update system packages)
│   5  Exit (Exit the menu)
```

---

## 📝 Configuración Manual

Si prefieres configurar manualmente, edita `config/config.conf`:

```bash
# Security Settings
ENABLE_PERMISSIONS=true  # Cambiar a true para habilitar
ADMIN_USERS=("root" "admin" "tu_usuario")  # Agregar usuarios admin

# External Scripts Configuration
# Formato: "Nombre|Ruta|Descripción|Nivel Requerido"
EXTERNAL_SCRIPTS="
Backup Database|/opt/scripts/backup_db.sh|Run database backup|2
System Update|/opt/scripts/update_system.sh|Update system packages|3
Monitor Services|/opt/scripts/monitor_services.sh|Check service status|1
"
```

---

## 🎯 Niveles de Permisos Explicados

| Nivel | Usuario | Descripción | Puede Ejecutar |
|-------|---------|-------------|----------------|
| **1** | Usuario normal | Acceso básico | Solo comandos de nivel 1 |
| **2** | Admin | Administrador | Comandos de nivel 1 y 2 |
| **3** | Root | Superusuario | Todos los comandos |

---

## ⚠️ Mensajes de Error Esperados

### Cuando intentas ejecutar un comando sin permisos:

```
❌ Access denied: Backup Database requires level 2 (you have level 1)
```

### Cuando el sistema está deshabilitado:

```
🔌 Permission System: Disabled
```

---

## 🐛 Solución de Problemas

### Problema: Los cambios no se aplican
**Solución:** Reinicia bashmenu completamente (sal y vuelve a entrar)

### Problema: Todos los comandos están bloqueados
**Solución:** Verifica que tu usuario esté correctamente identificado:
```bash
whoami
./test_permissions.sh  # Opción 5 para ver estado
```

### Problema: No veo el icono 🔒
**Solución:** Tu terminal debe soportar Unicode. Prueba con:
```bash
echo "🔒 Test"
```

---

## ✅ Checklist de Verificación

- [ ] Script de prueba ejecutado correctamente
- [ ] Sistema de permisos habilitado en config.conf
- [ ] Usuario actual identificado correctamente
- [ ] Menú muestra iconos 🔒 para comandos bloqueados
- [ ] Comandos de nivel superior están bloqueados
- [ ] Comandos de tu nivel o inferior son accesibles
- [ ] Mensaje de error aparece al intentar ejecutar comando bloqueado
- [ ] Sistema se puede deshabilitar correctamente

---

## 📞 Comandos Útiles

```bash
# Ver tu nivel actual
./test_permissions.sh  # Opción 5

# Habilitar permisos rápidamente
sed -i 's/^ENABLE_PERMISSIONS=.*/ENABLE_PERMISSIONS=true/' config/config.conf

# Deshabilitar permisos rápidamente
sed -i 's/^ENABLE_PERMISSIONS=.*/ENABLE_PERMISSIONS=false/' config/config.conf

# Ver configuración actual
grep "ENABLE_PERMISSIONS" config/config.conf

# Agregar usuario como admin
sed -i 's/^ADMIN_USERS=.*/ADMIN_USERS=("root" "admin" "tu_usuario")/' config/config.conf
```

---

## 🎓 Ejemplo Completo de Prueba

```bash
# 1. Preparar
chmod +x test_permissions.sh

# 2. Ver estado inicial
./test_permissions.sh
# Selecciona: 5 (Ver estado detallado)

# 3. Habilitar permisos
./test_permissions.sh
# Selecciona: 1 (Habilitar sistema de permisos)

# 4. Probar menú de prueba
./test_permissions.sh
# Selecciona: 4 (Probar permisos con menú de prueba)

# 5. Ejecutar bashmenu real
./bashmenu

# 6. Intentar ejecutar un comando bloqueado
# Observa el mensaje de error

# 7. Deshabilitar permisos
./test_permissions.sh
# Selecciona: 2 (Deshabilitar sistema de permisos)

# 8. Verificar que ahora todo es accesible
./bashmenu
```

---

¡Listo! Ahora tienes todo lo necesario para implementar y verificar el sistema de permisos. 🚀
