# If not running interactively, only update the path
if ! [[ $- == *i* ]]; then
    . ~/.config/bash/path
    return
fi


# Enable programmable completion feature; this is probably already included
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


. ~/.config/bash/rc

# Allow overriding the prompt
export PS1="$PS1_PREFIX$PS1$PS1_SUFFIX"
