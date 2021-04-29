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

