#!/bin/bash
set -xe

OPENGCS_GIT_REPO="$1"
MS_KERNEL_GIT_REPO="$2"
GIT_BRANCH="$3"
ARTIFACTS_PATH="$4"

# construct the path of each artifact based on the root artifact path
OPENGCS_ARTIFACT_DIR_PATH=$(ls -td -- $ARTIFACTS_PATH/* |  grep "__opengcs$" | head -n 1)
KERNEL_ARTIFACT_DIR_PATH=$(ls -td -- "$ARTIFACTS_PATH"/* |  grep  __msft-kernel_4.12 | head -n 1)

function check_opengcs_last_commit() {
    pushd "./opengcs"

    latest_opengcs_commit=$(git log --pretty=format:'%h' -n 1)
	latest_opengcs_built_commit=$(cat $OPENGCS_ARTIFACT_DIR_PATH/latest_opengcs_commit.log)

	if [ "$latest_opengcs_commit" != "$latest_opengcs_built_commit" ]
	then
	   echo "New opengcs build needed!"
	   echo "Lastest built commit: $latest_opengcs_built_commit"
	   echo "Latest commit on repo: $latest_opengcs_commit"
	else
        build_opengcs_status="no"
        echo "STATUS: ${build_opengcs_status} -> NO commits to build!"
	fi
    popd
}

function check_mskernel_last_commit() {
	pushd "./linux_kernel"

    latest_commit=$(git log --pretty=format:'%h' -n 1)
    latest_built_commit=$(cat $KERNEL_ARTIFACT_DIR_PATH/latest_kernel_commit.log)

    if [ "$latest_commit" != "$latest_built_commit" ]
    then
        echo "New kernel build needed!"
        echo "Lastest built commit: $latest_built_commit"
        echo "Latest commit on repo: $latest_commit"
    else
        build_kernel_status="no"
        echo "STATUS: ${build_kernel_status} -> NO commits to build!"
    fi
    popd
}

function get_repos() {
    # if opengcs repo exists, pull commits, if not -> clone it
    if [[ -d "./opengcs" ]]
    then
        pushd "./opengcs"
        git pull
        popd
    else
        git clone "${OPENGCS_GIT_REPO}" -b "${GIT_BRANCH}" opengcs
    fi

    # if MS linux kernel repo exists, pull commits, if not -> clone it
    if [[ -d "./linux_kernel" ]]
    then
		pushd "./linux_kernel"
        git pull
        popd
    else
        git clone "${MS_KERNEL_GIT_REPO}" -b "${GIT_BRANCH}" linux_kernel
    fi
}

if [[ ! -d "${ARTIFACTS_PATH}" ]]
then
    echo "${ARTIFACTS_PATH} artifacts path is not accessible, check the SMB share connectivity"
    exit 1
fi

get_repos
check_opengcs_last_commit
check_mskernel_last_commit

if [ "$build_opengcs_status" == "no" ] && [ "$build_kernel_status" == "no" ]
then
	echo "NOT triggering pipeline, NO new commits!"
    exit 1
else
	echo "Triggering pipeline, NEW commits!"
fi