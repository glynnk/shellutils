
if test -t 1; then
    # see if it supports colors...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test $ncolors -ge 8; then
        color_prompt=yes
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1="\$(aws-prompt.sh)${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$(git-prompt.sh)\$ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
fi


# example of how to do it properly
#green="\001$(tput setaf 2)\002"
#blue="\001$(tput setaf 4)\002"
#dim="\001$(tput dim)\002"
#reset="\001$(tput sgr0)\002"

#PS1="$dim[\t] " # [hh:mm:ss]
#PS1+="$green\u@\h" # user@host
#PS1+="$blue\w\$$reset " # workingdir$

#export PS1
#unset green blue dim reset

