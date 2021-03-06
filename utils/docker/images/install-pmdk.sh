#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2019-2020, Intel Corporation

#
# install-pmdk.sh <package_type> - installs PMDK
#

set -e

PREFIX=/usr
PACKAGE_TYPE=$1

# master: Version 1.8; 31.01.2020
PMDK_VERSION="1.8"

if [ "${SKIP_PMDK_BUILD}" ]; then
	echo "Variable 'SKIP_PMDK_BUILD' is set; skipping building of PMDK"
	exit
fi

git clone https://github.com/pmem/pmdk --shallow-since=2020-01-15
cd pmdk
git checkout $PMDK_VERSION

if [ "$PACKAGE_TYPE" = "" ]; then
	make -j$(nproc) install prefix=$PREFIX
else
	make -j$(nproc) BUILD_PACKAGE_CHECK=n $PACKAGE_TYPE
	if [ "$PACKAGE_TYPE" = "dpkg" ]; then
		sudo dpkg -i dpkg/libpmem_*.deb dpkg/libpmem-dev_*.deb
		sudo dpkg -i dpkg/libpmemobj_*.deb dpkg/libpmemobj-dev_*.deb
	elif [ "$PACKAGE_TYPE" = "rpm" ]; then
		sudo rpm -i rpm/*/pmdk-debuginfo-*.rpm
		sudo rpm -i rpm/*/libpmem-*.rpm
		sudo rpm -i rpm/*/libpmemobj-*.rpm
	fi
fi

cd ..
rm -r pmdk
