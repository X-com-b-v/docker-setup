## 0.1.7 (2023-06-15)


* a94b110 Restore global config clarification
* 79ecfda Move check for skipping sample file into separate if, otherwise replaceholdervalues are not updated



## 0.1.6 (2023-06-14)


* 592e92a DEVENV-35 add percona as dropin replacement for mysql8
* c2987f2 Updated php81 dockerfile to include rsync and mariadb-client
* 4efd0da Update percona volume so percona correctly loads config files
* 56a18b9 Added platform: linux/amd64 for m1 silicon compatibility (probably forces it over rosetta)
* 8b6ff33 Force recreate containers after running installer again, this applies new xdebug settings
* 47e8b26 Update gitconfig lg alias to display time better
* 84838a7 DEVENV-39 prioritise use of nginx.conf if found, even if webserver is configured as apache
* bab0155 DEVENV-39 skip sample file creation outside while loop body if we have nginx conf but apache is configured for specific host



## 0.1.5 (2023-05-01)


* abc6420 Updates to firstrun, apache sites enabled permissions and global config clarification



## 0.1.4 (2023-05-01)


* 4c6597d When installdir is /, make sure data and docker dirs are created and permissions are set



## 0.1.3 (2023-04-03)


* 3215750 With the change for docker-compose stack name, added the option to cleanup old docker containers using docker compose down



## 0.1.2 (2023-04-03)


* 01ca999 Change docker-compose stack name to "x-com". This requires running "docker compose down" before running the installer again, so containers in the old "docker" stack are removed
* 3aa83d0 Echo error output of rm dir cmd to /dev/null
* be5b74d Write latest php version to config and use that version if config file contains php version latest



## 0.1.1 (2023-03-28)


* 108a55c Add elasticsearch env variables and only add volume if elasticsearch is selected



## 0.1.0 (2023-03-27)


* aed2de5 Bump version to 0.1.0 as this version is pretty complete functionality-wise
* 219c211 Update nginx-sites, remove existing configs before loop so I do not end up with only 1 site enabled



## 0.0.19 (2023-03-26)


* 015e9a7 Updates to php80 and php81, push php80 image to registry
* c6ea8e9 Bump version to 0.0.19
* 8c60e23 Pull latest images after install
* efb41c9 Ask for cleanup of php home directories, defaults to no
* 2a5ea9b Update bitbucket pipelines to include all *.sh shell scripts
* 17e3fac move devctl and enter scripts to their .sh file types so shellcheck checks them too
* b01608f Show devenv version when running devctl without args
* ed22179 Update devctl to also include pull command
* 219e6e3 Added gitlab ci file, will not work yet



## 0.0.18 (2023-03-24)


* e640229 Bump version to 0.0.18
* 0264b47 DEVENV-32 updates to phprun for shellcheck
* a4c93a1 DEVENV-33 optimize nginx run script
* 8b1c541 DEVENV-30 get rid of samba
* 8e7be7f DEVENV-33 optimize nginx sites script, remove logic from apache run as well
* 1d207ac DEVENV-34 update changelog hash
* 4a94c3b Updated readme to include devctl or enter command not found
* bbf6d4b Updated the installer to show a welcome dialog and a link to the documentation after completion
* 5a3e91f Update nginx-sites.sh script so rm warnings are not shown
* 91a5ac8 Update install.sh so shellcheck passes, quote $FIRSTRUN



## 0.0.17 (2023-03-21)


* 19ef93a Apache also has to adhere to optional project slug change
* 842c1ef Bump version to 0.0.17
* cb8dfd9 Remove all ~/ references and replace them with $HOME
* 1f40aad docker compose up also removes orphans in case you deselected a previous option, helps keeping things clean
* bc4b151 DEVENV-30 add syncthing as a possible replacement for samba, so tortoiseSVN can maybe be used again
* 7220bad Revert "DEVENV-30 add syncthing as a possible replacement for samba, so tortoiseSVN can maybe be used again"
* 00be848 Rename install-dialog to just install as it is the only installer now
* 5e88912 Use shellcheck.net to fix shell syntax issues
* 7c0dec5 Write gitconfig username with quotes so it is interpreted as string
* 01a6a0d DEVENV-31 update bitbucket-pipelines
* 6a096b8 DEVENV-31 syntax fixes in install script



