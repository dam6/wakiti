#!/bin/bash

# Created by github.com/dam6

#Extra files
. $WORKING_PATH/wakiti.conf
. $WORKING_PATH/wakiti.custom
. $WORKING_PATH/wakiti.db


#Core bot functions
url_encode() {
	local encoded=$(echo $@ | sed s/\ /%20/g | sed s/$LINE_BREAK/%0A/g)
	echo $encoded
}

get_message(){
	local peticion=$(curl -s "$URL/getUpdates?offset=$NEW_OFFSET" -A "lmao" --header 'Accept: application/json' --header 'Content-Type: application/json' | grep "id")

	if [[ $peticion == "" ]]; then
		NEW_OFFSET=""
		CHAT_ID=""
		USERNAME=""
		LAST_MESSAGE=""
		return
	fi

	local tmpoffset=$(echo $peticion | sed -e "s/.*\"update_id\"://" -e "s/,.*//")
	NEW_OFFSET=$(($tmpoffset+1))
	CHAT_ID=$(echo $peticion | sed -e "s/.*chat\":{\"id\"://" -e "s/,.*//")
	USERNAME=$(echo $peticion | sed -e "s/.*\"username\":\"//" -e "s/\".*//")
	LAST_MESSAGE=$(echo $peticion | sed -e "s/.*\"text\":\"//" -e "s/\".*//")
	debug "RECIEVED MESSAGE" "OFFSET:$NEW_OFFSET CHAT ID:$CHAT_ID USERNAME:$USERNAME MESSAGE:$LAST_MESSAGE"
}

send_message() {
	local chat_id=$1
	local text=$(url_encode $2)
	curl -s -A 'lmao' "$URL/sendMessage?chat_id=$chat_id&text=$text"
}

temp_message() {
	local chat_id=$1
	local text=$(url_encode $2)
	local wait_time=$3
	local sended=$(curl -s -A 'lmao' "$URL/sendMessage?chat_id=$chat_id&text=$text")
	local mustdelete_message_id=$(echo $sended | sed -e "s/.*:{\"message_id\"://" -e "s/,.*//")
	sleep $wait_time
	curl -s -A 'lmao' "$URL/deleteMessage?chat_id=$chat_id&message_id=$mustdelete_message_id"
}

ctrl_c() {
	debug "Bot has been killed" "Pressed Ctrl_C on keyboard"
	send_message $ADMIN_CHAT_ID "ctrl c xp"
	exit 3
}

wakey_wakey() {
	debug "BOT INIT" ""
	send_message $ADMIN_CHAT_ID "Buenos dias bro"
}

admin_check() {
	if [[ $USERNAME != $ADMIN ]]; then
		send_message $CHAT_ID "Tu no eres admin payaso.nnnQue cojones haces tio??? Es que yo flipo de verdad..."
		return 1
	fi
}

debug() {
	echo
	echo
	echo "$1"
	shift
	echo "$@"
}




#Main program
trap ctrl_c INT

while true; do
	get_message
	if [[ $NEW_OFFSET != "" ]]; then
		categorize_message &
	fi
	sleep 1
done


# Created by github.com/dam6
