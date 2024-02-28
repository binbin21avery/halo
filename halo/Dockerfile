#基础镜像来源
FROM centos:7


LABEL os="Centos"  
LABEL arch="x86_64"

#基础环境配置
RUN yum -y install kde-l10n-Chinese  glibc-common  \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
    && yum install -y nss_wrapper nmap sysstat ftp make cmake gcc uuid uuid-devel bison flex perl perl-devel python-devel readline readline-devel libxml2 libxml2-devel iotop tcpdump strace gdb systemtap net-tools xdpyinfo libstdc++-devel gcc-c++ ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel libgcc libstdc++ libstdc++-devel libxcb make smartmontools zlib-devel tcl glibc glibc-devel openssl openssl-devel bc binutils nfs-utils perl-ExtUtils-Embed zstd zstd-devel libcurl libcurl-devel lz4 lz4-devel libicu libicu-devel autoconf \
    && yum -y clean all

ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8
ENV GOSU_VERSION 1.10

RUN  curl -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" -o /usr/local/bin/gosu \
     && chmod +x /usr/local/bin/gosu \
     && gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d


RUN set -eux \
    && groupadd -g 3000 halo \
    && useradd -u 3000 -g halo halo \
    && mkdir -p /u01/app/halo \
    && chown -R halo:halo /u01/app/halo \
    && mkdir -p /var/run/halo \
    && chown -R halo:halo /var/run/halo \
    && mkdir /halo-scripts \
    && mkdir -p /data/halo \
    && chown -R halo:halo /data/halo

#拷贝安装文件和证书
COPY ./halo_14.el7.x86_64.build231127.tar.gz  /usr/local/src/

RUN tar -zxf /usr/local/src/halo_14.el7.x86_64.build231127.tar.gz -C /u01/app/halo \
    && rm -rf /usr/local/src/halo_14.el7.x86_64.build231127.tar.gz \
    && rm -rf /u01/app/halo//u01/app/halo/product/shield



#数据挂载卷
VOLUME /data/halo


ENV HALO_HOME=/u01/app/halo/product/dbms/14
ENV PGHOST=/var/run/halo
ENV PATH=$HALO_HOME/bin:$PATH
ENV PGDATA=/data/halo
ENV ORACLE_HOME=/u01/app/halo/product/instantclient_12_2
ENV OCI_LIB_DIR=$ORACLE_HOME
ENV OCI_INC_DIR=$ORACLE_HOME/sdk/include
ENV LD_LIBRARY_PATH=$HALO_HOME/lib:$ORACLE_HOME/sdk/include/lib


COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]


STOPSIGNAL SIGINT


EXPOSE 1921

CMD ["postgres"]