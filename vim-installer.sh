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
        # Definations below make it easier to comment out unwanted features
        VIM_CONFIG_FLAGS="--prefix=$VIM_INSTALL_PREFIX" &&
        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --with-features=huge" &&
        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-cscope" &&
        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-multibyte" &&
        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-rubyinterp=yes" &&
        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-perlinterp=yes" &&
        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-luainterp=yes" &&
        VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-gui=gtk2" &&
        # Default, we use pythons in conda envs
        # If there is neither a conda nor python env, just comment the definations below
        PYTHON2_ENV=py27 && PYTHON3_ENV=py36 &&
        {
            for PYTHON_MAJOR in 2 3
            do
                {
                    if [ $PYTHON_MAJOR -gt 2 ]
                    then
                        PYTHON_QUALIFIER=$PYTHON_MAJOR
                    fi 
                } &&
                eval PYTHON_ENV=$(echo "\$PYTHON${PYTHON_MAJOR}_ENV") &&
                {
                    if [ "$PYTHON_ENV" != "" ]
                    then
                        source activate $PYTHON_ENV
                    fi
                } &&
                PYTHON_EXECUTABLE=$(which python${PYTHON_MAJOR}) &&
                {
                    if [ "$PYTHON_EXECUTABLE" != "" ]
                    then
                        PYTHON_VERSION=$($PYTHON_EXECUTABLE -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1"."$2}') &&
                        PYTHON_ROOT=$(dirname $(dirname $PYTHON_EXECUTABLE)) &&
                        {
                            for PY_CFG in $(find $PYTHON_ROOT/lib -name python$PYTHON_VERSION -type d -exec find {} -maxdepth 1 -name "config*" -type d \; 2>/dev/null)
                            do
                                VIM_CONFIG_FLAGS="$VIM_CONFIG_FLAGS --enable-python${PYTHON_QUALIFIER}interp=yes --with-python${PYTHON_QUALIFIER}-config-dir=$PY_CFG" && break
                            done
                        }
                    fi
                } &&
                {
                    if [ "$PYTHON_ENV" != "" ]
                    then
                        source deactivate
                    fi
                }
            done
        } &&
        echo "configure vim with flags: $VIM_CONFIG_FLAGS" &&
        cd $WORK_DIR && git clone --recursive https://github.com/vim/vim.git $VIM_DOWNLOAD_DIR && cd $VIM_DOWNLOAD_DIR &&
        ./configure $VIM_CONFIG_FLAGS &&
        make -j16 && make install &&
        cd $WORK_DIR && rm -fr $VIM_DOWNLOAD_DIR &&
        echo "Installed vim successfully!"
    fi
}
