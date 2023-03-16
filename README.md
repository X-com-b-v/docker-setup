# Introduction

The development environment as provided works crossplatform on WSL2 (Debian-based distros with `apt` as package manager), Linux and MacOS.

# Installation

_TODO describe ssh-keygen if not done so, clone project and run the installer_

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
$ brew install make dialog
```

## Create ssh keys and clone repository
If you have not created ssh keys before, run `ssh-keygen` to generate a private/public keypair. Login to Bitbucket and upload your public key. This should allow you to use `git clone git@bitbucket.org:x-com/docker-setup.git ~/git/docker-setup` to clone the repository.

## Run the installer

When you successfully cloned the repository in the previous step, run `cd ~/git/docker-setup` and `make prepare` to install some necessary packages (**Note: this only works on Debian related distros! Not on macOS or ArchLinux)**. Run `make` to run the installer. You will be greeted with a terminal based user interface.

Navigation might be a bit tricky: use the _arrow_ keys to move left/down/up/right, use _tab_ to highlight possibly different sections in a window, use the _spacebar_ to select specific options and press _enter / return_ to submit the field values. If you want to cancel, that can be done by using _tab_ to navigate to the cancel button in the bottom-right. Then press enter.

# Adding new hosts
Hosts can be added by entering any php container and run a git clone in the `/data/shared/sites` directory. Then, make sure you run a `composer install` in the cloned directory to install all necessary vendor modules. The `nginx` services provides a few site-templates which are used based on specific files in the cloned directory.

Exit the container and run `devctl reload` to update your hosts file and restart nginx. Nginx will then create a `.siteconfig` directory in the project folder which stores a few config files. Please check out these config files and remove `.example` if you need to make changes.

## Navigate to the project
The url slug is hardcoded at `.o.xotap.nl`. Based on the username you provided during the installation, projects can be navigated to via `https://project.username.o.xotap.nl`. You can also `cat /etc/hosts` after you've run `devctl reload` to see what URLs are created for your projects.

# Service port map
**Note:** Docker-compose has its own name resolving, so whenever you are in a container you can always use another container name to connect to it. So for example when you are in a php container and you want to connect to elasticsearch, you should use `elasticsearch` as the hostname instead of `localhost`.

|       Service name      |        Port local       | Port container |                                                                    Remarks                                                                    |
|:-----------------------:|:-----------------------:|:--------------:|:---------------------------------------------------------------------------------------------------------------------------------------------:|
| nginx                   | 8080 [80 if no varnish] | 80             | If you chose to use varnish, the local exposed port will be 8080 for nginx.                                                                   |
|                         | 443                     | 443            |                                                                                                                                               |
| apache                  |                         | 8888           | Apache is used by certain processwire projects where htaccess is required. The request comes from nginx and is proxy passed through to apache |
| mysql57                 | 3306                    | 3306           |                                                                                                                                               |
| mysql80                 | 3308                    | 3306           |                                                                                                                                               |
| redis                   | 6379                    | 6379           |                                                                                                                                               |
| mailtrap                | 8085                    | 8085           |                                                                                                                                               |
|                         | 25                      | 25             |                                                                                                                                               |
| elasticsearch           | 9200                    | 9200           |                                                                                                                                               |
| varnish                 | 80                      | 80             | Varnish is optional during installation. Useful for Magento caching.                                                                          |
| php73 php74 php80 php81 |                         |                | For all php containers there are no exposed ports, as everything goes through varnish/nginx.                                                  |          |                                                                                                                                               |

## Mailtrap
Mailtrap is used to catch mail locally. Unless an SMTP server is configured for a project, all mail sent via the php `mail()` (which is used by most frameworks) will be caught by mailtrap. You can navigate to mailtrap via `http://devserver:8085` and login by using `mailtrap` for both username and password. 

# Control your development environment
In order to run basic commands against the development environment, there are `enter` and `devctl` scripts. `devctl` is short for development control, whereas `enter` will let you log in to any of the running containers and give you a shell.

## Scripts
### Devctl
When running `devctl` without any parameters, the help function will be displayed:

```
Usage: /home/mycha/.local/bin/devctl [options]
All commands are executed in context of /home/mycha/x-com/docker
Options:
                        | Show this help
up [containers]         | Create and daemonize containers. Start existing containers
restart [containers]    | Restart containers
stop [containers]       | Stop containers.
start                   | Start all built containers
status|ps               | Shows running status of all containers managed by this docker-compose file (ps -a)
build [containers]      | Build containers in docker-compose file
hostversions [projects] | Show project used PHP versions
installdir              | Shows current install directory
dockerdir               | Shows current docker directory
sonarqube [options]     | Manage sonarqube and postgres instances
varnishacl              | Update the varnish vcl with docker_xcom_network ip/subnet
flushredis [db]         | Flush redis completely, or a single db
flushvarnish [url]      | Flush varnish url
tail [container]        | Tail container logs
updatehosts             | Update hostfile
reload                  | Updates hostfile and restarts nginx
```

Most options will speak for themselves.

### Enter
When running `enter` without any parameters, the script will show the running docker containers from the dev environment:

```
No arguments provided
docker-php74-1
docker-php73-1
docker-nginx-1
docker-varnish-1
docker_elasticsearch_1
docker_mailtrap_1
docker_redis_1
```

you will only need to use the docker compose service name to exec into a container. For example, to enter `docker-php74-1`, `enter php74` will suffice.
