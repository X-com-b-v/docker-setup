all: run

run:
	chmod +x ./install.sh
	./install.sh

prepare:
	if [ "$(shell uname)" = "Linux" ]; then \
		make prepare-linux; \
	elif [ "$(shell uname)" = "Darwin" ]; then \
		make prepare-macos; \
	else \
		echo "Unsupported OS"; \
	fi

prepare-linux:
	sudo apt-get update -qq;
	sudo apt-get install dialog curl git jq software-properties-common apt-transport-https gnupg-agent ca-certificates;

prepare-macos:
	brew --version; \
	if [ $$? -eq 0 ]; then \
		brew update; \
	else \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi;

	jq --version; \
	if [ $$? -ne 0 ]; then \
		brew install jq; \
	fi;