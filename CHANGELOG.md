## 0.0.4 (2022-11-23)


*  install subversion on php74 for legacy projects
*  DEVENV-15 support .ssh volume for ssh keys and configs
*  Update bitbucket pipelines so main branch can run
*  Update bitbucket pipeline step indents



## 0.0.3 (2022-11-15)


*  Add mysqli extension to php74 for legacy itix projects



## 0.0.2 (2022-11-10)


*  Add data/shared/modules for easier module development
*  Bump version to 0.0.2 as latest master. From here on, develop branch will be used for active development



## 0.0.1 (2022-11-09)


*  reset nginx client buffer sizes
*  Provide a fresh bashrc file for each install to account for changed options
*  Long due changes to devctl
*  devctl update usage
*  post-installation message
*  Changes to nginx run.sh
*  updates to readme
*  multiple improvements, include sonarqube, add sonarqube to devctl and also fixes to installer (option to overwrite devctl if it already exists)
*  always reset permissions. Previous commit added .editorconfig
*  added mysql80 build
*  fix devctl syntax
*  remove old non-dialog installscript
*  allow arguments to docker-compose
*  Revert "allow arguments to docker-compose"
*  do not reset permissions recursively, that might take a very long time
*  update xdebug for php74 and php80
*  xdebug port can be 9003 for multiple php instances
*  add rsync to containers
*  sonarqube.yml should be moved too
*  numerous fixes, allow devctl up parameters
*  prefer bash over zsh
*  use decent ls command
*  update welcome message
*  cleanup unnecessary files
*  update magento nginx template site basename
*  prepare shopware
*  update shopware nginx conf - untested
*  replace enter script as well, useful if there possibly are changes
*  updated docker installation
*  make use of /data/shared/sites/media so project media does not get removed after project removal
*  reset ownership and media dir created elsewhere
*  force remove
*  devctl flushredis
*  add alias to sign commits
*  hostversions specific project
*  flushredis now accepts db number
*  update usage, flushredis accepts a param
*  combine status and ps patterns
*  update devctl for dockerdir
*  remove skip configurator instead of giving me a completely new blank file, as nvm would be missing after reinstallation
*  updated shopware nginx configuration
*  updated readme
*  loop folders to be created
*  indents
*  nginx config dir loop
*  do not need site-configs anymore, I think
*  xdebug can be the same for all php containers
*  uniformity between all enabled php containers, set run.sh for each selected containers. Manage run.sh from one spot now
*  add starship to bashrc
*  php80 should use 8.0 sock
*  php80 should use correct home folder
*  replace debian buster with alpine image, this is insanely fast
*  added playings folder, this is where I tinker around with alpine images
*  alpine playins, php74 functional but no nullmailer yet
*  update playings, cleanup php74
*  stop nginx before starting it
*  set permissions on nginx to prevent 500
*  update to debian bullseye-slim
*  php72 on bullseye-slim has issues with mssql tools. Disable mssql tools for php73 for now as we do not need it
*  always copy latest Dockerfiles to php install dir
*  update docker-compose.yml to version 3
*  log4j format msg no lookups vulnerability fix
*  Remove elasticsearch6, only use 7
*  nginx Dockerfile update to prevent permission denied sometimes thrown in magento admin when saving config
*  Revert installdirectory and add elasticsearch volume so we do not miss data
*  added docker-compose elasticsearch volume so data is persistent after recreation of container
*  Disable twofact auth on development server by default
*  Use xcom_network as custom network, bridged, so all hosts can be reached by hostname
*  add extra host for host.docker.internal via host-gateway (supported from docker v20.04 and up)
*  use host-gateway instead of docker0 ip
*  Set mailtrap as nullmailer remote
*  Run update-alternatives for php74
*  Varnish support
*  Fix magento caching application config value. 2 is Varnish
*  Update enter script to accomodate for other shells
*  always copy files in services to their respective folders
*  create service directory if it does not yet exist
*  Added php74-new based on php7.4fpm bullseye image from official php dockerhub, process changes in our own setup. Set XCOM_SERVERTYPE as fastcgi_param $_SERVER var so no magic has to be done in php fpm
*  Added php73-new based on php73 fpm bullseye image
*  Update necessary scripts related to preparing dev environment, php72 73 and 74 now use php-fpm-bullseye or buster image, instead of debian based with extra repositories
*  remove old playings
*  Update dockerfiles, extensions used were insufficient for some php versions
*  php81
*  Update php73 dockerfile to include sqlsrv for mssql connections
*  fixes for php73 mssql drivers
*  opcache.ini resulted in everything being heavily cached
*  added sqlsrv.ini to php73
*  Add xdebug.output_dir as fastcgi param so profiling can be done on a per-project basis. Just enable xdebug.mode=profile and it should work
*  xdebug profiler output name so request uri is visible, makes it easy to find correct cachegrind file
*  update nginx config, set php74 as default
*  php73 install imagick
*  run mysql80 on port 3306 as well, map 3308 to 3306 via compose
*  update devctl to include "tail" so container logs can be tailed
*  Updated readme as dialog is a required dependency and allow for "/" to be set as install directory
*  update hosts via devctl
*  Move nginx to official nginx:stable image
*  change nginx pid
*  update fastcgi so https is always on, this fixes redirect issues in magento admin
*  remove backslash from processwire template definition
*  processwire nginx config uses sitebasename/htdocs as site root
*  update_hosts to use tmp hosts for edits
*  Add new reload command to update /etc/hosts and restart nginx, useful when adding new projects
*  always add  devserver to /etc/hosts for react projects
*  changes to devctl update_hosts, introduce reload functionality to update hosts and restart nginx, overall quality of life improvements to devctl.
*  Install dialog saves values to sudo user .config/docker-setup.config file to read for a second run with existing values
*  Devctl close reload case
*  replace docker-compose with docker compose as compose is a docker argument now
*  Rework of install dialog so user is prompted less with inputs, simply use a checklist to gather necessary information
*  Prepare settings for varnish and xdebug
*  Handle config file with defaults correctly
*  Mass updates to installer, now also writes selected php version to config
*  Update devctl usage to include varnishacl
*  updates to phprun and xdebug
*  varnish vcl acl set to ip which can be updated via devctl
*  Update gitconfig to push current and create/track remote branch if not exist
*  move git config to function and add xdebug start with trigger
*  nvm new version
*  changes to nginx run.sh, cleanup the file a bit
*  QoL improvements to devctl
*  Prompt user for /etc/xcomuser if file is not found
*  echo subnet for varnishacl for the case it needs to be adjusted manually
*  xdebug is default yes
*  python2 is still required by some processwire projects
*  officially saying goodbye to php56, php70 and php71 as no projects use these anymore
*  DEVENV-12 Check if logging dir exists per site enabled
*  Add mongodb extension to php
*  Added script version



## 2.2.0 (2021-07-09)


*  get rid of redis-cli, redis-cli is part of redis container
*  update redis to 6.2
*  run update-alternatives in php73, after install it defaults to 8.0



## 2.1.0 (2021-07-09)


*  oh my zsh support
*  Fixes for oh-my-zsh and new enter file
*  multiple fixes for oh-my-zsh
*  php7.3 somehow installed 8.0, run update-alternatives to set to php73
*  add ES7 container and move ES6
*  Prepare php80
*  updated readme
*  improvements to installer
*  php80 support should now work
*  removed php56 and php70 from paths as those php versions are deprecated
*  Create a dialog installer
*  fixes to dialog installer
*  A few more improvements
*  Make inputbox cancellable
*  fix php paths
*  Seperate docker php snippets and append them to docker-compose.yml later after selection
*  install.sh deprecated, docker-compose still version 2
*  dialog improvements
*  cleanup unnecessary services and make sure nginx is part of services as well
*  some improvements to nginx conf
*  textual improvements to install dialog



## 2.0.0 (2021-03-13)


*  use debian buster instead of stretch



