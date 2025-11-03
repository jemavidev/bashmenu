# Implementation Plan

- [x] 1. Crear módulo de carga de configuración de scripts
  - Crear archivo `src/script_loader.sh` con funciones para parsear scripts.conf
  - Implementar función `load_script_config()` que lee y parsea el archivo línea por línea
  - Implementar función `validate_script_entry()` que valida cada entrada individual
  - Crear array asociativo global `SCRIPT_ENTRIES` para almacenar configuración
  - Agregar manejo de comentarios y líneas vacías en el parser
  - _Requirements: 1.1, 1.5, 2.1, 2.2, 2.3_

- [x] 2. Crear módulo de validación de scripts
  - Crear archivo `src/script_validator.sh` con funciones de validación
  - Implementar función `validate_script_execution()` que verifica existencia, permisos y sintaxis
  - Implementar función `check_allowed_directory()` que verifica rutas permitidas contra ALLOWED_SCRIPT_DIRS
  - Implementar función `sanitize_parameters()` que limpia parámetros de entrada del usuario
  - Agregar validación de rutas absolutas vs relativas
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 2.4_

- [x] 3. Crear módulo de ejecución de scripts
  - Crear archivo `src/script_executor.sh` con funciones de ejecución
  - Implementar función `execute_script()` que ejecuta scripts y captura salida
  - Implementar función `prompt_for_parameters()` que solicita parámetros al usuario
  - Implementar función `display_script_output()` que muestra stdout/stderr con colores
  - Agregar captura de código de salida y logging
  - Implementar espera de Enter antes de regresar al menú
  - _Requirements: 3.5, 6.1, 6.2, 6.3, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 4. Integrar módulos con sistema de menú existente
  - Modificar `src/main.sh` para cargar los nuevos módulos (script_loader, script_validator, script_executor)
  - Modificar `src/menu.sh` función `initialize_menu()` para cargar scripts.conf
  - Implementar función `register_external_scripts()` que registra scripts como entradas de menú
  - Implementar función `create_script_wrapper()` que crea funciones dinámicas para cada script
  - Agregar lógica para deshabilitar plugins cuando hay scripts externos cargados
  - _Requirements: 1.1, 1.2, 1.3, 5.2, 5.3, 5.4_

- [x] 5. Crear función centralizada de manejo de errores
  - Implementar función `handle_script_error()` en `src/script_executor.sh`
  - Agregar manejo de errores para: script no encontrado, sin permisos, fuera de directorios permitidos
  - Agregar manejo de errores para: fallo de ejecución, timeout
  - Implementar logging de todos los errores
  - Agregar mensajes descriptivos para el usuario
  - _Requirements: 1.4, 2.5, 3.4, 3.5_

- [x] 6. Crear scripts de ejemplo
  - Crear directorio `plugins/examples/` en el proyecto
  - Crear script `git_operations.sh` con operaciones: pull, status, log
  - Crear script `docker_manager.sh` con operaciones: build, ps, logs, restart
  - Establecer permisos de ejecución en ambos scripts
  - Agregar comentarios explicativos en cada script
  - _Requirements: 4.3_

- [x] 7. Crear archivo de configuración de ejemplo
  - Crear archivo `config/scripts.conf.example` con formato documentado
  - Agregar comentarios explicativos sobre cada campo
  - Incluir ejemplos comentados para git_operations.sh y docker_manager.sh
  - Documentar formato de parámetros opcionales
  - Agregar sección de "Your scripts here" para que usuarios agreguen los suyos
  - _Requirements: 4.1, 4.4_

- [x] 8. Actualizar archivo de configuración principal
  - Modificar `config/config.conf` para agregar variable ALLOWED_SCRIPT_DIRS con valor por defecto
  - Agregar variable ENABLE_EXTERNAL_SCRIPTS=true
  - Cambiar ENABLE_PLUGINS=false por defecto
  - Agregar variable SCRIPT_EXECUTION_TIMEOUT con valor por defecto 300
  - Agregar variable LOG_SCRIPT_OUTPUT=true
  - Agregar comentarios explicativos para cada nueva variable
  - _Requirements: 5.1, 5.2_

- [x] 9. Actualizar script de instalación
  - Modificar `install.sh` para crear directorio `/opt/bashmenu/plugins/examples/`
  - Agregar copia de scripts de ejemplo al directorio de instalación
  - Agregar establecimiento de permisos de ejecución en scripts de ejemplo
  - Agregar copia de `scripts.conf.example` a `/opt/bashmenu/config/`
  - Actualizar mensaje final de instalación con instrucciones sobre scripts
  - _Requirements: 4.2, 4.5_

- [x] 10. Actualizar documentación
  - Actualizar `README.md` con sección sobre sistema de scripts externos
  - Documentar diferencia entre plugins y scripts externos
  - Agregar ejemplos de uso de scripts.conf
  - Agregar sección de troubleshooting para scripts
  - Actualizar sección de estructura del proyecto
  - _Requirements: 5.5_

- [x] 11. Crear tests de validación
  - Crear script de test para validar parsing de scripts.conf
  - Crear tests para validación de rutas y permisos
  - Crear tests para sanitización de parámetros
  - Crear tests de seguridad (inyección de comandos, rutas no permitidas)
  - _Requirements: 2.4, 3.3, 6.2_
