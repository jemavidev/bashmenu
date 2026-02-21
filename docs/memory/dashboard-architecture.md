# 📊 Dashboard de Memoria - Arquitectura y Diseño

## 🎯 Concepto

El Dashboard de Memoria es un **archivo HTML todo-en-uno** que permite visualizar y gestionar los archivos JSON de memoria del proyecto sin necesidad de scripts externos o dependencias de Python.

## 🏗️ Arquitectura

### Diseño Todo-en-Uno

```
dashboard.html
├── HTML Structure
├── CSS Styles (embedded)
├── JavaScript Logic (embedded)
└── No external dependencies
```

**Ventajas:**
- ✅ Sin dependencias externas
- ✅ Funciona offline
- ✅ Portable (un solo archivo)
- ✅ Fácil de distribuir
- ✅ No requiere servidor web

## 🔧 Funcionalidad

### 1. Lectura de Archivos JSON

El dashboard lee directamente los archivos JSON usando:

```javascript
// Opción A: File API (usuario selecciona archivos)
const fileInput = document.createElement('input');
fileInput.type = 'file';
fileInput.accept = '.json';
fileInput.onchange = (e) => {
  const file = e.target.files[0];
  const reader = new FileReader();
  reader.onload = (event) => {
    const data = JSON.parse(event.target.result);
    // Procesar datos
  };
  reader.readAsText(file);
};

// Opción B: Drag & Drop
dropZone.addEventListener('drop', (e) => {
  e.preventDefault();
  const file = e.dataTransfer.files[0];
  // Leer archivo
});
```

### 2. Operaciones CRUD

#### Create (Crear)
```javascript
function createEntry(type, data) {
  const memoryData = loadMemoryData(type);
  const newEntry = {
    id: generateId(),
    date: new Date().toISOString(),
    ...data
  };
  memoryData.push(newEntry);
  saveMemoryData(type, memoryData);
}
```

#### Read (Leer)
```javascript
function readEntries(type, filter = null) {
  const memoryData = loadMemoryData(type);
  if (filter) {
    return memoryData.filter(filter);
  }
  return memoryData;
}
```

#### Update (Actualizar)
```javascript
function updateEntry(type, id, updates) {
  const memoryData = loadMemoryData(type);
  const index = memoryData.findIndex(e => e.id === id);
  if (index !== -1) {
    memoryData[index] = { ...memoryData[index], ...updates };
    saveMemoryData(type, memoryData);
  }
}
```

#### Delete (Eliminar)
```javascript
function deleteEntry(type, id) {
  const memoryData = loadMemoryData(type);
  const filtered = memoryData.filter(e => e.id !== id);
  saveMemoryData(type, filtered);
}
```

### 3. Persistencia de Datos

**Dos estrategias:**

#### Estrategia A: LocalStorage (Temporal)
```javascript
// Guardar en navegador
function saveToLocalStorage(type, data) {
  localStorage.setItem(`memory_${type}`, JSON.stringify(data));
}

// Cargar desde navegador
function loadFromLocalStorage(type) {
  const data = localStorage.getItem(`memory_${type}`);
  return data ? JSON.parse(data) : [];
}
```

**Ventajas:**
- Rápido
- No requiere permisos
- Funciona offline

**Desventajas:**
- Datos solo en el navegador
- No sincroniza con archivos JSON

#### Estrategia B: File System Access API (Recomendada)
```javascript
// Solicitar acceso a directorio
async function requestDirectoryAccess() {
  const dirHandle = await window.showDirectoryPicker();
  return dirHandle;
}

// Leer archivo JSON
async function readJSONFile(dirHandle, filename) {
  const fileHandle = await dirHandle.getFileHandle(filename);
  const file = await fileHandle.getFile();
  const text = await file.text();
  return JSON.parse(text);
}

// Escribir archivo JSON
async function writeJSONFile(dirHandle, filename, data) {
  const fileHandle = await dirHandle.getFileHandle(filename, { create: true });
  const writable = await fileHandle.createWritable();
  await writable.write(JSON.stringify(data, null, 2));
  await writable.close();
}
```

**Ventajas:**
- ✅ Sincronización real con archivos
- ✅ Cambios persisten en disco
- ✅ Múltiples usuarios pueden ver cambios
- ✅ Compatible con Git

**Desventajas:**
- Requiere permisos del usuario
- Solo funciona en navegadores modernos (Chrome, Edge)

## 🎨 Interfaz de Usuario

### Componentes Principales

```
┌─────────────────────────────────────────┐
│  Header: BetterAgentX Memory Dashboard  │
├─────────────────────────────────────────┤
│  [Tabs: Context | Decisions | Progress] │
├─────────────────────────────────────────┤
│  Search: [___________] [Filter ▼]       │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐  │
│  │  Entry Card                       │  │
│  │  ─────────────────────────────    │  │
│  │  Title: Decision #001             │  │
│  │  Date: 2026-02-14                 │  │
│  │  [Edit] [Delete]                  │  │
│  └───────────────────────────────────┘  │
├─────────────────────────────────────────┤
│  [+ New Entry]                          │
└─────────────────────────────────────────┘
```

### Pestañas (Tabs)

1. **Overview** - Estadísticas generales
2. **Active Context** - Contexto actual del proyecto
3. **Decisions** - Log de decisiones técnicas
4. **Progress** - Tareas y progreso
5. **Patterns** - Patrones identificados
6. **Timeline** - Vista cronológica

## 🔄 Flujo de Trabajo

### Flujo Inicial (Primera Vez)