## 0.0.16 (2023-03-18)


* af1d07f Create .ssh directory in $HOME instead of /home/$USER for cross platform compatibility
* 4d2ef90 Updated readme file
* e7925b0 "devctl version" now shows current installed version
* 53b61ac Save gitconfig information to config file as well
* 221cf1c Allow to change project slug as some modules allow development at .local domains
* 29c633c Installer cleanup, make sure correct project version is used and use $HOME instead of ~
* cfe6dd3 When complete, run docker compose up --build -d to build an daemonize containers
* e1f4f38 Nginx volume map docker-setup.config to different location



## 0.0.15 (2023-03-16)


* 238fc5f devctl reload restarts apache on a new line to prevent docker compose exiting with statuscode because apache does not exist
* a17b1b0 Create ~/.local/bin if dir doesnt exist
* a1682c0 Refer to $HOME for devctl updatehosts and also update install dialog to get php path to uppercase
* 1bfdb0e Use awk to uppercase the first letter for $USER as default username
* 7bfc865 Write current devenv version to config file so I know what version is used when needing to debug something



## 0.0.14 (2023-03-13)


* f26d135 Rename apachelogs to logs so we have a single log dir
* bf2766f Prefill gitconfig username with $USER
* 9819040 update samba config
* 64f93c2 DEVENV-9 fix nginx run.sh
* ed7bfcb devctl build specific contains with no-cache
* 897d5b0 DEVENV-9 prepare nginx webpath, update apache run.sh to use $installdir as well
* db98bfc Cleanup directories when exiting script early
* b854281 Set default installdir to $HOME/x-com
* 5ea16d9 DEVENV-24 fixes voor apache



## 0.0.13 (2023-03-06)


* 2691312 bump version to 0.0.13
* 354f5a0 DEVENV-9 fix where folders are not created when target installdir is a place where elevated permissions are required



## 0.0.12 (2023-03-06)


* b321330 Bump version to 0.0.12 and update the way config file is written to
* b434776 php72 with ioncube
* b0e059f Update magento2-varnish nginx template so listen 443 ssl works
* 1037730 Update varnish compose snippet
* 948ed4d mysql56 legacy for yoeri
* 6c8eeea fix gitconfig
* 0904646 remove readonly from ssh volume mapping so container can write to known_hosts
* 61dff60 add ulimits for mysql to limit mem usage on arch
* 2373c10 Add apache logs to project in apachelogs dir. When apache is set in siteconfig config.json always use proxy template despite what nginx.conf says
* 269eb0e DEVENV-9 allow installer to be run without root/sudo
* 6f749e5 DEVENV-9 optimizations to installer, created new images because phprun script got updated



## 0.0.11 (2023-01-30)


* 86160af Rework some docker snippets, updates to nginx run
* d4247b6 Update personalization, still under preparation
* d8390d8 Make elasticsearch a setting
* b67f539 Fix apache dockerfile
* 7b0f702 Added php70 legacy without xdebug, mongo and imagick
* 34e6317 Prepare docker compose image builds
* 26146c5 Bump version to 0.0.11
* f903903 Docker images on dockerhub with xdebug enabled but via trigger
* 9895d93 Mailtrap github repo is now forked by myself, updated to php8.1 with roundcube 1.6.1 interface
* 731c6e5 Updated mailtrap container port as that no longer runs on 8085 but simply 80
* fb1d0c5 xdebug config is now volume mapped, default comes from image but this is an easy way to overwrite
* 8626117 php81 now also uses image
* d0ede36 added gitignore



## 0.0.10 (2023-01-16)


