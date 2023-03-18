all: run

run:
	chmod +x ./install.sh
	./install.sh

prepare:
	sudo apt-get update -qq
	sudo apt-get install dialog curl git jq software-properties-common apt-transport-https gnupg-agent ca-certificates
