#!/bin/sh
 
auto_ssh() {
trap "stty echo; exit 1" 2

host=$1
id=$2
#pass=$3
stty -echo
echo -n "password:"
read pass

stty echo
 
expect -c "
set timeout 5
spawn ssh $1
expect \"${id}@${host}'s password:\" {
send \"${pass}\n\"
} \"Name or service not known\" {
send \"echo \'$1 is not found\'\r\"
}
expect \"]\" {
send \"ls\r\"
}
expect \"]\" {
send \"hostname\r\"
}
interact
"
}

auto_ssh $1 $2 $3


echo "aaaaaaaaaaaaaa"
