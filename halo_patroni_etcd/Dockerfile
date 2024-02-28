#基础镜像来源
FROM halo:0.1

RUN yum install -y wget python3 python3-devel watchdog \
    && watchdog \
    && yum install -y epel-release \
    && yum install -y jq \
    && yum -y clean all



COPY ./etcd-v3.5.12-linux-amd64.tar.gz /usr/local/src/

#install etcd and start 
RUN tar -zxvf /usr/local/src/etcd-v3.5.12-linux-amd64.tar.gz -C /opt/ \
    && mkdir -p /tmp/scripts \
    && mkdir -p /etc/etcd \
    && mkdir -p /opt/patroni/logs \
    && mkdir -p /etc/patroni \
    && mkdir -p /tmp/logs \
    && chown -R halo:halo /etc/patroni /etc/etcd /opt/patroni /opt/patroni/logs /tmp/logs 

#启动watchdog

RUN watchdog 



COPY scripts /tmp/scripts
RUN chown -R halo:halo /tmp/scripts


RUN  mv /opt/etcd-v3.5.12-linux-amd64 /opt/etcd \
    && chown -R halo:halo /opt/etcd  



#安装patroni
#安装pip
RUN curl -o /usr/local/src/get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py
RUN python3 /usr/local/src/get-pip.py \
    && pip install --upgrade pip \
    && pip install --upgrade setuptools \
    && pip install --ignore-installed psycopg2 \
    && pip install psycopg2-binary \ 
    && pip install python-etcd \
    && pip install patroni==3.2.1 \ 
    && pip install configparser


ENV HALO_BASE=/u01/app/halo
ENV PATH=/opt/etcd:$PATH
ENV PATRONI_CONFIGURATION=/etc/patroni/patroni.yml



EXPOSE 1921 8008 
# 
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN chmod +x /tmp/scripts/halo-entrypoint.sh
RUN /tmp/scripts/halo-entrypoint.sh postgres

# USER halo


ENTRYPOINT ["entrypoint.sh"]





