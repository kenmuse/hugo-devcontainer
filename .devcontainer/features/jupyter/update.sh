#!/bin/sh

echo "Updating all dependencies to the latest versions ..."
pip3 install -r requirements.txt
pip3 list --format=json | jq -r '.[].name' | xargs -n1 pip3 install -U
pip3 freeze > requirements.txt
