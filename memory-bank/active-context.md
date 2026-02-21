# Contexto Activo del Proyecto

## Información General
- **Nombre:** Bashmenu - Interactive System Administration Menu
- **Tipo:** CLI Tool / System Administration Platform
- **Estado:** Refactorización y Mejora (v2.1 → v3.0)
- **Fecha inicio:** 2026-01-18
- **Repositorio:** /home/rafael/Insync/dispapyrussas@gmail.com/Google Drive/PAPYRUS/EL CLUB/GIT/Bashmenu

## Stack Tecnológico

### Core
- **Shell:** Bash 4.0+ (strict mode: `set -euo pipefail`)
- **Testing:** BATS (Bash Automated Testing System)
- **Linting:** ShellCheck
- **CI/CD:** GitHub Actions
- **Documentation:** Markdown + shdoc

### Dependencias Opcionales
- dialog/whiptail (Enhanced UI)
- fzf (Fuzzy search)
- jq (JSON processing)
- notify-send (Desktop notifications)

### Infraestructura
- **Deployment:** Native package managers (apt, yum, pacman)
- **Platforms:** Ubuntu, Debian, CentOS, Arch Linux
- **Architecture:** x86_64, ARM64

## Estado Actual (v2.1)

### Fortalezas
- ✅ Arquitectura modular (main.sh, src/, config/, plugins/)
- ✅ Sistema de logging completo con múltiples niveles
- ✅ Sistema de temas extensible (5 temas)
- ✅ Navegación jerárquica por directorios
- ✅ Auto-detección de scripts
- ✅ Sistema de permisos basado en roles (3 niveles)
- ✅ Soporte para scripts externos con configuración

### Áreas Críticas de Mejora
- ❌ Funciones muy largas (menu_loop: 1788 líneas)
- ❌ Sin pruebas automatizadas (0% cobertura)
- ❌ Validación de seguridad básica
- ❌ Sin búsqueda en tiempo real
- ❌ Sin sistema de favoritos
- ❌ Performance no optimizado (sin caching)

## Objetivo v3.0

Transformar Bashmenu en una plataforma de administración de sistemas de nivel empresarial, manteniendo simplicidad de uso mientras se agregan capacidades profesionales de seguridad, rendimiento y extensibilidad.

## Features Principales v3.0

### Epic 1: Code Quality & Architecture
1. Refactorizar menu_loop en módulos <100 líneas
2. Implementar sistema de pruebas con BATS (>80% cobertura)
3. Integrar ShellCheck en desarrollo y CI/CD

### Epic 2: Security Enhancements
1. Sistema de autenticación avanzado (PAM, LDAP/AD)
2. Auditoría completa de acciones (logs JSON estructurados)
3. Validación avanzada de scripts (análisis estático)

### Epic 3: User Experience Improvements
1. Sistema de búsqueda en tiempo real
2. Sistema de favoritos y marcadores
3. Ayuda contextual y tutoriales interactivos

### Epic 4: Performance & Scalability
1. Sistema de caching inteligente
2. Carga lazy de módulos
3. Optimización para 500+ scripts

### Epic 5: Plugin System & Extensibility
1. API para plugins en múltiples lenguajes
2. Marketplace de plugins
3. Sistema de hooks para extensiones

## Prioridades

1. **Velocidad de desarrollo:** Alta - Refactorización primero
2. **Calidad del código:** Crítica - Tests y linting obligatorios
3. **Rendimiento/Escalabilidad:** Alta - Caching y optimización
4. **Seguridad:** Crítica - Auditoría y validación robusta
5. **Experiencia de Usuario:** Alta - Búsqueda y favoritos

## Restricciones

- **Tecnología:** Solo Bash 4.0+, sin dependencias obligatorias
- **Compatibilidad:** Mantener compatibilidad con v2.1 configs
- **Timeline:** 24 semanas (6 meses) para v3.0
- **Recursos:** Open source, community-driven
- **Budget:** Minimal ($50/month para CI/CD)

## Métricas de Éxito

| Metric | Current (v2.1) | Target (v3.0) |
|--------|----------------|---------------|
| Code Coverage | 0% | >80% |
| Avg Load Time | 2.5s | <1.0s |
| Lines per Function | 200+ | <100 |
| Security Vulnerabilities | 5+ | 0 critical |
| User Satisfaction | 3.5/5 | 4.5/5 |
| Active Installations | 50 | 500+ |

## Documentos Clave

- **PRD:** PRD-Bashmenu-v3.0.md
- **README:** README.md
- **Roadmap:** OPORTUNIDAD DE MEJORAS.md
- **Examples:** EXAMPLES.md
- **UI Guide:** PROFESSIONAL_UI_GUIDE.md

## Próximos Pasos Inmediatos

1. ✅ PRD completado y documentado
2. ⏳ Configurar estructura de AgentX
3. ⏳ Inicializar memory-bank con contexto
4. ⏳ Crear roadmap detallado en progress.md
5. ⏳ Configurar CI/CD pipeline
6. ⏳ Comenzar refactorización de menu_loop

---

**Última actualización:** 2026-01-18  
**Responsable:** Product Manager Agent
