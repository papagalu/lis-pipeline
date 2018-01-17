#!/bin/bash

set -xe

ARTIFACTS_PATH="$1"
KERNEL_VERSION="$2"
KERNEL_ARTIFACT_PATH=$(ls -td -- "$ARTIFACTS_PATH"/* |  grep  __msft-kernel_$KERNEL_VERSION | head -n 1)

cd "$WORKSPACE/scripts/linux_containers_on_windows/db_parser"
sudo pip install -r requirements.txt

echo "Copying the test results"
sudo cp "$KERNEL_ARTIFACT_PATH/results/tests.json" "$WORKSPACE/scripts/linux_containers_on_windows/db_parser"
if [[ $? -eq 0 ]]
then
	echo "Test results copied successfully"
else
	echo "Test results failed to copy"
fi
