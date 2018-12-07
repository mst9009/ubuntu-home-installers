#!/bin/bash
# tmux depends on libevent 2.x and ncurses
# If you have not installed these dependences or you want to use self-build version
# you can run "./tmux-dependences-installer.sh" then "source ~/.bashrc"

cd $(dirname $0) &&
WORK_DIR=$(pwd) &&
echo "current work dir is $WORK_DIR" &&

TMUX_PREFIX=$HOME/.local/tmux &&
TMUX_DOWNLOAD_DIR=tmux-download &&

cd $WORK_DIR &&
{
    if [ -d $TMUX_DOWNLOAD_DIR ]
    then
        rm -fr $TMUX_DOWNLOAD_DIR &&
        {
            if [ -d $TMUX_PREFIX ]
            then
                rm -fr $TMUX_PREFIX
            fi
        }
    fi
} &&

#Install tmux
{
    if [ -d $TMUX_PREFIX ]
    then
        echo "tmux exist, skip install!"
    else
        echo "install tmux ..." &&
        cd $WORK_DIR &&
        git clone --recursive https://github.com/tmux/tmux.git $TMUX_DOWNLOAD_DIR &&
        cd $TMUX_DOWNLOAD_DIR && ./autogen.sh &&
        ./configure --prefix=$TMUX_PREFIX &&
        make -j8 && make install &&
        echo "Installed tmux successfully!"
    fi
} &&

ln -sf $WORK_DIR/.tmux.conf $HOME/.tmux.conf &&
cd $WORK_DIR && rm -fr $TMUX_DOWNLOAD_DIR
