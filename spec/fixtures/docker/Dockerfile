FROM centos:7

ENV LDAP_HOST=ldap
ENV LDAP_PORT=1389
ENV container=docker

VOLUME /sys/fs/cgroup

COPY puppet.repo /etc/yum.repos.d
COPY nifi.repo /etc/yum.repos.d/nifi.repo

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y openssh-server curl gcc git make rpm-build ruby ruby-devel tar sensu sudo which yum-plugin-versionlock && \
    yum install -y puppet-3.8.7 && \
    yum -y install java-1.8.0-openjdk-devel && \
    yum install -y nifi-registry && \
    yum versionlock puppet && \
    systemctl enable sshd && \
    echo "gem: --no-ri --no-rdoc" > /etc/gemrc && \
    echo "gem: --no-ri --no-rdoc" > /root/.gemrc && \
    yum clean all


COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
WORKDIR /root

ENTRYPOINT ["/entrypoint.sh"]