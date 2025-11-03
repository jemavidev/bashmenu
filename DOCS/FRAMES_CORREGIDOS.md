# Corrección de Frames (Marcos) en Bashmenu

## Problema Original

Los frames utilizaban caracteres Unicode especiales que no se visualizaban correctamente en todos los terminales:
- `╔═╗` (box drawing characters)
- `║` (vertical lines)
- `╚═╝` (box corners)
- `┌─┐` (light box drawing)
- `└─┘` (light box corners)

**Problemas**:
- No se veían bien en terminales básicos
- Incompatibilidad con algunos emuladores
- Problemas en conexiones SSH
- Codificación incorrecta en algunos sistemas

## Solución Implementada

Se reemplazaron todos los caracteres Unicode por **caracteres ASCII estándar** compatibles con cualquier terminal.

### Cambios en Temas

#### 1. Default Theme
**Antes**:
```
╭─────────────────────────────────────────────────╮
│              System Administration              │
╰─────────────────────────────────────────────────╯
```

**Ahora**:
```
==================================================
           System Administration
==================================================
```

#### 2. Dark Theme
**Antes**:
```
┌─────────────────────────────────────────────────┐
│              System Administration              │
└─────────────────────────────────────────────────┘
```

**Ahora**:
```
==================================================
|          System Administration                 |
==================================================
```

#### 3. Colorful Theme
**Antes**:
```
╔═════════════════════════════════════════════════╗
║              System Administration              ║
╚═════════════════════════════════════════════════╝
```

**Ahora**:
```
==================================================
||         System Administration                ||
==================================================
```

#### 4. Minimal Theme
Sin cambios - ya no usa frames

#### 5. Modern Theme
**Antes**:
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃              System Administration              ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

**Ahora**:
```
--------------------------------------------------
>          System Administration
--------------------------------------------------
```

### Cambios en Funciones Utilitarias

#### print_header()
**Antes**:
```bash
echo -e "${CYAN}╔$(printf '%.0s═' {1..58})╗${NC}"
printf "${CYAN}║${NC}%${padding}s%s%${padding}s${CYAN}║${NC}\n" "" "$title" ""
echo -e "${CYAN}╚$(printf '%.0s═' {1..58})╝${NC}"
```

**Ahora**:
```bash
echo -e "${CYAN}$(printf '%.0s=' {1..50})${NC}"
printf "${CYAN}%${padding}s%s%${padding}s${NC}\n" "" "$title" ""
echo -e "${CYAN}$(printf '%.0s=' {1..50})${NC}"
```

#### print_separator()
**Antes**:
```bash
echo -e "${CYAN}┌$(printf '%.0s─' {1..58})┐${NC}"
```

**Ahora**:
```bash
echo -e "${CYAN}$(printf '%.0s-' {1..50})${NC}"
```

## Caracteres Utilizados

### Caracteres ASCII Estándar
- `=` - Líneas horizontales principales
- `-` - Líneas horizontales secundarias/separadores
- `|` - Bordes verticales simples
- `||` - Bordes verticales dobles (tema colorful)
- `>` - Indicador moderno (tema modern)

### Ventajas
✅ Compatible con cualquier terminal
✅ Funciona en SSH sin problemas
✅ No requiere UTF-8
✅ Se ve igual en todos los sistemas
✅ Más rápido de renderizar

## Comparación Visual

### Antes (Unicode)
```
╔═══════════════════════════════════════════════╗
║  1. System Information                        ║
║  2. Disk Usage                                ║
║  3. Dashboard                                 ║
╚═══════════════════════════════════════════════╝
```

### Ahora (ASCII)
```
==================================================
|  1. System Information                        |
|  2. Disk Usage                                |
|  3. Dashboard                                 |
==================================================
```

## Temas Disponibles

### 1. default (Recomendado)
```
==================================================
           System Administration
==================================================
|  1. System Information                        |
|  2. Disk Usage                                |
==================================================
```
- Líneas dobles con `=`
- Bordes simples con `|`
- Limpio y profesional

### 2. dark
```
==================================================
|          System Administration                |
==================================================
|  1. System Information                        |
|  2. Disk Usage                                |
==================================================
```
- Similar a default
- Colores púrpura/amarillo

### 3. colorful
```
==================================================
||         System Administration               ||
==================================================
||  1. System Information                      ||
||  2. Disk Usage                              ||
==================================================
```
- Bordes dobles `||`
- Colores brillantes

### 4. minimal
```
           System Administration

  1. System Information
  2. Disk Usage
```
- Sin frames
- Máxima simplicidad

### 5. modern
```
--------------------------------------------------
>          System Administration
--------------------------------------------------
>  1. System Information
>  2. Disk Usage
--------------------------------------------------
```
- Guiones para líneas
- Indicador `>` para opciones

## Configuración

Para cambiar el tema, edita `config/config.conf`:

```bash
# Theme Settings
DEFAULT_THEME="default"  # Opciones: default, dark, colorful, minimal, modern
```

## Pruebas Realizadas

✅ Terminal básico (bash)
✅ SSH remoto
✅ Windows Terminal
✅ macOS Terminal
✅ Linux GNOME Terminal
✅ Conexiones con codificación ASCII
✅ Conexiones con codificación UTF-8

## Compatibilidad

### Antes
- ❌ Problemas en terminales antiguos
- ❌ Caracteres rotos en SSH
- ❌ Requiere UTF-8
- ⚠️ Depende del font

### Ahora
- ✅ Funciona en cualquier terminal
- ✅ Perfecto en SSH
- ✅ No requiere UTF-8
- ✅ Independiente del font

## Archivos Modificados

1. **src/menu.sh**
   - `initialize_themes()` - Todos los temas actualizados
   - Frames simplificados a ASCII

2. **src/utils.sh**
   - `print_header()` - Usa `=` en lugar de `═`
   - `print_separator()` - Usa `-` en lugar de `─`
   - `print_separator_end()` - Usa `-` en lugar de `─`

## Resultado

Los frames ahora se visualizan correctamente en:
- ✅ Todos los terminales
- ✅ Todas las conexiones SSH
- ✅ Todos los sistemas operativos
- ✅ Todas las configuraciones de codificación

**Aspecto profesional mantenido con máxima compatibilidad** 🎯
