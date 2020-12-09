#!/bin/bash

[[ -z "$1" ]] && { echo "error: terragrunt version required as argument (e.g v0.18.3)"; exit 1; }

version=$1
repo="https://github.com/gruntwork-io/terragrunt/releases/download/"
install_dir=/opt/terragrunt
mkdir -p $install_dir

case "$OSTYPE" in
  darwin*)  dist="darwin" ;;
  linux*)   dist="linux" ;;
  *)        echo "unknown: $OSTYPE" ; return -1;;
esac

release="terragrunt_${dist}_amd64"
url="${repo}${version}"
binary="$install_dir/${release}_${version}"

# only actually download and install if we need to
if [ ! -f $binary ]; then
  cwd=`pwd` 
  cd "${install_dir}" && \
    wget "${url}/SHA256SUMS"  && \
    wget "${url}/${release}" && \
    grep "${release}" SHA256SUMS | sha256sum -c && \
    chmod +x "$release" && \
    mv ${release} ${binary}
  cd $cwd
fi

[[ ! -f $binary ]] && { echo "error: no binary to symlink to."; exit 1; }
  
# always set up the symlink
rm -f /usr/local/bin/terragrunt
ln -s $binary /usr/local/bin/terragrunt

