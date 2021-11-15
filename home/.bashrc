if ! echo "$PATH" | grep -q '/usr/local/bin'; then
    PATH="/usr/local/bin:$PATH"
fi

# If not running interactively, only update the path
if ! [[ $- == *i* ]]; then
    . ~/.config/environment.d/ZZ-local-bin.conf
    return
fi

. ~/.config/bash/rc


export PATH
