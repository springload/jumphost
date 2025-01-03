FROM alpine

RUN apk update && \
    apk add knock git bash openssh && \
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa

COPY rootfs /
RUN mkdir -p /etc/ssh/sshd_principals/

VOLUME ["/var/log"]

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/usr/sbin/sshd", "-D" ]
