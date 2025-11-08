# Quick Start Guide

## Installation

1. Ensure Docker is installed and running:
```bash
docker --version
systemctl status docker
```

2. Make scripts executable (already done):
```bash
chmod +x DOCKER/*.sh
```

3. Optional - Add to PATH:
```bash
export PATH="$PATH:$(pwd)/DOCKER"
```

## Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `docker-build.sh` | Build Docker images | `./docker-build.sh` |
| `docker-run.sh` | Run containers | `./docker-run.sh` |
| `docker-stop.sh` | Stop/remove containers | `./docker-stop.sh` |
| `docker-images.sh` | Manage images | `./docker-images.sh` |
| `docker-clean.sh` | Clean unused resources | `./docker-clean.sh` |
| `docker-inspect.sh` | Inspect resources | `./docker-inspect.sh` |
| `docker-volumes.sh` | Manage volumes | `./docker-volumes.sh` |
| `docker-networks.sh` | Manage networks | `./docker-networks.sh` |
| `docker-logs.sh` | View container logs | `./docker-logs.sh` |
| `docker-exec.sh` | Execute commands in containers | `./docker-exec.sh` |

## Quick Examples

### Build an Image
```bash
cd DOCKER
./docker-build.sh
# Follow prompts to select Dockerfile, name image, configure options
```

### Run a Container
```bash
./docker-run.sh
# Select image, configure ports, volumes, environment variables
```

### View Logs
```bash
./docker-logs.sh
# Select container, configure log options (tail, follow, timestamps)
```

### Clean Up
```bash
./docker-clean.sh
# Choose what to clean: containers, images, volumes, networks, cache
```

### Execute Commands
```bash
./docker-exec.sh
# Select container, choose interactive shell or specific command
```

## Common Workflows

### Development Workflow
1. Build image: `./docker-build.sh`
2. Run container: `./docker-run.sh`
3. View logs: `./docker-logs.sh`
4. Execute commands: `./docker-exec.sh`
5. Stop when done: `./docker-stop.sh`

### Maintenance Workflow
1. Check disk usage: `./docker-clean.sh` → option 1
2. Clean stopped containers: `./docker-clean.sh` → option 2
3. Remove unused images: `./docker-clean.sh` → option 3
4. Clean volumes (careful!): `./docker-clean.sh` → option 4

### Backup Workflow
1. List volumes: `./docker-volumes.sh` → option 1
2. Backup volume: `./docker-volumes.sh` → option 5
3. Backups saved to: `./docker-volume-backups/`

### Troubleshooting Workflow
1. Inspect container: `./docker-inspect.sh`
2. View logs: `./docker-logs.sh`
3. Execute debug commands: `./docker-exec.sh`
4. Check resources: `./docker-clean.sh` → option 1

## Tips

- **All scripts are interactive** - just run them and follow prompts
- **Press Ctrl+C** to cancel any operation
- **Confirmations required** for destructive actions
- **Auto-retry** on failures (up to 3 attempts)
- **Colored output** for easy reading:
  - 🟢 Green = Success
  - 🔴 Red = Error
  - 🟡 Yellow = Warning
  - 🔵 Blue = Info

## Safety Features

✅ Input validation  
✅ Confirmation prompts for destructive actions  
✅ Graceful shutdown (SIGTERM before SIGKILL)  
✅ Timeout protection  
✅ Loop prevention  
✅ Error recovery  
✅ Resource cleanup  

## Need Help?

- **README.md** - Complete documentation
- **FAQ.md** - Frequently asked questions
- **TROUBLESHOOTING.md** - Common issues and solutions
- **Script comments** - Detailed inline documentation

## First Time Users

Try this sequence:
1. `./docker-images.sh` - See what images you have
2. `./docker-run.sh` - Run a simple container (e.g., nginx)
3. `./docker-logs.sh` - View its logs
4. `./docker-exec.sh` - Execute commands inside
5. `./docker-stop.sh` - Stop and remove it
6. `./docker-clean.sh` - Clean up

## Integration with Menu Systems

These scripts work great with menu systems:

```bash
#!/bin/bash
# menu.sh example

while true; do
    echo "Docker Management Menu"
    echo "1) Build Image"
    echo "2) Run Container"
    echo "3) Stop Container"
    echo "4) View Logs"
    echo "5) Clean Up"
    echo "0) Exit"
    
    read -p "Select: " choice
    
    case $choice in
        1) ./DOCKER/docker-build.sh ;;
        2) ./DOCKER/docker-run.sh ;;
        3) ./DOCKER/docker-stop.sh ;;
        4) ./DOCKER/docker-logs.sh ;;
        5) ./DOCKER/docker-clean.sh ;;
        0) exit 0 ;;
    esac
done
```

## Best Practices

1. **Use specific tags** - Avoid 'latest' in production
2. **Name your containers** - Makes management easier
3. **Use volumes** - For persistent data
4. **Set restart policies** - For automatic recovery
5. **Limit resources** - Prevent resource exhaustion
6. **Regular cleanup** - Keep system healthy
7. **Backup volumes** - Before major changes
8. **Check logs** - When troubleshooting

## Support

For issues or questions:
1. Check FAQ.md
2. Review TROUBLESHOOTING.md
3. Examine script output (colored messages)
4. Enable logging (see README.md)
5. Check Docker documentation

Happy Dockering! 🐳
