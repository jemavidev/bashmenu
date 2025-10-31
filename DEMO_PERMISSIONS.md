# 🎯 Cómo Usar el Sistema de Permisos en Bashmenu

## 📖 Guía Práctica Paso a Paso

---

## 1️⃣ HABILITAR EL SISTEMA DE PERMISOS

### Opción A: Usando el script de prueba (Recomendado)
```bash
./test_permissions.sh
# Selecciona: 1 (Enable permission system)
```

### Opción B: Manualmente
```bash
# Editar el archivo de configuración
nano config/config.conf

# Cambiar esta línea:
ENABLE_PERMISSIONS=false
# Por:
ENABLE_PERMISSIONS=true

# Guardar y salir (Ctrl+X, Y, Enter)
```

---

## 2️⃣ EJECUTAR BASHMENU

```bash
./bashmenu
```

### 🎨 Lo que verás:

#### Pantalla de Bienvenida:
```
╔════════════════════════════════════════════════════════╗
║       Welcome to Bashmenu v2.0                         ║
╚════════════════════════════════════════════════════════╝

🚀 System Information:
   🖥️  Hostname: myserver
   🐧 OS: Ubuntu 22.04
   ⚙️  Kernel: 5.15.0
   ⏱️  Uptime: 2 days
   👤 User: john

🔌 Plugin System: Enabled
🔒 Permission System: Enabled    ← ¡ACTIVADO!
🎨 Available Themes: default, dark, colorful, minimal, modern

✨ Ready to start! Press any key to continue...
```

---

## 3️⃣ MENÚ PRINCIPAL CON PERMISOS

### Si eres Usuario Normal (Nivel 1):
```
╭─────────────────────────────────────────────────╮
║     System Administration Menu [14:30:45]      ║
╰─────────────────────────────────────────────────╯

│   1  System Information (Show detailed system information)
│   2  Disk Usage (Show disk space usage)
│ 🔒 3  Backup Database (Run database backup)
│ 🔒 4  System Update (Update system packages)
│ 🔒 5  System Tools (Run system tools)
│   6  Exit (Exit the menu)

Use ↑↓ arrows or numbers to navigate • Enter to select • q to quit
```

**Nota:** Los comandos con 🔒 están bloqueados para tu nivel

---

## 4️⃣ INTENTAR EJECUTAR UN COMANDO BLOQUEADO

### Qué pasa si intentas ejecutar la opción 3 (Backup Database):

```bash
# Presionas 3 o seleccionas con flechas y Enter
```

### Resultado:
```
❌ Access denied: Backup Database requires level 2 (you have level 1)

Press Enter to continue...
```

---

## 5️⃣ AGREGAR TU USUARIO COMO ADMINISTRADOR

### Para poder ejecutar comandos de nivel 2:

```bash
# Sal del menú (presiona 'q')

# Ejecuta el script de prueba
./test_permissions.sh

# Selecciona: 3 (Add current user as admin)
```

### Resultado:
```
[Action] Adding john as administrator...
✓ User john added as administrator
⚠ Restart bashmenu to apply changes
```

---

## 6️⃣ VOLVER A EJECUTAR BASHMENU

```bash
./bashmenu
```

### Ahora verás (como Admin - Nivel 2):
```
╭─────────────────────────────────────────────────╮
║     System Administration Menu [14:35:20]      ║
╰─────────────────────────────────────────────────╯

│   1  System Information (Show detailed system information)
│   2  Disk Usage (Show disk space usage)
│   3  Backup Database (Run database backup)          ← ¡Ya no tiene 🔒!
│   4  System Update (Update system packages)         ← ¡Ya no tiene 🔒!
│ 🔒 5  System Tools (Run system tools)                ← Nivel 3 aún bloqueado
│   6  Exit (Exit the menu)
```

**Ahora puedes ejecutar comandos de nivel 1 y 2** ✅

---

## 7️⃣ EJECUTAR COMO ROOT (Nivel 3)

### Para acceso completo:

```bash
# Cambiar a root
sudo su

# Ejecutar bashmenu
./bashmenu
```

### Verás (como Root - Nivel 3):
```
╭─────────────────────────────────────────────────╮
║     System Administration Menu [14:40:15]      ║
╰─────────────────────────────────────────────────╯

│   1  System Information (Show detailed system information)
│   2  Disk Usage (Show disk space usage)
│   3  Backup Database (Run database backup)
│   4  System Update (Update system packages)
│   5  System Tools (Run system tools)              ← ¡Todo desbloqueado!
│   6  Exit (Exit the menu)
```

**Todos los comandos están disponibles** ✅✅✅

---

## 8️⃣ CONFIGURAR SCRIPTS PERSONALIZADOS CON NIVELES

### Editar configuración:
```bash
nano config/config.conf
```

### Agregar tus propios scripts con niveles:
```bash
# External Scripts Configuration
# Format: "Display Name|Absolute Path|Description|Required Level"
EXTERNAL_SCRIPTS="
Backup Database|/opt/scripts/backup_db.sh|Run database backup|2
System Update|/opt/scripts/update_system.sh|Update system packages|3
Monitor Services|/opt/scripts/monitor_services.sh|Check service status|1
Restart Apache|/opt/scripts/restart_apache.sh|Restart web server|2
Clean Logs|/opt/scripts/clean_logs.sh|Clean old log files|1
Reboot Server|/opt/scripts/reboot.sh|Reboot the server|3
"
```

