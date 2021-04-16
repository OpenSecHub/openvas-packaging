#/usr/bin/bash

apt update

apt install -y redis-server nmap snmp gnutls-bin \
  postgresql postgresql-contrib \
  libgpgme11 libical3 libradcli4 libssh-gcrypt-4 \
  libhiredis0.1* libmicrohttpd12 \
  xml-twig-tools xsltproc \
  python3-pip python3-distutils

pip3 install --upgrade pip
pip3 install ospd-openvas

dpkg -i openvas-v20.8.1-amd64-v1.0.deb


bash /opt/gvm/update/update.sh