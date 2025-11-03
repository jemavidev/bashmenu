# Plugin System Tools Simplificado

## Cambios Realizados

El plugin `system_tools.sh` ha sido completamente simplificado para incluir solo 5 comandos básicos y útiles.

### Antes (Versión 1.0)

- ❌ System Health Check (complejo)
- ❌ System Benchmark (lento)
- ❌ Process Analysis (demasiado detallado)
- ❌ Network Analysis (complejo)
- ❌ Security Check (avanzado)

**Total**: 5 comandos complejos

### Ahora (Versión 2.0)

- ✅ List Files (ls -la)
- ✅ List Detailed (ll)
- ✅ Disk Space (df -h)
- ✅ Memory (free -h)
- ✅ Processes (ps aux)

**Total**: 5 comandos simples y rápidos

## Comandos Incluidos

### 1. List Files (ls)

**Comando**: `ls -la`

**Muestra**:

- Todos los archivos (incluyendo ocultos)
- Permisos, propietario, tamaño
- Fecha de modificación
- Directorio actual

**Uso**: Ver contenido del directorio actual

### 2. List Detailed (ll)

**Comando**: `ls -lAh --color=auto`

**Muestra**:

- Lista detallada con colores
- Tamaños en formato legible (KB, MB, GB)
- Todos los archivos excepto . y ..
- Con colores para mejor visualización

**Uso**: Ver archivos con tamaños legibles

### 3. Disk Space (df)

**Comando**: `df -h`

**Muestra**:

- Uso de disco de todos los filesystems
- Tamaños en formato legible
- Porcentaje de uso
- Resumen del filesystem raíz

**Uso**: Verificar espacio disponible en disco

### 4. Memory (free)

**Comando**: `free -h`

**Muestra**:

- Memoria total, usada y disponible
- Memoria swap
- Porcentaje de uso
- Barra visual de uso

**Uso**: Verificar uso de memoria RAM

### 5. Processes (ps)

**Comando**: `ps aux --sort=-%cpu`

**Muestra**:

- Top 15 procesos por uso de CPU
- Usuario, PID, %CPU, %MEM
- Comando completo
- Resumen de procesos totales

**Uso**: Ver qué procesos consumen más recursos

## Características

### Simplicidad

✅ Comandos directos sin complejidad
✅ Salida clara y fácil de entender
✅ Ejecución rápida (< 1 segundo)

### Utilidad

✅ Comandos que se usan diariamente
✅ Información práctica y directa
✅ Sin dependencias externas

### Presentación

✅ Headers claros con print_header()
✅ Separadores visuales
✅ Colores para mejor legibilidad
✅ Resúmenes útiles

## Ejemplo de Salida

### List Files (ls)

```
==================================================
           List Files (ls -la)
==================================================

Current directory: /home/user

--------------------------------------------------
total 48
drwxr-xr-x  5 user user 4096 Nov  1 10:30 .
drwxr-xr-x 10 root root 4096 Oct 15 08:20 ..
-rw-r--r--  1 user user  220 Oct 15 08:20 .bash_logout
-rw-r--r--  1 user user 3526 Oct 15 08:20 .bashrc
drwxr-xr-x  3 user user 4096 Nov  1 10:25 Documents
--------------------------------------------------
Tip: Use 'cd' command to change directory
```

### Disk Space (df)

```
==================================================
           Disk Space (df -h)
==================================================

--------------------------------------------------
Filesystem usage:

Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   25G   23G  52% /
/dev/sda2       100G   45G   50G  48% /home

--------------------------------------------------
Root filesystem:
  Used: 25G
  Available: 23G
  Usage: 52%
```

### Memory (free)

```
==================================================
           Memory Usage (free -h)
==================================================

--------------------------------------------------
Memory information:

              total        used        free      shared
Mem:           16Gi       8.2Gi       5.1Gi       256Mi
Swap:         2.0Gi          0B       2.0Gi

--------------------------------------------------
Summary:
  Used: 8.2Gi / 16Gi
  Usage: 51%
[█████████████████████░░░░░░░░░] 51%
```

## Comparación de Tamaño

### Antes

- **Líneas de código**: ~250
- **Funciones**: 5 complejas
- **Tiempo de ejecución**: Variable (1-30 segundos)
- **Dependencias**: bc, netstat, systemctl, etc.

### Ahora

- **Líneas de código**: ~120
- **Funciones**: 5 simples
- **Tiempo de ejecución**: < 1 segundo
- **Dependencias**: Solo comandos básicos

**Reducción**: ~52% menos código

## Ventajas

### Para el Usuario

✅ Más rápido de usar
✅ Más fácil de entender
✅ Resultados inmediatos
✅ Sin esperas largas

### Para el Sistema

✅ Menos carga de CPU
✅ Menos uso de memoria
✅ Más estable
✅ Menos dependencias

### Para Mantenimiento

✅ Código más simple
✅ Más fácil de debuggear
✅ Menos puntos de fallo
✅ Más fácil de extender

## Integración con Bashmenu

El plugin se registra automáticamente cuando se carga:

```bash
# En el menú principal verás:
1. System Information
2. Disk Usage
3. Dashboard
4. Quick Status
5. List Files (ls)        # Plugin
6. List Detailed (ll)     # Plugin
7. Disk Space (df)        # Plugin
8. Memory (free)          # Plugin
9. Processes (ps)         # Plugin
10. Exit
```

## Personalización

Para agregar más comandos, edita `plugins/system_tools.sh`:

```bash
# Agregar nuevo comando
cmd_mi_comando() {
    clear
    print_header "Mi Comando"
    echo ""
    print_separator

    # Tu comando aquí
    mi_comando

    echo ""
    print_separator
}

# Registrar en el menú
register_plugin_commands() {
    if [[ -z "${EXTERNAL_SCRIPTS:-}" ]]; then
        # ... comandos existentes ...
        add_menu_item "Mi Comando" "cmd_mi_comando" "Descripción" 1
    fi
}
```

## Comandos Removidos

Los siguientes comandos fueron removidos por ser demasiado complejos:

1. **System Health Check** - Demasiado detallado, lento
2. **System Benchmark** - Muy lento (30+ segundos)
3. **Process Analysis** - Información excesiva
4. **Network Analysis** - Requiere permisos especiales
5. **Security Check** - Requiere acceso a logs del sistema

**Razón**: Mantener el plugin simple, rápido y funcional.

## Conclusión

El plugin ahora es:

- ✅ **Simple**: Solo comandos básicos
- ✅ **Rápido**: Ejecución instantánea
- ✅ **Útil**: Comandos de uso diario
- ✅ **Limpio**: Código fácil de mantener

**Perfecto para uso diario en administración de sistemas** 🎯
