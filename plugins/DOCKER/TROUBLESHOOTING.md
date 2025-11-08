# Troubleshooting Guide

## Common Issues and Solutions

### Docker Daemon Issues

#### Problem: "Docker daemon is not available"
**Symptoms:**
- Scripts fail immediately with error message
- Cannot connect to Docker

**Solutions:**
1. Check if Docker is running:
   ```bash
   systemctl status docker
   ```

2. Start Docker service:
   ```bash
   sudo systemctl start docker
   ```

3. Enable Docker to start on boot:
   ```bash
   sudo systemctl enable docker
   ```

4. Check Docker socket permissions:
   ```bash
   ls -l /var/run/docker.sock
   sudo chmod 666 /var/run/docker.sock
   ```

5. Add user to docker group:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

### Build Issues

#### Problem: Build timeout
**Symptoms:**
- Build exceeds 600 seconds
- Script terminates with timeout error

**Solutions:**
1. Increase timeout in script (edit BUILD_TIMEOUT constant)
2. Optimize Dockerfile:
   - Use smaller base images
   - Combine RUN commands
   - Use .dockerignore file
   - Leverage build cache

#### Problem: Dockerfile not found
**Symptoms:**
- Script cannot locate Dockerfile
- "Dockerfile not found" error

**Solutions:**
1. Ensure Dockerfile exists in current directory
2. Check file name (case-sensitive)
3. Provide full path when prompted
4. Check file permissions

### Container Issues

#### Problem: Container fails to start
**Symptoms:**
- Container created but not running
- Exits immediately after start

**Solutions:**
1. Check logs:
   ```bash
   docker logs <container_id>
   ```

2. Verify image exists and is correct
3. Check port conflicts
4. Verify volume paths exist
5. Check resource limits

#### Problem: Port already in use
**Symptoms:**
- "bind: address already in use" error
- Container fails to start

**Solutions:**
1. Find process using port:
   ```bash
   sudo lsof -i :<port>
   sudo netstat -tulpn | grep <port>
   ```

2. Stop conflicting service or use different port
3. Remove stopped containers using the port:
   ```bash
   docker ps -a | grep <port>
   docker rm <container_id>
   ```

#### Problem: Cannot stop container
**Symptoms:**
- Container doesn't respond to stop command
- Timeout during graceful shutdown

**Solutions:**
1. Script automatically tries SIGKILL after timeout
2. Manually force kill:
   ```bash
   docker kill <container_id>
   ```

3. Check container logs for issues
4. Restart Docker daemon if persistent

### Image Issues

#### Problem: Cannot remove image
**Symptoms:**
- "image is being used" error
- "image has dependent child images"

**Solutions:**
1. Stop and remove containers using the image:
   ```bash
   docker ps -a --filter ancestor=<image_id>
   docker rm <container_id>
   ```

2. Use force remove option in script
3. Remove dependent images first
4. Use `docker image prune -a` for cleanup

#### Problem: Image pull fails
**Symptoms:**
- Cannot download image
- Network timeout
- Authentication error

**Solutions:**
1. Check internet connection
2. Login to registry:
   ```bash
   docker login
   ```

3. Verify image name and tag
4. Check registry availability
5. Use proxy if behind firewall

### Volume Issues

#### Problem: Cannot remove volume
**Symptoms:**
- "volume is in use" error
- Volume removal fails

**Solutions:**
1. Check which containers use the volume:
   ```bash
   docker ps -a --filter volume=<volume_name>
   ```

2. Stop and remove containers first
3. Use force remove if necessary

#### Problem: Volume backup fails
**Symptoms:**
- Backup script fails
- Permission denied errors

**Solutions:**
1. Ensure backup directory exists and is writable
2. Check disk space
3. Verify volume exists and is accessible
4. Run with appropriate permissions

### Network Issues

#### Problem: Cannot remove network
**Symptoms:**
- "network has active endpoints" error
- Network in use

**Solutions:**
1. Disconnect all containers first:
   ```bash
   docker network inspect <network_name>
   docker network disconnect <network_name> <container>
   ```

2. Stop containers using the network
3. Use script's disconnect function

#### Problem: Container cannot connect to network
**Symptoms:**
- Connection refused
- Network unreachable

**Solutions:**
1. Verify network exists
2. Check network configuration
3. Ensure container is running
4. Check firewall rules
5. Verify DNS settings

### Permission Issues

#### Problem: Permission denied
**Symptoms:**
- Cannot access Docker socket
- Cannot write files
- Cannot execute scripts

**Solutions:**
1. Add user to docker group (see Docker Daemon Issues)
2. Check script permissions:
   ```bash
   chmod +x DOCKER/*.sh
   ```

3. Check file/directory ownership
4. Run with sudo if necessary (not recommended)

### Script Issues

#### Problem: Script hangs or loops
**Symptoms:**
- Script doesn't respond
- Infinite loop detected

**Solutions:**
1. Scripts have built-in loop prevention (max 10 iterations)
2. Press Ctrl+C to interrupt
3. Check Docker daemon status
4. Review script logs if enabled

#### Problem: Invalid input errors
**Symptoms:**
- Repeated "invalid input" messages
- Cannot proceed with operation

**Solutions:**
1. Follow input format examples
2. Check for special characters
3. Use suggested values
4. Cancel and restart if stuck

### Performance Issues

#### Problem: Slow operations
**Symptoms:**
- Commands take long time
- Timeouts occur frequently

**Solutions:**
1. Check system resources:
   ```bash
   docker system df
   docker stats
   ```

2. Clean up unused resources:
   ```bash
   ./docker-clean.sh
   ```

3. Increase timeout values in scripts
4. Check disk I/O performance
5. Verify network speed for pulls/pushes

#### Problem: Out of disk space
**Symptoms:**
- "no space left on device" error
- Operations fail

**Solutions:**
1. Check disk usage:
   ```bash
   df -h
   docker system df
   ```

2. Run cleanup script:
   ```bash
   ./docker-clean.sh
   ```

3. Remove unused images and containers
4. Prune build cache
5. Move Docker data directory if needed

## Getting Help

### Enable Logging

Set environment variables for detailed logging:
```bash
export DOCKER_SCRIPTS_LOG=1
export DOCKER_SCRIPTS_LOG_DIR="/var/log/docker-scripts"
```

### Check Docker Logs

```bash
# System logs
journalctl -u docker

# Container logs
docker logs <container_id>

# Docker daemon logs
sudo tail -f /var/log/docker.log
```

### Diagnostic Commands

```bash
# Docker info
docker info
docker version

# System resources
docker system df
docker stats --no-stream

# List all resources
docker ps -a
docker images
docker volume ls
docker network ls

# Inspect specific resource
docker inspect <id>
```

### Report Issues

When reporting issues, include:
1. Script name and version
2. Error message (full output)
3. Docker version (`docker version`)
4. OS and version
5. Steps to reproduce
6. Relevant logs

## Additional Resources

- Docker Documentation: https://docs.docker.com/
- Docker Hub: https://hub.docker.com/
- Docker Forums: https://forums.docker.com/
- Stack Overflow: https://stackoverflow.com/questions/tagged/docker
