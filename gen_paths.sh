#!/bin/sh

#https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/init.lua

URL_PREFIX="https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main"
URL_SUFFIX=""

ROUTER_MODULE="./Network/RouterLogic"
ENDPOINT_MODULE="./Network/EndpointLogic"
UTILS_MODULE="./Utils"

rm ./Install/paths.lua
rm ./Install/install.lua
mkdir Install

function rec(){
    if [ -d $1 ]; then
        # echo $1 is directory, opening...
        for i in $(ls $1)
        do
            rec "$1/$i" "$2" "$3"
        done
    else
        tmp="${1#*.}"
        echo "$2$tmp$3-->$1"
    fi
}

read -p "Path prefix (empty for default)" prefix
if [ "$prefix" = "" ]; then
    echo "using default prefix ($URL_PREFIX)"
    prefix=$URL_PREFIX
fi

read -p "Path suffix (empty for default)" suffix
if [ "$suffix" = "" ]; then
    echo "using default suffix ($URL_SUFFIX)"
    suffix=$URL_SUFFIX
fi

echo "PATHS = [[" >> ./Install/paths.lua
rec "." $prefix $suffix >> ./Install/paths.lua
echo "]]" >> ./Install/paths.lua

cat "./Install/paths.lua" >> "./Install/install.lua"
cat "./Install/setup.lua" >> "./Install/install.lua" 