* 382e855 DEVENV-17 php74 should also include sqlsrv for mssql connections (profilplast), and pin xdebug version for old version as latest xdebug has dropped support for php7
* 9b84c43 Bump version to 0.0.10
* 74b4469 specifiy xdebug version for php72
* af12691 Updated proxyport
* edd6106 Updated readme
* 3d830f6 Added mongo via installer
* 7c8ae5f DEVENV-25 add mysqli and DEVENV-22 install mongodb with libssl-dev to enable libmongoc SSL
* 4dea318 DEVENV-22 mongodb default user/pass are root/xcom
* a342991 DEVENV-24 htdocs/updateinfo should always use apache
* 3d261fa Added makefile, updated editorconfig and automatically create containers at the end of installation if user wants to
* f5c9475 Updates to makefile, apache and nginx run
* 5e588c8 Apache using bullseye-slim and remove some dependencies that will probably not be used
* 0ff7fee Pin mongo to version 6 and updated mongo volumes
* 251f4ca add imagick



## 0.0.9 (2023-01-10)


* 78f759d Updated install dialog script
* dd94521 DEVENV-14 add samba



## 0.0.8 (2023-01-10)


* d8677f4 DEVENV-18 prepare moving of personalizations
* 5812787 update development version to 0.0.7
* 762baf3 DEVENV-19 prepare apache
* 8ee42c2 bump version to 0.0.8



## 0.0.7 (2022-12-14)


* 5aa9ac5 Updated gitconfig
* d5f8d4d Added license.md
* b520ac6 zz-docker can be a global dependency as except for phpversion everything is the same, installer updated to update phpversion with sed
* 649ef9c update development version to 0.0.7



## 0.0.6 (2022-11-23)


* b797e02 DEVENV-15 ssh volume read only on target container
* 2ccca5d DEVENV-15 Version 0.0.6 will be used



## 0.0.5 (2022-11-23)


* 8eb2198 Check if tag exists when a PR from develop is openend
* 7192cc3 Bump version to 0.0.5 to validate PR pipeline



## 0.0.4 (2022-11-23)


* ca2cbd2 install subversion on php74 for legacy projects
* 024b5e2 DEVENV-15 support .ssh volume for ssh keys and configs
* d3aa5a7 Update bitbucket pipelines so main branch can run
* 0b2c3da Update bitbucket pipeline step indents



## 0.0.3 (2022-11-15)


* 4de0964 Add mysqli extension to php74 for legacy itix projects



## 0.0.2 (2022-11-10)


* b24390f Add data/shared/modules for easier module development
* 7f275cf Bump version to 0.0.2 as latest master. From here on, develop branch will be used for active development



## 0.0.1 (2022-11-09)


