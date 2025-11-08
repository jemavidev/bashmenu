# Frequently Asked Questions (FAQ)

## General Questions

### What are these scripts?
These are interactive bash scripts for managing Docker containers, images, volumes, and networks. They provide a user-friendly interface with best practices built-in.

### Do I need to install anything?
You only need:
- Bash 4.0 or higher (usually pre-installed on Linux)
- Docker installed and running
- Standard Unix utilities (timeout, grep, awk)

### Can I use these scripts in production?
Yes, but with caution. The scripts include safety features like confirmations for destructive actions, but always test in a non-production environment first.

### Are the scripts safe to use?
Yes. The scripts:
- Ask for confirmation before destructive operations
- Validate all inputs
- Include error handling and recovery
- Have timeout protection
- Prevent infinite loops

## Usage Questions

### How do I run a script?
```bash
cd DOCKER
./docker-build.sh
```

Or make them available system-wide:
```bash
export PATH="$PATH:/path/to/DOCKER"
docker-build.sh
```

### Can I automate the scripts?
The scripts are designed for interactive use. For automation, use Docker commands directly or create wrapper scripts that provide inputs programmatically.

### Can I run multiple scripts simultaneously?
Yes, the scripts are designed to be safe for concurrent execution. However, be careful with operations on the same resources.

### How do I cancel an operation?
Press `Ctrl+C` at any time. The scripts will clean up and exit gracefully.

## Docker Build Questions

### Why does the script warn about 'latest' tag?
Using 'latest' tag is not recommended because:
- It's ambiguous (which version is "latest"?)
- Can cause unexpected behavior when image updates
- Makes rollbacks difficult
- Best practice is to use specific version tags (e.g., v1.0.0, 2.3.4)

### Can I use build arguments?
Yes, the script has an option to add build arguments interactively.

### How do I build multi-stage Dockerfiles?
The script supports specifying a target stage for multi-stage builds.

### What if my build takes longer than 10 minutes?
The default timeout is 600 seconds (10 minutes). You can modify the `BUILD_TIMEOUT` constant in the script.

## Docker Run Questions

### Can I run containers in the background?
Yes, containers are run in detached mode (`-d`) by default.

### How do I expose multiple ports?
The script allows you to add multiple port mappings interactively.

### Can I mount multiple volumes?
Yes, you can add as many volume mounts as needed.

### What restart policies are available?
- `no` - Never restart
- `on-failure` - Restart only on failure
- `always` - Always restart
- `unless-stopped` - Always restart unless manually stopped (recommended)

### How do I set resource limits?
The script has an option to configure CPU and memory limits.

## Docker Stop Questions

### What's the difference between stop and kill?
- **Stop**: Sends SIGTERM, waits for graceful shutdown (10 seconds), then SIGKILL if needed
- **Kill**: Immediately sends SIGKILL

The script uses graceful stop by default.

### Can I stop multiple containers at once?
Yes, select multiple containers by entering numbers separated by spaces (e.g., "1 3 5").

### Will stopping a container delete it?
No, stopped containers remain on the system. The script asks if you want to remove them.

### What happens to volumes when I remove a container?
By default, volumes are preserved. The script asks if you want to remove associated volumes.

## Docker Images Questions

### What are dangling images?
Dangling images are untagged images (shown as `<none>:<none>`). They're usually intermediate layers from failed builds or replaced images.

### How do I remove all unused images?
Use the docker-clean.sh script and select the images cleanup option.

### Can I push images to private registries?
Yes, but you need to login first:
```bash
docker login your-registry.com
```

### Why can't I remove an image?
The image might be:
- Used by a running container
- Used by a stopped container
- Referenced by another image
Use the force remove option or remove dependent containers first.

## Docker Clean Questions

### Is it safe to clean everything?
The "clean everything" option removes:
- Stopped containers
- Dangling images
- Unused volumes (with confirmation)
- Unused networks
- Build cache

It's safe but will require re-downloading/rebuilding resources later.

### Will cleaning delete my data?
- Containers: No data loss (data is in volumes)
- Images: Can be re-pulled/rebuilt
- Volumes: Only if you confirm removal (PERMANENT DATA LOSS)
- Networks: Can be recreated

### How much space will I free?
The script shows a preview before cleaning and disk usage after. Typical savings range from hundreds of MB to several GB.

