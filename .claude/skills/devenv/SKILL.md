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

| File present | Framework | PHP |
|---|---|---|
| `/bin/magento` | Magento 2 | latest |
| `/app/etc/local.xml` | Magento 1 | 7.4 |
| `/web/` dir | Craft CMS | latest |
| `/htdocs/wire/` dir | ProcessWire | latest |
| `/artisan` | Laravel | latest |
| `/htdocs/` dir | Generic/Apache | latest |

Override via `<project>/.siteconfig/config.json`, e.g.:
```json
{"template":"magento2","webserver":"nginx","php_version":"8.3"}
```

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
