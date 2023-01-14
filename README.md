# Install
## Dependencies
You will need [Docker CE](https://docs.docker.com/engine/install/ubuntu/) installed.

The installer requires `dialog` and `make`, this can be installed via `sudo apt install dialog make`

## Run the install script
* Run the installscript with `sudo`. The installer will prompt you for this if you're not root.
* In order to select options during installer dialog, use the `spacebar` to select or deselect them.
* The installscript will ask you for a location where you want to install, defaults to /home/user/x-com
```bash
$ chmod +x install-dialog.sh
$ make prepare
$ make
```
The installer will automatically install needed packages on your system if you tell it to (advised for first run). It will also create necessary folders based on the chosen install path.  
 It is important to note that references to `xcomuser` in all documents refer to your base user which you used to run the script with. For example, my username in Linux is `mycha` and this name will be used as `xcomuser`.  

## Devctl
Devctl is small tool which helps managing containers. After installation, you can run `devctl build` to build all containers.

## Sonarqube
There's a separate sonarqube.yml file which will download and give you a sonarqube instance linked to a postgres db. Run this by using `docker-compose -f sonarqube.yml up -d`

## Adding new hosts
You can simply run `devctl reload` to update the hosts and restart nginx, so all vhosts are created.

## Running xdebug
xDebug will work when configuring PHPStorm correctly. There's a few things of note here. The current setup expects you to run docker version 20.04+ (check with `docker -v` to see current version). More information on why can be found below (the `extra_hosts` part).

To configure xdebug connection in PHP storm, add a new configuration 

![Config1](https://i.imgur.com/lqZ7RnI.png)

Click + and in the dropdown list select PHP Remote Debug. 

![Config2](https://i.imgur.com/Rtrj8Of.png)

Give it a name and select "Filter debug connection by IDE key". 
As IDE key (session id) fill in PHPStorm. 

![Config3](https://i.imgur.com/nEvxQF6.png)

Next, click the three dots next to Server. Create a new server and fill in the information as such:

![Config4](https://i.imgur.com/TIU8kDZ.png)

Make sure the server is selected. Click apply and OK. Next go to your settings by pressing CTRL + ALT + S click on "PHP" in the left sidebar.

Switch the PHP language level to whatever level your project is supposed to be (php 7.3 is default for newly created hosts)

Next, click the three dots next to CLI interpreter, click + (From Docker, VM, Vagrant etc). In the popup, click on the Docker radio button and choose the correct Image name from the dropdown list. This should be the same docker image as your PHP language level. Click OK and next to the name, uncheck "Visible only for this project" as you can share these between projects. Click Apply and OK. Next, click on the folder icon next to "Docker container". Click on the first entry in the small table you see, followed by the pencil icon. Change the container path from /opt/project to /data/shared/sites/<projectname>

![Config5](https://i.imgur.com/CAreP8F.png)

The PHP containers contain
```
extra_hosts:
      - "host.docker.internal:host-gateway"
```
in the `docker-compose.yml` file. If, for some reason you cannot get a connection with xDebug, it's because the `xdebug.client_host` (in `/etc/php/<version>/mods-available/xdebug.ini`) cannot resolve to the correct IP. In order to correct this, you must change the line above to
```
extra_hosts:
      - "host.docker.internal:172.17.0.1"
```
because `172.17.0.1` is the default `docker0` ip. You can validate this by running `ip address` in your terminal, output:
```
4: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:88:c7:0f:72 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:88ff:fec7:f72/64 scope link
       valid_lft forever preferred_lft forever
```

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

