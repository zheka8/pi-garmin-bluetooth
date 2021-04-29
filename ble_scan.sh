#!/bin/bash

# Periodically scan for bluetooth low energy devices and
# perform an action if the desired device is found

# Scan params
SCAN_INTERVAL=2       #time between scans (seconds)
SCAN_DURATION="2"     #duration of each scan (seconds)
SCAN_QUERY="RTL"      #target device
NUM_FOUND=0           #number of devices found that match target
NUM_MISSES=0          #number of times target not found
NUM_MISSES_TO_STOP=8  #number of times the target is not found before action is taken

# Recording state (# find raspivid proc instead?)
IS_RECORDING=0

start_video_recording () {
    echo "Starting video recording"
    IS_RECORDING=1
}

stop_video_recording () {
    echo "Stopping video recording"
    IS_RECORDING=0
}

scan () {
    NUM_FOUND=$(sudo timeout -s SIGINT "$SCAN_DURATION"s hcitool -i hci0 lescan | grep "$SCAN_QUERY" | wc -l)

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
        scan

        if [[ $NUM_FOUND -gt 0 ]] && [[ $IS_RECORDING -eq 0 ]] 
        then
	    start_video_recording
        elif [[ $NUM_MISSES -ge $NUM_MISSES_TO_STOP ]] && [[ $IS_RECORDING -eq 1 ]]
        then
	    stop_video_recording
        fi

	sleep $SCAN_INTERVAL
    done
}

main_loop
