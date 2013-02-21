#!/bin/sh

. ./util.sh

readFile $1 simple

LOGINED_SERVERS=()
function getLoginedServers(){
   local str=""
   LOGINED_SERVERS=()
   local count=0
   for INDEX in `seq 0 ${#READ_DATA[*]}`
   do
      str=`echo "${READ_DATA[${INDEX}]}" | awk '{ num = split($0,arr,":"); if(num == 2 && arr[1] == "Login_Success") print arr[2] }'`
      trim ${str}
      str=${TRIMED_STR}
      if [ ${#str} -eq 0 ]; then
         continue
      fi
      LOGINED_SERVERS[${count}]="${str}"
      count=`expr ${count} + 1`
   done
}

getLoginedServers
echo "num: ${#LOGINED_SERVERS[*]}"
for line in ${LOGINED_SERVERS[*]}
do
   echo $line
done
