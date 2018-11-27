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
        PYTHON_BIN=$(which python) &&
        {
            if [ "$PYTHON_BIN" != "" ]
            then
                PYTHON_ROOT=$(dirname $(dirname $PYTHON_BIN)) &&
                {
                    for PY_CFG in `find $PYTHON_ROOT/lib -name python* -type d -exec find {} -maxdepth 1 -name "config*" -type d \;`
                    do
                        WITH_PYTHON_CONFIG_DIR=--with-python-config-dir=$PY_CFG/ &&
                        echo "find python config dictionary in $PY_CFG/" && 
                        echo "we will build vim with $WITH_PYTHON_CONFIG_DIR"
                        break
                    done
                }
            fi
        } &&

        cd $WORK_DIR && git clone --recursive https://github.com/vim/vim.git $VIM_DOWNLOAD_DIR && cd $VIM_DOWNLOAD_DIR &&
        ./configure --with-features=huge --enable-pythoninterp --enable-rubyinterp --enable-luainterp --enable-perlinterp \
            --enable-gui=gtk2 --enable-cscope --prefix=$VIM_INSTALL_PREFIX $WITH_PYTHON_CONFIG_DIR &&
        make -j16 && make install &&
        cd $WORK_DIR && rm -fr $VIM_DOWNLOAD_DIR &&
        echo "install vim done!"
    fi
}
