# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Docker-based PHP development environment for web development. The installer builds a `docker-compose.yml` by concatenating modular snippets, then the `devctl` and `nginx-sites` scripts manage the running environment.

## Core Architecture

### Snippet-Based Compose File Generation

`install.sh` builds `$installdir/docker/docker-compose.yml` by:
1. Copying `./docker/docker-compose.yml` (base with nginx, redis, mailtrap, mailhog, network)
2. Conditionally appending files from `docker-compose-snippets/` (one per optional service)
3. Running `sed -i` to replace `installdirectory` placeholder with the actual path throughout
4. Detecting ARM64 vs AMD64 and uncommenting the appropriate platform-specific lines

PHP versions each get their own snippet (`docker-compose-snippets/php81`, etc.) and a full directory copy from `./docker/php81/`. The installer runs per-version `sed` to substitute `##PHPVERSION##` in `dep/zz-docker.conf` and `dep/phprun.sh` before copying them.

### Config File

`~/.config/docker-setup.config` is a shell script (sourced with `.`), not JSON. It is also mounted read-only into containers at `/etc/docker-setup.config`. All scripts — `install.sh`, `devctl.sh`, `nginx-sites.sh`, `phprun.sh` — source this file. Key variables:

- `installdir`: Root installation path
- `USERNAME`: Used in site URLs (`project.username.o.xotap.nl`)
- `PROJECTSLUG`: Domain suffix (default `.o.xotap.nl`)
- `PHPLATEST`: The latest selected PHP version; resolves the `"latest"` value in per-site config
- `SETUP_*`: on/off flags for all optional services (persisted between installer runs)
- `FIRSTRUN`: Set to `0` after first run; controls auto-enabling of default services

### PHP / Nginx Communication

All PHP versions communicate with Nginx exclusively via Unix sockets. Socket paths follow the pattern `/data/shared/sockets/php{version}-fpm.sock` (e.g., `php81-fpm.sock`). No PHP container exposes a TCP port. The `phpsockets` named volume is shared between all PHP containers and Nginx.

### nginx-sites.sh Framework Detection

`nginx-sites` scans subdirectories of `/data/shared/sites` and auto-detects the framework per site. Detection priority (first match wins):

| File/Dir checked | Framework | Webserver | PHP version | Template |
|---|---|---|---|---|
| `/bin/magento` | magento2 | nginx | latest | magento2 |
| `/app/etc/local.xml` | magento1 | nginx | 7.4 | magento |
| `/web/` directory | craft | nginx | latest | craft |
| `/htdocs/wire/` directory | processwire | apache | latest | processwire |
| `/artisan` | laravel | nginx | latest | laravel |
| `/htdocs/` directory | generic | apache | latest | default |
| (none) | none | nginx | latest | default |

Detected config is stored in `$SITEROOT/.siteconfig/config.json`:
```json
{"template":"magento2","webserver":"nginx","php_version":"latest"}
```

To override auto-detection, edit this file. Custom nginx/apache configs can be placed at `$SITEROOT/.siteconfig/nginx.conf` or `.siteconfig/apache.conf` — these take precedence over templates.

**Placeholder substitutions** applied when writing nginx/apache configs:
- `##USE_PHPVERSION##` → resolved PHP version number
- `##SITEBASENAME##` → directory name
- `##XCOMUSER##` / `##PROJECTSLUG##` → from config
- `##DOMAIN##` → `.${USERNAME}${PROJECTSLUG}`
- `##INCLUDE_PARAMS##` → inlined `params.conf` include for Magento/Craft

`nginx-sites` also truncates per-site log files to the last 1000 lines on each run.

### WSL2 Host File Handling

`devctl updatehosts` detects WSL2 by checking for `/mnt/c` and writes to the Windows hosts file at `/mnt/c/Windows/System32/drivers/etc/hosts` using the `eth0` IP. On native Linux/macOS it writes to `/etc/hosts` using `127.0.0.1`.

### Varnish Port Assignment

When `SETUP_VARNISH=on`, the installer rewrites the nginx service's port mapping from `80:80` to `8080:80` via sed, and appends the varnish snippet which binds port 80. Two Varnish services exist:
- `varnish-magento`: port 80, uses `magento2.vcl`
- `varnish-craft`: port 81, uses `craft.vcl`

### Xdebug Mode Configuration

