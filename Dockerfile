FROM amd64/centos:latest

# Enabled systemd
ENV container=docker UID="1005" GID="65538"

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#VOLUME [ "/sys/fs/cgroup" ]

VOLUME [ "/config" ]
VOLUME [ "/volume1/Warez/download" ]
VOLUME [ "/volume1/Warez/download-incomplete" ]

# copy root
COPY rootfs/ /

# Enable some repos
RUN yum install -y epel-release
RUN yum install -y 'dnf-command(config-manager)'
RUN yum config-manager --set-enabled PowerTools

# rTorrent
RUN yum install -y rtorrent psmisc
RUN groupadd rtorrent --gid=${GID}
RUN useradd rtorrent -d /home/rtorrent -G wheel --uid=${UID} --gid=${GID}

# flood
RUN yum -y install gcc-c++ make
RUN yum -y install  mediainfo libmediainfo mediainfo-gui
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash -
RUN yum install -y nodejs git
RUN git clone https://github.com/jfurrow/flood.git /opt/flood
RUN cp /defaults/config/flood/config.js /opt/flood/config.js
WORKDIR /opt/flood/
RUN npm install
RUN npm install -g node-gyp
RUN npm run build
# RUN useradd flood -d /home/flood -G wheel
RUN chown -R rtorrent:${GID} /opt/flood/

# nginx
RUN yum install -y nginx
RUN cp -r /defaults/config/nginx/nginx.conf /etc/nginx/nginx.conf

#configure services (systemd)
RUN systemctl enable prepare-config.service
RUN systemctl enable rtorrent.service
RUN systemctl enable flood.service
RUN systemctl enable nginx

WORKDIR /root/

# End
CMD ["/usr/sbin/init"]
