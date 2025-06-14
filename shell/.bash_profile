#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if uwsm check may-start && uwsm select; then
    exec uwsm start default
fi

alias ff="fastfetch"
alias hibernate="systemctl hibernate"
