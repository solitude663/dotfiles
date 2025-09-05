#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if uwsm check may-start && uwsm select; then
    exec uwsm start default
fi

alias ff="fastfetch"
alias hibernate="systemctl hibernate"

# TeX Live 2025 paths
export PATH="/home/tonii/texlive/2025/bin/x86_64-linux:$PATH"
export MANPATH="/home/tonii/texlive/2025/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/home/tonii/texlive/2025/texmf-dist/doc/info:$INFOPATH"

# Add /home/tonii/texlive/2025/texmf-dist/doc/man to MANPATH.
# Add /home/tonii/texlive/2025/texmf-dist/doc/info to INFOPATH.
# Most importantly, add /home/tonii/texlive/2025/bin/x86_64-linux
