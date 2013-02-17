#!/bin/sh
#ログインテスト実行

if [ $# -ne 2 ]; then
   echo "[usage] loginTest.sh <file name> <password>"
   exit 1
fi

TIME=`date '+%Y%m%d%H%M%S'`
sh loginTest.sh "$1" "$2" > log/loginTest-${TIME}.log 2>&1
   

