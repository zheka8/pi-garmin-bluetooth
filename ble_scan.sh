#!/bin/bash

# Periodically scan for bluetooth low energy devices and
# enable video recording if the device is found

# Scan params
SCAN_INTERVAL=2       #time between scans (seconds)
SCAN_DURATION="2"     #duration of each scan (seconds)
SCAN_QUERY="RTL"      #target device
NUM_FOUND=0           #number of devices found that match target
NUM_MISSES=0          #number of times target not found
NUM_MISSES_TO_STOP=8  #number of times the target is not found before stopping rec

# Recording state
IS_RECORDING=-1

# Recording params
SEG_DURATION=3600000  # (ms)  new file every hour
WIDTH=1024
HEIGHT=768

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
    
    raspivid -o data/$FILE_NAME.h264 -t 0 -s -sg $SEG_DURATION \
	     -w $WIDTH -h $HEIGHT &
    
    update_state
}

stop_video_recording () {
    echo "Stopping video recording"
    pkill raspivid
    update_state
}

scan () {
    NUM_FOUND=$(sudo timeout -s SIGINT "$SCAN_DURATION"s \
	        hcitool -i hci0 lescan | grep "$SCAN_QUERY" | wc -l)

    # keep track consecutive absences of target device
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
    echo "Loop here"
    
    while [ 1 ]
    do
	# perform the scan and verify if recording is currently on
        scan
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

#start_video_recording
#sleep 5
#stop_video_recording
