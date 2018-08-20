FROM ubuntu:16.04

RUN apt-get update \
  && apt-get install -y python-pip libsodium18 privoxy \
  && apt-get clean

RUN pip install shadowsocks==2.8.2
RUN sed -i -e 's|^listen-address|#listen-address|g' /etc/privoxy/config
RUN echo "listen-address 0.0.0.0:8118" >>/etc/privoxy/config
RUN echo "forward-socks5 / localhost:1080 ." >>/etc/privoxy/config

RUN mv /usr/local/bin/sslocal /usr/local/bin/sslocal.local
RUN echo '#!/usr/bin/env bash' >/usr/local/bin/sslocal
RUN echo 'service privoxy restart' >>/usr/local/bin/sslocal
RUN echo 'exec sslocal.local $@' >>/usr/local/bin/sslocal
RUN chmod a+x /usr/local/bin/sslocal

EXPOSE 1080 8118 8388

# Configure container to run as an executable
CMD ["/usr/local/bin/ssserver"]

# USAGE
# ssserver -k PASSWORD
# sslocal -b 0.0.0.0 -k PASSWORD
# service privoxy restart

# socket5 proxy port 1080
# http proxy port 8118
# ss server 8388
