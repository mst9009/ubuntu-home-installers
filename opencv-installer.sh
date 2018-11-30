#!/bin/bash
# Automatic download and build opencv
# You should specified the version you want to install in command line
# The default download url will be https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip
if [ $# -lt 1 ]
then
    echo "You must specify a version number!" >&2
    exit 1
fi

OPENCV_VERSION=$1 &&
cd $(dirname $0) &&
WORK_DIR=$(pwd) &&
echo "current work dir is $WORK_DIR" &&

OPENCV_DOWNLOAD_DIR="opencv-download" &&
OPENCV_DOWNLOAD_FILE="opencv-$OPENCV_VERSION.zip" &&
OPENCV_UNZIP_DIR=${OPENCV_DOWNLOAD_FILE%.*} &&
OPENCV_INSTALL_PREFIX="$HOME/.local/opencv-$OPENCV_VERSION" &&
OPENCV_MAJOR_VERSION=${OPENCV_VERSION%%.*} &&

cd $WORK_DIR && mkdir -p $OPENCV_DOWNLOAD_DIR && 
cd $OPENCV_DOWNLOAD_DIR && rm -fr $OPENCV_UNZIP_DIR &&
{
    if [ ! -f $OPENCV_DOWNLOAD_FILE ]
    then
        wget -O $OPENCV_DOWNLOAD_FILE  https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip
    fi
} &&
unzip -q $OPENCV_DOWNLOAD_FILE && cd $OPENCV_UNZIP_DIR &&
mkdir -p build && cd build && rm -fr * &&

# Default, we use pythons in conda envs
# If there is neither a conda nor python env, just comment the definations below
PYTHON2_ENV=py27 && PYTHON3_ENV=py36 &&

OPENCV_CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$OPENCV_INSTALL_PREFIX" &&
# Make without cuda
OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DWITH_CUBLAS=OFF -DWITH_CUDA=OFF -DWITH_CUFFT=OFF" &&
# for opencv-3.* and higher, we need to configure python
{
    if [ $OPENCV_MAJOR_VERSION -gt 2 ]
    then
        {
            for PYTHON_MAJOR in 2 3
            do
                PYTHON_QUALIFIER=$PYTHON_MAJOR &&
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
                        OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_EXECUTABLE=$PYTHON_EXECUTABLE" &&
                        {
                            for PYTHON_INCLUDE_DIR in $(find $PYTHON_ROOT/include -maxdepth 1 \( -name "python${PYTHON_VERSION}" -or -name "python${PYTHON_VERSION}m" \) -type d 2>/dev/null)
                            do
                                OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_INCLUDE_DIR=$PYTHON_INCLUDE_DIR" && break
                            done
                        } &&
                        {
                            for PYTHON_INCLUDE_DIR2 in $(find $PYTHON_ROOT/include/x86_64-linux-gnu -maxdepth 1 \( -name "python${PYTHON_VERSION}" -or -name "python${PYTHON_VERSION}m" \) -type d 2>/dev/null)
                            do
                                OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_INCLUDE_DIR2=$PYTHON_INCLUDE_DIR2" && break
                            done
                        } &&
                        {
                            for PYTHON_LIBRARY in $(find $PYTHON_ROOT/lib -maxdepth 2 \( -name "libpython${PYTHON_VERSION}.so" -or -name "libpython${PYTHON_VERSION}m.so" \) \( -type d -or -type l \) 2>/dev/null)
                            do
                                OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_LIBRARY=$PYTHON_LIBRARY" && break
                            done
                        } &&
                        OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_LIBRARY_DEBUG=" &&
                        {
                            for PYTHON_NUMPY_INCLUDE_DIRS in $(find $PYTHON_ROOT/lib/python${PYTHON_VERSION} -maxdepth 2 -name "numpy" -type d -exec find {} -maxdepth 2 -name "include" -type d \; 2>/dev/null)
                            do
                                OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_NUMPY_INCLUDE_DIRS=$PYTHON_NUMPY_INCLUDE_DIRS" && break
                            done
                        } &&
                        # TODO It is not clear what this flag does 
                        PYTHON_PACKAGES_DIR=lib/python${PYTHON_VERSION} &&
                        {
                            if [ -d $PYTHON_ROOT/$PYTHON_PACKAGES_DIR/site-packages ]
                            then
                                OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_PACKAGES_PATH=$OPENCV_INSTALL_PREFIX/$PYTHON_PACKAGES_DIR/site-packages"
                            elif [ -d $PYTHON_ROOT/$PYTHON_PACKAGES_DIR/dist-packages ]
                            then
                                OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_PACKAGES_PATH=$OPENCV_INSTALL_PREFIX/$PYTHON_PACKAGES_DIR/dist-packages"
                            else
                                OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON${PYTHON_QUALIFIER}_PACKAGES_PATH=$OPENCV_INSTALL_PREFIX/$PYTHON_PACKAGES_DIR/site-packages"
                            fi
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
        echo "OPENCV_CMAKE_FLAG=S$OPENCV_CMAKE_FLAGS" &&
        cmake $OPENCV_CMAKE_FLAGS ..
    else
        {
            if [ "$PYTHON2_ENV" != "" ]
            then
                source activate $PYTHON2_ENV
            fi
        } &&
        PYTHON_EXECUTABLE=$(which python2) &&
        {
            if [ "$PYTHON_EXECUTABLE" != "" ]
            then
                PYTHON_VERSION=$($PYTHON_EXECUTABLE -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1"."$2}') &&
                PYTHON_ROOT=$(dirname $(dirname $PYTHON_EXECUTABLE)) &&
                # TODO It is not clear what this flag does 
                PYTHON_PACKAGES_DIR=lib/python${PYTHON_VERSION} &&
                {
                    if [ -d $PYTHON_ROOT/$PYTHON_PACKAGES_DIR/site-packages ]
                    then
                        OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON_PACKAGES_PATH=$OPENCV_INSTALL_PREFIX/$PYTHON_PACKAGES_DIR/site-packages"
                    elif [ -d $PYTHON_ROOT/$PYTHON_PACKAGES_DIR/dist-packages ]
                    then
                        OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON_PACKAGES_PATH=$OPENCV_INSTALL_PREFIX/$PYTHON_PACKAGES_DIR/dist-packages"
                    else
                        OPENCV_CMAKE_FLAGS="$OPENCV_CMAKE_FLAGS -DPYTHON_PACKAGES_PATH=$OPENCV_INSTALL_PREFIX/$PYTHON_PACKAGES_DIR/site-packages"
                    fi
                }
            fi
        } &&
        echo "OPENCV_CMAKE_FLAG=S$OPENCV_CMAKE_FLAGS" &&
        cmake $OPENCV_CMAKE_FLAGS .. &&
        {
            if [ "$PYTHON2_ENV" != "" ]
            then
                source deactivate
            fi
        } 
    fi
} &&
make -j8 && make install &&
cd $WORK_DIR/$OPENCV_DOWNLOAD_DIR && rm -fr $OPENCV_UNZIP_DIR &&
echo "Installed opencv-$OPENCV_VERSION successfully!"
