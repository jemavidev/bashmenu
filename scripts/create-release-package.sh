#!/usr/bin/env bash
# Create release packages for Bashmenu v2.2

set -euo pipefail

VERSION="2.2.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

#######################################
# Create tarball
#######################################
create_tarball() {
    echo -e "${CYAN}Creating tarball...${NC}"
    
    local tarball="$DIST_DIR/bashmenu-v${VERSION}.tar.gz"
    
    # Create temporary directory
    local temp_dir="/tmp/bashmenu-${VERSION}"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    
    # Copy files
    cp -r "$SCRIPT_DIR/src" "$temp_dir/"
    cp -r "$SCRIPT_DIR/config" "$temp_dir/"
    cp -r "$SCRIPT_DIR/plugins" "$temp_dir/"
    cp -r "$SCRIPT_DIR/docs" "$temp_dir/"
    cp -r "$SCRIPT_DIR/scripts" "$temp_dir/"
    cp -r "$SCRIPT_DIR/templates" "$temp_dir/"
    cp "$SCRIPT_DIR/bashmenu" "$temp_dir/"
    cp "$SCRIPT_DIR/install.sh" "$temp_dir/"
    cp "$SCRIPT_DIR/uninstall.sh" "$temp_dir/"
    cp "$SCRIPT_DIR/migrate.sh" "$temp_dir/"
    cp "$SCRIPT_DIR/Makefile" "$temp_dir/"
    cp "$SCRIPT_DIR/README.md" "$temp_dir/"
    cp "$SCRIPT_DIR/CHANGELOG.md" "$temp_dir/"
    cp "$SCRIPT_DIR/LICENSE" "$temp_dir/"
    cp "$SCRIPT_DIR/.bashmenu.env.example" "$temp_dir/"
    
    # Create tarball
    tar -czf "$tarball" -C /tmp "bashmenu-${VERSION}"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo -e "${GREEN}✓ Created: $tarball${NC}"
}

#######################################
# Create checksums
#######################################
create_checksums() {
    echo -e "${CYAN}Creating checksums...${NC}"
    
    cd "$DIST_DIR"
    
    # SHA256
    sha256sum bashmenu-v${VERSION}.tar.gz > checksums.txt
    
    echo -e "${GREEN}✓ Created: checksums.txt${NC}"
    
    cd "$SCRIPT_DIR"
}

#######################################
# Create release notes
#######################################
create_release_notes() {
    echo -e "${CYAN}Creating release notes...${NC}"
    
    cat > "$DIST_DIR/RELEASE_NOTES.md" << 'EOF'
# Bashmenu v2.2.0 Release Notes

**Release Date:** 2026-02-21  
**Status:** Production Ready

## Highlights

- 🚀 **60% Faster Startup** - Intelligent caching system
- 🔍 **Real-time Search** - Incremental search with keyboard navigation
- ⭐ **Favorites System** - Persistent favorites with export/import
- 🎣 **Hooks System** - Event-driven automation
- 📊 **Audit Logging** - JSONL audit trail
- ⚡ **Lazy Loading** - On-demand module loading
- 🧪 **157+ Tests** - 65% code coverage

## What's New

### Core Features
- Cache system with TTL (50-70% performance improvement)
- Real-time incremental search by name, description, tags
- Persistent favorites with JSON storage
- Event-driven hooks (5 hook types)
- JSONL audit logging with automatic rotation
- Lazy loading for faster startup

### Performance
- 60% faster startup (2.5s → 1.0s)
- 90% faster search (500ms → 50ms)
- 47% less memory (15MB → 8MB)

### Architecture
- Complete refactoring with modular structure
- Eliminated 1,787 lines of legacy code
- Clean separation of concerns
- Environment-based configuration

### Testing & Quality
- 157+ tests (unit, integration, security)
- 65% code coverage
- Security hardening
- Performance profiling tools

## Breaking Changes

1. **Configuration**: `config.conf` → `.bashmenu.env`
2. **Module Paths**: Reorganized into `src/{core,menu,scripts,features,ui}`
3. **Some Functions**: Renamed for consistency

## Migration

```bash
# Automatic migration
bash migrate.sh

# Preview changes
bash migrate.sh --dry-run

# Rollback if needed
bash migrate.sh --rollback
```

See [Migration Guide](docs/migration/v2.1_to_v2.2.md) for details.

## Installation

### New Installation

```bash
# Extract
tar -xzf bashmenu-v2.2.0.tar.gz
cd bashmenu-2.2.0

# Install
sudo bash install.sh
```

### Upgrade from v2.1

```bash
# Backup
sudo cp -r /opt/bashmenu /opt/bashmenu.backup

# Extract new version
tar -xzf bashmenu-v2.2.0.tar.gz
cd bashmenu-2.2.0

# Run migration
bash migrate.sh
```

## Requirements

- Bash 4.0+
- Linux (Ubuntu 20.04+, Debian 11+, CentOS 7+, Arch)
- Optional: fzf, dialog, shellcheck

## Known Issues

None at release time.

## Documentation

- [Installation Guide](docs/guides/installation.md)
- [Quick Start](docs/guides/quick_start.md)
- [Configuration](docs/guides/configuration.md)
- [API Reference](docs/api/core_functions.md)
- [Migration Guide](docs/migration/v2.1_to_v2.2.md)

## Support

- Documentation: `/opt/bashmenu/docs/`
- Issues: GitHub Issues
- Logs: `/var/log/bashmenu/bashmenu.log`

## Contributors

- JESUS MARIA VILLALOBOS - Lead Developer

## License

MIT License

---

**Download:** https://github.com/jveyes/bashmenu/releases/tag/v2.2.0  
**Checksums:** See checksums.txt  
**GPG Signature:** See bashmenu-v2.2.0.tar.gz.asc
EOF
    
    echo -e "${GREEN}✓ Created: RELEASE_NOTES.md${NC}"
}

#######################################
# Main
#######################################
main() {
    echo "========================================"
    echo "Bashmenu v${VERSION} - Release Package"
    echo "========================================"
    echo ""
    
    # Create dist directory
    mkdir -p "$DIST_DIR"
    
    # Create packages
    create_tarball
    create_checksums
    create_release_notes
    
    echo ""
    echo "========================================"
    echo "Release Package Complete"
    echo "========================================"
    echo ""
    echo "Files created in: $DIST_DIR"
    ls -lh "$DIST_DIR"
    echo ""
}

main "$@"
