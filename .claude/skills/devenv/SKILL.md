---
name: devenv
description: Use when working with the X-com Docker development environment — managing PHP containers, sites, databases, caching, Xdebug, or diagnosing container issues.
allowed-tools: Bash(devctl *) Bash(enter *) Bash(nginx-sites) Bash(docker *) Read Write Edit
argument-hint: "[task or issue description]"
---

You are helping manage the X-com Docker development environment.

## Current state

!`devctl status 2>/dev/null || echo "(devctl not available — is the environment installed?)"`

## Key commands

| Command | Effect |
|---|---|
| `devctl up [containers]` | Start containers |
| `devctl stop [containers]` | Stop containers |
| `devctl restart [containers]` | Restart containers |
| `devctl recreate [containers]` | Force recreate (after config/Xdebug changes) |
| `devctl reload` | Regenerate nginx site configs + reload nginx |
| `devctl tail [container]` | Follow container logs |
| `devctl flushredis [db]` | Flush Redis (all or specific db) |
| `devctl flushvarnish [url]` | Purge Varnish for URL |
| `devctl build [container]` | Rebuild image without cache |
| `devctl ps / status` | Show container status |
| `enter [container]` | Open shell in container |
| `nginx-sites` | Regenerate nginx/apache site configs only |

Container names: `nginx`, `php81`, `php82`, `php83`, `php84`, `php85`, `mysql80`, `mysql57`, `redis`, `elasticsearch7`, `elasticsearch8`, `opensearch`, `mailtrap`, `mailhog`

## Sites

Projects live in `/data/shared/sites/<project-name>/`. After adding a project, run `devctl reload` to update hosts and nginx config. Site URLs follow `<project-name>.<username>.o.xotap.nl`.

Framework auto-detection (first match wins):

| File present | Framework | Webserver | PHP |
|---|---|---|---|
| `/bin/magento` | Magento 2 | nginx | latest |
| `/app/etc/local.xml` | Magento 1 | nginx | 7.4 |
| `/web/` dir | Craft CMS | nginx | latest |
| `/htdocs/wire/` dir | ProcessWire | apache | latest |
| `/artisan` | Laravel | nginx | latest |
| `/htdocs/` dir | Generic | apache | latest |

Override via `<project>/.siteconfig/config.json`, e.g.:
```json
{"template":"magento2","webserver":"nginx","php_version":"8.3"}
```

Available templates: `magento2`, `magento2-varnish`, `magento`, `craft`, `craft-varnish`, `laravel`, `processwire`, `drupal9`, `symfony`, `symfony4`, `shopware`, `default`

## Nginx / Apache config generation

`nginx-sites` (called by `devctl reload`) scans every subdirectory of `/data/shared/sites`, auto-detects the framework, and writes configs to:
- `<installdir>/docker/nginx/sites-enabled/<site>.conf`
- `<installdir>/docker/apache/sites-enabled/<site>.conf` (Apache sites only)

**Config selection priority for nginx** (first match wins):
1. `.siteconfig/nginx.conf` — custom override, used as-is
2. `proxy.conf` template — used when `webserver=apache` (nginx proxies to Apache on port 8888)
3. Template matching `webserver` field from `.siteconfig/config.json` (e.g. `magento2.conf`)
4. `default.conf` fallback

**Config selection priority for apache** (first match wins):
1. `.siteconfig/apache.conf` — custom override
2. Template matching `template` field (e.g. `processwire.conf`)
3. `default.conf` fallback

After writing, placeholders are substituted in the generated config file:

| Placeholder | Replaced with |
|---|---|
| `##SITEBASENAME##` | Directory name of the project |
| `##USE_PHPVERSION##` | Resolved PHP version (e.g. `84`) |
| `##DOMAIN##` | `.username.o.xotap.nl` |
| `##XCOMUSER##` | Username from config |
| `##PROJECTSLUG##` | Domain suffix (`.o.xotap.nl`) |
| `##INCLUDE_PARAMS##` | Inlined `params.conf` include (Magento/Craft only) |
| `##WEBPATH##` | `/data/shared/sites` |

**Per-site customization files** (in `<project>/.siteconfig/`):

| File | Purpose |
|---|---|
| `config.json` | Override framework/webserver/PHP detection |
| `nginx.conf` | Full custom nginx vhost (replaces template) |
| `apache.conf` | Full custom apache vhost (replaces template) |
| `params.conf` | Extra `fastcgi_param` lines (Magento/Craft — included via `##INCLUDE_PARAMS##`) |
| `nginx.conf.example` | Last generated nginx config — safe to copy and customise |
| `apache.conf.example` | Last generated apache config — safe to copy and customise |
| `params.conf.example` | Generated params template with store URLs |

**Activating `params.conf` for Magento 2:**
Every `nginx-sites` run writes a fresh `params.conf.example` containing `fastcgi_param` lines for base URLs, secure URLs, and cookie domain per store. Copy it to `params.conf` to activate it — nginx will include it inside the PHP location block via `##INCLUDE_PARAMS##`. The example is regenerated each run so it reflects the current domain; your live `params.conf` is never overwritten.

```bash
cp .siteconfig/params.conf.example .siteconfig/params.conf
devctl reload
```

Site logs are at `<project>/logs/access.nginx.log` and `<project>/logs/error.nginx.log`, truncated to the last 1000 lines on each `nginx-sites` run.

## Ports

| Service | Host port(s) |
|---|---|
| HTTP | 80 (8080 if Varnish) |
| MySQL 5.7 / 8.0 | 3306 / 3308 |
| Redis | 6379 |
| Elasticsearch 7 / 8 | 9202 / 9200 |
| OpenSearch | 9201 |
| Mailtrap UI | 8085 |

## Task

$ARGUMENTS
