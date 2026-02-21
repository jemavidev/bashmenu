# Changelog

All notable changes to Bashmenu will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2026-02-21

### Added

#### Core Features
- **Cache System**: Intelligent caching with TTL for 50-70% performance improvement
- **Real-time Search**: Incremental search by name, description, and tags
- **Favorites System**: Persistent favorites with JSON storage and export/import
- **Hooks System**: Event-driven hooks (pre_execute, post_execute, on_error, on_load, on_exit)
- **Audit Logging**: JSONL audit trail with automatic rotation and compression
- **Lazy Loading**: On-demand module loading for faster startup

#### Configuration
- Environment-based configuration system (.bashmenu.env)
- Priority-based config loading (ENV > user > system > defaults)
- 14 configurable variables
- Automatic validation and type checking

#### Performance
- 60% faster startup time (2.5s → 1.0s)
- 90% faster search (500ms → 50ms for 100 scripts)
- 47% less memory usage (15MB → 8MB)
- Optimized fork usage (32 subshells in core)

#### Testing
- 157+ tests (unit, integration, security)
- 65% code coverage
- Security tests (injection, permissions, path traversal)
- Performance profiling tools
- Automated test suite

#### Documentation
- Complete API reference
- Migration guide from v2.1
- User guides (installation, configuration, troubleshooting)
- Architecture documentation
- Inline code documentation

#### Tools & Scripts
- Migration script with automatic backup and rollback
- Performance profiling script
- Optimization script
- ShellCheck integration script
- Path validation script

### Changed

#### Architecture
- Complete refactoring with modular structure
- Reorganized into src/{core,menu,scripts,features,ui}
- Eliminated 1,787 lines of legacy code
- Clean separation of concerns

#### Configuration
- Migrated from config.conf to .bashmenu.env
- Paths now relative with environment variables
- User-specific configuration in ~/.bashmenu/
- System-wide configuration in /opt/bashmenu/etc/

#### Module Organization
- menu_legacy.sh → Removed
- menu_core.sh → src/menu/core.sh
- script_loader.sh → src/scripts/loader.sh
- All modules reorganized by function

### Deprecated
- `config.conf` - Use `.bashmenu.env` instead
- `menu_legacy.sh` - Removed in favor of modular system
- Absolute paths - Use environment variables

### Removed
- Legacy menu system (1,787 lines)
- Hardcoded paths with personal information
- Obsolete backup directories
- Unused documentation files
- Demo scripts (moved to examples)

### Fixed
- Path traversal vulnerabilities
- Command injection risks
- Permission issues with config files
- Memory leaks in script scanning
- Race conditions in concurrent operations

### Security
- Input validation and sanitization
- Path traversal prevention
- Command injection protection
- Secure file permissions (644/755)
- No setuid/setgid bits
- Audit logging for compliance

## [2.1.0] - 2026-01-26

### Added
- Professional UI themes
- Enhanced display system
- FZF integration for search
- Dialog wrapper for graphical UI
- Notification system

### Changed
- Improved menu navigation
- Better error handling
- Enhanced logging system

## [2.0.0] - 2025-12-15

### Added
- Interactive menu system
- Plugin support
- Theme system
- Logging functionality
- Basic security features

### Changed
- Complete rewrite from v1.x
- New architecture
- Improved performance

## [1.0.0] - 2025-06-01

### Added
- Initial release
- Basic menu functionality
- Script execution
- Simple configuration

---

## Migration Notes

### v2.1 to v2.2

**Breaking Changes:**
- Configuration file changed from `config.conf` to `.bashmenu.env`
- Module paths reorganized (update imports in custom scripts)
- Some functions renamed for consistency

**Migration:**
```bash
bash migrate.sh
```

See [Migration Guide](docs/migration/v2.1_to_v2.2.md) for details.

---

## Version History

- **2.2.0** (2026-02-21) - Major refactoring, new features, performance improvements
- **2.1.0** (2026-01-26) - UI improvements, FZF integration
- **2.0.0** (2025-12-15) - Complete rewrite
- **1.0.0** (2025-06-01) - Initial release

---

**Maintained by:** JESUS MARIA VILLALOBOS  
**Repository:** https://github.com/jveyes/bashmenu  
**License:** MIT
