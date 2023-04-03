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



