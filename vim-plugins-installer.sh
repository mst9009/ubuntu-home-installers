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

VIMRC_FILE=$HOME/.vimrc && touch $VIMRC_FILE &&
{
cat<<EOF>$VIMRC_FILE
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'Lokaltog/vim-powerline'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'Yggdroot/indentLine'
Plugin 'derekwyatt/vim-fswitch'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'scrooloose/nerdcommenter'
Plugin 'vim-scripts/DrawIt'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'Valloric/YouCompleteMe'
Plugin 'derekwyatt/vim-protodef'
Plugin 'scrooloose/nerdtree'
Plugin 'fholgado/minibufexpl.vim'
Plugin 'gcmt/wildfire.vim'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'yegappan/grep'
Plugin 'mileszs/ack.vim'
Plugin 'dyng/ctrlsf.vim'
call vundle#end()
filetype plugin indent on
EOF
} &&

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
} &&
{
cat<<EOF>>$VIMRC_FILE
" set the value of <leader>
let mapleader=";"
set incsearch
set ignorecase
set nocompatible
set backspace=indent,eol,start
" enable intelligent completion of vim command-line
set wildmenu
" enable status bar
set laststatus=2
" displays the current position of the cursor
set ruler
" enable line number
set number
" highlight cursor line
" set cursorline
" highlight cursor colum
" set cursorcolumn
" highlight search results
set hlsearch
" disable cursor flicker
set gcr=a:block-blinkon0
set nowrap
" set gvim font
set guifont=YaHei\ Consolas\ Hybrid\ 11.5
syntax enable
syntax on
" switch split screens in insert mode
imap <C-W> <Esc><C-W>
" indent setting
" expanding tab to multi spaces
set expandtab
" the length (number of spaces) of a tab while editing
set tabstop=4
" the length (number of spaces) of a tab while formatting
set shiftwidth=4
" consider a continuous number of Spaces as a TAB character
set softtabstop=4
" fold setting
set foldmethod=indent
" set foldmethod=syntax
" unfold when starting vim
set nofoldenable
" vim-fswitch setting
nmap <silent> <Leader>sw :FSHere<cr>
" ctrlsf setting
nnoremap <Leader>sp :CtrlSF<CR>
" UltiSnips setting
let g:UltiSnipsExpandTrigger="<leader><tab>"
let g:UltiSnipsJumpForwardTrigger="<leader><tab>"
let g:UltiSnipsJumpBackwardTrigger="<leader><s-tab>"
" ycm setting
let g:ycm_complete_in_comments=1
" specifies a fallback path to a config file which is used if no .ycm_extra_conf.py is found
" TODO: comment or modify this line once you have a .ycm_extra_conf.py or compile_commands.json
let g:ycm_global_ycm_extra_conf='$PLUGIN_YCM_ROOT/third_party/ycmd/.ycm_extra_conf.py'
" allow vim to load the.ycm_extra_conf.py file without prompting
let g:ycm_confirm_extra_conf=0
" shortcut for OmniCppComplete engine
inoremap <leader>c <C-x><C-o>
" the completion content does not appear as a sub-window, but only as a completion list
set completeopt-=preview
let g:ycm_add_preview_to_completeopt=0
" list the matches from the first character
let g:ycm_min_num_of_chars_for_completion=1
" disable cache the matches
let g:ycm_cache_omnifunc=0
" syntax keyword completion
let g:ycm_seed_identifiers_with_syntax=1
nnoremap <leader>gt :YcmCompleter GoTo<CR>
nnoremap <leader>gc :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
" protodef setting
" the path of pullproto.pl
let g:protodefprotogetter='$VIM_BUNDLE_ROOT/protodef/pullproto.pl'
" keep the order between declaration and defination
let g:disable_protodef_sorting=1
" NERDtree setting
nmap <Leader>fl :NERDTreeToggle<CR>
let NERDTreeWinSize=32
let NERDTreeWinPos="right"
let NERDTreeShowHidden=1
" disable redundant help information in NERDtree subwindow
let NERDTreeMinimalUI=1
" remove corresponding buffer while the file removed 
let NERDTreeAutoDeleteBuffer=1
" MiniBufExplorer setting
map <Leader>bl :MBEToggle<cr>
map <Leader>bn :MBEbn<cr>
map <Leader>bp :MBEbp<cr>
" wildfire setting
map <SPACE> <Plug>(wildfire-fuel)
vmap <S-SPACE> <Plug>(wildfire-water)
let g:wildfire_objects = ["i'", 'i"', "i)", "i]", "i}", "i>", "ip"]
"indent-line setting"
let g:indentLine_char='|'
let g:indentLine_enabled=1
EOF
} && echo "config vim done!" ||
{
    echo "something went error, we will restore vim settings..." &&
{
cat<<EOF>$VIMRC_FILE
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
call vundle#end()
filetype plugin indent on
EOF
} &&
    $VIM_BIN +PluginClean! +qall ||
    {
        cd $VIM_BUNDLE_ROOT && rm -fr *
        rm -f $VIMRC_FILE
    }
}

cd $WORK_DIR && rm -fr $YCM_BUILD_DIR
