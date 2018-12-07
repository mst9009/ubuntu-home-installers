#!/bin/bash
# Extend env variabls in $HOME/.local 
# Usage:
#   ln -sf ${this file} ~/.extend_env.sh
# Then append belows to ~/.bashrc
#   if [ -x ~/.extend_env.sh ]
#   then
#     . "~/.extend_env.sh"
#   fi
PROGRAM_ROOT=$HOME/.local
BIN_APPENDAGE_DIRS="llvm opencv vim cuda cmake tmux"
INCLUDE_APPENDAGE_DIRS="llvm opencv cuda cudnn/cuda libevent ncurses"
LIBRARY_APPENDAGE_DIRS="llvm opencv cuda cudnn/cuda libevent ncurses"

for BIN_DIR in $BIN_APPENDAGE_DIRS 
do
    for BIN_ROOT in $(find $PROGRAM_ROOT/$BIN_DIR -maxdepth 1 -follow -name "bin" \( -type d -or -type l \) 2>/dev/null)
    do
        if [[ $PATH != *$BIN_ROOT* ]]
        then
            PATH="$BIN_ROOT:$PATH"
        fi
    done
done

for INCLUDE_DIR in $INCLUDE_APPENDAGE_DIRS
do
    for INCLUDE_ROOT in $(find $PROGRAM_ROOT/$INCLUDE_DIR -maxdepth 1 -follow -name "include" \( -type d -or -type l \) 2>/dev/null)
    do
        if [[ $C_INCLUDE_PATH != *$INCLUDE_ROOT* ]]
        then
            C_INCLUDE_PATH="$INCLUDE_ROOT:$C_INCLUDE_PATH"
        fi
        if [[ $CPLUS_INCLUDE_PATH != *$INCLUDE_ROOT* ]]
        then
            CPLUS_INCLUDE_PATH="$INCLUDE_ROOT:$CPLUS_INCLUDE_PATH"
        fi
    done
done

for LIBRARY_DIR in $LIBRARY_APPENDAGE_DIRS
do
    for LIBRARY_ROOT in $(find $PROGRAM_ROOT/$LIBRARY_DIR -maxdepth 1 -follow \( -name "lib" -or -name "lib64" \) \( -type d -or -type l \) 2>/dev/null)
    do
        if [[ $LIBRARY_PATH != *$LIBRARY_ROOT* ]]
        then
            LIBRARY_PATH="$LIBRARY_ROOT:$LIBRARY_PATH"
        fi
        if [[ $LD_LIBRARY_PATH != *$LIBRARY_ROOT* ]]
        then
            LD_LIBRARY_PATH="$LIBRARY_ROOT:$LD_LIBRARY_PATH"
        fi
    done
done

export PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH
