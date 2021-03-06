#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2019-2020, Intel Corporation

#
# run-build.sh <pmemkv_version> - is called inside a Docker container;
#        checks bindings' building and installation with given version of pmemkv
#

set -e

source `dirname $0`/prepare-for-build.sh

function run_example() {
	example_name=$1
	jar_path=../pmemkv-binding/target/pmemkv-1.0.0.jar
# Find path to a jar with specific example name
  example_path=`find .. | grep -P '\b(?!pmemkv)\b([a-zA-Z]+)\-([0-9.]+)\.jar' | grep ${example_name}`
	java -ea -Xms1G -cp ${jar_path}:${example_path} ${example_name}
}

# install pmemkv
pmemkv_version=$1
cd /opt/pmemkv-$pmemkv_version/
if [ "${PACKAGE_MANAGER}" = "deb" ]; then
	echo $USERPASS | sudo -S dpkg -i libpmemkv*.deb
elif [ "${PACKAGE_MANAGER}" = "rpm" ]; then
	echo $USERPASS | sudo -S rpm -i libpmemkv*.rpm
else
	echo "PACKAGE_MANAGER env variable not set or set improperly ('deb' or 'rpm' supported)."
	exit 1
fi

echo
echo "###########################################################"
echo "### Verifying building and installing of the java bindings"
echo "###########################################################"
cd $WORKDIR
mkdir -p ~/.m2/repository
cp -r /opt/java/repository ~/.m2/
mvn install -e

echo
echo "###########################################################"
echo "### Verifying building and execution of examples"
echo "###########################################################"
cd examples
run_example StringExample
run_example ByteBufferExample
run_example MixedTypesExample
#PicturesExample is a GUI application, so just test compilation.
run_example PicturesExample

# Trigger auto doc update
if [[ "$AUTO_DOC_UPDATE" == "1" ]]; then
	echo "Running auto doc update"
	$SCRIPTSDIR/run-doc-update.sh
fi
