## Instructions
### Allow hcitool to run without elevated privelages

```
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcitool`
```

### Configure systemd service
* Place ble_scan.service in /etc/systemd/system

* To enable on boot:

```
sudo systemctl enable ble_scan.service
```

* To start/stop:

```
sudo systemctl [start|stop] ble_scan.service
```

* Log entries appear in /var/log/syslog

### To stream over ssh (sftp) using VLC

vlc sftp://user@host:/path/to/file

### To transfer files from Raspberry Pi over the network
```
rsync -pvah --progress user@host:/path/pi-garmin-bluetooth/data/*.h264 .
```

## Video Processing
### Convert h264 videos to mp4
* Using VLC:
```
vlc --no-repeat --no-loop -I dummy file.h264 --sout='#transcode{vcodec=h264,acodec=none,scodec=none,soverlay}:std{access=file{no-overwrite},mux=mp4,dst="file.mp4"}' vlc://quit
```

### Combine processed videos
* Install MP4box
```
brew install MP4box
```
* Combine
```
MP4Box -cat video1.mp4 -cat video2.mp4 -cat video3.mp4 combined.mp4
```
