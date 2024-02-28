#基础镜像来源
FROM centos:7

#基础环境配置
RUN yum -y install kde-l10n-Chinese  glibc-common  \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
    && yum install -y sudo nss_wrapper sysstat ftp make cmake gcc uuid uuid-devel bison flex perl perl-devel python-devel readline readline-devel libxml2 libxml2-devel iotop tcpdump strace gdb systemtap net-tools xdpyinfo libstdc++-devel gcc-c++ ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel libgcc libstdc++ libstdc++-devel libxcb make smartmontools zlib-devel tcl glibc glibc-devel openssl openssl-devel bc binutils nfs-utils perl-ExtUtils-Embed zstd zstd-devel libcurl libcurl-devel lz4 lz4-devel libicu libicu-devel autoconf \
    && yum -y clean all



RUN  curl -sSL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" -o /usr/local/bin/gosu \
     && chmod +x /usr/local/bin/gosu \
     && gosu nobody true


RUN set -eux \
    && groupadd -g 3000 halo \
    && useradd -u 3000 -g halo halo \
    && mkdir -p /var/lib/halo/conf \
    && chown -R halo:halo /var/lib/halo/conf \
    && mkdir -p /u01/app/halo \
    && chown -R halo:halo /u01/app/halo \
    && mkdir -p /var/run/halo \
    && chown -R halo:halo /var/run/halo \
    && mkdir -p /data/halo \
    && chown -R halo:halo /data/halo \
    && mkdir -p /var/lib/halo/conf \
    && chown -R halo:halo /var/lib/halo/conf \
    && mkdir /halo-scripts
