#!/bin/bash

if [ -d /tmp/public-keys ]; then
  pushd /tmp/public-keys
  git pull origin master
  popd
else
  git clone $PUBLIC_KEYS_REPO /tmp/public-keys
fi

FILES=/tmp/public-keys/ssh/*
for f in $FILES
do
  user=$(basename $f)
  user=${user%"_authorized_keys"}
  adduser -D -s /bin/bash $user
  passwd -u $user >/dev/null 2>&1
  mkdir -p -m 700 "/home/$user/.ssh"
  install -m 600 -o $user -g $user $f /home/$user/.ssh/authorized_keys
  echo "$user@jumphost" > /etc/ssh/sshd_principals/$user
  echo "Created user $user"
done
