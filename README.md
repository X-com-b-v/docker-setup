# Introduction

The development environment as provided works crossplatform on WSL2 (Debian-based distros with `apt` as package manager), Linux and MacOS.

# Installation

The following chapters describe on how to install the development environment on Linux. It is a lot like the process on WSL, but there is no virtualization layer as Docker is natively available for Linux.

## WSL

Microsoft announced WSL availability through the Windows Store. Simply search for `wsl` in the store and install Windows Subsystem for Linux. Afterwards, you can also install Debian via the store.

In order to actually enable WSL, run the following two commands in a cmd run as administrator:

`dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`

`dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`

Reboot your machine and enjoy the new WSL environment.

## Prerequisites

Docker (ce) with the docker compose plugin are required. You can also opt to use Docker Desktop on any of the supported platforms.
Packages `make` and `dialog` are required.

```bash
debian:
$ sudo apt install make dialog

MacOS:
$ brew install make dialog jq
```

## Clone repository
Run `git clone git@github.com:X-com-b-v/docker-setup.git ~/git/docker-setup` to clone the repository.

## Run the installer

When you successfully cloned the repository in the previous step, run `cd ~/git/docker-setup` and `make prepare` to install some necessary packages. Run `make` to run the installer. You will be greeted with a terminal based user interface.

Navigation might be a bit tricky: use the _arrow_ keys to move left/down/up/right, use _tab_ to highlight possibly different sections in a window, use the _spacebar_ to select specific options and press _enter / return_ to submit the field values. If you want to cancel, that can be done by using _tab_ to navigate to the cancel button in the bottom-right. Then press enter.

# Adding new hosts

Hosts can be added by entering any php container and run a git clone in the `/data/shared/sites` directory. Then, make sure you run a `composer install` in the cloned directory to install all necessary vendor modules. The `nginx` services provides a few site-templates which are used based on specific files in the cloned directory.

Exit the container and run `devctl reload` to update your hosts file and restart nginx. Nginx will then create a `.siteconfig` directory in the project folder which stores a few config files. Please check out these config files and remove `.example` if you need to make changes.

## Navigate to the project

The url slug is hardcoded at `.o.xotap.nl`. Based on the username you provided during the installation, projects can be navigated to via `https://project.username.o.xotap.nl`. You can also `cat /etc/hosts` after you've run `devctl reload` to see what URLs are created for your projects.

# Service port map

**Note:** Docker-compose has its own name resolving, so whenever you are in a container you can always use another container name to connect to it. So for example when you are in a php container and you want to connect to elasticsearch, you should use `elasticsearch` as the hostname instead of `localhost`.


|               Service name                |       Port local        | Port container |                                                                    Remarks                                                                    |
|:-----------------------------------------:|:-----------------------:|:--------------:|:---------------------------------------------------------------------------------------------------------------------------------------------:|
|                   nginx                   | 80 [8080 if varnish enabled] |       80       |                                  When Varnish is enabled, nginx port changes to 8080 and Varnish takes port 80.                                  |
|                                           |           443           |      443       | HTTPS traffic                                                                                                                                               |
|                  apache                   |           N/A           |      N/A       | No exposed ports. Used internally via nginx proxy for ProcessWire projects requiring .htaccess |
|                  mysql56                  |          3305           |      3306      | MySQL 5.6 (Deprecated)                                                                                                                      |
|                  mysql57                  |          3306           |      3306      | MySQL 5.7 (Deprecated)                                                                                                                      |
|                  mysql80                  |          3308           |      3306      | MySQL 8.0 (Current)                                                                                                                                   |
|                   mongo                   |         27017           |     27017      | MongoDB 6.0 (Optional)                                                                                                                                  |
|                   redis                   |          6379           |      6379      | Redis cache server                                                                                                                                               |
|                  mailhog                  |          1025           |      1025      | SMTP server for mail testing                                                                  |
|                                           |          8025           |      8025      | MailHog web interface                                                                     |
|                 mailtrap                  |          8085           |       80       | Mailtrap web interface                                                                     |
|                                           |           25            |       25       | SMTP server for mail testing                                                                |
|              elasticsearch7               |          9200           |      9200      | Elasticsearch 7 (for Magento <= 2.4.6-p3). **Cannot run simultaneously with elasticsearch8**                                                                                                  |
|                                           |          9300           |      9300      |                                                                                                                                               |
|              elasticsearch8               |          9200           |      9200      | Elasticsearch 8 (for Magento >= 2.4.6). **Cannot run simultaneously with elasticsearch7**                                                                                                     |
|                                           |          9300           |      9300      |                                                                                                                                               |
|                opensearch                 |          9201           |      9200      | OpenSearch (for Magento >= 2.4.8). Alternative to Elasticsearch                                                                                                          |
|                                           |          9301           |      9300      |                                                                                                                                               |
|                varnish-magento            |           80            |       80       | Varnish for Magento 2 with magento2.vcl. When enabled, nginx moves to 8080. |
|                varnish-craft              |           81            |       80       | Varnish for Craft CMS with craft.vcl. Alternative to varnish-magento. |
| php70 php72 php73 php74 php80 php81 php82 php83 php84 |           N/A           |       N/A       |                         No exposed ports. All PHP traffic routed through nginx/varnish via Unix sockets.                          |

