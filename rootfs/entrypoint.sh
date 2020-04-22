#!/bin/bash

if [ ! -z "$PUBLIC_KEYS_REPO" ]; then
  /setup-users.sh
fi

if [ ! -z "$SSH_CA_PUB" ]; then
  echo "Setting up CA based keys..."
  echo "$SSH_CA_PUB" > /etc/ssh/ca.pub
  echo "TrustedUserCAKeys /etc/ssh/ca.pub" >> /etc/ssh/sshd_config
  echo "AuthorizedPrincipalsFile /etc/ssh/sshd_principals/%u" >> /etc/ssh/sshd_config
  mkdir -p /etc/ssh/sshd_principals
  echo "jumphost" > /etc/ssh/sshd_principals/jump-user
  adduser -D -s /bin/bash jump-user
  passwd -u jump-user >/dev/null 2>&1
fi

if [ ! -z "$SSH_HOST_RSA_KEY" ]; then
  echo "Setting Host key..."
  echo -e "$SSH_HOST_RSA_KEY" > /etc/ssh/ssh_host_rsa_key
  echo -e "$SSH_HOST_DSA_KEY" > /etc/ssh/ssh_host_dsa_key
fi

if [ ! -z "$KNOCK_SEQUENCE" ]; then
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
fi

syslogd

if [ ! -z "$SSH_CA_PUB" ] && [ ! -z "$AUTO_CREATE_USERS" ]; then
  echo "Will auto create users as needed"
  /watch-users.sh &
fi

echo "Starting Jumphost..."
exec "$@"