* 6e4e319 init commit for linux docker setup x-com
* 3f8d828 cleanup of install script and updated readme
* 14724f2 new docker compose
* 1924518 replace absolute paths with installdirectory to be replaced during install
* f5c9ed4 set max_map_count for sonarqube
* 9d4c7ed replace absolute dir with installdirectory
* ff3328e cannot change directory for enduser from within script, as it runs in their own subprocess
* 92ca2bb cleanup and move files into docker directory which makes it easier to copy/paste
* efd80dc installdirectory somehow got renamed again
* 1880640 copy docker-compose to installdir first before replacing values
* 5b1d60d Option to automatically restart docker containers every reboot
* 9601027 cleanup apache containers as we dont use that for magento2
* 7c2aa18 add enter script which will make it easier to access containers
* 8d9dc8e general fixes to install script to optimize it more and adjustment to nginx siteconfig
* c5bcc19 renamed install to install.sh
* 750e2ee gitconfig will be copied into container
* 437fde5 syntax error fix
* 8e5624a ssh support
* 17d15f8 prompt automatic docker install
* 1996814 updates to automatic docker install
* 7b42114 move gitconfig to dep folder
* 0eabbc3 added section comments and also included ssh config if found
* b8ff78c added upzip and ubuntu check to installer
* afef8bd Skip configurator git hooks, enabled xdebug for every php7 container
* a2a6e22 Add devctl as global executable which supports docker-compose from any directory
* 2e182d3 Just prompt sudo password if not part of docker group
* ec187ef typo for devctl copy
* cad8a3b add git autocomplete for branches and stuff
* 8a2127b get a list of php versions for hosts so its easier to enter container
* 2479955 add hostversions to devctl script
* 149fe3b Updated readme
* 763ab5f add welcoming message when entering container
* 447bf76 new docker compose version and eoan is now supported
* 66745ed make sudo user owner of docker after completion
* a0971ef make sysctl max map count permanent for sonarqube
* 39fc273 set inotify for phpstorm
* 97eac97 Add dependencies for Magesuite to container
* ac574f0 Add php7.4 docker support
* 50ffeb2 add to installer as well
* b27e824 add redis-cli to home path
* c758094 add phonetic plugin to elasticsearch
* b97f0b7 new docker-compose version
* 0070a56 add stop/start commands with multiple arg support
* 0abdb8c fix devctl sed, should also fix installer for systems other than ubuntu
* 103dfee add redis start as optional
* 271deff fix devctl restart, add containers as argument
* 0fbde9b fix redis-cli
* 9e7cebd copy X-com keys if found
* 17415c3 disable unused docker containers
* 3085c22 Use newer elasticsearch version as 6.* is supported by Magento and is needed for search
* f6ba917 copy xcom key and added toilet to php73 home
* 02b0f83 Update install.sh
* 697e1ba let mysql run on port 3306
* 1571248 keep 56 compatibility ON
* cda6229 set execute permission on docker compose
* a205a96 php74 container
* 258604b map media to directory so we can symlink it
* 074109b fix enter script, didnt work if user was part of docker group
* 93bd511 another fix for enter script
* 820b4e6 adds mysql allowed packet size
* 41b052f fix run.sh scripts for php
* e9fada8 [: -neq: binary operator expected
* 0bd599d add media folder to be used in pub/media symlink
* f67c72e some maintenance
* 0ccb79c enable php74
* e9d51a6 fix /etc/skel for paths
* 3d0d9be fix typo and add buffer sizes
* 41b6865 add xdebug max nesting level 512 for all php versions
* 8387a21 Added sqlsrv for mssql connection, only php72 and php73
* 8427534 Update dockerfiles for php72 and php73 to correctly install sqlsrv and update xdebug for xdebug version 3 - rebuild container for this
* 71a8ace need unixodbc-dev to use pecl
* 3ccbb5c set develop and debug modes for xdebug
* 267d3d4 xdebug 3 for php72 and php73
* 498de96 install oh-my-zsh and specifiy (pdo_)sqlsrv version for php72
* cd073aa elasticsearch port and network mode host do not work togeter
* b369e90 set mysql default charset
* 616ef96 gitconfig alias
* 2ff210c prune on fetch
* 566b3bc use debian buster instead of stretch
* 9dca57d oh my zsh support
* e33e0e2 Fixes for oh-my-zsh and new enter file
* 33ff925 multiple fixes for oh-my-zsh
* 7cf8757 php7.3 somehow installed 8.0, run update-alternatives to set to php73
* 3cdaed2 add ES7 container and move ES6
* ab2c672 Prepare php80
* 0b42b06 updated readme
* 0278181 improvements to installer
* 5d7e183 php80 support should now work
* bfcfaa8 removed php56 and php70 from paths as those php versions are deprecated
* d3cc8c8 Create a dialog installer
* b8e56ef fixes to dialog installer
* a7d3cea A few more improvements
* bcf15a6 Make inputbox cancellable
* bca03e9 fix php paths
* 57d13a3 Seperate docker php snippets and append them to docker-compose.yml later after selection
* e33827a install.sh deprecated, docker-compose still version 2
* 1e6a795 dialog improvements
* 333e4f5 cleanup unnecessary services and make sure nginx is part of services as well
* 31940a0 some improvements to nginx conf
* e8dfd82 textual improvements to install dialog
* 08bd531 get rid of redis-cli, redis-cli is part of redis container
* 9a9134e update redis to 6.2
* 81dbc73 run update-alternatives in php73, after install it defaults to 8.0
* 2d14bec reset nginx client buffer sizes
* 89c5e6c Provide a fresh bashrc file for each install to account for changed options
* abc5e41 Long due changes to devctl
* 50c952d devctl update usage
* 431e4ea post-installation message
* 8b164bf Changes to nginx run.sh
* 9ac3efc updates to readme
* fabab24 multiple improvements, include sonarqube, add sonarqube to devctl and also fixes to installer (option to overwrite devctl if it already exists)
* 8360862 always reset permissions. Previous commit added .editorconfig
* b76e136 added mysql80 build
* 5b6c170 fix devctl syntax
* 57afe8d remove old non-dialog installscript
* e6e69ab allow arguments to docker-compose
* e5666b5 Revert "allow arguments to docker-compose"
* afc0362 do not reset permissions recursively, that might take a very long time
* c493912 update xdebug for php74 and php80
* 6f96d29 xdebug port can be 9003 for multiple php instances
* eb5945a add rsync to containers
* 08b33fe sonarqube.yml should be moved too
* b71382c numerous fixes, allow devctl up parameters
* 4d13883 prefer bash over zsh
* 1656fd4 use decent ls command
* cc399c8 update welcome message
* 1a9649d cleanup unnecessary files
* d345af4 update magento nginx template site basename
* a58cbb9 prepare shopware
* 623dfdd update shopware nginx conf - untested
* 1e6cb34 replace enter script as well, useful if there possibly are changes
* a72214f updated docker installation
* ed7a728 make use of /data/shared/sites/media so project media does not get removed after project removal
* 1876b0d reset ownership and media dir created elsewhere
* 5562962 force remove
* e45c694 devctl flushredis
* 33ef57b add alias to sign commits
* 1f460f1 hostversions specific project
* ba0ecaf flushredis now accepts db number
* b9c6427 update usage, flushredis accepts a param
* c75ccb1 combine status and ps patterns
* 1913df1 update devctl for dockerdir
* 9c80e44 remove skip configurator instead of giving me a completely new blank file, as nvm would be missing after reinstallation
* 7d2e0e7 updated shopware nginx configuration
* 3190ac8 updated readme
* b94220b loop folders to be created
* 0a998f4 indents
* 78b2f0a nginx config dir loop
* 58de4a0 do not need site-configs anymore, I think
* bd5f366 xdebug can be the same for all php containers
* e86505f uniformity between all enabled php containers, set run.sh for each selected containers. Manage run.sh from one spot now
* 1a623f2 add starship to bashrc
* 9286b11 php80 should use 8.0 sock
* 147cce3 php80 should use correct home folder
* 4ed044a replace debian buster with alpine image, this is insanely fast
* c14bd77 added playings folder, this is where I tinker around with alpine images
* b2dda09 alpine playins, php74 functional but no nullmailer yet
* 274ccd5 update playings, cleanup php74
* cd6c77d stop nginx before starting it
* cebe731 set permissions on nginx to prevent 500
* 01b52a3 update to debian bullseye-slim
* aa3be20 php72 on bullseye-slim has issues with mssql tools. Disable mssql tools for php73 for now as we do not need it
* 69eb6b6 always copy latest Dockerfiles to php install dir
* 509a703 update docker-compose.yml to version 3
* bb5207d log4j format msg no lookups vulnerability fix
* a83f77b Remove elasticsearch6, only use 7
* b2e6aba nginx Dockerfile update to prevent permission denied sometimes thrown in magento admin when saving config
* cf71bcb Revert installdirectory and add elasticsearch volume so we do not miss data
* 9e5a6c3 added docker-compose elasticsearch volume so data is persistent after recreation of container
* 4e76964 Disable twofact auth on development server by default
* d791fb1 Use xcom_network as custom network, bridged, so all hosts can be reached by hostname
* da7205b add extra host for host.docker.internal via host-gateway (supported from docker v20.04 and up)
* 7fbc873 use host-gateway instead of docker0 ip
* 2f15964 Set mailtrap as nullmailer remote
* 3b57153 Run update-alternatives for php74
* 71f77ac Varnish support
* e2bc4e7 Fix magento caching application config value. 2 is Varnish
* 31499a8 Update enter script to accomodate for other shells
* 1826d4e always copy files in services to their respective folders
* 81fd776 create service directory if it does not yet exist
* 4fb3b66 Added php74-new based on php7.4fpm bullseye image from official php dockerhub, process changes in our own setup. Set XCOM_SERVERTYPE as fastcgi_param $_SERVER var so no magic has to be done in php fpm
* 305c58e Added php73-new based on php73 fpm bullseye image
* 7452dbb Update necessary scripts related to preparing dev environment, php72 73 and 74 now use php-fpm-bullseye or buster image, instead of debian based with extra repositories
* 5ec31f4 remove old playings
* c9a9855 Update dockerfiles, extensions used were insufficient for some php versions
* 2400e0d php81
* d6e5be2 Update php73 dockerfile to include sqlsrv for mssql connections
* c9dbaad fixes for php73 mssql drivers
* ebaf937 opcache.ini resulted in everything being heavily cached
* e66a62c added sqlsrv.ini to php73
* 9681391 Add xdebug.output_dir as fastcgi param so profiling can be done on a per-project basis. Just enable xdebug.mode=profile and it should work
* a218bda xdebug profiler output name so request uri is visible, makes it easy to find correct cachegrind file
* 6a2034f update nginx config, set php74 as default
* abf0ccf php73 install imagick
* 754c2b1 run mysql80 on port 3306 as well, map 3308 to 3306 via compose
* bb0d620 update devctl to include "tail" so container logs can be tailed
* 91cf4d1 Updated readme as dialog is a required dependency and allow for "/" to be set as install directory
* e368fcb update hosts via devctl
* 6cc2bd0 Move nginx to official nginx:stable image
* 9d9004f change nginx pid
* e8ea203 update fastcgi so https is always on, this fixes redirect issues in magento admin
* dd9aa5e remove backslash from processwire template definition
* 4b2fba1 processwire nginx config uses sitebasename/htdocs as site root
* 426648a update_hosts to use tmp hosts for edits
* e37a9f2 Add new reload command to update /etc/hosts and restart nginx, useful when adding new projects
* 6d4b668 always add  devserver to /etc/hosts for react projects
* 2752f67 changes to devctl update_hosts, introduce reload functionality to update hosts and restart nginx, overall quality of life improvements to devctl.
* 844b947 Install dialog saves values to sudo user .config/docker-setup.config file to read for a second run with existing values
* 67f07b9 Devctl close reload case
* 73a8cd3 replace docker-compose with docker compose as compose is a docker argument now
* a59f0e6 Rework of install dialog so user is prompted less with inputs, simply use a checklist to gather necessary information
* ac406e1 Prepare settings for varnish and xdebug
* fb099fe Handle config file with defaults correctly
* 6a12fba Mass updates to installer, now also writes selected php version to config
* ee7b723 Update devctl usage to include varnishacl
* a5b89e3 updates to phprun and xdebug
* 7e52164 varnish vcl acl set to ip which can be updated via devctl
* 6c157af Update gitconfig to push current and create/track remote branch if not exist
* b72b513 move git config to function and add xdebug start with trigger
* 3dd69a2 nvm new version
* 4d8d7af changes to nginx run.sh, cleanup the file a bit
* 728b25e QoL improvements to devctl
* 05ea8e5 Prompt user for /etc/xcomuser if file is not found
* 03936a4 echo subnet for varnishacl for the case it needs to be adjusted manually
* fca2a21 xdebug is default yes
* 8aa66fb python2 is still required by some processwire projects
* e0dad11 officially saying goodbye to php56, php70 and php71 as no projects use these anymore
* ff795a7 DEVENV-12 Check if logging dir exists per site enabled
* e712e47 Add mongodb extension to php
* 8c3e98c Added script version



