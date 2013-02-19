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
echo ""
 
expect -c "
set timeout 3
spawn ssh $1
expect \"Are you sure you want to continue connecting (yes/no)?\" {
	send \"yes\n\"
	expect \"${id}@${host}'s password:\" {
		send \"${pass}\n\"
	}
} \"${id}@${host}'s password:\" {
	send \"${pass}\n\"
}

expect \"~]\" {
	send \"sudo -l\n\"
} \">\" {
	send \"sudo -l\n\"
}
expect \"Password:\" {
	send \"${pass}\n\"
} \"password\" {
	send \"${pass}\n\"
}
expect \"~]\" {
        send \"exit\n\"
} \">\" {
	send \"exit\n\"
}

interact
"
}

auto_ssh $1 $2


