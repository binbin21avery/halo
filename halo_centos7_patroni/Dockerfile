FROM centos:7
MAINTAINER wangzhibin <wangzhibin>
ENV USER="postgresql" \    
    PASSWORD=123456 \    
    GROUP=postgresql 
RUN useradd ${USER} \       
    && chown -R ${USER}:${GROUP} /home/${USER} \       
    && yum -y update && yum install -y iptables sudo net-tools iproute  openssh-server openssh-clients which vim sudo crontabs
    
#安装etcd
COPY etcd/etcd /usr/sbin
COPY etcd/etcdctl /usr/sbin
#安装database
COPY lib/ /home/${USER}/lib
COPY include/ /home/${USER}/include
COPY share/ /home/${USER}/share
COPY bin/ /home/${USER}/bin/
COPY patroni/ /home/${USER}/patroni
#安装vip-manager
COPY vip-manager/vip-manager /usr/sbin
#安装执行脚本
COPY runtime/ /home/${USER}/runtime
COPY entrypoint.sh /sbin/entrypoint.sh
#设置环境变量
ENV LD_LIBRARY_PATH /home/${USER}/lib
ENV PATH /home/${USER}/bin:$PATH
ENV ETCDCTL_API=3
#安装Patroni
RUN yum -y install epel-release python-devel \
    && yum -y install python-pip \ 
    && pip install /home/${USER}/patroni/1/pip-20.3.3.tar.gz \    
    && pip install /home/${USER}/patroni/1/psycopg2-2.8.6-cp27-cp27mu-linux_x86_64.whl \    
    && pip install --no-index --find-links=/home/${USER}/patroni/2/ -r /home/${USER}/patroni/2/requirements.txt \    
    && pip install /home/${USER}/patroni/3/patroni-2.0.1-py2-none-any.whl
    #修改执行权限
RUN chmod 755 /sbin/entrypoint.sh \ 
    && mkdir /home/${USER}/etcddata \
    && chown -R ${USER}:${GROUP} /home/${USER} \
    && echo 'root:root123456' | chpasswd \
    && chmod 755 /sbin/etcd \
    && chmod 755 /sbin/etcdctl \
    && chmod 755 /sbin/vip-manager
    #设置Sudo
RUN chmod 777 /etc/sudoers \       
    && sed -i '/## Allow root to run any commands anywhere/a '${USER}' ALL=(ALL) NOPASSWD:ALL' /etc/sudoers \       
    && chmod 440 /etc/sudoers
#切换用户
USER ${USER}
#切换工作目录
WORKDIR /home/${USER}
#启动入口程序CMD 
["/bin/bash", "/sbin/entrypoint.sh"]
