#!/bin/sh
# 皆さんが苦労するであろう
# サーバ申請後のログイン確認テストを
# 自動で行うためのスクリプト

. loginTest3.sh

#-----------------------
# ファイルを1行ごとに読み込む関数
# 空行は削除し、配列READ_DATAに格納する
#-----------------------
READ_DATA=()

function readFile(){
   local count=0
   local null_line=" *"
   local default="*"
   while read line
   do 
      line=`echo "${line}" | sed -e 's/^\s*$//'`
      if [ "${line}" = "" ]; then
         continue
      fi
      line=`echo "${line}" | sed -e 's/^[^\[]*\[\(.*\)\].*$/\1/'`
      READ_DATA[${count}]="${line}"
      count=`expr ${count} + 1`
   done < $1
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

#---------------------
# 各ホストへのアクセステストを行う
# 1.ホスト名の生成
# 2.アクセス
# 3.sudo権限の確認
#---------------------
function accessTest(){
   if [ "$1" = "" ]; then
      echo "接続先ホストがありません。"
      echo "処理をスキップします。"
      return 1
   fi
   local sudoArry=( $2 )
   local sudoCommand=""
   for SUDO in ${sudoArry[@]}
   do
      sudoCommand="${sudoCommand}sudo su ${SUDO};${PASSWORD};exit;"
   done

   local hostArry=( $1 )
   local maxIndex=`expr ${#hostArry[*]} - 1`
   for INDEX in `seq 1 ${maxIndex}`
   do
      local val=${hostArry[$INDEX]}
      case ${val} in
      *-*)
         val=( `echo "${val}" | tr '[' ' ' | tr ']' ' '` )
         local range=`echo ${val[0]} | tr '-' ' '`
         for INDEX in `seq ${range}`
         do
            #echo "${hostArry[0]}${INDEX}${val[1]}に対してアクセステストを行います。"
            #echo "ssh ${hostArry[0]}${INDEX}${val[1]};y;${PASSWORD};${sudoCommand}exit;"
            #ssh ${hostArry[0]}${INDEX}${val[1]} | "y;${PASSWORD};${sudoCommand}exit;"
	    auto_ssh ${hostArry[0]}${INDEX}${val[1]} otatakefumi01 ${PASSWORD}
         done
         ;;
      *)
         #echo "${hostArry[0]}${val}に対してアクセステストを行います。"
         #ssh ${hostArry[0]}${val} | "y;${PASSWORD};${sudoCommand}exit;"
	 auto_ssh ${hostArry[0]}${val} otatakefumi01 ${PASSWORD}
         ;;
      esac
   done
}

function accessTest2(){
auto_ssh $1 $2 $PASSWORD
}

#----------------------
# main
#----------------------
if [ $# -ne 2 ]; then
   echo "[usage] loginTest.sh <file name> <password>"
   exit 1;
fi

isReadableFile $1
if [ ! $? -eq 0 ]; then
   echo "${1}を読み込むことが出来ませんでした。"
   exit 1
fi
echo "$1の読み込みを開始します。"
readFile $1
echo "$1読み込み完了。"

echo "読み込み結果(行数)チェック"
if [ `expr ${#READ_DATA[*]} % 3` -ne 0 ]; then
   echo "サーバのリストファイルに不備があります。"
   echo "再度ご確認ください。"
   exit 1
fi
echo "読み込み結果(行数)チェック完了"

PASSWORD="$2"

echo "アクセステスト開始"
SERVER_MAX_INDEX=`expr \( ${#READ_DATA[*]} / 3 \) - 1`
for INDEX in `seq 0 ${SERVER_MAX_INDEX}`
do
   i=`expr ${INDEX} \* 3`
   HOST_NAMES="${READ_DATA[i]}"
   HOST_NAMES=`echo "${HOST_NAMES}" | tr ',' ' '`
   i=`expr ${i} + 1`
   SUDO_USERS="${READ_DATA[i]}"
   SUDO_USERS=`echo "${SUDO_USERS}" | tr ',' ' '`
   i=`expr ${i} + 1`
   GROUP_LIST="${READ_DATA[i]}"
   GROUP_LIST=`echo "${GROUP_LIST}" | tr ',' ' '`
   accessTest "${HOST_NAMES}" "${SUDO_USERS}" "${GROUP_LIST}"
done
echo "アクセステスト完了"