### Explicación de niveles:
- **Nivel 1**: Comandos seguros que cualquier usuario puede ejecutar
- **Nivel 2**: Comandos administrativos que requieren permisos elevados
- **Nivel 3**: Comandos críticos solo para root/superusuario

---

## 9️⃣ DESHABILITAR EL SISTEMA DE PERMISOS

### Si quieres que todos tengan acceso a todo:

```bash
./test_permissions.sh
# Selecciona: 2 (Disable permission system)
```

### O manualmente:
```bash
nano config/config.conf
# Cambiar:
ENABLE_PERMISSIONS=true
# Por:
ENABLE_PERMISSIONS=false
```

---

## 🎮 CASOS DE USO PRÁCTICOS

### Caso 1: Servidor Compartido
```
Tienes 3 usuarios:
- alice (desarrolladora) → Nivel 1
- bob (administrador) → Nivel 2  
- root (superusuario) → Nivel 3

alice puede:
  ✓ Ver información del sistema
  ✓ Revisar logs
  ✗ Hacer backups
  ✗ Actualizar sistema

bob puede:
  ✓ Ver información del sistema
  ✓ Revisar logs
  ✓ Hacer backups
  ✗ Actualizar sistema

root puede:
  ✓ Todo
```

### Caso 2: Servidor Personal
```
Solo tú usas el servidor:
→ Deshabilita permisos (ENABLE_PERMISSIONS=false)
→ Acceso completo a todo sin restricciones
```

### Caso 3: Servidor de Producción
```
Múltiples administradores:
→ Habilita permisos (ENABLE_PERMISSIONS=true)
→ Define claramente quién puede hacer qué
→ Auditoría de acciones críticas
```

---

## 🔍 VERIFICAR ESTADO ACTUAL

### Ver tu nivel y configuración:
```bash
./test_permissions.sh
# Selecciona: 5 (View detailed status)
```

### Resultado:
```
[Detailed Status]

═══ User Information ═══
   Current user: john
   Permission level: 2
   UID: 1000
   GID: 1000

═══ Permission Configuration ═══
   ENABLE_PERMISSIONS=true
   ADMIN_USERS=("root" "admin" "john")

═══ Configured External Scripts ═══
   Backup Database - Required level: 2
   System Update - Required level: 3
   Monitor Services - Required level: 1
```

---

## 📊 TABLA RESUMEN DE NIVELES

| Nivel | Usuario | Puede Ejecutar | Ejemplo de Comandos |
|-------|---------|----------------|---------------------|
| **1** | Normal | Solo lectura y comandos seguros | Ver info, revisar logs, monitorear |
| **2** | Admin | Comandos administrativos | Backups, reiniciar servicios, limpiar |
| **3** | Root | Comandos críticos del sistema | Actualizar sistema, reboot, configuración de red |

---

## ⚡ COMANDOS RÁPIDOS

```bash
# Habilitar permisos
sed -i 's/^ENABLE_PERMISSIONS=.*/ENABLE_PERMISSIONS=true/' config/config.conf

# Deshabilitar permisos
sed -i 's/^ENABLE_PERMISSIONS=.*/ENABLE_PERMISSIONS=false/' config/config.conf

# Agregar usuario como admin
sed -i 's/^ADMIN_USERS=.*/ADMIN_USERS=("root" "admin" "tu_usuario")/' config/config.conf

# Ver configuración actual
grep "ENABLE_PERMISSIONS\|ADMIN_USERS" config/config.conf

# Verificar tu nivel
whoami && ./test_permissions.sh
```

---

## 🎯 FLUJO COMPLETO DE USO

```
1. Instalar bashmenu
   ↓
2. Decidir si necesitas permisos
   ↓
3. Si SÍ → Habilitar (ENABLE_PERMISSIONS=true)
   ↓
4. Configurar usuarios admin en ADMIN_USERS
   ↓
5. Definir niveles para scripts externos
   ↓
6. Ejecutar ./bashmenu
   ↓
7. Ver iconos 🔒 en comandos bloqueados
   ↓
8. Usuarios solo pueden ejecutar comandos de su nivel o inferior
```

---

## ✅ CHECKLIST DE VERIFICACIÓN

- [ ] Sistema de permisos habilitado en config.conf
- [ ] Usuarios admin configurados correctamente
- [ ] Scripts externos tienen niveles asignados
- [ ] Al ejecutar bashmenu, veo el estado del sistema de permisos
- [ ] Comandos bloqueados muestran icono 🔒
- [ ] Al intentar ejecutar comando bloqueado, veo mensaje de error
- [ ] Puedo ejecutar comandos de mi nivel o inferior
- [ ] Puedo deshabilitar el sistema cuando quiera

---

¡Listo! Ahora sabes exactamente cómo usar el sistema de permisos en tu aplicativo. 🚀
