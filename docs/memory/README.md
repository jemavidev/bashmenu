# 💾 Sistema de Memoria de BetterAgents

El **Sistema de Memoria** de BetterAgents permite mantener contexto persistente entre sesiones, documentar decisiones técnicas, rastrear progreso y capturar patrones reutilizables.

## 🎯 ¿Qué es el Sistema de Memoria?

Es un sistema de documentación automática que:

1. **Captura** decisiones técnicas importantes
2. **Rastrea** progreso de tareas y milestones
3. **Documenta** patrones y soluciones reutilizables
4. **Mantiene** contexto activo del proyecto
5. **Proporciona** historial completo y timeline

## 📁 Archivos de Memoria

El sistema utiliza 4 archivos principales en `.kiro/memory/`:

### 1. `active-context.md` - Contexto Activo

**Propósito:** Mantener el estado actual del proyecto

**Contiene:**
- Objetivo actual del proyecto
- Fase de desarrollo actual
- Stack tecnológico en uso
- Equipo y roles
- Próximos pasos

**Cuándo se actualiza:**
- Inicio de nuevo proyecto
- Cambio de fase
- Cambio de tecnología
- Cambio de objetivo
- Actualización de equipo

**Ejemplo:**
```markdown
# Contexto Activo del Proyecto

## Proyecto Actual
**Nombre:** Sistema de Autenticación API
**Fase:** Implementación
**Inicio:** 2026-02-10

## Objetivo Actual
Implementar sistema completo de autenticación con JWT para API REST

## Stack Tecnológico
- **Backend:** Node.js + Express
- **Base de Datos:** PostgreSQL
- **Autenticación:** JWT + bcrypt
- **Testing:** Jest + Supertest

## Equipo
- **Architect:** Diseño del sistema
- **Coder:** Implementación
- **Security:** Revisión de seguridad
- **Tester:** Tests y QA

## Próximos Pasos
1. Completar endpoints de autenticación
2. Implementar refresh tokens
3. Añadir rate limiting
4. Documentar API
```

### 2. `progress.md` - Seguimiento de Progreso

**Propósito:** Rastrear tareas completadas y en progreso

**Contiene:**
- Tareas completadas con fechas
- Tareas en progreso
- Tareas pendientes
- Milestones alcanzados
- Agentes involucrados

**Cuándo se actualiza:**
- Tarea completada
- Nueva tarea iniciada
- Milestone alcanzado
- Cambio de estado de tarea

**Ejemplo:**
```markdown
# Seguimiento de Progreso

## Tareas Completadas ✅

### 2026-02-12 - Implementación JWT Authentication
- **Agente:** Coder
- **Descripción:** Sistema completo de autenticación con JWT
- **Resultado:** Login, registro y refresh tokens funcionando
- **Archivos:** `auth.js`, `jwt_utils.js`, `middleware/auth.js`

### 2026-02-11 - Diseño de Arquitectura
- **Agente:** Architect
- **Descripción:** Arquitectura del sistema de autenticación
- **Resultado:** Diseño aprobado con revisión de Critic
- **Documentos:** `docs/architecture.md`

## Tareas en Progreso 🔄

### Rate Limiting Implementation
- **Agente:** Coder
- **Inicio:** 2026-02-12
- **Progreso:** 60%
- **Bloqueadores:** Ninguno

## Tareas Pendientes 📋

- [ ] Implementar email verification
- [ ] Añadir OAuth providers
- [ ] Configurar monitoring
- [ ] Escribir documentación de API
```

### 3. `decision-log.md` - Registro de Decisiones (ADR)

**Propósito:** Documentar decisiones técnicas importantes

**Contiene:**
- Decisiones arquitectónicas
- Elecciones de tecnología
- Trade-offs considerados
- Alternativas evaluadas
- Razones y contexto

**Cuándo se actualiza:**
- Decisión arquitectónica tomada
- Tecnología seleccionada
- Patrón de diseño elegido
- Trade-off importante evaluado

