# Install
## Dependencies
You will need [Docker](https://docs.docker.com/install/) and [Docker-compose](https://docs.docker.com/compose/install/) installed. You can let the script try and do this for you, but it's better if you do it manually as the function is untested.

## Run the install script
* Run the installscript with `sudo`. The installer will prompt you for this if you're not root.
* The installscript will ask you for a location where you want to install, defaults to /home/user/x-com
```bash
$ chmod +x install-dialog.sh
$ sudo ./install-dialog.sh
```
The installer will automatically install needed packages on your system. It will also create necessary folders based on the chosen install path.  
It is important to note that references to `xcomuser` in all documents refer to your base user which you used to run the script with. For example, my username in Linux is `mycha` and this name will be used as `xcomuser`.

## Devctl
Devctl is small tool which helps managing containers. After installation, you can run `devctl build` to build all containers.

## Sonarqube
There's a separate sonarqube.yml file which will download and give you a sonarqube instance linked to a postgres db. Run this by using `docker-compose -f sonarqube.yml up -d`

## Adding new hosts
You can simply add new hosts by adding the project folder (or git clone the project) to the `installdir/data/shared/sites/` directory. 
Run `devctl restart nginx` from your machine, or go back to the `installdir/docker` directory and run `docker-compose restart nginx` to restart the nginx container so new hosts are found and added. You can access the new host by using this url: `http://<host>.<xcomuser>.o.xotap.nl` after adding them to your `/etc/hosts` file. See the next chapter

## Accessing your hosts
Since we are working on linux and docker uses the native host, you can simply add entries mapped to localhost in your /etc/hosts file. `127.0.0.1 <host>.<xcomuser>.o.xotap.nl`.
Open a web browser and browse to `<host>.<xcomuser>.o.xotap.nl`. This can of course be any host you added.

### Run commands in container
To execute commands on the commandline you need to login a specific PHP container. Otherwise no php executable will be available. Here you can also use/install npm, bower, grunt, gulp composer e.t.c.

Easiest is to use the `enter` script which is placed in `/usr/local/bin`:
```bash
enter php72
```

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
Whenever I have time I will make updates to this repository. You can always re-run the installer, it should not break your existing installation. Do however choose all PHP options you've previously selected as well, otherwise they will be excluded from your docker-compose file after the installer has done its work.

### Sidenotes
- You can add your own user to the `docker` group so you won't need to use sudo every time. (According to the internet, this is discouraged but I still do it)
- You can use a database manager like mysql-workbench or dbeaver to easily access mysql instances (my personal preference goes to dbeaver as workbench tends to crash often). You could also use integrated db manager in PHPStorm (which is a small version of DataGrip or so it seems)

