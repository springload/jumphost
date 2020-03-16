#!/bin/bash

if [ -d /tmp/public-keys ]; then
  pushd /tmp/public-keys
  git pull origin master
  popd
else
  git clone https://github.com/springload/public-keys /tmp/public-keys
fi

FILES=/tmp/public-keys/ssh/*
for f in $FILES
do
  user=$(basename $f)
  user=${user%"_authorized_keys"}
  echo $user
  adduser -D -s /bin/bash $user
  passwd -u $user
  mkdir -p -m 700 "/home/$user/.ssh"
  install -m 600 -o $user -g $user $f /home/$user/.ssh/authorized_keys
done
