#!/bin/bash
# This script will install llvm with clang package
# If you want to more tools or learn more information, please reference to http://clang.llvm.org/

cd $(dirname $0) &&
WORK_DIR=$(pwd) &&
echo "current work dir is $WORK_DIR" &&

LLVM_INSTALL_PREFIX=$HOME/.local/llvm &&
LLVM_DOWNLOAD_DIR=llvm-download &&
cd $WORK_DIR &&
{
    if [ -d $LLVM_DOWNLOAD_DIR ]
    then
        rm -fr $LLVM_DOWNLOAD_DIR &&
        {
            if [ -d $LLVM_INSTALL_PREFIX ]
            then
                rm -fr $LLVM_INSTALL_PREFIX
            fi
        }
    fi
} &&
{
    if [ -d $LLVM_INSTALL_PREFIX ]
    then
        echo "llvm exist, skip install!"
    else
        cd $WORK_DIR && mkdir $LLVM_DOWNLOAD_DIR && cd $LLVM_DOWNLOAD_DIR &&
        {
            {
		rm -fr * &&
		echo "try to use svn to checkout packages first..." &&
        	echo "checkout llvm ..." && svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm && echo "done!" &&
        	cd llvm/tools &&
        	echo "checkout clang ..." && svn co http://llvm.org/svn/llvm-project/cfe/trunk clang && echo "done!" &&
        	cd ../.. && cd llvm/tools/clang/tools &&
        	echo "checkout extra clang tools ..." && svn co http://llvm.org/svn/llvm-project/clang-tools-extra/trunk extra && echo "done!" &&
        	cd ../../../.. && cd llvm/projects &&
        	echo "checkout compiler-rt ..." && svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt && echo "done!" &&
        	echo "checkout libc++ ..." && svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx && echo "done!" &&
        	echo "checkout libc++abi ..." && svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi && echo "done!" &&
        	cd ../.. 
            } ||
	    {
		rm -fr * &&
		echo "svn failed, use wget to download packages ..." &&
        	LLVM_DOWNLOAD_URL=http://releases.llvm.org/6.0.1/llvm-6.0.1.src.tar.xz &&
        	LLVM_DOWNLOAD_NAME=${LLVM_DOWNLOAD_URL##*/} && LLVM_FOLDER_NAME=${LLVM_DOWNLOAD_NAME%%.tar*} &&
        	CLANG_DOWNLOAD_URL=http://releases.llvm.org/6.0.1/cfe-6.0.1.src.tar.xz &&
        	CLANG_DOWNLOAD_NAME=${CLANG_DOWNLOAD_URL##*/} && CLANG_FOLDER_NAME=${CLANG_DOWNLOAD_NAME%%.tar*} &&
        	EXTRA_DOWNLOAD_URL=http://releases.llvm.org/6.0.1/clang-tools-extra-6.0.1.src.tar.xz &&
        	EXTRA_DOWNLOAD_NAME=${EXTRA_DOWNLOAD_URL##*/} && EXTRA_FOLDER_NAME=${EXTRA_DOWNLOAD_NAME%%.tar*} &&
        	COMPILER_RT_DOWNLOAD_URL=http://releases.llvm.org/6.0.1/compiler-rt-6.0.1.src.tar.xz &&
        	COMPILER_RT_DOWNLOAD_NAME=${COMPILER_RT_DOWNLOAD_URL##*/} && COMPILER_RT_FOLDER_NAME=${COMPILER_RT_DOWNLOAD_NAME%%.tar*} &&
        	LIBCXX_DOWNLOAD_URL=http://releases.llvm.org/6.0.1/libcxx-6.0.1.src.tar.xz &&
        	LIBCXX_DOWNLOAD_NAME=${LIBCXX_DOWNLOAD_URL##*/} && LIBCXX_FOLDER_NAME=${LIBCXX_DOWNLOAD_NAME%%.tar*} &&
        	LIBCXXABI_DOWNLOAD_URL=http://releases.llvm.org/6.0.1/libcxxabi-6.0.1.src.tar.xz &&
        	LIBCXXABI_DOWNLOAD_NAME=${LIBCXXABI_DOWNLOAD_URL##*/} && LIBCXXABI_FOLDER_NAME=${LIBCXXABI_DOWNLOAD_NAME%%.tar*} &&
        	echo "download srcs ..." &&
        	mkdir tempdir && cd tempdir &&
        	wget $LLVM_DOWNLOAD_URL $CLANG_DOWNLOAD_URL $EXTRA_DOWNLOAD_URL $COMPILER_RT_DOWNLOAD_URL $LIBCXX_DOWNLOAD_URL $LIBCXXABI_DOWNLOAD_URL &&
        	echo "download done!" &&
        	echo "unpackage llvm ..." && tar -xJf $LLVM_DOWNLOAD_NAME && mv $LLVM_FOLDER_NAME ../llvm && echo "done!" &&
        	echo "unpackage clang ..." && tar -xJf $CLANG_DOWNLOAD_NAME && mv $CLANG_FOLDER_NAME ../llvm/tools/clang && echo "done!" &&
        	echo "unpackage extra ..." && tar -xJf $EXTRA_DOWNLOAD_NAME && mv $EXTRA_FOLDER_NAME ../llvm/tools/clang/tools/extra && echo "done!" &&
        	echo "unpackage compiler-rt ..." && tar -xJf $COMPILER_RT_DOWNLOAD_NAME && mv $COMPILER_RT_FOLDER_NAME ../llvm/projects/compiler-rt && echo "done!" &&
        	echo "unpackage libcxx ..." && tar -xJf $LIBCXX_DOWNLOAD_NAME && mv $LIBCXX_FOLDER_NAME ../llvm/projects/libcxx && echo "done!" &&
        	echo "unpackage libcxxabi ..." && tar -xJf $LIBCXXABI_DOWNLOAD_NAME && mv $LIBCXXABI_FOLDER_NAME ../llvm/projects/libcxxabi && echo "done!" &&
        	echo "unpackage done!" && cd .. 
            }
        } &&
        {
            echo "build and install ..." &&
            mkdir build && cd build &&
            cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$LLVM_INSTALL_PREFIX ../llvm &&
            make -j16 && make install &&
            cd $LLVM_INSTALL_PREFIX/bin && ./clang --version && echo "install llvm & clang successful!" 
        } || echo "failed to download packages,please try again!"        
        cd $WORK_DIR && rm -fr $LLVM_DOWNLOAD_DIR
    fi
}
