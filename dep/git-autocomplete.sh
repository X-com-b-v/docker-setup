#!/usr/bin/env bash

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

echo "if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

source /etc/bash_completion.d/git-prompt
source /etc/bash_completion.d/git-flow" >> ~/.bashrc

# source ~/.bashrc