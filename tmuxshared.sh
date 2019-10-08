#!/bin/bash

# see https://www.howtoforge.com/sharing-terminal-sessions-with-tmux-and-screen

source ~/bin/common.sh || exit 1
source $CREDSFILE

SHAREDGROUP=$1

if [ "$1" == "" ]; then
	echo "Usage $0 GROUP_TO_SHARE_SESSION_WITH"
	exit 1
fi

SOCKETNAME=/tmp/${USER}-tmux-socket
SESSIONNAME=${USER}-tmux-session

echo "Will share session with group $0"
echo "Attach to session with:"
echo "  tmux -S $SOCKETNAME attach -t $SESSIONNAME -r"
echo "-r for readonly"
confirm "Continue?"

tmux -S $SOCKETNAME new -s $SESSIONNAME
chgrp $0 $SOCKETNAME
