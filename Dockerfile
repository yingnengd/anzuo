FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
ARG ROOT_PASSWORD
RUN sed -i.bak -e "s%http://us.archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list

# Install packages
RUN apt-get update \
    && \
    # Install the required packages for display    
    apt-get install -y --no-install-recommends \
      supervisor \
      openssh-server \
      xvfb \
      x11vnc \
      # && \
    # Install utilities(optional).
    # apt-get install -y \
      git \
      sudo \
      wget \
      curl \
      net-tools \
      vim-tiny \
      # && \
    #python packages
    # apt-get install -y \
      python3-pip \
      python-opengl \
      python3-setuptools \
      && \
    # Clean up
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN pip3 install gym

# set up ssh
RUN mkdir -p /var/run/sshd
RUN echo root:${ROOT_PASSWORD}| chpasswd

RUN sed -i 's/#\?PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# install noVNC
RUN mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/novnc/noVNC/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/novnc/websockify/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# add user
RUN useradd -m -s /bin/bash user
RUN echo user:${ROOT_PASSWORD}| chpasswd
WORKDIR /home/user/workspace

USER root
WORKDIR /root

RUN echo "export DISPLAY=:0"  >> /etc/profile
EXPOSE 8080 22
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /startup.sh
RUN chmod 744 /startup.sh
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
# CMD ["/startup.sh"]