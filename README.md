# Install
This installscript is meant for Linux only. For Windows, use Kim Peeters' installation script using the command below:
```
git clone https://xcom-ro:xco5991@bitbucket.org/X-com/devserver.git /docker
```
## Dependencies
You will need [Docker](https://docs.docker.com/install/) and [Docker-compose](https://docs.docker.com/compose/install/) installed.

## Run the install script
* Run the installscript with sudo, not as logged in root user. This will create the `/etc/xcomuser` file with your current username
* The installscript will ask you for a location where 
```bash
$ chmod +x install
$ sudo ./install
```
The installscript will automatically install the packages you need. It will create the necessary folders based on your preferred installation dir (I advice to simply use a subdirectory in your home folder).  
The script will copy all files in this directory to your chosen installation path.

## Docker-compose
After the installscript did its work, you will now be in the installdir/docker directory. All you have to do is run `sudo docker-compose up -d`. This will build and run your created containers. Take a cup of coffee, this might take a while.

## Adding new hosts
You can simply add new hosts by adding the project folder (or git clone the project) to the `installdir/data/shared/sites/` directory. After this, go back to the `installdir/docker` directory and run `sudo ./devctl nginxrestart` (or run `docker-compose restart nginx`) to restart the nginx container so new hosts are found and added. You can access the new host by using this url: `http://<host>.<xcomuser>.o.xotap.nl

## X-Com DNS and accessing your hosts
### Internal network
If you are in the X-Com network, a DNS entry probably already is created so you will not have to edit your `/etc/hosts` file in order to access your project. Just browse to the url configured based on your project name directory and `/etc/xcomuser` file, an example:  
`magento2.mycha.o.xotap.nl`

### No DNS or internal network
If you are working from home or any other location, you will need to fetch your current NAT IP address (192.168.x.x for example) and add the host manually to your `/etc/hosts` file. An example on my end:
```
192.168.2.185 magento2.mycha.o.xotap.nl
```
Open a web browser and browse to `magento2.mycha.o.xotap.nl`. This can of course be any host you added.

## Run commands
In order to run commands, you could access the docker containers directly and use `php` commands there. I like to have all php software on my local machine so I don't have to run all commands from docker. To do this, you will need all [Magento's required php dependencies](https://devdocs.magento.com/guides/v2.3/install-gde/system-requirements-tech.html#required-php-extensions) on your machine.


### Run commands in container
To execute commands on the commandline you need to login a specific PHP container. Otherwise no php executable will be available. Here you can also use/install npm, bower, grunt, gulp composer e.t.c.

From within the installdir/docker directory:

```bash
$ docker-compose exec php56 bash
```
From anywhere on your machine, using normal docker:
```bash
# get list of running containers
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
f5408d1ec3cd        docker_php56        "/run.sh"                3 hours ago         Up 3 hours                              docker_php56_1

# php5.6 container through container ID
docker exec -ti  f5408d1ec3cd /bin/bash

# to exit them, just:
exit
or press CTRL+D
```

## Container maintenance
There is no active maintenance on the docker-compose file. Maybe I will add it as a private repo on bitbucket so it is accessible for everyone within the team. So if you want to update the containers, you have to manually copy/paste the docker-compose file to your installdir/docker directory and run `docker-compose build` and `docker-compose up -d` again.

### Sidenotes
- You can add your own user to the `docker` group so you won't need to use sudo every time. Although this is not encouraged
- You can use a database manager like mysql-workbench or dbeaver to easily access mysql instances (my personal preference goes to dbeaver as workbench tends to crash often).

