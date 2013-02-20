#!/bin/sh
 
auto_ssh() {

host=$1
id=$2
pass=$3
expect -c "
set timeout 3
spawn ssh $1
expect \"Are you sure you want to continue connecting (yes/no)?\" {
	send \"yes\r\"
	expect \"${id}@${host}'s password:\" {
		send \"${pass}\r\"
	}
} \"${id}@${host}'s password:\" {
	send \"${pass}\r\"
}

expect \"~]\" {
	send \"sudo -l\r\"
} \">\" {
	send \"sudo -l\r\"
}
expect \"Password:\" {
	send \"${pass}\r\"
} \"password\" {
	send \"${pass}\r\"
} \":\" {
	send \"${pass}\r\"
}
expect \"~]\" {
        send \"exit\r\"
} \">\" {
	send \"exit\r\"
}

interact
"
}

