#!/bin/bash

# Periodically scan for bluetooth low energy devices and
# perform an action if the desired device is found


SCAN_DURATION="5"
SCAN_QUERY="unknown*"
NUM_FOUND=0

start_video_recording () {
    echo "Starting video recording"
}

scan () {
    NUM_FOUND=$(sudo timeout -s SIGINT "$SCAN_DURATION"s hcitool -i hci0 lescan | grep "$SCAN_QUERY" | wc -l)
}

main_loop () {
    echo "Loop here"
    scan

    if [[ $NUM_FOUND -gt 0 ]] 
    then
	start_video_recording
    fi
}


main_loop
echo $NUM_FOUND