**Formato ADR (Architecture Decision Record):**
```markdown
## 2026-02-12 - Decisión #001: Usar PostgreSQL

### Contexto
Necesitamos seleccionar base de datos para el sistema de autenticación

### Decisión
Usar PostgreSQL en lugar de MongoDB

### Razones
1. **Relaciones:** Necesitamos relaciones entre usuarios, roles y permisos
2. **ACID:** Transacciones críticas para autenticación
3. **JSON Support:** PostgreSQL soporta JSON para flexibilidad
4. **Madurez:** Más maduro y probado en producción
5. **Equipo:** Equipo tiene más experiencia con SQL

### Alternativas Consideradas
- **MongoDB:** Rechazada por falta de transacciones ACID robustas
- **MySQL:** Considerada pero PostgreSQL tiene mejor soporte JSON

### Consecuencias
**Positivas:**
- Integridad de datos garantizada
- Transacciones ACID
- Mejor para relaciones complejas

**Negativas:**
- Menos flexible que NoSQL
- Requiere migraciones de schema

### Agentes Involucrados
- **Architect:** Propuesta inicial
- **Critic:** Revisión y alternativas
- **Security:** Validación de seguridad
- **AgentX:** Documentación

### Estado
✅ Aprobada e implementada
```

### 4. `patterns.md` - Patrones y Aprendizajes

**Propósito:** Capturar soluciones reutilizables y lecciones aprendidas

**Contiene:**
- Patrones de diseño aplicados
- Soluciones elegantes a problemas
- Anti-patrones descubiertos
- Best practices aprendidas
- Code snippets reutilizables

**Cuándo se actualiza:**
- Patrón útil identificado
- Solución elegante implementada
- Anti-patrón descubierto
- Best practice aprendida

**Ejemplo:**
```markdown
## Patrón #001: Dependency Injection para Testing

**Identificado por:** Coder  
**Fecha:** 2026-02-12  
**Categoría:** Testing

### Contexto
Testing de servicios con dependencias de base de datos

### Problema
Tests lentos y frágiles por dependencia de DB real

### Solución
```javascript
// Antes: Dependencia directa
class UserService {
  constructor() {
    this.db = new Database();
  }
}

// Después: Dependency Injection
class UserService {
  constructor(db = new Database()) {
    this.db = db;
  }
}

// En tests
const mockDb = { query: jest.fn() };
const service = new UserService(mockDb);
```

### Ventajas
- Tests rápidos (sin DB real)
- Código más testeable
- Fácil de mockear
- Mejor separación de concerns

### Cuándo Usar
- Servicios con dependencias externas
- Código que necesita testing
- Cuando quieres flexibilidad

### Cuándo NO Usar
- Clases muy simples sin dependencias
- Overhead innecesario para casos triviales
```

## 🤖 Gestión Automática por AgentX

**AgentX es el administrador único del sistema de memoria.** Detecta automáticamente contenido digno de documentar.

### Detección Automática

AgentX analiza CADA conversación buscando:

#### 🔍 Triggers de Detección

**Decisiones Técnicas:**
- Keywords: "decidimos", "vamos a usar", "elegimos", "optamos por"
- Acción: Documenta en `decision-log.md`

**Progreso de Tareas:**
- Keywords: "completado", "terminado", "implementado", "finished"
- Acción: Actualiza `progress.md`

**Patrones y Aprendizajes:**
- Keywords: "patrón", "solución", "aprendimos", "pattern", "learned"
- Acción: Añade a `patterns.md`

**Cambios de Contexto:**
- Keywords: "ahora trabajamos en", "siguiente fase", "nuevo objetivo"
- Acción: Actualiza `active-context.md`

### Protocolo de Actualización

```
Para CADA interacción, AgentX pregunta:

1. ¿Hay una decisión técnica? → decision-log.md
2. ¿Se completó o inició una tarea? → progress.md
3. ¿Se identificó un patrón útil? → patterns.md
4. ¿Cambió el contexto del proyecto? → active-context.md

Si SÍ → Actualiza memoria AUTOMÁTICAMENTE
Si INCIERTO → Pregunta al usuario
```

### Formato de Actualización

Cuando AgentX actualiza memoria, muestra:

```markdown
---
🧠 AgentX
💾 Memory Update: [file-name]
---

[Respuesta principal]

---

## 💾 Actualización de Memoria

**Archivo:** `.kiro/memory/[file-name]`
**Acción:** [Added/Updated/Documented]
**Razón:** [Por qué es digno de memoria]

**Contenido agregado:**
[Muestra lo que se añadió]
```

## 📊 Dashboard Interactivo

El sistema incluye un **dashboard HTML interactivo** para visualizar y gestionar la memoria.

### Características del Dashboard

✅ **Vista General** - Estadísticas y resumen
✅ **6 Pestañas de Navegación** - Overview, Decisiones, Progreso, Patrones, Contexto, Timeline
✅ **Búsqueda en Tiempo Real** - Filtra contenido instantáneamente
✅ **Operaciones CRUD** - Crear, leer, actualizar, eliminar entradas
✅ **Vista Timeline** - Visualización cronológica
✅ **Persistencia Local** - Usa localStorage del navegador
✅ **Sincronización** - Script Python para sync bidireccional

