# If not running interactively, only update the path
if [ -z "$PS1" ]; then
    . ~/.config/bash/path
    return
fi


# Enable programmable completion feature; this is probably already included
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


. ~/.config/bash/rc