```
1. Usuario abre dashboard.html
2. Dashboard solicita acceso a .kiro/memory/
3. Usuario concede permiso
4. Dashboard lee todos los archivos JSON
5. Muestra datos en interfaz
```

### Flujo de Edición

```
1. Usuario hace clic en "Edit"
2. Modal se abre con formulario
3. Usuario modifica datos
4. Usuario hace clic en "Save"
5. Dashboard actualiza archivo JSON
6. Interfaz se refresca automáticamente
```

### Flujo de Creación

```
1. Usuario hace clic en "+ New Entry"
2. Modal se abre con formulario vacío
3. Usuario llena datos
4. Usuario hace clic en "Create"
5. Dashboard añade entrada al JSON
6. Dashboard guarda archivo
7. Nueva entrada aparece en lista
```

## 🚫 Por Qué NO Necesitamos sync-memory.py

### Problema Original

El concepto de `sync-memory.py` era:
```
Archivos .md (legibles) ↔ sync-memory.py ↔ JSON (para dashboard)
```

### Solución Actual

Con archivos JSON nativos:
```
Archivos .json ↔ Dashboard HTML (lectura/escritura directa)
```

**Ventajas:**
- ✅ Sin dependencia de Python
- ✅ Sin paso de sincronización manual
- ✅ Cambios en tiempo real
- ✅ Menos complejidad
- ✅ Menos puntos de fallo

## 🔐 Seguridad y Permisos

### File System Access API

```javascript
// Solicitar permiso una vez
const dirHandle = await window.showDirectoryPicker();

// Verificar permiso antes de cada operación
const permission = await dirHandle.queryPermission({ mode: 'readwrite' });
if (permission !== 'granted') {
  await dirHandle.requestPermission({ mode: 'readwrite' });
}
```

### Validación de Datos

```javascript
function validateEntry(type, data) {
  const schemas = {
    decision: {
      required: ['id', 'date', 'title', 'decision'],
      optional: ['context', 'consequences', 'alternatives']
    },
    progress: {
      required: ['id', 'date', 'title', 'status'],
      optional: ['priority', 'agent', 'blockers']
    }
  };
  
  const schema = schemas[type];
  for (const field of schema.required) {
    if (!data[field]) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
  return true;
}
```

## 📱 Responsive Design

```css
/* Mobile First */
.dashboard {
  padding: 1rem;
}

/* Tablet */
@media (min-width: 768px) {
  .dashboard {
    padding: 2rem;
    max-width: 720px;
    margin: 0 auto;
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .dashboard {
    max-width: 1200px;
    display: grid;
    grid-template-columns: 250px 1fr;
  }
}
```

## 🎯 Características Avanzadas

### 1. Búsqueda en Tiempo Real

```javascript
function searchEntries(query) {
  const allEntries = getAllEntries();
  return allEntries.filter(entry => {
    const searchText = JSON.stringify(entry).toLowerCase();
    return searchText.includes(query.toLowerCase());
  });
}
```

### 2. Filtros

```javascript
function filterByDate(entries, startDate, endDate) {
  return entries.filter(e => {
    const date = new Date(e.date);
    return date >= startDate && date <= endDate;
  });
}

function filterByAgent(entries, agent) {
  return entries.filter(e => e.agent === agent);
}
```

### 3. Exportar/Importar

```javascript
// Exportar todo
function exportAll() {
  const data = {
    context: loadMemoryData('context'),
    decisions: loadMemoryData('decisions'),
    progress: loadMemoryData('progress'),
    patterns: loadMemoryData('patterns')
  };
  
  const blob = new Blob([JSON.stringify(data, null, 2)], {
    type: 'application/json'
  });
  
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `memory-backup-${Date.now()}.json`;
  a.click();
}

// Importar
function importData(file) {
  const reader = new FileReader();
  reader.onload = (e) => {
    const data = JSON.parse(e.target.result);
    // Restaurar datos
  };
  reader.readAsText(file);
}
```

## 🔄 Compatibilidad con Git

Los archivos JSON son Git-friendly:

```bash
# Ver cambios
git diff .kiro/memory/decision-log.json

# Commit cambios
git add .kiro/memory/*.json
git commit -m "docs: update memory - added decision #005"
```

## 📊 Estadísticas

```javascript
function calculateStats() {
  return {
    totalDecisions: loadMemoryData('decisions').length,
    totalTasks: loadMemoryData('progress').length,
    completedTasks: loadMemoryData('progress')
      .filter(t => t.status === 'completed').length,
    totalPatterns: loadMemoryData('patterns').length,
    lastUpdate: getLastUpdateDate()
  };
}
```

## 🎨 Temas (Dark/Light Mode)

```javascript
function toggleTheme() {
  const currentTheme = document.body.dataset.theme || 'light';
  const newTheme = currentTheme === 'light' ? 'dark' : 'light';
  document.body.dataset.theme = newTheme;
  localStorage.setItem('theme', newTheme);
}
```

## 🚀 Próximos Pasos

Para implementar el dashboard:

1. **Diseñar estructura HTML** - Layout y componentes
2. **Implementar File System Access API** - Lectura/escritura de JSON
3. **Crear operaciones CRUD** - Create, Read, Update, Delete
4. **Añadir búsqueda y filtros** - UX mejorada
5. **Implementar validación** - Datos consistentes
6. **Añadir exportar/importar** - Backup y restauración
7. **Testing** - Verificar en diferentes navegadores

---

**Version:** 2.1.0  
**Last Updated:** 2026-02-14  
**Status:** Design Document (Implementation Pending)
