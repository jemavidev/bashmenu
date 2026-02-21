# 🚀 Guía de Instalación - BetterAgents

**Sistema de 12 agentes especializados de IA para Kiro Code**

**Plataforma:** Ubuntu/Debian (Linux con base .deb)  
**Tiempo estimado:** 10-15 minutos  
**Nivel:** Principiante a Avanzado

---

## 📋 Tabla de Contenidos

1. [Requisitos del Sistema](#requisitos-del-sistema)
2. [Instalación Rápida](#instalación-rápida)
3. [Instalación Paso a Paso](#instalación-paso-a-paso)
4. [Instalación de Skills](#instalación-de-skills)
5. [Verificación](#verificación)
6. [Uso del Sistema](#uso-del-sistema)
7. [Solución de Problemas](#solución-de-problemas)
8. [Actualización](#actualización)

---

## 📦 Requisitos del Sistema

### Sistema Operativo
- ✅ Ubuntu 20.04 LTS o superior
- ✅ Debian 11 o superior
- ✅ Linux Mint 20 o superior
- ✅ Pop!_OS 20.04 o superior

### Hardware Mínimo
- CPU: 2 cores
- RAM: 4GB
- Disco: 1GB libre

### Software Requerido
| Software | Versión Mínima | Instalación |
|----------|----------------|-------------|
| **Kiro Code** | Última | [kiro.ai](https://kiro.ai) |
| **Node.js** | 18.x | Se instala en la guía |
| **npm** | 9.x | Incluido con Node.js |
| **Git** | 2.x | Se instala en la guía |

---

## ⚡ Instalación Rápida

Para usuarios con experiencia que ya tienen Node.js 18+ y Kiro Code instalados:

```bash
# 1. Clonar el repositorio
git clone https://github.com/jemavidev/BetterAgentX.git
cd BetterAgentX

# 2. Ejecutar instalación automática
chmod +x install.sh
./install.sh

# 3. Abrir Kiro Code
kiro .
```

**¡Listo!** Los 12 agentes están disponibles.

---

## 🔧 Instalación Paso a Paso

### Paso 1: Actualizar el Sistema

```bash
# Actualizar lista de paquetes
sudo apt update

# Actualizar paquetes instalados (opcional pero recomendado)
sudo apt upgrade -y
```

---

### Paso 2: Instalar Git

```bash
# Verificar si Git está instalado
git --version

# Si no está instalado:
sudo apt install git -y

# Verificar instalación
git --version
# Debería mostrar: git version 2.x.x
```

---

### Paso 3: Instalar Node.js y npm

#### Opción A: Instalación con nvm (Recomendado)

```bash
# 1. Descargar e instalar nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 2. Cargar nvm en la sesión actual
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 3. Instalar Node.js 20 LTS
nvm install 20

# 4. Verificar instalación
node --version  # Debería mostrar v20.x.x
npm --version   # Debería mostrar 10.x.x
```

#### Opción B: Instalación desde NodeSource

```bash
# 1. Agregar repositorio de NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# 2. Instalar Node.js
sudo apt install -y nodejs

# 3. Verificar instalación
node --version
npm --version
```

---

### Paso 4: Instalar Kiro Code

#### Descargar Kiro Code

1. Visita [kiro.ai](https://kiro.ai)
2. Descarga la versión para Linux (.deb)
3. Instala el paquete:

```bash
# Navega a la carpeta de descargas
cd ~/Downloads

# Instala el paquete .deb (reemplaza X.X.X con la versión descargada)
sudo dpkg -i kiro-X.X.X-amd64.deb

# Si hay errores de dependencias, ejecuta:
sudo apt install -f -y

# Verificar instalación
kiro --version
```

#### Alternativa: Instalación desde terminal

```bash
# Si Kiro proporciona un script de instalación
curl -fsSL https://kiro.ai/install.sh | bash

# O usando snap (si está disponible)
sudo snap install kiro-code
```

---

### Paso 5: Clonar el Repositorio

```bash
# 1. Navegar a tu carpeta de proyectos
cd ~/Documents
mkdir -p GIT
cd GIT

# 2. Clonar BetterAgents
git clone https://github.com/jemavidev/BetterAgentX.git

# 3. Entrar al directorio
cd BetterAgentX

# 4. Verificar contenido
ls -la
# Deberías ver: .agents/, .kiro/, README.md, etc.
```

---

### Paso 6: Verificar Estructura

```bash
# Verificar que los 12 agentes están presentes
ls -1 .kiro/steering/agents/

# Deberías ver:
# architect.md
# coder.md
# critic.md
# data-scientist.md
# devops.md
# product-manager.md
# researcher.md
# security.md
# teacher.md
# tester.md
# ux-designer.md
# writer.md

# Contar agentes
ls -1 .kiro/steering/agents/ | wc -l
# Debería mostrar: 12
```

---

### Paso 7: Verificar Sistema de Memoria

```bash
# Verificar archivos de memoria
ls -la .kiro/memory/

# Deberías ver:
# active-context.md
# decision-log.md
# patterns.md
# progress.md
# README.md
```

---

## 📚 Instalación de Skills

Los skills son opcionales pero mejoran significativamente las capacidades de los agentes.

### Skills Esenciales (Recomendado)

```bash
# Instalar los 5 skills más importantes
npx skills add wshobson/agents/architecture-patterns
npx skills add obra/superpowers/systematic-debugging
npx skills add vercel-labs/agent-skills/vercel-react-best-practices
npx skills add anthropics/skills/webapp-testing
npx skills add anthropics/skills/doc-coauthoring
```

### Instalación Completa de Skills

Para instalar todos los skills recomendados (~60 skills):

```bash
# Ejecutar script de instalación de skills
chmod +x install-skills.sh
./install-skills.sh
```

El script te preguntará:
1. **Instalar todos** - Recomendado para uso completo
2. **Instalar por agente** - Selectivo
3. **Instalar esenciales** - Solo los 5 básicos

### Verificar Skills Instalados

```bash
# Listar skills instalados
npx skills list

# Buscar skills disponibles
npx skills find

# Ver información de un skill
npx skills info wshobson/agents/architecture-patterns
```

---

## ✅ Verificación

### Script de Verificación Automática

```bash
# Crear script de verificación
cat > verify.sh << 'EOF'
#!/bin/bash

echo "🔍 Verificando instalación de BetterAgents..."
echo ""

# Verificar Node.js
echo "=== Node.js ==="
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
else
    echo "❌ Node.js no está instalado"
fi

# Verificar npm
if command -v npm &> /dev/null; then
    echo "✅ npm: $(npm --version)"
else
    echo "❌ npm no está instalado"
fi
echo ""

# Verificar Kiro
echo "=== Kiro Code ==="
if command -v kiro &> /dev/null; then
    echo "✅ Kiro Code: $(kiro --version)"
else
    echo "❌ Kiro Code no está instalado"
fi
echo ""

# Verificar estructura
echo "=== Estructura del Proyecto ==="
if [ -d ".kiro/steering/agents" ]; then
    AGENT_COUNT=$(ls -1 .kiro/steering/agents/*.md 2>/dev/null | wc -l)
    echo "✅ Agentes instalados: $AGENT_COUNT/12"
    
    if [ "$AGENT_COUNT" -eq 12 ]; then
        echo "✅ Todos los agentes están presentes"
    else
        echo "⚠️  Faltan agentes"
    fi
else
    echo "❌ Carpeta de agentes no encontrada"
fi
echo ""

# Verificar memoria
echo "=== Sistema de Memoria ==="
if [ -d ".kiro/memory" ]; then
    MEMORY_COUNT=$(ls -1 .kiro/memory/*.md 2>/dev/null | wc -l)
    echo "✅ Archivos de memoria: $MEMORY_COUNT/5"
else
    echo "❌ Sistema de memoria no encontrado"
fi
echo ""

# Verificar skills
echo "=== Skills ==="
if [ -d ".agents/skills" ]; then
    echo "✅ Carpeta de skills presente"
else
    echo "⚠️  Carpeta de skills no encontrada"
fi
echo ""

# Resumen
echo "=== Resumen ==="
if [ "$AGENT_COUNT" -eq 12 ] && command -v kiro &> /dev/null && command -v node &> /dev/null; then
    echo "✅ ¡Instalación completa y exitosa!"
    echo ""
    echo "🚀 Para empezar, ejecuta:"
    echo "   kiro ."
else
    echo "⚠️  La instalación está incompleta"
    echo "   Revisa los errores arriba"
fi
EOF

chmod +x verify.sh
./verify.sh
```

### Verificación Manual

```bash
# 1. Verificar Node.js y npm
node --version && npm --version

# 2. Verificar Kiro Code
kiro --version

# 3. Contar agentes
ls -1 .kiro/steering/agents/*.md | wc -l
# Debe mostrar: 12

# 4. Verificar memoria
ls -1 .kiro/memory/*.md | wc -l
# Debe mostrar: 5

# 5. Ver tamaño del proyecto
du -sh .
# Debe mostrar: ~850KB
```

---

## 🚀 Uso del Sistema

### Iniciar Kiro Code

```bash
# Desde el directorio del proyecto
cd ~/Documents/GIT/BetterAgents
kiro .
```

### Usar los Agentes

En el chat de Kiro Code, menciona al agente con `@`:

```
@architect Diseña un sistema de autenticación con JWT
```

Respuesta esperada:
```
---
🧠 AgentX/Architect
---

[Respuesta estructurada del agente...]
```

### Los 12 Agentes Disponibles

| Comando | Agente | Especialidad |
|---------|--------|--------------|
| `@architect` | 🏗️ Architect | Diseño de sistemas y arquitectura |
| `@coder` | 💻 Coder | Implementación de código |
| `@critic` | 🎭 Critic | Análisis crítico (Tenth Man Rule) |
| `@tester` | 🧪 Tester | Testing y QA |
| `@writer` | ✍️ Writer | Documentación técnica |
| `@researcher` | 🔍 Researcher | Investigación y análisis |
| `@teacher` | 👨‍🏫 Teacher | Explicaciones didácticas |
| `@devops` | 🚀 DevOps | Infraestructura y deployment |
| `@security` | 🔒 Security | Seguridad y vulnerabilidades |
| `@ux-designer` | 🎨 UX Designer | Diseño UI/UX |
| `@data-scientist` | 📊 Data Scientist | Análisis de datos |
| `@product-manager` | 📋 Product Manager | Gestión de producto |

### Workflow Colaborativo

```
1. @architect → Diseña la arquitectura
2. @critic → Revisa y encuentra problemas
3. @security → Analiza vulnerabilidades
4. @coder → Implementa el código
5. @tester → Define estrategia de testing
6. @writer → Documenta la solución
```

### Usar el Sistema de Memoria

```bash
# Editar contexto actual
nano .kiro/memory/active-context.md

# Ver progreso
cat .kiro/memory/progress.md

# Documentar decisión
nano .kiro/memory/decision-log.md

# Guardar patrón
nano .kiro/memory/patterns.md
```

---

## 🔧 Solución de Problemas

### Problema: "kiro: command not found"

**Solución:**
```bash
# Verificar si Kiro está instalado
which kiro

# Si no está en el PATH, agregar manualmente
echo 'export PATH="$PATH:/opt/kiro/bin"' >> ~/.bashrc
source ~/.bashrc

# O reinstalar Kiro
sudo dpkg -i ~/Downloads/kiro-*.deb
```

---

### Problema: "node: command not found"

**Solución:**
```bash
# Reinstalar Node.js con nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install 20
```

---

### Problema: "No se encuentran los agentes"

**Solución:**
```bash
# Verificar que estás en el directorio correcto
pwd
# Debe mostrar: /home/tu-usuario/Documents/GIT/BetterAgents

# Verificar estructura
ls -la .kiro/steering/agents/

# Si la carpeta está vacía, el repositorio no se clonó correctamente
# Volver a clonar:
cd ..
rm -rf BetterAgents
git clone https://github.com/jemavidev/BetterAgentX.git
cd BetterAgentX
```

---

### Problema: "npx: command not found"

**Solución:**
```bash
# npx viene con npm, verificar npm
npm --version

# Si npm está instalado pero npx no funciona
npm install -g npx

# O actualizar npm
npm install -g npm@latest
```

---

### Problema: Permisos denegados

**Solución:**
```bash
# Si tienes problemas de permisos con npm
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Reinstalar paquetes globales si es necesario
npm install -g npx
```

---

### Problema: Skills no se instalan

**Solución:**
```bash
# Verificar conexión a internet
ping -c 3 google.com

# Limpiar caché de npm
npm cache clean --force

# Intentar instalar skill específico con verbose
npx skills add wshobson/agents/architecture-patterns --verbose

# Si persiste, verificar versión de Node.js
node --version
# Debe ser 18.x o superior
```

---

### Problema: Kiro no abre el proyecto

**Solución:**
```bash
# Verificar que estás en el directorio correcto
pwd

# Intentar abrir con ruta absoluta
kiro ~/Documents/GIT/BetterAgents

# Verificar logs de Kiro
kiro --help

# Reinstalar Kiro si es necesario
sudo apt remove kiro-code
sudo dpkg -i ~/Downloads/kiro-*.deb
```

---

## 🔄 Actualización

### Actualizar BetterAgents

```bash
# Navegar al directorio
cd ~/Documents/GIT/BetterAgents

# Guardar cambios locales (si los hay)
git stash

# Actualizar desde GitHub
git pull origin main

# Restaurar cambios locales
git stash pop

# Verificar actualización
cat betteragents.json | grep version
```

### Actualizar Skills (Recomendado)

BetterAgents incluye un script dedicado para mantener los skills actualizados:

```bash
# Ejecutar script de actualización
./update-skills.sh
```

El script:
1. ✅ Verifica skills instalados
2. ✅ Detecta actualizaciones disponibles
3. ✅ Actualiza todos los skills automáticamente
4. ✅ Muestra resumen de cambios

#### Actualización Manual de Skills

```bash
# Verificar actualizaciones disponibles
npx skills check

# Actualizar todos los skills
npx skills update

# Actualizar skill específico
npx skills update wshobson/agents/architecture-patterns

# Ver skills instalados
npx skills list
```

#### Frecuencia Recomendada

- **Semanal:** Para proyectos activos
- **Mensual:** Para proyectos en mantenimiento
- **Antes de iniciar nuevo proyecto:** Siempre

#### Automatizar Actualizaciones (Opcional)

Puedes crear un cron job para actualizar automáticamente:

```bash
# Editar crontab
crontab -e

# Añadir línea para actualizar cada lunes a las 9 AM
0 9 * * 1 cd ~/Documents/GIT/BetterAgents && ./update-skills.sh -y >> ~/betteragents-update.log 2>&1
```

### Actualizar Node.js

```bash
# Con nvm
nvm install 20
nvm use 20

# Verificar versión
node --version
```

### Actualizar Kiro Code

```bash
# Descargar nueva versión desde kiro.ai
# Luego instalar:
sudo dpkg -i ~/Downloads/kiro-nueva-version.deb
```

---

## 📊 Comandos Útiles

### Información del Sistema

```bash
# Ver versión de BetterAgents
cat betteragents.json | grep version

# Ver tamaño del proyecto
du -sh .

# Contar archivos
find . -type f | wc -l

# Ver estructura completa
tree -L 3 -a
```

### Gestión de Skills

```bash
# Listar skills instalados
npx skills list

# Buscar skills
npx skills find architecture

# Ver info de skill
npx skills info wshobson/agents/architecture-patterns

# Verificar actualizaciones
npx skills check

# Actualizar todos los skills
npx skills update

# Actualizar skill específico
npx skills update wshobson/agents/architecture-patterns

# Desinstalar skill
npx skills remove wshobson/agents/architecture-patterns

# Instalar nuevo skill
npx skills add nuevo/skill
```

### Script de Actualización

```bash
# Actualizar skills automáticamente
./update-skills.sh

# El script:
# - Verifica skills instalados
# - Detecta actualizaciones disponibles
# - Actualiza todos los skills
# - Muestra resumen
```

### Mantenimiento

```bash
# Limpiar caché de npm
npm cache clean --force

# Verificar integridad
./verify.sh

# Backup del sistema de memoria
cp -r .kiro/memory .kiro/memory.backup

# Restaurar memoria
cp -r .kiro/memory.backup .kiro/memory
```

---

## 🎯 Próximos Pasos

Después de la instalación exitosa:

1. **Familiarízate con los agentes**
   ```
   @teacher Explícame cómo funcionan los agentes
   ```

2. **Configura tu primer proyecto**
   ```
   nano .kiro/memory/active-context.md
   ```

3. **Prueba un workflow completo**
   ```
   @architect Diseña un sistema simple
   @critic Revisa el diseño
   @coder Implementa una función básica
   ```

4. **Instala skills adicionales**
   ```bash
   npx skills find
   npx skills add [skill-que-necesites]
   ```

5. **Lee la documentación completa**
   ```bash
   cat README.md
   cat .kiro/memory/README.md
   ```

---

## 📚 Recursos Adicionales

- **Documentación de Kiro:** [kiro.ai/docs](https://kiro.ai/docs)
- **Skills disponibles:** [skills.sh](https://skills.sh)
- **Repositorio GitHub:** [github.com/jemavidev/BetterAgentX](https://github.com/jemavidev/BetterAgentX)
- **Reportar issues:** [github.com/jemavidev/BetterAgentX/issues](https://github.com/jemavidev/BetterAgentX/issues)

---

## 🤝 Contribuir

¿Quieres mejorar BetterAgents?

1. Fork el repositorio
2. Crea una rama: `git checkout -b feature/mejora`
3. Commit cambios: `git commit -am 'Añade nueva feature'`
4. Push: `git push origin feature/mejora`
5. Abre un Pull Request

---

## 📄 Licencia

MIT License - Ver [license](license) para más detalles

---

## ✨ ¡Listo!

Tu sistema BetterAgents está instalado y funcionando. 

**Comando para empezar:**
```bash
kiro .
```

**Primer comando de prueba:**
```
@architect Hola! ¿Puedes explicarme cómo funcionas?
```

---

**¿Problemas?** Revisa la sección de [Solución de Problemas](#solución-de-problemas) o abre un issue en GitHub.

**¡Feliz coding con tus 12 agentes especializados! 🚀**
