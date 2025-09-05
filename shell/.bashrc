#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# TODO
# eval `keychain --eval id_ed25519`
eval `keychain --eval --quiet id_ed25519`

alias ff="fastfetch"
alias hibernate="systemctl hibernate"

export PATH="/home/tonii/texlive/2025/bin/x86_64-linux:$PATH"
export MANPATH="/home/tonii/texlive/2025/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/home/tonii/texlive/2025/texmf-dist/doc/info:$INFOPATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH"
