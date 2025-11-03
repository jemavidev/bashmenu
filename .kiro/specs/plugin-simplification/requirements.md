# Requirements Document

## Introduction

Este documento define los requisitos para simplificar el sistema de plugins/scripts de Bashmenu, permitiendo que los usuarios agreguen fácilmente scripts personalizados al menú sin necesidad de modificar código fuente. El objetivo es que después de instalar Bashmenu en un servidor cloud, el usuario pueda agregar sus propios scripts (para Git, Docker, deployments, etc.) simplemente colocándolos en un directorio y configurando entradas de menú mediante un archivo de configuración simple.

## Glossary

- **Bashmenu**: Sistema de menú interactivo para administración de servidores Linux
- **Script Personalizado**: Script bash creado por el usuario para realizar tareas específicas del servidor
- **Directorio de Scripts**: Ubicación donde se almacenan los scripts personalizados del usuario (/opt/bashmenu/plugins)
- **Archivo de Configuración**: Archivo que mapea scripts a entradas del menú (scripts.conf)
- **Sistema de Validación**: Mecanismo que verifica la existencia y permisos de scripts antes de ejecutarlos
- **Entrada de Menú**: Opción visible en el menú de Bashmenu que ejecuta un script

## Requirements

### Requirement 1

**User Story:** Como administrador de servidor, quiero colocar mis scripts en un directorio específico y que automáticamente estén disponibles en el menú, para no tener que modificar código fuente.

#### Acceptance Criteria

1. WHEN el usuario coloca un script en /opt/bashmenu/plugins/, THE Bashmenu SHALL detectar automáticamente el script durante la inicialización
2. THE Bashmenu SHALL validar que cada script tenga permisos de ejecución antes de mostrarlo en el menú
3. THE Bashmenu SHALL mostrar solo scripts válidos en el menú principal
4. IF un script no tiene permisos de ejecución, THEN THE Bashmenu SHALL registrar una advertencia en el log pero continuar la inicialización
5. THE Bashmenu SHALL cargar la configuración de scripts desde /opt/bashmenu/config/scripts.conf

### Requirement 2

**User Story:** Como administrador de servidor, quiero configurar las entradas del menú mediante un archivo simple de texto, para poder agregar o modificar opciones sin editar código bash.

#### Acceptance Criteria

1. THE Bashmenu SHALL leer el archivo scripts.conf con formato "Nombre|Ruta|Descripción|Nivel"
2. WHEN el archivo scripts.conf contiene una línea válida, THE Bashmenu SHALL crear una entrada de menú correspondiente
3. THE Bashmenu SHALL ignorar líneas vacías y comentarios (que comienzan con #) en scripts.conf
4. THE Bashmenu SHALL validar que cada ruta de script sea absoluta y exista en el sistema
5. IF una entrada en scripts.conf es inválida, THEN THE Bashmenu SHALL registrar un error y omitir esa entrada específica

### Requirement 3

**User Story:** Como administrador de servidor, quiero que el sistema valide mis scripts antes de ejecutarlos, para evitar errores y problemas de seguridad.

#### Acceptance Criteria

1. WHEN un usuario selecciona una entrada de menú, THE Bashmenu SHALL verificar que el script existe antes de ejecutarlo
2. THE Bashmenu SHALL verificar que el script tiene permisos de ejecución antes de ejecutarlo
3. THE Bashmenu SHALL verificar que la ruta del script está dentro de los directorios permitidos (ALLOWED_SCRIPT_DIRS)
4. IF un script falla la validación, THEN THE Bashmenu SHALL mostrar un mensaje de error descriptivo al usuario
5. THE Bashmenu SHALL registrar todos los intentos de ejecución de scripts en el log del sistema

### Requirement 4

**User Story:** Como administrador de servidor, quiero ver ejemplos de scripts y configuración después de la instalación, para entender rápidamente cómo agregar mis propios scripts.

#### Acceptance Criteria

1. WHEN el instalador completa la instalación, THE Bashmenu SHALL crear un archivo scripts.conf.example con ejemplos comentados
2. THE Bashmenu SHALL crear scripts de ejemplo en /opt/bashmenu/plugins/examples/ durante la instalación
3. THE Bashmenu SHALL incluir dos scripts de ejemplo: git_operations.sh y docker_manager.sh
4. THE Bashmenu SHALL incluir comentarios explicativos en scripts.conf.example sobre el formato y uso
5. THE Bashmenu SHALL mostrar la ubicación de los ejemplos al finalizar la instalación

### Requirement 5

**User Story:** Como administrador de servidor, quiero que el sistema de plugins antiguo sea deshabilitado por defecto, para simplificar la configuración y evitar confusión.

#### Acceptance Criteria

1. THE Bashmenu SHALL establecer ENABLE_PLUGINS=false por defecto en config.conf
2. WHEN EXTERNAL_SCRIPTS está configurado en scripts.conf, THE Bashmenu SHALL deshabilitar automáticamente el sistema de plugins
3. THE Bashmenu SHALL mostrar un mensaje informativo si ambos sistemas (plugins y scripts externos) están habilitados
4. THE Bashmenu SHALL priorizar scripts externos sobre plugins cuando ambos están habilitados
5. THE Bashmenu SHALL documentar claramente en el README la diferencia entre plugins y scripts externos

### Requirement 6

**User Story:** Como administrador de servidor, quiero ejecutar scripts con parámetros opcionales desde el menú, para tener mayor flexibilidad en las operaciones.

#### Acceptance Criteria

1. WHEN un script requiere parámetros, THE Bashmenu SHALL solicitar al usuario que ingrese los parámetros antes de la ejecución
2. THE Bashmenu SHALL validar y sanitizar los parámetros ingresados por el usuario
3. THE Bashmenu SHALL pasar los parámetros al script de forma segura usando comillas apropiadas
4. THE Bashmenu SHALL permitir configurar parámetros predeterminados en scripts.conf usando el formato "Nombre|Ruta|Descripción|Nivel|Parámetros"
5. IF el usuario cancela la entrada de parámetros, THEN THE Bashmenu SHALL abortar la ejecución del script y regresar al menú

### Requirement 7

**User Story:** Como administrador de servidor, quiero ver la salida de mis scripts en tiempo real, para monitorear el progreso de operaciones largas.

#### Acceptance Criteria

1. WHEN un script se ejecuta, THE Bashmenu SHALL mostrar la salida estándar (stdout) en tiempo real
2. THE Bashmenu SHALL mostrar la salida de error (stderr) en color rojo para distinguirla
3. WHEN un script termina, THE Bashmenu SHALL mostrar el código de salida del script
4. THE Bashmenu SHALL registrar toda la salida del script en el archivo de log
5. THE Bashmenu SHALL esperar a que el usuario presione Enter antes de regresar al menú principal
