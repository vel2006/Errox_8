#!/bin/bash
#-SEEING IF THE PORTS ARE OPEN-#
ScanPorts()
{
	#A VARIABLE FOR HOLDING OPEN PORTS AND SERVICES#
	local returnArray=()
	#SCANNING THE IP TO SEE THE OPEN PORTS AND SERVICES#
	local smlPortsToScan=(7 9 13 21 22 23 25 26 37 53 79 80 81 88 106 110 111 113 119 135 139 143 144 179 199 389 427 443 444 445 465 513 514 515 543 544 548 554 587 631 646 873 990 993 995 1025 1026 1027 1028 1029 1110 1433 1720 1723 1755 1900 2000 2001 2049 2121 2717 3000 3128 3306 3389 3986 4899 5000 5009 5051 5060 5101 5109 5357 5432 5631 5666 5800 5900 6000 6001 6646 7070 8000 8008 8009 8080 8081 8443 8888 9100 9999 10000 32768 49152 49153 49154 49155 49156 49157)
	local medPortsToScan=(1 3 4 6 7 9 13 17 19 20 21 22 23 24 25 26 30 32 33 37 42 43 53 70 79 80 81 82 83 84 85 88 89 90 99 100 106 109 110 111 113 119 125 135 139 143 144 146 161 163 179 199 211 212 222 254 255 256 259 264 280 301 306 311 340 366 389 406 407 416 417 425 427 443 444 445 458 464 465 481 497 500 512 513 514 515 524 541 543 544 545 548 554 555 563 587 593 616 617 625 631 636 646 648 666 667 668 683 687 691 700 705 711 714 720 722 726 749 765 777 783 787 800 801 808 843 873 873 880 888 898 900 901 902 903 911 912 981 987 990 992 993 995 999 1000)
	#MAKING THE TEMP VAR LOCAL#
	local temp=""
	#DOING A SMALL PORT SCAN#
	if [[ $2 == "sm" ]]; then
		#LOOPING THROUGH THE PORTS#
		for port in ${smlPortsToScan[@]}; do
			echo "Trying port: $port"
			#SCANNING THE PORT AND SAVING IT WITHIN A TEMP VARIABLE#
			temp=$(sudo nc -zv -w 1 $1 $port 2>&1 | grep "open")
			#IF ITS NULL, MEANING THAT THE PORT IS EITHER CLOSED OR ITS HIDING....SNEAKY#
			if [[ -z "$temp" ]]; then
				continue
			else
				#THIS IF STATEMENT IS USEFULL, ITS SO THAT WHEN AN IP IS SCANNED NOT A DOMAIN eg: 1.1.1.1 NOT site.com#
				if [[ $(echo "$temp" | awk '{print $1}') == "(UNKNOWN)" ]]; then
					#ADDING THE OUTPUT TO AN ARRAY FOR STORAGE#
					returnArray+=($(echo "$temp" | awk '{print $3}'))
					returnArray+=($(echo "$temp" | awk '{print $4}' | awk -F '[()]' '{print $2}'))
				else
					returnArray+=($(echo "$temp" | awk '{print $2}'))
					returnArray+=($(echo "$temp" | awk '{print $3}' | awk -F '[()]' '{print $2}'))
				fi
			fi
		done
	#DOING A NORMAL SIZED PORT SCAN#
	elif [[ $2 == "md" ]]; then
		#LOOPING THROUGH THE PORTS#
		for port in ${medPortsToScan[@]}; do
			#TELLING THE USER WHICH PORT IS BEING SCANNED#
			echo "Trying port: $port"
			#SCANNING THE PORT AND SAVING THE OUTPUT INSIDE OF A TEMP VARIABLE#
			temp=$(nc -zv -w 1 $1 $port 2>&1 | grep "open")
			#IF THE OUTPUT IS NULL, THE PORT IS EITHER CLOSED OR SOMEONE IS BEING SNEEKY#
			if [[ -z "$temp" ]]; then
				continue
			else
				#THIS IF STATEMENT IS USEFULL, ITS SO THAT WHEN AN IP IS SCANNED NOT A DOMAIN eg: 1.1.1.1 NOT site.com#
				if [[ $(echo "$temp" | awk '{print $1}') == "(UNKNOWN)" ]]; then
					#ADDING THE OUTPUT TO AN ARRAY FOR STORAGE#
					returnArray+=($(echo "$temp" | awk '{print $3}'))
					returnArray+=($(echo "$temp" | awk '{print $4}' | awk -F '[()]' '{print $2}'))
				else
					returnArray+=($(echo "$temp" | awk '{print $2}'))
					returnArray+=($(echo "$temp" | awk '{print $3}' | awk -F '[()]' '{print $2}'))
				fi
			fi
		done
	#SCANNING THE PORT THAT WAS PASSED INSTEAD OF A SCAN SIZE#
	elif [[ "$2" =~ ^[0-9]+$ ]]; then
		#SAVING THE PORT SCAN IN THE TEMP VARIABLE#
		temp=$(nc -zv -w 1 $1 $2 2>&1 | grep "open")
		#SEEING IF THE OUTPUT IS NULL (YES THIS IS A DIFFERENT WAY)
		if [[ $? -ne 0 ]]; then
			echo "Not open"
		else
			#THIS IF STATEMENT IS USEFULL, ITS SO THAT WHEN AN IP IS SCANNED NOT A DOMAIN eg: 1.1.1.1 NOT site.com#
			if [[ $(echo "$temp" | awk '{print $1}') == "(UNKNOWN)" ]]; then
				#YES, IM ADDING IT TO THE ARRAY, THIS IS GOING TO BE USEFULL LATER#
				returnArray+=($(echo "$temp" | awk '{print $3}'))
				returnArray+=($(echo "$temp" | awk '{print $4}' | awk -F '[()]' '{print $2}'))
			else
				returnArray+=($(echo "$temp" | awk '{print $2}'))
				returnArray+=($(echo "$temp" | awk '{print $3}' | awk -F '[()]' '{print $2}'))
			fi
		fi
	fi
	#SEEING IF THE USER INPUT FOR THERE TO BE AN INDEPTH SCAN#
	if [[ -z $3 ]]; then
		#PRINTING OUT THE PORTS AND SERVICE#
		echo ${returnArray[@]}
	else
		#THIS IS WHY EVERYTHING IS STORED INSIDE THE ARRAY, EASE OF RUNTIME#
		for (( i = 1; i < ${#returnArray[@]}; i += 2 )); do
			#GETTING THE PORT INFO#
			echo "Port: ${returnArray[$i - 1]}"
			echo "Info:"
			PortInfo ${returnArray[$i]} $1 ${returnArray[$i - 1]}
		done
	fi
}
#GETTING SERVICE RUNNING ON PORT INFO#
PortInfo()
{
	if [[ $1 == 'http' ]]; then
		#THIS LOOKS WEIRD, BECAUSE IT IS. FOR WHATEVER REASON IT REFUSES TO PRINT OUT ALL LINES UNLESS ITS THROUGH CAT#
		(echo -e "HEAD / HTTP/1.1\r\nHost: $2\r\nConnection: close\r\n\r\n" | nc $2 $3 2>&1) > temp.txt
		sudo cat temp.txt
		sudo rm temp.txt
	elif [[ $1 == 'ftp' ]]; then
		#GETTING THE INFO OVER FTP#
		for id_string in "220" "220-" "220 ProFTPD" "220 vsFTPd"; do
			echo -e "HELP\r\n" | nc -w 5 $2 $3 | grep "vsFTP" && break
		done
	elif [[ $1 == 'ssh' ]]; then
		#GETTING THE INFO OVER SSH#
		for id_string in "SSH-2.0-OpenSSH_" "SSH-2.0-SSH_" "SSH-2.0"; do
			echo -e "${id_string}\r\n" | nc -w 5 $2 $3 | grep -oP "SSH-\S+" && break
		done
	else
		#ITS 23:05...LET ME SLEEP#
		echo "$1 is not supported yet, please file this as a problem on the github: github.com/vel2006/Errox_8"
	fi
}
#-STARTUP LOGIC, USED TO FIND WHAT MODE THE SCRIPT WILL RUN IN-#
if [[ $# == 0 ]]; then
	echo "Enter the ip you wish to scan"
	read -p ">" target
	echo "What type of scan do you want to do"
	echo "small, medium, large, or type a port number (sm/md/lr/(port number))"
	read -p ">" port
	echo "Get service info (y/n)"
	read -p ">" Yn
	if [[ $Yn == 'y' ]]; then
		ScanPorts $target $port 1
	else
		ScanPorts $target $port
	fi
elif [[ $1 == "-help" ]]; then
	#HELP PAGE FOR USERS#
	echo "WARNING!"
	echo "THIS FILE IS OPTIMIZED FOR LAN NETWORKS AND HAS NOT BEEN TESTED ON ANY WLAN NETWORKS OR FORIN IPS"
	echo "THIS FILE HAS ONLY BEEN TESTEN ON THE eth0 INTERFACE AND NONE OTHERS, BE SURE TO CHANGE IF NEEDED"
	echo "Programed by: That1EthicalHacker"
	echo "Errox_8.sh is a script for port scanning, this will not replace nmap but is anoter option for those who want to use just bash"
	echo "Simply run the script and answer the prompts, and the script will do the rest"
	echo "If you encounter a problem, or want something added, add it to github.com/vel2006/Errox_8"
	echo "Happy pentesting"
else
	#FIRST TIME?#
	echo "Run './Errox_7Server.sh -help' or read 'README.md' for assistance"
fi
