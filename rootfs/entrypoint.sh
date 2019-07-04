#!/bin/bash

git clone https://github.com/springload/public-keys /tmp/public-keys

FILES=/tmp/public-keys/ssh/*
for f in $FILES
do
  user=$(basename $f)
  user=${user%"_authorized_keys"}
  echo $user
  adduser -D -s /bin/bash $user
  passwd -u $user
  mkdir -p -m 700 "/home/$user/.ssh"
  cp $f "/home/$user/.ssh/authorized_keys"
  chmod 600 "/home/$user/.ssh/authorized_keys"
  chown -R $user:$user "/home/$user/.ssh"
done

echo -e "$SSH_HOST_RSA_KEY" > /etc/ssh/ssh_host_rsa_key
echo -e "$SSH_HOST_DSA_KEY" > /etc/ssh/ssh_host_dsa_key

echo '[options]
        logfile = /var/log/knockd.log
[openclosePort]
        sequence      = '$KNOCK_SEQUENCE'
        seq_timeout   = 15
        tcpflags      = syn
        start_command = /sbin/iptables -I JUMPHOST -s %IP% -p tcp --dport 2222 -j ACCEPT
        cmd_timeout   = 10
        stop_command  = /sbin/iptables -D JUMPHOST -s %IP% -p tcp --dport 2222 -j ACCEPT

' > /etc/knockd.conf

knockd -d

syslogd

exec "$@"
