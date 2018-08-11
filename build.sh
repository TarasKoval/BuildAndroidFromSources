#!/bin/bash
set -o errexit
set -o nounset

if [[ $# -ne 1 ]]; then
	echo "usage: $0 <\"parametres\">"
	exit 0
fi

set +u

installPath=$1

## declare an array variable
declare -a listOfPackages=(	"openjdk-8-jdk" "git-core" "gnupg" "flex" "bison" "gperf" "build-essential" 
							"zip" "curl" "zlib1g-dev" "gcc-multilib" "ccache" "g++-multilib" "libc6-dev-i386" 
							"lib32ncurses5-dev" "x11proto-core-dev" "libx11-dev" "lib32z-dev" "libgl1-mesa-dev" 
							"libxml2-utils" "liblz4-tool" "xsltproc" "unzip" "python-networkx" "python-wand" 
							"python-crypto" "sed")

## now loop through the above array and install needed packages
for package in "${listOfPackages[@]}"
do
   if ! [ -x "$(command -v "$package")" ]; then
	sudo apt-get install "$package"
fi
done

cd "$installPath"
export workspace=$(pwd)/android
mkdir -p ${workspace}
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ${workspace}/repo
chmod +x ${workspace}/repo
cd ${workspace}
${workspace}/repo init -u https://android.googlesource.com/platform/manifest -b android-8.1.0_r41
${workspace}/repo sync -j4 -c --no-tags

sed -i 's/PROP_VALUE_MAX\ =\ 91/PROP_VALUE_MAX\ =\ 128/g' ./build/tools/post_process_props.py

export USE_CCACHE=1
export CCACHE_DIR=${workspace}/.ccache
${workspace}/prebuilts/misc/linux-x86/ccache/ccache -M 50G
source build/envsetup.sh
lunch aosp_car_x86_64
make
