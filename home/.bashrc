if ! echo "$PATH" | grep -q '/usr/local/bin'; then
    PATH="/usr/local/bin:$PATH"
fi

# If not running interactively, only update the path
if ! [[ $- == *i* ]]; then
    . ~/.config/environment.d/ZZ-local-bin.conf
    return
fi


# Enable programmable completion feature; this is probably already included
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


. ~/.config/bash/rc

# Allow overriding the prompt
export PS1="\e[37m→ \t\e[0;m\n$PS1_PREFIX$PS1$PS1_SUFFIX"

export PATH
