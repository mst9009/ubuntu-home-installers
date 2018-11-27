#!/bin/bash
# More information https://github.com/vim/vim

cd $(dirname $0) &&
WORK_DIR=$(pwd) &&
echo "current work dir is $WORK_DIR" &&

VIM_INSTALL_PREFIX=$HOME/.local/vim &&
VIM_DOWNLOAD_DIR=vim-download &&
cd $WORK_DIR && 
{
    if [ -d $VIM_DOWNLOAD_DIR ]
    then
        rm -fr $VIM_DOWNLOAD_DIR &&
        {
            if [ -d $VIM_INSTALL_PREFIX ]
            then
                rm -fr $VIM_INSTALL_PREFIX
            fi
        }
    fi
} &&
{
	if [ -d $VIM_INSTALL_PREFIX ]
    then
        echo "vim exist, skip install!"
    else
        echo "install vim ..." &&
        VIM_CONFIG_FLAGS="--prefix=$VIM_INSTALL_PREFIX \
                          --with-features=huge \
                          --enable-cscope \
                          --enable-multibyte \
                          --enable-rubyinterp=yes \
                          --enable-perlinterp=yes \
                          --enable-luainterp=yes \
                          --enable-gui=gtk2" &&
        PYTHON_BIN=$(which python) &&
        {
            if [ "$PYTHON_BIN" != "" ]
            then
                PYTHON_ROOT=$(dirname $(dirname $PYTHON_BIN)) &&
		        PYTHON_VERSION=$(python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1"."$2}') &&
                {
                    for PY_CFG in $(find $PYTHON_ROOT/lib -name python$PYTHON_VERSION -type d -exec find {} -maxdepth 1 -name "config*" -type d \;)
                    do
                        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-pythoninterp=yes --with-python-config-dir=$PY_CFG"
                        break
                    done
                }
            fi
        } &&
        PYTHON3_BIN=$(which python3) &&
        {
            if [ "$PYTHON3_BIN" != "" ]
            then
                PYTHON3_ROOT=$(dirname $(dirname $PYTHON3_BIN)) &&
                PYTHON3_VERSION=$(python3 -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1"."$2}') &&
                {
                    for PY3_CFG in $(find $PYTHON3_ROOT/lib -name python$PYTHON3_VERSION -type d -exec find {} -maxdepth 1 -name "config*" -type d \;)
                    do
                        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-python3interp=yes --with-python3-config-dir=$PY3_CFG"
                        break
                    done
                }
            fi
        } &&
        echo "configure vim with flags: $VIM_CONFIG_FLAGS" &&
        cd $WORK_DIR && git clone --recursive https://github.com/vim/vim.git $VIM_DOWNLOAD_DIR && cd $VIM_DOWNLOAD_DIR &&
        ./configure $VIM_CONFIG_FLAGS &&
        make -j16 && make install &&
        cd $WORK_DIR && rm -fr $VIM_DOWNLOAD_DIR &&
        echo "install vim done!"
    fi
}
