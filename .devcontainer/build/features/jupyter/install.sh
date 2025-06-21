#!/usr/bin/env bash

if [ "alpine" == "$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2)" ]
then
    sudo apk --no-cache --update-cache add gcc gfortran python3 \
    python3-dev py3-pip build-base wget freetype-dev libpng-dev \
    openblas-dev linux-headers libffi-dev cairo-dev pandoc
else
    sudo apt-get update
    sudo apt-get install -y python3-dev libpng-dev libffi-dev pandoc python3-pip libcairo2-dev

    # Clean up
    sudo apt-get clean
    sudo rm -rf /var/lib/apt/lists/*
fi

sudo -H pip install --no-cache-dir  -U pip setuptools wheel
#sudo -H pip install ipykernel notebook nbconvert
sudo -H pip install --no-cache-dir  -U ipykernel notebook matplotlib numpy scipy svglib seaborn jupyter nbconvert pandas
# sudo su -s /bin/sh ${_CONTAINER_USER} << EOF
# pip download -r requirements.txt --only-binary ':all:' --no-binary cffi,kiwisolver,matplotlib,psutil,pycairo,pandas,numpy,pyYAML,retrying,scipy,svglib
# pip install -U --user --prefer-binary ipykernel notebook matplotlib numpy scipy svglib seaborn jupyter nbconvert pandas
# EOF
rm -Rf /root/.cache/pip
