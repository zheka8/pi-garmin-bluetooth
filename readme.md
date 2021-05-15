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

## Video Processing
### Convert h264 videos to mp4
* Install h264
```
brew install x264
```
* Convert
```
x264 raw_stream.264 -o playable_video.mp4
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
