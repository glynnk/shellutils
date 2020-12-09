#!/bin/bash

[[ -z "$1" ]] && { echo "error: terraform version required as argument (e.g 0.12.21)"; exit 1; }

case "$OSTYPE" in
  darwin*)  dist="darwin" ;;
  linux*)   dist="linux" ;;
  *)        echo "unknown: $OSTYPE" ; return -1;;
esac

url="https://releases.hashicorp.com/terraform/$1/terraform_${1}_${dist}_amd64.zip"

version=$1
repo="https://releases.hashicorp.com/terraform/"
install_dir=/opt/terraform
mkdir -p $install_dir


binary="$install_dir/terraform_${1}_${dist}_amd64"

# only actually download and install if we need to
if [ ! -f $binary ]; then
  cwd=`pwd` 
  cd "${install_dir}" && \
    wget $url  && \
    unzip terraform_${1}_${dist}_amd64.zip && \
    mv terraform $binary
  cd $cwd
fi

[[ ! -f $binary ]] && { echo "error: no binary to symlink to."; exit 1; }
  
# always set up the symlink
rm -f /usr/local/bin/terraform
ln -s $binary /usr/local/bin/terraform

