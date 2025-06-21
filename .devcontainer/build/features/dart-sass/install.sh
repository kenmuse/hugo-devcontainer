#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne "0"  ]; then echo "Must be run as root or with sudo"; exit 1; fi

DEBIAN_FRONTEND=noninteractive apt-get update -qq 
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -qq apt-transport-https ca-certificates curl gpg tar gzip > /dev/null

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
DART_DIR="${DART_DIR:-"/usr/local/dart-sass"}"
# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

PROCESSOR_ARCHITECTURE=$(uname -m)
if [ "${PROCESSOR_ARCHITECTURE}" == "arm64" ] || [ "${PROCESSOR_ARCHITECTURE}" == "aarch64" ]; then
    declare -r PLATFORM=arm64
else
    declare -r PLATFORM=x64
fi

cd /tmp
declare -r DART_VERSION=$(curl -s https://api.github.com/repos/sass/dart-sass/releases/latest | grep '"tag_name":' | sed s/^.*\"\:// | cut -d\" -f2)
echo " ******* Installing Dart Sass v${DART_VERSION} (${PLATFORM}) ******* "
echo "Source: https://github.com/sass/dart-sass/download/v${DART_VERSION}/dart-sass-${DART_VERSION}-linux-${PLATFORM}.tar.gz"
curl -sLfo dart.tar.gz https://github.com/sass/dart-sass/releases/download/${DART_VERSION}/dart-sass-${DART_VERSION}-linux-${PLATFORM}.tar.gz
mkdir -p $DART_DIR
tar -xzvf dart.tar.gz -C $DART_DIR --strip-components=1 > /dev/null
rm dart.tar.gz
chown -R "${USERNAME}":"${USERNAME}" $DART_DIR
chmod -R g+r+w $DART_DIR
find $DART_DIR -type d -print0 | xargs -n 1 -0 chmod g+s

# Clean up
rm -rf /var/lib/apt/lists/*
