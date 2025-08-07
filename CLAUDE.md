# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Docker-based development environment setup for web development, primarily targeting PHP applications. It provides a multi-service containerized environment with support for various PHP versions, databases, caching, and development tools.

## Core Architecture

### Installation System
- **Interactive installer**: `install.sh` provides a dialog-based terminal UI for configuration
- **Configuration storage**: Settings saved to `~/.config/docker-setup.config`
- **Cross-platform support**: Works on WSL2, Linux, and macOS

### Docker Architecture
- **Main compose file**: `docker/docker-compose.yml` (dynamically generated during installation)
- **Modular services**: Individual service configurations in `docker-compose-snippets/`
- **Custom images**: Built from Dockerfiles in `docker/` subdirectories
- **Shared volumes**: Projects stored in `/data/shared/sites`, media in `/data/shared/media`

### Service Structure
- **Web servers**: Nginx (primary), Apache (for specific needs like ProcessWire)
- **PHP versions**: Support for PHP 7.0-8.4 with FPM via Unix sockets
- **Databases**: MySQL 5.6/5.7/8.0, optional MongoDB
- **Search**: Elasticsearch 7/8, OpenSearch
- **Caching**: Redis, optional Varnish with framework-specific VCL (Craft CMS, Magento 2)
- **Mail**: Mailtrap and MailHog for development email testing

### Site Management
- **Auto-discovery**: Nginx automatically configures sites based on directories in `/data/shared/sites`
- **Template system**: Site configurations generated from templates in `docker/nginx/site-templates/`
- **Framework support**: Pre-configured templates for Laravel, Magento, Symfony, Craft CMS, etc.
- **URL structure**: Sites accessible at `project.username.o.xotap.nl` format

## Development Commands

### Installation and Setup
- `make prepare`: Install system dependencies (dialog, jq, etc.)
- `make` or `make run`: Run the interactive installer
- `./install.sh`: Direct installer execution

### Container Management (via devctl script)
- `devctl up [containers]`: Start containers (creates if needed)
- `devctl stop [containers]`: Stop containers
- `devctl restart [containers]`: Restart containers
- `devctl build [containers]`: Build container images
- `devctl pull [containers]`: Pull latest images
- `devctl recreate [containers]`: Force recreate (useful after Xdebug changes)
- `devctl status` or `devctl ps`: Show container status

### Site Management
- `devctl reload`: Update hosts file and restart nginx (run after adding projects)
- `devctl updatehosts`: Update system hosts file with project URLs
- `nginx-sites`: Regenerate nginx site configurations

### Development Tools
- `enter [container]`: Enter a running container (e.g., `enter php81`)
- `devctl tail [container]`: Follow container logs
- `devctl flushredis [db]`: Clear Redis cache
- `devctl flushvarnish [url]`: Clear Varnish cache for URL
- `devctl varnishacl`: Update Varnish ACL with Docker network subnet

### Directory Information
- `devctl installdir`: Show installation directory
- `devctl dockerdir`: Show docker directory

## Key Configuration Files

### Installation Config
- `~/.config/docker-setup.config`: User preferences and settings
- `dep/`: Dependency files (shell scripts, configs) copied during installation

### Docker Configs
- `docker/docker-compose.yml`: Generated compose file with selected services
- `docker/*/Dockerfile`: Custom container definitions
- `docker/*/conf.d/`: PHP and service configurations
- `docker/nginx/site-templates/`: Nginx virtual host templates

### PHP Configuration
- Xdebug configuration in `dep/xdebug.ini`
- PHP-FPM pools in `dep/zz-docker.conf`
- Per-version PHP settings in `docker/php*/conf.d/php.ini`

## Project Structure Expectations

### Adding New Projects
1. Clone project to `/data/shared/sites/project-name`
2. Run `composer install` if PHP project
3. Execute `devctl reload` to update hosts and nginx config
4. Project accessible at `project-name.username.o.xotap.nl`

### Site Detection
- Nginx automatically detects framework type based on files:
  - Laravel: presence of `artisan`
  - Magento: `app/etc/env.php` or `app/code`
  - Symfony: `bin/console`
  - Craft CMS: `craft` executable
- Falls back to default PHP configuration if no framework detected

## Network and Port Configuration

### Default Ports
- HTTP: 80 (8080 if Varnish enabled)
- HTTPS: 443
- MySQL 5.6: 3305, MySQL 5.7: 3306, MySQL 8.0: 3308
- MongoDB: 27017
- Redis: 6379
- Elasticsearch 7/8: 9200, 9300
- OpenSearch: 9201, 9301
- Mailtrap UI: 8085, SMTP: 25
- MailHog UI: 8025, SMTP: 1025

### Internal Communication
- Containers communicate using service names (e.g., `mysql80`, `redis`, `elasticsearch`)
- PHP-FPM via Unix sockets at `/data/shared/sockets/`

## Development Features

### Varnish Caching (Optional)
- **Dual service setup**: `varnish-magento` (port 80) and `varnish-craft` (port 81)
- **Framework-specific VCL**: Each service loads appropriate VCL file (magento2.vcl or craft.vcl)
- **Port handling**: varnish-magento takes port 80 (nginx moves to 8080), varnish-craft uses port 81
- **Cache management**: Built-in purging commands and ACL management
- **ESI support**: Edge Side Includes for advanced caching strategies

### Xdebug Support
- Optional Xdebug installation for all PHP versions
- Configurable trigger modes (always-on or request-triggered)
- IDE integration via standard Xdebug ports

### Mail Testing
- All PHP `mail()` calls intercepted by Mailtrap/MailHog
- No external mail delivery in development

### SSL/TLS
- Self-signed certificates automatically generated
- HTTPS available for all sites

### Architecture Support
- Automatic detection of ARM64 (Apple Silicon) vs AMD64
- Platform-specific optimizations in Docker configurations

## Version Management
- Current version tracked in `version.sh` 
- Version info stored in user config for debugging support