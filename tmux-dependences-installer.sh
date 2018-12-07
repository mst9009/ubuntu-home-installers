#!/bin/bash
# Install libevent and ncurses for tmux
# You can change the url used for downloading ncurses
# After installing these dependences, run "source ~/.bashrc" to enable libs

cd $(dirname $0) &&
WORK_DIR=$(pwd) &&
echo "current work dir is $WORK_DIR" &&

LIBEVENT_PREFIX=$HOME/.local/libevent &&
NCURSES_PREFIX=$HOME/.local/ncurses &&
TMUX_DEPENDENCES_DOWNLOAD_DIR=tmux-dependences-download &&

cd $WORK_DIR &&
{
    if [ -d $TMUX_DEPENDENCES_DOWNLOAD_DIR ]
    then
        rm -fr $TMUX_DEPENDENCES_DOWNLOAD_DIR &&
        {
            if [ -d $LIBEVENT_PREFIX ]
            then
                rm -fr $LIBEVENT_PREFIX
            fi
        } &&
        {
            if [ -d $NCURSES_PREFIX ]
            then
                rm -fr $NCURSES_PREFIX
            fi
        }
    fi
} &&

cd $WORK_DIR && mkdir -p $TMUX_DEPENDENCES_DOWNLOAD_DIR &&
cd $TMUX_DEPENDENCES_DOWNLOAD_DIR && rm -fr * &&

# Install libevent
{
    if [ -d $LIBEVENT_PREFIX ]
    then
        echo "libevent exist, skip install!"
    else
        echo "install libevent ..." &&
        LIBEVENT_DOWNLOAD_DIR=libevent_download &&
        cd $WORK_DIR/$TMUX_DEPENDENCES_DOWNLOAD_DIR &&
        git clone --recursive https://github.com/libevent/libevent.git $LIBEVENT_DOWNLOAD_DIR &&
        cd $LIBEVENT_DOWNLOAD_DIR && ./autogen.sh &&
        ./configure --prefix=$LIBEVENT_PREFIX &&
        make -j8 && make install &&
        echo "Installed libevent successfully!"
    fi
} &&
# Install ncurses
{
    if [ -d $NCURSES_PREFIX ]
    then
        echo "ncurses exist, skip install!"
    else
        echo "install ncurses ..." &&
        cd $WORK_DIR/$TMUX_DEPENDENCES_DOWNLOAD_DIR &&
        wget -N https://invisible-mirror.net/archives/ncurses/ncurses-6.1.tar.gz &&
        {
            for FILE_NAME in $(find . -maxdepth 1 -name "ncurses*.tar.gz" -type f 2>/dev/null)
            do
                NCURSES_DOWNLOAD_FILE=${FILE_NAME##*/} && break
            done
        } &&
        {
            if [ "$NCURSES_DOWNLOAD_FILE" != "" ]
            then
                echo "untar download file: $NCURSES_DOWNLOAD_FILE" &&
                tar -zxf $NCURSES_DOWNLOAD_FILE &&
                {
                    for DIR_NAME in $(find . -maxdepth 1 -name "ncurses*" -type d 2>/dev/null)
                    do
                        NCURSES_SOURCE_DIR=${DIR_NAME##*/} && break
                    done
                } &&
                {
                    if [ "$NCURSES_SOURCE_DIR" != "" ]
                    then
                        echo "enter source dir: $NCURSES_SOURCE_DIR" &&
                        cd $NCURSES_SOURCE_DIR &&
                        ./configure --prefix=$NCURSES_PREFIX &&
                        make -j8 && make install &&
                        echo "Installed ncurses successfully!"
                    else
                        echo "Can not find ncurses source dir!"
                    fi
                }
            else
                echo "Can not find ncurses download file!"
            fi
        }
    fi
} && cd $WORK_DIR && rm -fr $TMUX_DEPENDENCES_DOWNLOAD_DIR
