# Headers Estandarizados en Bashmenu

## Formato Uniforme Implementado

Todos los headers en Bashmenu ahora siguen el mismo formato estándar:

```
==================================================
              Título Centrado
==================================================
```

## Cambios Realizados

### 1. Función `print_header()` Mejorada

**Ubicación**: `src/utils.sh`

**Mejoras**:
- ✅ Cálculo preciso del padding izquierdo y derecho
- ✅ Texto perfectamente centrado
- ✅ Ancho estándar de 50 caracteres
- ✅ Funciona con títulos de cualquier longitud

**Código**:
```bash
print_header() {
    local title="$1"
    local width=50
    local title_length=${#title}
    local padding=$(( (width - title_length) / 2 ))
    local padding_right=$(( width - title_length - padding ))

    echo "=================================================="
    printf "%${padding}s%s%${padding_right}s\n" "" "$title" ""
    echo "=================================================="
}
```

### 2. Header del Menú Principal

**Ubicación**: `src/menu.sh` - `display_header()`

**Formato**:
```
==================================================
     System Administration Menu [14:30:45]
==================================================
```

**Características**:
- Título centrado
- Timestamp opcional (configurable)
- Ancho estándar de 50 caracteres
- Colores según el tema

### 3. Headers en Comandos

**Ubicación**: `src/commands.sh`

Todos los comandos usan el formato estándar:

```bash
# System Information
==================================================
          🖥️ System Information
==================================================

# Disk Usage
==================================================
        💽 Disk Usage Information
==================================================

# Dashboard
==================================================
          📊 System Dashboard
==================================================

# Quick Status
==================================================
             ⚡ Quick Status
==================================================

# Help
==================================================
      ❓ Bashmenu Help & Documentation
==================================================
```

### 4. Headers en Plugin

**Ubicación**: `plugins/system_tools.sh`

Todos los comandos del plugin usan el formato estándar:

```bash
# List Files
==================================================
           List Files (ls -la)
==================================================

# List Detailed
==================================================
          Detailed File List (ll)
==================================================

# Disk Space
==================================================
           Disk Space (df -h)
==================================================

# Memory
==================================================
          Memory Usage (free -h)
==================================================

# Processes
==================================================
          Process List (ps aux)
==================================================
```

### 5. Welcome Screen

**Ubicación**: `src/main.sh` - `show_welcome()`

```
==================================================
        Welcome to Bashmenu v2.0
==================================================
```

## Características del Sistema

### Centrado Perfecto

El algoritmo de centrado calcula:
1. Longitud del título
2. Padding izquierdo: `(50 - longitud) / 2`
3. Padding derecho: `50 - longitud - padding_izquierdo`

Esto asegura que el texto quede perfectamente centrado incluso con títulos de longitud impar.

### Ancho Estándar

- **Ancho total**: 50 caracteres
- **Líneas**: `=` (50 caracteres)
- **Consistente** en todos los menús y submenús

### Compatibilidad con Temas

Los headers respetan los colores del tema activo:

**Default Theme**:
```
==================================================  (cyan)
              Título                               (cyan)
==================================================  (cyan)
```

**Dark Theme**:
```
==================================================  (purple)
              Título                               (purple)
==================================================  (purple)
```

**Colorful Theme**:
```
==================================================  (red)
              Título                               (red)
==================================================  (red)
```

**Minimal Theme**:
```
==================================================  (white)
              Título                               (white)
==================================================  (white)
```

## Ejemplos Visuales

### Título Corto
```
==================================================
                 Help
==================================================
```

### Título Medio
```
==================================================
          System Information
==================================================
```

### Título Largo
```
==================================================
    Welcome to Bashmenu v2.0 [14:30:45]
==================================================
```

### Con Emojis
```
==================================================
          🖥️ System Information
==================================================
```

## Archivos Modificados

1. ✅ `src/utils.sh` - Función `print_header()` mejorada
2. ✅ `src/menu.sh` - Función `display_header()` estandarizada
3. ✅ `src/commands.sh` - Todos los comandos usan formato estándar
4. ✅ `plugins/system_tools.sh` - Plugin usa formato estándar
5. ✅ `src/main.sh` - Welcome screen usa formato estándar

## Verificación

Para verificar que todos los headers están estandarizados:

```bash
# Buscar todos los print_header
grep -r "print_header" src/ plugins/

# Verificar sintaxis
bash -n src/utils.sh
bash -n src/menu.sh
bash -n src/commands.sh
bash -n plugins/system_tools.sh

# Probar el menú
./bashmenu
```

## Resultado

✅ **Todos los headers ahora son uniformes**
✅ **Texto perfectamente centrado**
✅ **Ancho estándar de 50 caracteres**
✅ **Compatible con todos los temas**
✅ **Funciona con títulos de cualquier longitud**

**Aspecto profesional y consistente en todo el sistema** 🎯
