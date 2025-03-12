FROM kalilinux/kali-rolling:latest
LABEL maintainer="admin@csalab.id"
RUN sed -i "s/http.kali.org/mirrors.ocf.berkeley.edu/g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install \
    sudo \
    openssh-server \
    python2 \
    dialog \
    firefox-esr \
    inetutils-ping \
    htop \
    nano \
    net-tools \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    tigervnc-viewer \
    novnc \
    dbus-x11
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install \
    xfce4-goodies \
    kali-linux-large \
    kali-desktop-xfce && \
    apt-get -y full-upgrade
RUN apt-get -y autoremove && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -c "Kali Linux" -s /bin/bash -d /home/kali kali && \
    sed -i "s/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g" /etc/ssh/sshd_config && \
    sed -i "s/off/remote/g" /usr/share/novnc/app/ui.js && \
    echo "kali ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    touch /usr/share/novnc/index.htm
    # Create directory for SSH daemon's runtime files
RUN echo '/usr/sbin/sshd -D' >>/kali.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config # Allow root login via SSH
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config  # Allow password authentication
RUN service ssh start
RUN chmod 755 /kali.sh

# Expose port
EXPOSE 22 80 443 9050 8888 53 3000 9050 8888 3306 8118

# Start the shell script on container startup

COPY /root /

CMD  /kali.sh
COPY startup.sh /startup.sh
USER kali
WORKDIR /home/kali
ENV PASSWORD=kalilinux
ENV SHELL=/bin/bash
EXPOSE 8080
ENTRYPOINT ["/bin/bash", "/startup.sh"]