The installer modifies `dep/xdebug.ini` via sed before copying it to each PHP version's `conf.d/`:
- `SETUP_XDEBUG=off`: comments out `xdebug.mode=debug,develop`, uncomments `xdebug.mode=off`
- `SETUP_XDEBUG_TRIGGER=on`: enables `xdebug.start_with_request=trigger` instead of `yes`

Xdebug connects to `host.docker.internal:9003` with IDE key `PHPSTORM`.

### Elasticsearch / OpenSearch Mutual Exclusivity

Elasticsearch 7 and Elasticsearch 8 cannot coexist. OpenSearch is independent and can be combined with either. The volume snippet appended depends on which combination is selected (`elasticsearch-volume`, `elasticsearch-opensearch-volume`, or `opensearch-volume`). If no search service is selected, `phpsockets-volume` is appended instead (to close the volumes section).

### Platform-Specific sed

On ARM64 (macOS Apple Silicon), the installer uses BSD sed syntax: `sed -i ''`. On AMD64 (Linux/WSL2), it uses GNU sed: `sed -i`. This affects any modifications to the installer for file substitutions.

## Commands

### Installation
- `make prepare`: Install system dependencies (`dialog`, `jq`, `curl`, etc.) — OS-aware
- `make` or `make run`: Run the interactive installer (`./install.sh`)
- `./install` and `./install.sh` are identical binaries

### Container Management (`devctl`)
- `devctl up [containers]`: `docker compose up -d`
- `devctl stop [containers]`: `docker compose stop`
- `devctl start`: `docker compose start` (all containers)
- `devctl restart [containers]`: `docker compose restart`
- `devctl recreate [containers]`: `docker compose up -d --force-recreate` (use after Xdebug changes)
- `devctl build [containers]`: `docker compose build --no-cache`
- `devctl pull [containers]`: `docker compose pull`
- `devctl status` / `devctl ps`: `docker compose ps -a`
- `devctl tail [container]`: `docker compose logs -f`
- `devctl version`: Show VERSION from config

### Site & Cache Management
- `devctl reload`: Runs `updatehosts` + `nginx-sites` + nginx reload (+ apache if enabled)
- `devctl updatehosts`: Regenerate `/etc/hosts` entries from sites directory
- `nginx-sites`: Regenerate nginx/apache site configs from templates
- `devctl flushredis [db]`: `redis-cli flushall` or `redis-cli -n [db] flushdb`
- `devctl flushvarnish [url]`: HTTP PURGE with `X-Magento-Tags-Pattern: .*`
- `devctl varnishacl`: Update Varnish ACL with current Docker network subnet

### Utilities
- `enter [container]`: Enter a running container (e.g., `enter php81`)
- `devctl installdir`: Print `$installdir`
- `devctl dockerdir`: Print `$installdir/docker`

## Key Files

| Path | Purpose |
|---|---|
| `install.sh` | Interactive installer (dialog-based) |
| `dep/devctl.sh` | Source for `~/‌.local/bin/devctl` |
| `dep/nginx-sites.sh` | Source for `~/‌.local/bin/nginx-sites` |
| `dep/zz-docker.conf` | PHP-FPM pool config template (`##PHPVERSION##` placeholder) |
| `dep/xdebug.ini` | Xdebug config template (modified per install options) |
| `dep/opcache.ini` | OPcache config (copied verbatim to each PHP version) |
| `dep/phprun.sh` | Container entrypoint template (`##PHPVERSION##` placeholder) |
| `docker-compose-snippets/*` | Per-service compose fragments appended during install |
| `docker/nginx/site-templates/` | Nginx virtual host templates (one per framework) |
| `docker/docker-compose.yml` | Base compose file (nginx, redis, mail, network) |
| `version.sh` | Single `export VERSION=x.y.z` sourced by install.sh |

## Default Service Ports

| Service | Port(s) |
|---|---|
| HTTP | 80 (8080 if Varnish enabled) |
| HTTPS | 443 |
| MySQL 5.6 / 5.7 / 8.0 | 3305 / 3306 / 3308 |
| MongoDB | 27017 |
| Redis | 6379 |
| Elasticsearch 7/8 | 9200, 9300 |
| OpenSearch | 9201, 9301 |
| Mailtrap UI / SMTP | 8085 / 25 |
| MailHog UI / SMTP | 8025 / 1025 |
