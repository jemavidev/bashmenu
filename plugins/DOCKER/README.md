# Docker Management Scripts

A collection of modular, independent bash scripts for Docker management with best practices, interactive interfaces, and auto-repair capabilities.

## Overview

This collection provides 10 specialized scripts for common Docker operations:

1. **docker-build.sh** - Build Docker images with best practices
2. **docker-run.sh** - Run containers with interactive configuration
3. **docker-stop.sh** - Stop and remove containers safely
4. **docker-images.sh** - Manage images (list, remove, tag, push)
5. **docker-clean.sh** - Intelligent cleanup of unused resources
6. **docker-inspect.sh** - Inspect containers and images in detail
7. **docker-volumes.sh** - Manage Docker volumes
8. **docker-networks.sh** - Manage Docker networks
9. **docker-logs.sh** - View container logs with options
10. **docker-exec.sh** - Execute commands inside containers

## Features

- **Modular & Independent**: Each script works standalone without dependencies
- **Interactive**: User-friendly prompts and selection menus
- **Auto-Repair**: Automatic retry logic and error recovery
- **Safe**: Confirmations for destructive operations
- **Colorful**: Clear, colored output for better readability
- **Resilient**: Timeouts and loop prevention
- **Best Practices**: Implements Docker security and efficiency standards

## Installation

```bash
# Clone or copy scripts to DOCKER directory
cd /path/to/DOCKER

# Make all scripts executable
chmod +x *.sh

# Optional: Add to PATH
export PATH="$PATH:/path/to/DOCKER"
```

## Usage

### Running Scripts Directly

```bash
# Build an image
./docker-build.sh

# Run a container
./docker-run.sh

# View logs
./docker-logs.sh
```

### Integration with Menu Systems

Scripts are designed to be called from menu systems:

```bash
case $option in
    1) ./DOCKER/docker-build.sh ;;
    2) ./DOCKER/docker-run.sh ;;
    3) ./DOCKER/docker-stop.sh ;;
    # ...
esac
```

## Script Details

### docker-build.sh
Build Docker images with interactive configuration.

**Features:**
- Automatic Dockerfile detection
- Image name and tag validation
- Build arguments support
- Multi-stage build support
- No-cache option
- Build verification

**Usage:**
```bash
./docker-build.sh
```

### docker-run.sh
Run containers with full configuration options.

**Features:**
- Image selection from available images
- Port mapping configuration
- Volume mounting
- Environment variables
- Network configuration
- Resource limits (CPU, memory)
- Restart policies
- Health checks

**Usage:**
```bash
./docker-run.sh
```

### docker-stop.sh
Stop and remove containers safely.

**Features:**
- List running containers
- Multiple container selection
- Graceful shutdown (SIGTERM before SIGKILL)
- Optional volume removal
- Confirmation for destructive actions

**Usage:**
```bash
./docker-stop.sh
```

### docker-images.sh
Manage Docker images.

**Features:**
- List images with details
- Remove images (with confirmation)
- Create tags
- Push to registry
- Show dangling images
- Space usage information

**Usage:**
```bash
./docker-images.sh
```

### docker-clean.sh
Clean up unused Docker resources.

**Features:**
- Preview before deletion
- Selective cleanup options
- Remove stopped containers
- Remove unused images
- Remove unused volumes
- Remove unused networks
- Clean build cache
- Show freed space

**Usage:**
```bash
./docker-clean.sh
```

### docker-inspect.sh
Inspect containers and images in detail.

**Features:**
- Formatted output (not just JSON)
- Container and image inspection
- Real-time stats
- Log tail integration
- Export to file option

**Usage:**
```bash
./docker-inspect.sh
```

### docker-volumes.sh
Manage Docker volumes.

**Features:**
- List volumes with usage info
- Create named volumes
- Remove volumes (with safety checks)
- Inspect volume details
- Backup volumes to tar.gz
- Restore volumes from backup

**Usage:**
```bash
./docker-volumes.sh
```

### docker-networks.sh
Manage Docker networks.

**Features:**
- List networks with details
- Create networks (bridge, overlay, macvlan)
- Remove networks (with validation)
- Connect/disconnect containers
- Subnet and gateway configuration
- Inspect network details

**Usage:**
```bash
./docker-networks.sh
```

### docker-logs.sh
View container logs with options.

**Features:**
- Select from running or stopped containers
- Tail (limit lines)
- Follow mode (real-time)
- Timestamps
- Date/time filtering (since, until)
- Export logs to file

**Usage:**
```bash
./docker-logs.sh
```

### docker-exec.sh
Execute commands inside containers.

**Features:**
- Automatic shell detection (bash, sh, ash)
- Interactive shell mode
- Execute specific commands
- Run as specific user
- Custom working directory
- Additional environment variables
- Timeout for non-interactive commands

**Usage:**
```bash
./docker-exec.sh
```

## Common Functions Library

The `common-functions.sh` file contains shared utilities:

- Color output functions
- Docker daemon validation
- Input validation
- Interactive selection menus
- Retry and timeout logic
- Loop prevention
- Confirmation prompts
- Error handling
- Cleanup handlers

Scripts can source this file or embed functions directly for independence.

## Configuration

### Environment Variables

```bash
# Enable logging (optional)
export DOCKER_SCRIPTS_LOG=1
export DOCKER_SCRIPTS_LOG_DIR="/var/log/docker-scripts"
```

### Timeouts

Default timeouts (can be modified in scripts):
- Docker operations: 30 seconds
- General commands: 60 seconds
- Build operations: 300 seconds (5 minutes)

### Retry Configuration

- Maximum retries: 3 attempts
- Retry delay: 2 seconds
- Maximum iterations (loop prevention): 10

## Exit Codes

- `0` - Success
- `1` - Docker error
- `2` - User cancelled
- `3` - Validation error
- `4` - Timeout error

## Requirements

- Bash 4.0 or higher
- Docker installed and running
- Standard Unix utilities (timeout, grep, awk, etc.)

## Best Practices Implemented

1. **Security**
   - No root required (unless necessary)
   - Input sanitization
   - Confirmation for destructive actions
   - Secure credential handling

2. **Reliability**
   - Automatic retry logic
   - Timeout protection
   - Loop prevention
   - Graceful error handling

3. **Docker Best Practices**
   - Specific image tags (not 'latest')
   - Named containers and volumes
   - Resource limits
   - Health checks
   - Proper cleanup

4. **Usability**
   - Interactive prompts
   - Clear colored output
   - Progress indicators
   - Helpful error messages
   - Operation summaries

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.

## FAQ

See [FAQ.md](FAQ.md) for frequently asked questions.

## Version

Current version: 1.0.0

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]

## Support

[Add support information here]
