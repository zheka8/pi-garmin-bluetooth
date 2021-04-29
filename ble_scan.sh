#!/bin/bash

# Periodically scan for bluetooth low energy devices and
# enable video recording if the device is found

# Scan params
SCAN_INTERVAL=10      #time between scans (seconds)
SCAN_DURATION="2"     #duration of each scan (seconds)
SCAN_QUERY="RTL23101" #target device
NUM_FOUND=0           #number of devices found that match target
NUM_MISSES=0          #number of times target not found
NUM_MISSES_TO_STOP=8  #number of times the target is not found before stopping rec

# Recording state
IS_RECORDING=-1

# Recording params
SEG_DURATION=$((1*60*60*1000))  # (ms) new file every hour
WIDTH=1280
HEIGHT=720

# Data
ERR_FILE="errors.txt"

# Path
FULL_PATH=$(realpath $0)
DIR_PATH=$(dirname $FULL_PATH)

update_state () {
    # check if recording is on
    IS_RECORDING=$(pgrep raspivid)

    if [[ -z "$IS_RECORDING" ]]
    then
        IS_RECORDING=-1
    fi

    echo "IS_RECORDING $IS_RECORDING"
}

start_video_recording () {
    echo "Starting video recording"
    FILE_NAME=`date +"%Y_%m_%d_%H_%M"`
    
    raspivid -o "$DIR_PATH/data/$FILE_NAME.%d.h264" \
	     -t 0 -s -sg $SEG_DURATION \
	     -w $WIDTH -h $HEIGHT &
    
    update_state
}

stop_video_recording () {
    echo "Stopping video recording"
    pkill raspivid
    update_state
}

toggle_interface () {
    # in case of I/O errors, set bluetooth interface down and up
    echo "Resetting interface"
    sudo hciconfig hci0 down
    sudo hciconfig hci0 up
}

check_for_errors () {
    # check if there were errors from previous scan and try to reset
    NUM_ERRORS=$(wc -l "$DIR_PATH/data/$ERR_FILE" | awk {'print $1;'})
    echo "NUM ERRORS $NUM_ERRORS"

    if [[ $NUM_ERRORS -gt 0 ]]
    then
        toggle_interface
    fi 
}

scan () {
    NUM_FOUND=$(timeout -s SIGINT "$SCAN_DURATION"s \
    	        hcitool -i hci0 lescan 2>"$DIR_PATH/data/$ERR_FILE" \
		| grep "$SCAN_QUERY" | wc -l)

    if [[ $NUM_FOUND -eq 0 ]]
    then
        let NUM_MISSES=$NUM_MISSES+1
    else
	NUM_MISSES=0
    fi

    echo "NUM FOUND: $NUM_FOUND"
    echo "NUM MISSED: $NUM_MISSES"
}

main_loop () {
    while [ 1 ]
    do
	# perform the scan and verify if recording is currently on
        scan
	check_for_errors
	update_state

        if [[ $NUM_FOUND -gt 0 ]] && [[ $IS_RECORDING -eq -1 ]] 
        then
	    start_video_recording
        elif [[ $NUM_MISSES -ge $NUM_MISSES_TO_STOP ]] && [[ $IS_RECORDING -ge 0 ]]
        then
	    stop_video_recording
	fi

	sleep $SCAN_INTERVAL
    done
}

main_loop
