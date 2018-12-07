#!/bin/bash
# Buld a C/C++ IDE based on YouCompleteMe
# More information about vim plugins: https://github.com/int32bit/use_vim_as_ide#1

cd $(dirname $0) &&
WORK_DIR=$(pwd) &&
echo "current work dir is $WORK_DIR" &&

VIM_BUNDLE_ROOT=$HOME/.vim/bundle &&
{
    if [ ! -d $VIM_BUNDLE_ROOT ]
    then
        mkdir -p $VIM_BUNDLE_ROOT
    fi
} &&

PLUGIN_VUNDLE_ROOT=$VIM_BUNDLE_ROOT/Vundle.vim &&
{
    if [ -d $PLUGIN_VUNDLE_ROOT ]
    then
        echo "vundle exist, skip install!"
    else
        echo "install vundle ..." &&
        git clone --recursive https://github.com/VundleVim/Vundle.vim.git $PLUGIN_VUNDLE_ROOT &&
        echo "install vundle done!"
    fi
} &&

VIMRC_FILE=$HOME/.vimrc && ln -sf $WORK_DIR/.vimrc.full $VIMRC_FILE &&

# If you have a custom vim and you want to use this version, uncomment this line
# Otherwise, if you want to use the systerm vim, keep this line comment
CUSTOM_VIM_PREFIX=$HOME/.local/vim &&
VIM_BIN="" &&
{
    if [ "$CUSTOM_VIM_PREFIX" != "" ] && [ -x $CUSTOM_VIM_PREFIX/bin/vim ]
    then
        echo "use custom vim ..." &&
        VIM_BIN=$CUSTOM_VIM_PREFIX/bin/vim
    else
        echo "use systerm vim ..." &&
        VIM_BIN=vim
    fi
} &&
PLUGIN_YCM_ROOT=$VIM_BUNDLE_ROOT/YouCompleteMe &&
{
    for tt in first second third
    do
        echo "install vim plugins use $VIM_BIN ($tt time) ..." &&
	$VIM_BIN +PluginInstall +qall &&
        {
            if [ -d $PLUGIN_YCM_ROOT ]
            then
                echo "install vim plugins ($tt time) done!"
                break
            else
                echo "install vim plugins ($tt time) failed!"
            fi
        }
    done
} &&

# Default, we use the official install script to install YCM. If this dose not work, we build it from source
YCM_INSTALL_FLAG="--clang-completer" &&
# If you want to build ycm_core without clang support, uncomment this line and keep other YCM_BUILD_FLAG definations comment
# YCM_BUILD_FLAG="" &&
# If you have downloaded a pre-build clang+llvm package and extract it into $HOME/.local/llvm+clang 
# you can build ycm_core with it by uncommenting this line and keeping other YCM_BUILD_FLAG definations comment
# YCM_BUILD_FLAG="-DPATH_TO_LLVM_ROOT=$HOME/.local/llvm+clang" &&
# If you have a custom build llvm in $HOME/.local/llvm
# you can build ycm_core with it by uncommenting this line and keeping other YCM_BUILD_FLAG definations comment
YCM_BUILD_FLAG="-DEXTERNAL_LIBCLANG_PATH=$HOME/.local/llvm/lib/libclang.so" &&
# If you want to use the system version of libclang, uncomment this line and keep other YCM_BUILD_FLAG definations comment
# YCM_BUILD_FLAG="-DUSE_SYSTEM_LIBCLANG=ON" &&
# More information about YCM installation, refer to https://github.com/Valloric/YouCompleteMe/tree/master
YCM_BUILD_DIR=ycm-build &&
{
    {
        echo "install YCM with script..." &&
        cd $PLUGIN_YCM_ROOT && python install.py $YCM_INSTALL_FLAG &&
        echo "install YCM done!"
    } ||
    {
        echo "failed to install YCM with script, build from source..." &&
        cd $WORK_DIR && mkdir -p $YCM_BUILD_DIR && cd $YCM_BUILD_DIR && rm -fr * &&
        
        echo "build ycm_core ..." &&
        cd $WORK_DIR/$YCM_BUILD_DIR && mkdir ycm-core-build && cd ycm-core-build &&
        cmake -G "Unix Makefiles" $YCM_BUILD_FLAG . $PLUGIN_YCM_ROOT/third_party/ycmd/cpp &&
        cmake --build . --target ycm_core &&
        
        # [Optional] Build the regex module for improved Unicode support and better performance with regular expressions
        echo "build ycm_regex ..." &&
        cd $WORK_DIR/$YCM_BUILD_DIR && mkdir ycm-regex-build && cd ycm-regex-build &&
        cmake -G "Unix Makefiles" . $PLUGIN_YCM_ROOT/third_party/ycmd/third_party/cregex &&
        cmake --build . --target _regex &&
        
        echo "build YCM from source done!"
    }
} && echo "config vim done!" ||
{
    echo "something went error, we will restore vim settings..." &&
    ln -sf $WORK_DIR/.vimrc.base $VIMRC_FILE &&
    $VIM_BIN +PluginClean! +qall ||
    {
        cd $VIM_BUNDLE_ROOT && rm -fr *
        rm -f $VIMRC_FILE
    }
}

cd $WORK_DIR && rm -fr $YCM_BUILD_DIR
