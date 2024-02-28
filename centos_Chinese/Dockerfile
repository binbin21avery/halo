#基础镜像来源
FROM centos:7



RUN yum -y install kde-l10n-Chinese  glibc-common  \
    && yum clean all  \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 


ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8




CMD ["/bin/bash"]





