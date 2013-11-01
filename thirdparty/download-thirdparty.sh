#!/bin/bash
# Copyright (c) 2013, Cloudera, inc.

set -x
set -e

TP_DIR=$(readlink -f $(dirname $BASH_SOURCE))
cd $TP_DIR

source vars.sh

TARBALL="cyrus-sasl-${CYRUS_SASL_VERSION}.tar.gz"
if [ ! -f "$TARBALL" ]; then
  echo "Fetching cyrus-sasl"
  wget ${CLOUDFRONT_URL_PREFIX}/$TARBALL
fi
if [ -d cyrus-sasl-${CYRUS_SASL_VERSION} ]; then
  # jenkins / rhel has problems if we don't build from pristine every time
  rm -rf cyrus-sasl-${CYRUS_SASL_VERSION}
fi
tar xvzf $TARBALL
unset TARBALL

if [ ! -d gtest-${GTEST_VERSION} ]; then
  echo "Fetching gtest"
  wget -c ${CLOUDFRONT_URL_PREFIX}/gtest-${GTEST_VERSION}.zip
  unzip gtest-${GTEST_VERSION}.zip
  rm gtest-${GTEST_VERSION}.zip
fi

if [ ! -d glog-${GLOG_VERSION} ]; then
  echo "Fetching glog"
  wget -c ${CLOUDFRONT_URL_PREFIX}/glog-${GLOG_VERSION}.tar.gz
  tar xzf glog-${GLOG_VERSION}.tar.gz
  rm glog-${GLOG_VERSION}.tar.gz
fi

if [ ! -d gflags-${GFLAGS_VERSION} ]; then
  echo "Fetching gflags"
  wget -c ${CLOUDFRONT_URL_PREFIX}/gflags-${GFLAGS_VERSION}.zip
  unzip gflags-${GFLAGS_VERSION}.zip
  rm gflags-${GFLAGS_VERSION}.zip
fi

# Check that the gperftools patch has been applied.
# If you add or remove patches, bump the patchlevel below to ensure
# that any new Jenkins builds pick up your patches.
GPERFTOOLS_PATCHLEVEL=1
if [ ! -f gperftools-${GPERFTOOLS_VERSION}/patchlevel-$GPERFTOOLS_PATCHLEVEL ]; then
  echo It appears that the gperftools version we have is missing
  echo the latest local patches. Removing it so we re-download it.
  rm -Rf gperftools-${GPERFTOOLS_VERSION}
fi

if [ ! -d gperftools-${GPERFTOOLS_VERSION} ]; then
  echo "Fetching gperftools"
  wget -c ${CLOUDFRONT_URL_PREFIX}/gperftools-${GPERFTOOLS_VERSION}.tar.gz
  tar xzf gperftools-${GPERFTOOLS_VERSION}.tar.gz
  rm gperftools-${GPERFTOOLS_VERSION}.tar.gz
  pushd gperftools-${GPERFTOOLS_VERSION}
  patch -p1 < $TP_DIR/patches/gperftools-issue-560-Revert-issue-481.patch
  touch patchlevel-$GPERFTOOLS_PATCHLEVEL
  popd
fi

if [ ! -d protobuf-${PROTOBUF_VERSION} ]; then
  echo "Fetching protobuf"
  wget -c ${CLOUDFRONT_URL_PREFIX}/protobuf-${PROTOBUF_VERSION}.tar.gz
  tar xzf protobuf-${PROTOBUF_VERSION}.tar.gz
  rm protobuf-${PROTOBUF_VERSION}.tar.gz
fi

if [ ! -d cmake-${CMAKE_VERSION} ]; then
  echo "Fetching cmake"
  wget -c ${CLOUDFRONT_URL_PREFIX}/cmake-${CMAKE_VERSION}.tar.gz
  tar xzf cmake-${CMAKE_VERSION}.tar.gz
  rm cmake-${CMAKE_VERSION}.tar.gz
fi

if [ ! -d snappy-${SNAPPY_VERSION} ]; then
  echo "Fetching snappy"
  wget -c ${CLOUDFRONT_URL_PREFIX}/snappy-${SNAPPY_VERSION}.tar.gz
  tar xzf snappy-${SNAPPY_VERSION}.tar.gz
  rm snappy-${SNAPPY_VERSION}.tar.gz
fi

if [ ! -d zlib-${ZLIB_VERSION} ]; then
  echo "Fetching zlib"
  wget -c ${CLOUDFRONT_URL_PREFIX}/zlib-${ZLIB_VERSION}.tar.gz
  tar xzf zlib-${ZLIB_VERSION}.tar.gz
  rm zlib-${ZLIB_VERSION}.tar.gz
fi

if [ ! -d libev-${LIBEV_VERSION} ]; then
  echo "Fetching libev"
  wget ${CLOUDFRONT_URL_PREFIX}/libev-${LIBEV_VERSION}.tar.gz
  tar xvzf libev-${LIBEV_VERSION}.tar.gz
  rm libev-${LIBEV_VERSION}.tar.gz
fi

if [ ! -d $RAPIDJSON_DIR ]; then
  echo "Fetching rapidjson"
  wget ${CLOUDFRONT_URL_PREFIX}/rapidjson-${RAPIDJSON_VERSION}.zip
  unzip rapidjson-${RAPIDJSON_VERSION}.zip
  mv rapidjson ${RAPIDJSON_DIR}
  rm rapidjson-${RAPIDJSON_VERSION}.zip
fi

if [ ! -d $SQUEASEL_DIR ]; then
  echo "Fetching squeasel"
  wget -O squeasel-${SQUEASEL_VERSION}.tar.gz ${CLOUDFRONT_URL_PREFIX}/squeasel-${SQUEASEL_VERSION}.tar.gz
  tar xzf squeasel-$SQUEASEL_VERSION.tar.gz
  rm squeasel-$SQUEASEL_VERSION.tar.gz
fi

if [ ! -d $GSG_DIR ]; then
  echo "Fetching google style guide"
  wget ${CLOUDFRONT_URL_PREFIX}/google-styleguide-r${GSG_REVISION}.tar.gz
  tar xzf google-styleguide-r${GSG_REVISION}.tar.gz
  rm google-styleguide-r${GSG_REVISION}.tar.gz
fi

if [ ! -d $GCOVR_DIR ]; then
  echo "Fetching gcovr"
  wget ${CLOUDFRONT_URL_PREFIX}/gcovr-${GCOVR_VERSION}.tar.gz
  tar xzf gcovr-${GCOVR_VERSION}.tar.gz
  rm gcovr-${GCOVR_VERSION}.tar.gz
fi

if [ ! -d $CURL_DIR ]; then
  echo "Fetching curl"
  wget ${CLOUDFRONT_URL_PREFIX}/curl-${CURL_VERSION}.tar.gz
  tar xzf curl-${CURL_VERSION}.tar.gz
  rm curl-${CURL_VERSION}.tar.gz
fi

echo "---------------"
echo "Thirdparty dependencies downloaded successfully"