### Abrir el Dashboard

```bash
# Opción 1: Script rápido
./kiro/memory/open-dashboard.sh

# Opción 2: Abrir directamente
open .kiro/memory/dashboard.html

# Opción 3: Servidor local
cd .kiro/memory
python3 -m http.server 8000
# Visita: http://localhost:8000/dashboard.html
```

### Sincronización Dashboard ↔ Markdown

El dashboard usa localStorage. Para sincronizar con archivos markdown:

```bash
# Sincronizar: Markdown → Dashboard (JSON)
python3 .kiro/memory/sync-memory.py

# El script:
# 1. Lee archivos .md
# 2. Parsea contenido
# 3. Genera memory-data.json
# 4. Dashboard carga el JSON
```

**Flujo de trabajo recomendado:**
1. AgentX actualiza archivos `.md`
2. Ejecuta `sync-memory.py` para actualizar JSON
3. Refresca dashboard para ver cambios

## 🎯 Contribuciones de Agentes

Todos los agentes pueden sugerir actualizaciones de memoria a AgentX:

### Formato de Sugerencia

```markdown
💾 **Memory Suggestion:** [file-name]
[Qué debería documentarse y por qué]
```

### Ejemplo de Flujo

```
1. Coder implementa feature
2. Coder sugiere: "💾 Memory Suggestion: patterns.md
   Patrón de DI usado para testing - permite mockear DB fácilmente"
3. AgentX evalúa la sugerencia
4. AgentX documenta en patterns.md
5. AgentX confirma al usuario
```

## 💡 Mejores Prácticas

### Para Usuarios

1. **Confía en AgentX** - Detecta automáticamente qué documentar
2. **Revisa periódicamente** - Usa el dashboard para revisar memoria
3. **Mantén actualizado** - Ejecuta sync cuando sea necesario
4. **Usa comandos explícitos** - "Documenta esto en memoria" si AgentX no detecta

### Para Agentes

1. **Sugiere memoria** - Cuando identifiques contenido valioso
2. **Sé específico** - Explica QUÉ y POR QUÉ documentar
3. **Usa formato correcto** - `💾 **Memory Suggestion:** [file]`
4. **Confía en AgentX** - Él decide si documentar o no

### Mantenimiento

**Semanal:**
- Revisar `active-context.md` - ¿Está actualizado?
- Revisar `progress.md` - ¿Archivar tareas antiguas?

**Mensual:**
- Revisar `decision-log.md` - ¿Decisiones a revisar?
- Revisar `patterns.md` - ¿Patrones a refinar?

## 🔧 Configuración

En `config/.betteragents-config`:

```bash
# Habilitar sistema de memoria automática
MEMORY_ENABLED=true

# Directorio de memoria
MEMORY_DIR=.kiro/memory

# Actualización automática de memoria por AgentX
MEMORY_AUTO_UPDATE=true

# Solicitar confirmación antes de documentar
MEMORY_ASK_BEFORE_SAVE=false

# Guardar logs de actualizaciones de memoria
MEMORY_LOG_UPDATES=true
```

## 📝 Comandos de Memoria

### Comandos Explícitos del Usuario

```
"Documenta esto en memoria"
"Guarda esta decisión"
"Añade esto a patrones"
"Actualiza el contexto"
"Muéstrame la memoria actual"
"¿Qué hay en decision-log?"
```

### Respuesta de AgentX

AgentX:
- Cumple inmediatamente
- Muestra lo que documentó
- Confirma la actualización

## 🚀 Ventajas del Sistema de Memoria

✅ **Contexto Persistente** - Mantiene información entre sesiones
✅ **Documentación Automática** - AgentX documenta sin intervención
✅ **Historial Completo** - Timeline de decisiones y progreso
✅ **Patrones Reutilizables** - Captura soluciones para reusar
✅ **Dashboard Visual** - Interfaz amigable para consultar
✅ **Colaboración Mejorada** - Todos los agentes contribuyen
✅ **Onboarding Rápido** - Nuevos miembros leen la memoria

## 📚 Recursos Relacionados

- [Guía de AgentX](../agentx/README.md)
- [Dashboard README](.kiro/memory/dashboard-readme.md)
- [Guía de Memoria para AgentX](.kiro/memory/agentx-memory-guide.md)
- [Templates de Memoria](../../templates/memory/)

---

**El Sistema de Memoria: Tu segundo cerebro para el proyecto 🧠💾**
