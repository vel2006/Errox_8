#!/bin/bash
#-SEEING IF THE PORTS ARE OPEN-#
ScanPorts()
{
	#A VARIABLE FOR HOLDING OPEN PORTS AND SERVICES#
	returnArray=()
	#SCANNING THE IP TO SEE THE OPEN PORTS AND SERVICES#
	smlPortsToScan=(7 9 13 21 22 23 25 26 37 53 79 80 81 88 106 110 111 113 119 135 139 143 144 179 199 389 427 443 444 445 465 513 514 515 543 544 548 554 587 631 646 873 990 993 995 1025 1026 1027 1028 1029 1110 1433 1720 1723 1755 1900 2000 2001 2049 2121 2717 3000 3128 3306 3389 3986 4899 5000 5009 5051 5060 5101 5109 5357 5432 5631 5666 5800 5900 6000 6001 6646 7070 8000 8008 8009 8080 8081 8443 8888 9100 9999 10000 32768 49152 49153 49154 49155 49156 49157)
	medPortsToScan=(1 3 4 6 7 9 13 17 19 20 21 22 23 24 25 26 30 32 33 37 42 43 53 70 79 80 81 82 83 84 85 88 89 90 99 100 106 109 110 111 113 119 125 135 139 143 144 146 161 163 179 199 211 212 222 254 255 256 259 264 280 301 306 311 340 366 389 406 407 416 417 425 427 443 444 445 458 464 465 481 497 500 512 513 514 515 524 541 543 544 545 548 554 555 563 587 593 616 617 625 631 636 646 648 666 667 668 683 687 691 700 705 711 714 720 722 726 749 765 777 783 787 800 801 808 843 873 873 880 888 898 900 901 902 903 911 912 981 987 990 992 993 995 999 1000)
	if [[ $2 == "sm" ]]; then
		for port in ${smlPortsToScan[@]}; do
			echo "Trying port: $port"
			temp=$(sudo nc -zv -w 1 $1 $port 2>&1 | grep "open")
			if [[ $port == 7 ]]; then
				if [[ -z "$temp" ]]; then
					continue
				else
					if [[ $(echo "$temp" | awk '{print $1}') == "(UNKNOWN)" ]]; then
     						returnArray+=($(echo "$temp" | awk '{print $3}'))
	   					returnArray+=($(echo "$temp" | awk '{print $4}' | awk -F '[()]' '{print $2}'))
	 				else
      						returnArray+=($(echo "$temp" | awk '{print $2}'))
	    					returnArray+=($(echo "$temp" | awk '{print $3}' | awk -F '[()]' '{print $2}'))
	  				fi
				fi
			else
				if [[ -z "$temp" ]]; then
					continue
				else
					if [[ $(echo "$temp" | awk '{print $1}') == "(UNKNOWN)" ]]; then
						returnArray+=($(echo "$temp" | awk '{print $3}'))
						returnArray+=($(echo "$temp" | awk '{print $4}' | awk -F '[()]' '{print $2}'))
					else
						returnArray+=($(echo "$temp" | awk '{print $2}'))
						returnArray+=($(echo "$temp" | awk '{print $3}' | awk -F '[()]' '{print $2}'))
					fi
				fi
			fi
		done
	elif [[ $2 == "md" ]]; then
		for port in ${medPortsToScan[@]}; do
			echo "Trying port: $port"
			temp=$(nc -zv -w 1 $1 $port 2>&1 | grep "open")
			if [[ -z "$temp" ]]; then
				continue
			else
				if [[ $port == 1 ]]; then
					if [[ $(echo "$temp" | awk '{print $1}') == "(UNKNOWN)" ]]; then
						returnArray+=($(echo "$temp" | awk '{print $3}'))
						returnArray+=($(echo "$temp" | awk '{print $4}' | awk -F '[()]' '{print $2}'))
					else
						returnArray+=($(echo "$temp" | awk '{print $2}'))
						returnArray+=($(echo "$temp" | awk '{print $3}' | awk -F '[()]' '{print $2}'))
					fi
				fi
			fi
		done
	elif [[ "$2" =~ ^[0-9]+$ ]]; then
		temp=$(nc -zv -w 1 $1 $2 2>&1 | grep "open")
		if [[ $? -ne 0 ]]; then
			echo "Port: $2 is not open"
		else
			if [[ $(echo "$temp" | awk '{print $1}') == "(UNKNOWN)" ]]; then
				returnArray+=($(echo "$temp" | awk '{print $3}'))
				returnArray+=($(echo "$temp" | awk '{print $4}' | awk -F '[()]' '{print $2}'))
			else
				returnArray+=($(echo "$temp" | awk '{print $2}'))
				returnArray+=($(echo "$temp" | awk '{print $3}' | awk -F '[()]' '{print $2}'))
			fi
		fi
	fi
	echo "${returnArray[@]}"
}
#-STARTUP LOGIC, USED TO FIND WHAT MODE THE SCRIPT WILL RUN IN-#
if [[ $# == 0 ]]; then
	echo "Enter the ip you wish to scan"
	read -p ">" target
	echo "What type of scan do you want to do"
	echo "small, medium, large, or type a port number (sm/md/lr/(port number))"
	read -p ">" port
	ScanPorts $target $port
elif [[ $1 == "-help" ]]; then
	#HELP PAGE FOR USERS#
	echo "WARNING!"
	echo "THIS FILE IS OPTIMIZED FOR LAN NETWORKS AND HAS NOT BEEN TESTED ON ANY WLAN NETWORKS OR FORIN IPS"
	echo "THIS FILE HAS ONLY BEEN TESTEN ON THE eth0 INTERFACE AND NONE OTHERS, BE SURE TO CHANGE IF NEEDED"
	echo "Programed by: That1EthicalHacker"
 	echo "Read the README.md file"
else
	#FIRST TIME?#
	echo "Run './Errox_7Server.sh -help' for assistance"
fi
