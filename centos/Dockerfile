FROM centos:7

RUN  yum install -y python3 python3-devel

COPY ./patroni.tar.gz /usr/local/src/
RUN mkdir /u01



# RUN curl -o /usr/local/src/get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py
# RUN python3 /usr/local/src/get-pip.py \
#     && pip install pyyaml 

# RUN mkdir -p /opt/patroni/logs/


# ENV ETCD_CLUSTER_MODE=false


# WORKDIR /app

# COPY docker-entrypoint.sh /app/

# COPY launch.sh /app/
# RUN chmod +x /app/docker-entrypoint.sh

# COPY script.py /app/

# RUN python3 script.py

# ENTRYPOINT ["/app/docker-entrypoint.sh"]

CMD ["/bin/bash", "-c","sleep 3600s;"]




