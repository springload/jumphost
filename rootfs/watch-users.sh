tail -f -n 0 /var/log/messages |
while read line; do
if [[ "$line" =~ "Invalid user "([^ ]*) ]]
  then  newuser=${BASH_REMATCH[1]}
    adduser -D -s /bin/bash $newuser
    passwd -u $newuser >/dev/null 2>&1
    echo "$newuser@jumphost" > /etc/ssh/sshd_principals/$newuser
    echo "Created user $newuser"
  fi
done
