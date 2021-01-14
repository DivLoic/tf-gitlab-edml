#!/usr/bin/env bash

### ssh
# login into compute instance with '--ssh-flag="-p 2222"'
echo 'Port 2222' >> /etc/ssh/sshd_config
sudo systemctl reload sshd.service
