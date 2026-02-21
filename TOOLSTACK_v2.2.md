# Bashmenu v2.2 - Toolstack y Tecnologías

## Stack Tecnológico

### Core Technologies

| Tecnología | Versión | Propósito | Requerido |
|------------|---------|-----------|-----------|
| Bash | 4.0+ | Shell scripting | ✅ Sí |
| GNU Coreutils | Any | Utilidades básicas | ✅ Sí |
| GNU Findutils | Any | Búsqueda de archivos | ✅ Sí |

### Development Tools

| Herramienta | Versión | Propósito | Requerido |
|-------------|---------|-----------|-----------|
| ShellCheck | 0.7+ | Linting y análisis estático | ✅ Sí (dev) |
| BATS | 1.2+ | Testing framework | ✅ Sí (dev) |
| Git | 2.0+ | Control de versiones | ✅ Sí (dev) |
| Make | Any | Build automation | ⚠️ Opcional |

### Optional Enhancements

| Herramienta | Versión | Propósito | Requerido |
|-------------|---------|-----------|-----------|
| dialog | 1.3+ | UI mejorada | ❌ No |
| whiptail | Any | UI alternativa | ❌ No |
| fzf | 0.20+ | Búsqueda fuzzy | ❌ No |
| jq | 1.5+ | Procesamiento JSON | ❌ No |
| notify-send | Any | Notificaciones desktop | ❌ No |

---

## Instalación de Herramientas

### Ubuntu/Debian

```bash
# Core (ya instalado normalmente)
sudo apt-get update
sudo apt-get install bash coreutils findutils

# Development
sudo apt-get install shellcheck git make

# BATS (desde repositorio)
sudo apt-get install bats

# O instalar BATS manualmente
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local

# Optional enhancements
sudo apt-get install dialog whiptail jq libnotify-bin

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### CentOS/RHEL/Rocky

```bash
# Core
sudo yum install bash coreutils findutils

# Development
sudo yum install git make
sudo yum install epel-release
sudo yum install ShellCheck

# BATS (manual)
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local

# Optional
sudo yum install dialog newt jq libnotify

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### Arch Linux

```bash
# Core (ya instalado)
sudo pacman -S bash coreutils findutils

# Development
sudo pacman -S shellcheck git make bats

# Optional
sudo pacman -S dialog jq libnotify fzf
```

---

## Estructura de Testing

### BATS (Bash Automated Testing System)

**Instalación:**
```bash
# Opción 1: Package manager
sudo apt-get install bats  # Ubuntu/Debian
sudo yum install bats      # CentOS/RHEL
sudo pacman -S bats        # Arch

# Opción 2: Manual
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

**Uso:**
```bash
# Ejecutar todos los tests
bats tests/

# Ejecutar tests específicos
bats tests/unit/core/

# Con output verbose
bats -t tests/

# Con timing
bats --timing tests/
```

**Ejemplo de Test:**
```bash
#!/usr/bin/env bats

@test "config.sh loads environment variables" {
    source src/core/config.sh
    load_env_file ".bashmenu.env.example"
    
    [ -n "$BASHMENU_HOME" ]
    [ "$BASHMENU_THEME" = "modern" ]
}
```

### ShellCheck

**Instalación:**
```bash
# Ubuntu/Debian
sudo apt-get install shellcheck

# CentOS/RHEL
sudo yum install epel-release
sudo yum install ShellCheck

# Arch
sudo pacman -S shellcheck

# macOS
brew install shellcheck
```

**Uso:**
```bash
# Verificar un archivo
shellcheck src/main.sh

# Verificar todos los archivos
find src -name "*.sh" -exec shellcheck {} \;

# Con formato específico
shellcheck -f gcc src/main.sh  # Para CI/CD

# Ignorar warnings específicos
shellcheck -e SC2034 src/main.sh  # Ignora variables no usadas
```

**Configuración (.shellcheckrc):**
```bash
# Disable specific warnings
disable=SC2034  # Unused variables
disable=SC1090  # Can't follow non-constant source

# Enable optional checks
enable=all
```

---

## CI/CD Pipeline

### GitHub Actions

**Archivo:** `.github/workflows/tests.yml`

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y shellcheck bats
    
    - name: Run ShellCheck
      run: |
        find src -name "*.sh" -exec shellcheck {} \;
    
    - name: Run BATS tests
      run: |
        bats tests/
    
    - name: Check coverage
      run: |
        ./scripts/dev/coverage.sh
```

**Archivo:** `.github/workflows/lint.yml`

```yaml
name: Lint

on: [push, pull_request]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run ShellCheck
      uses: ludeeus/action-shellcheck@master
      with:
        severity: error
```

---

## Build Tools

### Makefile