## Varnish Caching

Varnish is an optional HTTP accelerator that can be enabled during installation. The setup provides two framework-specific Varnish services:

### Service Configuration
- **varnish-magento**: Host port 80 → container port 80, uses `magento2.vcl`
- **varnish-craft**: Host port 81 → container port 80, uses `craft.vcl`
- **Internal communication**: Both services accessible as `service:80` within Docker network
- **External access**: `localhost:80` (magento) or `localhost:81` (craft)

### Framework Support
- **Magento 2 (varnish-magento)**: 
  - Full page caching with GraphQL support
  - Tag-based purging via X-Magento-Tags-Pattern
  - ESI processing for dynamic content
  - When enabled, nginx moves to port 8080
- **Craft CMS (varnish-craft)**:
  - ESI support for edge-side includes
  - Admin/action URL bypass
  - Custom TTL for static files (CSS/JS: 1d, Images: 1w, Fonts: 1y)
  - Accessible on port 81

### Cache Management
- `devctl flushvarnish [url]`: Purge specific URLs
- `devctl varnishacl`: Update ACL with Docker network subnet
- VCL files located in `docker/varnish/` directory

## Mailtrap

Mailtrap is used to catch mail locally. Unless an SMTP server is configured for a project, all mail sent via the php `mail()` (which is used by most frameworks) will be caught by mailtrap. You can navigate to mailtrap via `http://devserver:8085` and login by using `mailtrap` for both username and password.

## Mailhog

Mailhog is used to catch mail locally. Unless an SMTP server is configured for a project, all mail sent via the php `mail()` (which is used by most frameworks) will be caught by mailhog. You can navigate to mailhog via `http://devserver:8025`.

# Control your development environment

In order to run basic commands against the development environment, there are `enter` and `devctl` scripts. `devctl` is short for development control, whereas `enter` will let you log in to any of the running containers and give you a shell.

## Scripts

Scripts are placed in `$HOME/.local/bin` and if you see the notice `devctl` or `enter` commands are not found, please add the following to your `$HOME/.bashrc` file:

### Windows

```sh
if [ -d $HOME/.local/bin ]; then
    PATH="$PATH:$HOME/.local/bin"
fi
```

### MacOS

```sh
if [ -d $HOME/.local/bin ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
```

### Devctl

When running `devctl` without any parameters, the help function will be displayed:

```
Usage: /home/user/.local/bin/devctl [options]
All commands are executed in context of /home/user/x-com/docker
Options:
                        | Show this help
up [containers]         | Create and daemonize containers. Start existing containers
restart [containers]    | Restart containers
stop [containers]       | Stop containers.
start                   | Start all built containers
status|ps               | Shows running status of all containers managed by this docker-compose file (ps -a)
build [containers]      | Build containers in docker-compose file
installdir              | Shows current install directory
dockerdir               | Shows current docker directory
varnishacl              | Update the varnish vcl with docker_xcom_network ip/subnet
flushredis [db]         | Flush redis completely, or a single db
flushvarnish [url]      | Flush varnish url
tail [container]        | Tail container logs
updatehosts             | Update hostfile
reload                  | Updates hostfile and restarts nginx
recreate [containers]   | Force recreate containers. Usefal after enabling/disabling Xdebug
```

Most options will speak for themselves.

### Enter

When running `enter` without any parameters, the script will show the running docker containers from the dev environment:

```
No arguments provided
docker-php73-1
docker-php74-1
docker-php80-1
docker-php81-1
docker-php82-1
docker-php83-1
docker-php84-1
docker-nginx-1
docker-varnish-1
docker_elasticsearch7_1
docker_mailtrap_1
docker_mailhog_1
docker_redis_1
docker_mysql57_1
docker_mysql80_1
```

you will only need to use the docker compose service name to exec into a container. For example, to enter `docker-php74-1`, `enter php74` will suffice.
