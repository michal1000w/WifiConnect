#!/bin/bash
clear

while true
do
	printf "$(tput setaf 2)Welcome to Wifi Connecter\n"
	printf "$(tput setaf 1)author: Michał Wieczorek$(tput setaf 2)\n\n"

	printf "connect    -   Connect you to a network\n"
	printf "netinfo    -   Shows you current net connection\n"
	printf "exit       -   Exit\n\n"

	read komenda

	if [ "$komenda" == "connect" ]; then
		clear
		printf "$(tput setaf 1)Disconnecting from current wifi & restarting network services..."
		service network-manager restart
		service networking restart
		ifconfig wlan0 down

		printf "\n\nStarting up wlan0...\n"
		ifconfig wlan0 up

		printf "$(tput setaf 1)Scanning available networks...\n\n"
		printf "$(tput setaf 2)Networks:\n$(tput setaf 7)"
		iw wlan0 scan | grep "SSID"

		printf "\n\nSet the name of a network you want to connect: "
		read SSID
		printf "\nSet a password: "
		read -s PASSWORD

		printf "\n\n$(tput setaf 1)Creating password file for $SSID"
		wpa_passphrase $SSID $PASSWORD >> password.conf

		printf "\n\n$(tput setaf 2)Connecting to: $SSID\n\n$(tput setaf 7)"
		rm -rf /run/wpa_supplicant/wlan0
		killall wpa_supplicant
		wpa_supplicant -B -i wlan0 -c password.conf -D wext -C /run/wpa_supplicant GROUP=wheel

		printf "\n$(tput setaf 1)Deleting password.conf\n"
		rm password.conf

		printf "\nGetting ip\n"
		dhclient -r wlan0
		dhclient wlan0

		printf "$(tput setaf 2)\nYou are now connected to:$(tput setaf 7)\n"
		iw wlan0 link | grep -e "SSID" -e "Not"
		printf "\n$(tput setaf 2)Connection info:$(tput setaf 7)\n"
		ifconfig wlan0 | grep "inet"
		printf "\n\n"

		continue
	elif [ "$komenda" == "netinfo" ]; then
		clear
		printf "$(tput setaf 2)You are now connected to:$(tput setaf 7)\n"
		iw wlan0 link | grep -e "SSID" -e "Not"
		printf "\n$(tput setaf 2)Connection info:$(tput setaf 7)\n"
		ifconfig wlan0 | grep "inet"
		printf "\n\n"

		continue
	elif [ "$komenda" == "exit" ]; then
		exit
	else
		clear
		continue
	fi
done