```makefile
.PHONY: help install test lint clean

help:
	@echo "Bashmenu v2.2 - Available targets:"
	@echo "  install    - Install bashmenu system-wide"
	@echo "  test       - Run all tests"
	@echo "  lint       - Run shellcheck"
	@echo "  clean      - Clean build artifacts"
	@echo "  coverage   - Generate coverage report"

install:
	@echo "Installing bashmenu..."
	sudo ./install.sh

test:
	@echo "Running tests..."
	bats tests/

lint:
	@echo "Running shellcheck..."
	find src -name "*.sh" -exec shellcheck {} \;

clean:
	@echo "Cleaning..."
	rm -rf dist/
	rm -rf ~/.bashmenu/cache/

coverage:
	@echo "Generating coverage report..."
	./scripts/dev/coverage.sh
```

---

## Development Environment Setup

### Script: scripts/dev/setup_dev.sh

```bash
#!/bin/bash
set -euo pipefail

echo "Setting up Bashmenu development environment..."

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS"
    exit 1
fi

# Install dependencies based on OS
case $OS in
    ubuntu|debian)
        sudo apt-get update
        sudo apt-get install -y shellcheck bats git make jq
        ;;
    centos|rhel|rocky)
        sudo yum install -y epel-release
        sudo yum install -y ShellCheck git make jq
        # Install BATS manually
        git clone https://github.com/bats-core/bats-core.git /tmp/bats
        cd /tmp/bats && sudo ./install.sh /usr/local
        ;;
    arch)
        sudo pacman -S --noconfirm shellcheck bats git make jq
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Install fzf (optional)
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

# Setup git hooks
echo "Setting up git hooks..."
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running shellcheck..."
find src -name "*.sh" -exec shellcheck {} \;
if [ $? -ne 0 ]; then
    echo "ShellCheck failed. Commit aborted."
    exit 1
fi
echo "ShellCheck passed."
EOF
chmod +x .git/hooks/pre-commit

echo "Development environment setup complete!"
echo "Run 'make test' to verify installation."
```

---

## Code Quality Tools

### ShellCheck Rules

**Enabled by default:**
- SC2034: Variable unused
- SC2086: Quote to prevent word splitting
- SC2155: Declare and assign separately
- SC2164: Use cd ... || exit in case cd fails

**Custom rules (.shellcheckrc):**
```bash
# Bashmenu ShellCheck Configuration

# Disable false positives
disable=SC1090  # Can't follow non-constant source
disable=SC1091  # Not following sourced files

# Enable all optional checks
enable=all

# Set shell dialect
shell=bash

# Exclude patterns
exclude=lib/
exclude=bats-testing/
```

### Code Coverage

**Script:** `scripts/dev/coverage.sh`

```bash
#!/bin/bash
set -euo pipefail

echo "Generating code coverage report..."

# Count total functions
total_functions=$(grep -r "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*()[[:space:]]*{" src/ | wc -l)

# Count tested functions
tested_functions=$(grep -r "@test" tests/ | wc -l)

# Calculate coverage
coverage=$((tested_functions * 100 / total_functions))

echo "Total functions: $total_functions"
echo "Tested functions: $tested_functions"
echo "Coverage: ${coverage}%"

if [ $coverage -lt 60 ]; then
    echo "❌ Coverage below 60% threshold"
    exit 1
else
    echo "✅ Coverage meets 60% threshold"
fi
```

---

## Performance Benchmarking

### Script: scripts/dev/benchmark.sh

```bash
#!/bin/bash
set -euo pipefail

echo "Running performance benchmarks..."

# Benchmark startup time
echo "Testing startup time..."
for i in {1..10}; do
    /usr/bin/time -f "%e" ./bashmenu --version 2>&1 | tail -1
done | awk '{sum+=$1} END {print "Average startup: " sum/NR "s"}'

# Benchmark search
echo "Testing search performance..."
# TODO: Implement search benchmark

# Benchmark cache
echo "Testing cache performance..."
# TODO: Implement cache benchmark
```

---

## Documentation Tools

### shdoc (Shell Documentation Generator)

```bash
# Install shdoc
curl -L https://github.com/reconquest/shdoc/releases/download/v1.1/shdoc-linux-amd64 \
    -o /usr/local/bin/shdoc
chmod +x /usr/local/bin/shdoc

# Generate documentation
shdoc < src/core/config.sh > docs/api/config.md
```

### Markdown Linting

```bash
# Install markdownlint
npm install -g markdownlint-cli

# Lint markdown files
markdownlint docs/
```

---

## Recommended IDE Setup

### VS Code Extensions

```json
{
  "recommendations": [
    "timonwong.shellcheck",
    "foxundermoon.shell-format",
    "rogalmic.bash-debug",
    "mads-hartmann.bash-ide-vscode"
  ]
}
```

### VS Code Settings

```json
{
  "shellcheck.enable": true,
  "shellcheck.run": "onSave",
  "shellformat.flag": "-i 4",
  "[shellscript]": {
    "editor.defaultFormatter": "foxundermoon.shell-format"
  }
}
```

---

## Summary

### Minimum Requirements (Development)
- Bash 4.0+
- ShellCheck 0.7+
- BATS 1.2+
- Git 2.0+

### Recommended Setup
- All minimum requirements
- fzf (enhanced search)
- jq (JSON processing)
- dialog (better UI)
- VS Code with extensions

### Installation Time
- Minimum setup: ~5 minutes
- Full setup: ~15 minutes
- First build/test: ~2 minutes

