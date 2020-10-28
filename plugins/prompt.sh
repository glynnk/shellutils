case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1="\$(aws-prompt.sh)${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$(git-prompt.sh)\$ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
fi

