## Custom: Everything below this line is auto-edited by setup scripts

# emacs
export EDITOR=emacs

#####################################################################
# Enable re-attaching screen sessions with ssh-agent support
if [[ -n "$SSH_TTY" && -S "$SSH_AUTH_SOCK" && ! -L "$SSH_AUTH_SOCK" ]]; then
    rm -f ~/.ssh/ssh_auth_sock
    ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
    export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
fi
#####################################################################

#####################################################################
# Enable startx chromium kiosk startup if on tty1

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] \
  && exec startx -- -nocursor

#####################################################################
