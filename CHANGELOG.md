## 0.0.14 (2023-03-13)


*  Rename apachelogs to logs so we have a single log dir
*  Prefill gitconfig username with $USER
*  update samba config
*  DEVENV-9 fix nginx run.sh
*  devctl build specific contains with no-cache
*  DEVENV-9 prepare nginx webpath, update apache run.sh to use $installdir as well
*  Cleanup directories when exiting script early
*  Set default installdir to $HOME/x-com
*  DEVENV-24 fixes voor apache



## 0.0.13 (2023-03-06)


*  bump version to 0.0.13
*  DEVENV-9 fix where folders are not created when target installdir is a place where elevated permissions are required



## 0.0.12 (2023-03-06)


*  Bump version to 0.0.12 and update the way config file is written to
*  php72 with ioncube
*  Update magento2-varnish nginx template so listen 443 ssl works
*  Update varnish compose snippet
*  mysql56 legacy for yoeri
*  fix gitconfig
*  remove readonly from ssh volume mapping so container can write to known_hosts
*  add ulimits for mysql to limit mem usage on arch
*  Add apache logs to project in apachelogs dir. When apache is set in siteconfig config.json always use proxy template despite what nginx.conf says
*  DEVENV-9 allow installer to be run without root/sudo
*  DEVENV-9 optimizations to installer, created new images because phprun script got updated



## 0.0.11 (2023-01-30)


*  Rework some docker snippets, updates to nginx run
*  Update personalization, still under preparation
*  Make elasticsearch a setting
*  Fix apache dockerfile
*  Added php70 legacy without xdebug, mongo and imagick
*  Prepare docker compose image builds
*  Bump version to 0.0.11
*  Docker images on dockerhub with xdebug enabled but via trigger
*  Mailtrap github repo is now forked by myself, updated to php8.1 with roundcube 1.6.1 interface
*  Updated mailtrap container port as that no longer runs on 8085 but simply 80
*  xdebug config is now volume mapped, default comes from image but this is an easy way to overwrite
*  php81 now also uses image
*  added gitignore



## 0.0.10 (2023-01-16)


*  DEVENV-17 php74 should also include sqlsrv for mssql connections (profilplast), and pin xdebug version for old version as latest xdebug has dropped support for php7
*  Bump version to 0.0.10
*  specifiy xdebug version for php72
*  Updated proxyport
*  Updated readme
*  Added mongo via installer
*  DEVENV-25 add mysqli and DEVENV-22 install mongodb with libssl-dev to enable libmongoc SSL
*  DEVENV-22 mongodb default user/pass are root/xcom
*  DEVENV-24 htdocs/updateinfo should always use apache
*  Added makefile, updated editorconfig and automatically create containers at the end of installation if user wants to
*  Updates to makefile, apache and nginx run
*  Apache using bullseye-slim and remove some dependencies that will probably not be used
*  Pin mongo to version 6 and updated mongo volumes
*  add imagick



## 0.0.9 (2023-01-10)


*  Updated install dialog script
*  DEVENV-14 add samba



## 0.0.8 (2023-01-10)


*  DEVENV-18 prepare moving of personalizations
*  update development version to 0.0.7
*  DEVENV-19 prepare apache
*  bump version to 0.0.8



## 0.0.7 (2022-12-14)


*  Updated gitconfig
*  Added license.md
*  zz-docker can be a global dependency as except for phpversion everything is the same, installer updated to update phpversion with sed
*  update development version to 0.0.7



## 0.0.6 (2022-11-23)


*  DEVENV-15 ssh volume read only on target container
*  DEVENV-15 Version 0.0.6 will be used



## 0.0.5 (2022-11-23)


*  Check if tag exists when a PR from develop is openend
*  Bump version to 0.0.5 to validate PR pipeline



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



