all: run

run:
	chmod +x ./install-dialog.sh
	sudo ./install-dialog.sh

prepare:
	sudo apt-get update -qq
	sudo apt-get install curl git jq software-properties-common apt-transport-https gnupg-agent ca-certificates
