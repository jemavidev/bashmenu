# Bashmenu v2.2 - Plan de Refactorización Completo

**Fecha:** 2026-02-20
**Versión Objetivo:** v2.2 "Stable & Enhanced"
**Timeline:** 6 semanas
**Estado:** Planificación

---

## Resumen Ejecutivo

Refactorización completa de Bashmenu para:
- Limpiar arquitectura (eliminar código legacy)
- Implementar sistema de configuración .env
- Convertir paths absolutos a relativos donde aplique
- Agregar funcionalidades faltantes (caching, búsqueda, favoritos, hooks, ayuda mejorada, auditoría JSON)
- Aumentar cobertura de tests a >60%
- Mantener compatibilidad con instalaciones existentes

---

## Decisiones Clave

| Aspecto | Decisión |
|---------|----------|
| Versión | v2.2 |
| Timeline | 6 semanas |
| Compatibilidad | Mantener backward compatibility |
| Sistema Operativo | Multi-distro Linux (Ubuntu, Debian, CentOS, Arch) |
| Bash Mínimo | 4.0+ |
| Instalación | System-wide (/opt/bashmenu) |
| Logs | /var/log/bashmenu (system) o ~/.bashmenu/logs (user) |
| Plugins | ~/.bashmenu/plugins (user) + /opt/bashmenu/plugins (system) |
| Config | .bashmenu.env (root proyecto) |
| Herramientas | bash, shellcheck, bats, jq (opcional) |

---

## Objetivos Medibles

| Métrica | Actual | Objetivo v2.2 |
|---------|--------|---------------|
| Cobertura de tests | <20% | >60% |
| Líneas por función | Algunas >100 | Todas <100 |
| ShellCheck errors | No ejecutado | 0 críticos |
| Startup time | ~2.5s | <1.5s |
| Funcionalidades PRD | 45% | 75% |
| Documentación | 60% | 90% |

---

## Fases del Proyecto

### Fase 1: Limpieza y Estructura (Semana 1-2)
- Reorganizar directorios
- Eliminar código legacy
- Implementar sistema .env
- Convertir paths a relativos
- Instalar herramientas (shellcheck, bats)

### Fase 2: Funcionalidades Core (Semana 3-4)
- Sistema de caching
- Búsqueda en tiempo real
- Sistema de favoritos
- Ayuda contextual mejorada
- Auditoría JSON estructurada

### Fase 3: Funcionalidades Avanzadas (Semana 4-5)
- Carga lazy de módulos
- Sistema de hooks básico
- Optimización de performance

### Fase 4: Testing y Documentación (Semana 5-6)
- Tests unitarios (>60% coverage)
- Tests de integración
- Tests de seguridad
- Documentación completa
- Guía de migración

### Fase 5: Release (Semana 6)
- Script de migración automática
- Release notes
- Instaladores actualizados
- Validación en múltiples distros

---

## Próximos Pasos

1. Crear estructura de directorios nueva
2. Diseñar sistema .env
3. Crear PRD detallado
4. Crear toolstack
5. Crear task breakdown
6. Implementar fase por fase

