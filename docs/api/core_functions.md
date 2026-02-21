# Core Functions API Reference

## Configuration Module (src/core/config.sh)

### load_configuration()
Load configuration from .env files with priority.

**Priority:** ENV > ~/.bashmenu/.bashmenu.env > /opt/bashmenu/etc/.bashmenu.env > defaults

**Returns:** 0 on success

**Example:**
```bash
source src/core/config.sh
load_configuration
```

### get_config(key)
Get configuration value.

**Parameters:**
- `$1` - Configuration key

**Returns:** Configuration value

**Example:**
```bash
theme=$(get_config "BASHMENU_THEME")
```

### set_config(key, value)
Set configuration value at runtime.

**Parameters:**
- `$1` - Configuration key
- `$2` - Configuration value

**Returns:** 0 on success

**Example:**
```bash
set_config "BASHMENU_THEME" "modern"
```

### is_config_enabled(key)
Check if boolean config is enabled.

**Parameters:**
- `$1` - Configuration key

**Returns:** 0 if enabled, 1 if disabled

**Example:**
```bash
if is_config_enabled "BASHMENU_ENABLE_CACHE"; then
    echo "Cache enabled"
fi
```

---

## Cache Module (src/scripts/cache.sh)

### cache_init()
Initialize cache system.

**Returns:** 0 on success

**Example:**
```bash
source src/scripts/cache.sh
cache_init
```

### cache_get(type, key)
Get value from cache.

**Parameters:**
- `$1` - Cache type (scripts, validation, metadata)
- `$2` - Cache key

**Returns:** Cached value or empty

**Example:**
```bash
scripts=$(cache_get "scripts" "list")
```

### cache_set(type, key, value)
Set value in cache.

**Parameters:**
- `$1` - Cache type
- `$2` - Cache key
- `$3` - Value to cache

**Returns:** 0 on success

**Example:**
```bash
cache_set "scripts" "list" "$script_list"
```

### cache_invalidate(type, key)
Invalidate cache entry.

**Parameters:**
- `$1` - Cache type
- `$2` - Cache key

**Returns:** 0 on success

**Example:**
```bash
cache_invalidate "scripts" "list"
```

### cache_clear()
Clear all cache.

**Returns:** 0 on success

**Example:**
```bash
cache_clear
```

### cache_stats()
Get cache statistics.

**Returns:** JSON with stats

**Example:**
```bash
stats=$(cache_stats)
echo "$stats"
```

---

## Search Module (src/features/search.sh)

### search_init()
Initialize search system.

**Returns:** 0 on success

### search_by_name(query, directory)
Search scripts by name.

**Parameters:**
- `$1` - Search query
- `$2` - Scripts directory

**Returns:** Matching script paths (one per line)

**Example:**
```bash
results=$(search_by_name "deploy" "/opt/bashmenu/plugins")
```

### search_incremental(query, directory, mode)
Perform incremental search.

**Parameters:**
- `$1` - Search query
- `$2` - Scripts directory
- `$3` - Search mode (name|description|tags|all)

**Returns:** Number of results found

**Example:**
```bash
search_incremental "backup" "$PLUGINS_DIR" "all"
echo "Found: ${#SEARCH_RESULTS[@]} results"
```

---

## Favorites Module (src/features/favorites.sh)

### favorites_init()
Initialize favorites system.

**Returns:** 0 on success

### favorites_add(script_path)
Add script to favorites.

**Parameters:**
- `$1` - Script path

**Returns:** 0 on success, 1 if already exists

**Example:**
```bash
favorites_add "/opt/bashmenu/plugins/deploy.sh"
```

### favorites_remove(script_path)
Remove script from favorites.

**Parameters:**
- `$1` - Script path

**Returns:** 0 on success, 1 if not found

### favorites_is_favorite(script_path)
Check if script is in favorites.

**Parameters:**
- `$1` - Script path

**Returns:** 0 if favorite, 1 if not

**Example:**
```bash
if favorites_is_favorite "$script"; then
    echo "⭐"
fi
```

### favorites_list()
List all favorites.

**Returns:** List of favorite scripts (one per line)

### favorites_export(file_path)
Export favorites to file.

**Parameters:**
- `$1` - Export file path

**Returns:** 0 on success

---

## Hooks Module (src/features/hooks.sh)

### hooks_init()
Initialize hooks system.

**Returns:** 0 on success

### register_hook(hook_name, function_name, priority)
Register a hook.

**Parameters:**
- `$1` - Hook name (pre_execute, post_execute, on_error, on_load, on_exit)
- `$2` - Function name to call
- `$3` - Priority (0-100, lower = higher priority) [default: 50]

**Returns:** 0 on success, 1 on error

**Example:**
```bash
my_hook() {
    echo "Hook executed"
    return 0
}

register_hook "pre_execute" "my_hook" 10
```

### execute_hooks(hook_name, ...)
Execute hooks for an event.

**Parameters:**
- `$1` - Hook name
- `$@` - Additional arguments to pass to hook functions

**Returns:** 0 if all hooks succeed, 1 if any hook fails

**Example:**
```bash
execute_hooks "pre_execute" "$script_path"
```

### unregister_hook(hook_name, function_name)
Unregister a hook.

**Parameters:**
- `$1` - Hook name
- `$2` - Function name

**Returns:** 0 on success, 1 if not found

---

## Audit Module (src/features/audit.sh)

### audit_init()
Initialize audit system.

**Returns:** 0 on success

### audit_log_event(action, script, result, exit_code, duration)
Log audit event.

**Parameters:**
- `$1` - Action (execute_script, search, add_favorite, etc.)
- `$2` - Script path (optional)
- `$3` - Result (success|failure)
- `$4` - Exit code (optional)
- `$5` - Duration in ms (optional)

**Returns:** 0 on success

**Example:**
```bash
audit_log_event "execute_script" "/path/to/script.sh" "success" 0 1234
```

### audit_query(filter_type, filter_value, limit)
Query audit log.

**Parameters:**
- `$1` - Filter type (action|user|result|date|all)
- `$2` - Filter value
- `$3` - Limit (optional, default: 100)

**Returns:** Matching audit entries

**Example:**
```bash
audit_query "action" "execute_script" 50
```

### audit_export(file_path, format)
Export audit log.

**Parameters:**
- `$1` - Export file path
- `$2` - Format (jsonl|json|csv) [default: jsonl]

**Returns:** 0 on success

**Example:**
```bash
audit_export "/tmp/audit.csv" "csv"
```

---

## Lazy Loader Module (src/features/lazy_loader.sh)

### lazy_init()
Initialize lazy loader.

**Returns:** 0 on success

### lazy_load_module(module_name)
Load a module on-demand.

**Parameters:**
- `$1` - Module name (search, favorites, hooks, audit, cache)

**Returns:** 0 on success, 1 on error

**Example:**
```bash
lazy_load_module "search"
```

### lazy_preload(...)
Preload multiple modules.

**Parameters:**
- `$@` - Module names to preload

**Returns:** 0 on success

**Example:**
```bash
lazy_preload "cache" "search" "favorites"
```

---

## Error Codes

- `0` - Success
- `1` - General error
- `2` - Invalid arguments
- `3` - File not found
- `4` - Permission denied

---

**Version:** 2.2  
**Last Updated:** 2026-02-21
