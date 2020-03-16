#!/bin/bash

/setup-users.sh

if [ $SSH_CA_PUB ]; then
  echo "Setting up CA based keys..."
  echo "$SSH_CA_PUB" > /etc/ssh/ca.pub
  echo "TrustedUserCAKeys /etc/ssh/ca.pub" >> /etc/ssh/sshd_config
  # echo "AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u" >> /etc/ssh/sshd_config
fi

echo "Setting Host key..."
echo -e "$SSH_HOST_RSA_KEY" > /etc/ssh/ssh_host_rsa_key
echo -e "$SSH_HOST_DSA_KEY" > /etc/ssh/ssh_host_dsa_key

echo "Setting up knockd..."
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

echo "Starting Jumphost..."
exec "$@"
