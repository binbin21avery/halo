FROM busybox:latest

COPY ./entrypoint.sh /

RUN mkdir -p /u01/app/halo

ENV HALO_BASE=/u01/app/halo

CMD ["/bin/sh","-c","sleep 3600s;"]