### How often should I clean?
Depends on usage. Weekly or monthly cleaning is common. Monitor with:
```bash
docker system df
```

## Docker Volumes Questions

### What's the difference between volumes and bind mounts?
- **Volumes**: Managed by Docker, stored in Docker's directory
- **Bind mounts**: Direct mount of host directory

The scripts work with both.

### Can I backup volumes?
Yes, the docker-volumes.sh script includes backup/restore functionality.

### Where are backups stored?
By default in `./docker-volume-backups/`. You can modify the `BACKUP_DIR` constant.

### Can I move volumes between hosts?
Yes, use the backup feature to create a tar.gz, transfer it, and restore on another host.

## Docker Networks Questions

### What network drivers are available?
- **bridge**: Default, for containers on same host
- **overlay**: For multi-host networking (Swarm)
- **macvlan**: Assign MAC address to container
- **host**: Use host's network directly
- **none**: No networking

### When should I create custom networks?
Create custom networks when you need:
- Container isolation
- Custom DNS resolution
- Specific subnet/gateway
- Better security

### Can containers communicate across networks?
Only if they're connected to the same network. Use the connect/disconnect functions to manage this.

## Docker Logs Questions

### How far back do logs go?
Logs are stored since container creation, but can be large. Use the tail option to limit output.

### Can I filter logs by time?
Yes, use the "since" and "until" options (e.g., "1h", "30m", "2023-01-01").

### How do I follow logs in real-time?
Select the "follow" option. Press Ctrl+C to stop.

### Can I export logs?
Yes, the script offers to export logs to a file after viewing.

## Docker Exec Questions

### What's the difference between exec and run?
- **exec**: Execute command in existing running container
- **run**: Create and start new container

### Why can't I exec into my container?
The container must be running. Check status with:
```bash
docker ps
```

### What if bash is not available?
The script automatically detects available shells (bash, sh, ash) and uses the best option.

### Can I run commands as a different user?
Yes, the script has an option to specify the user.

## Integration Questions

### Can I use these with Docker Compose?
These scripts work with individual containers. For Compose, use `docker-compose` commands directly.

### Do these work with Kubernetes?
No, these are Docker-specific. Kubernetes uses different concepts (pods, deployments, etc.).

### Can I integrate with CI/CD?
The scripts are interactive. For CI/CD, use Docker commands directly or create non-interactive wrapper scripts.

### Do these work with Podman?
Not directly, but Podman has Docker-compatible commands. You might need minor modifications.

## Troubleshooting Questions

### Why do I get "permission denied"?
You need to be in the docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### The script hangs, what do I do?
Press Ctrl+C to interrupt. Scripts have built-in loop prevention and will auto-exit after 10 iterations.

### How do I enable debug mode?
Set environment variables:
```bash
export DOCKER_SCRIPTS_LOG=1
export DOCKER_SCRIPTS_LOG_DIR="/var/log/docker-scripts"
```

### Where can I get help?
1. Check TROUBLESHOOTING.md
2. Review Docker documentation
3. Check script comments
4. Search Docker forums/Stack Overflow

## Best Practices Questions

### Should I use 'latest' tag?
No, use specific version tags for better control and reproducibility.

### How should I name containers?
Use descriptive names that indicate purpose (e.g., "web-server", "db-primary").

### Should I use restart policies?
Yes, `unless-stopped` is recommended for most services.

### How do I secure my containers?
- Don't run as root inside containers
- Use specific image tags
- Limit resources
- Use custom networks
- Keep images updated
- Scan for vulnerabilities

### Should I use volumes or bind mounts?
- **Volumes**: For production, better performance, Docker-managed
- **Bind mounts**: For development, direct access to code

## Advanced Questions

### Can I modify the scripts?
Yes, they're open source. Follow the code standards in the comments.

### How do I add new features?
1. Follow the existing script structure
2. Include error handling
3. Add input validation
4. Update documentation
5. Test thoroughly

### Can I create my own scripts using these as templates?
Absolutely! The common-functions.sh file provides reusable utilities.

### How do I contribute?
[Add contribution guidelines here]

## Still Have Questions?

- Read the README.md for overview
- Check TROUBLESHOOTING.md for issues
- Review Docker documentation
- Ask in Docker forums or Stack Overflow
