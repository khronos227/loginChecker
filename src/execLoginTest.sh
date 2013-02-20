#!/bin/sh
#ログインテスト実行

if [ $# -ne 1 ]; then
   echo "[usage] loginTest.sh <file name>"
   exit 1
fi

trap "stty echo; exit 1" 2

stty -echo
echo -n "password:"
read PASSWORD

stty echo
echo ""

TIME=`date '+%Y%m%d%H%M%S'`
sh loginTest.sh "$1" "${PASSWORD}" > log/loginTest-${TIME}.log 2>&1
   

