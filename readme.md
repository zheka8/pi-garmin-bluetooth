## Instructions
# Allow hcitool to run without elevated privelages
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcitool`

# Configure systemd service
place ble_scan.service in /etc/systemd/system
to enable on boot:
  sudo systemctl enable ble_scan.service
to start/stop:
  sudo systemctl [start|stop] ble_scan.service


