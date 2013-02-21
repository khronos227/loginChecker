#!/bin/sh

#-----------------------
# ファイルを1行ごとに読み込む関数
# 空行は削除し、配列READ_DATAに格納する
#-----------------------
READ_DATA=()

function readFile(){
   READ_DATA=()
   if [ $# -lt 1 ]; then
      echo "読み込みファイルを指定してください。" 
      exit 1
   fi
   local readSimply=$#
   local count=0
   while read line
   do 
      trim ${line}
      line=${TRIMED_STR}
      #line=`echo "${line}" | sed -e 's/^\s*$//'`
      if [ "${line}" = "" ]; then
         continue
      fi
      if [ ${readSimply} -eq 1 ]; then
         line=`echo "${line}" | sed -e 's/^[^\[]*\[\(.*\)\].*$/\1/'`
      fi
      READ_DATA[${count}]="${line}"
      count=`expr ${count} + 1`
   done < $1
}

TRIMED_STR=""
function trim(){
   TRIMED_STR=""
   if [ $# -lt 1 ]; then
      return 0
   fi
   TRIMED_STR=`echo "$1" | sed -e 's/^\s*$//'`
}

#----------------------
# ファイルが存在し，読み取り可能であるかを確認する
# 返り値：読み取り可能=>0
#         読み取り不可=>1
#----------------------
function isReadableFile(){
   if [ ! -e $1 ]; then
      echo "ファイル${1}が存在しません。"
      return 1
   elif [ ! -f $1 ]; then
      echo "${1}はファイルではありません。"
      return 1
   elif [ ! -r $1 ]; then
      echo "${1}の読み込み権限がありません。"
      return 1
   elif [ ! -s $1 ]; then
      echo "${1}のファイルサイズが0です。"
      return 1
   fi
   return 0
}

