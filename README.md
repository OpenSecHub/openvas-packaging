# openvas-packaging

> only tested in Ubuntu20.04(server).

===================

<!-- TOC -->

- [openvas-packaging](#openvas-packaging)
    - [Info](#info)
        - [openvas modules](#openvas-modules)
        - [openvas service](#openvas-service)
    - [Compile](#compile)
        - [Create build environment](#create-build-environment)
        - [Build sources](#build-sources)
        - [Download feeds](#download-feeds)
        - [Build package](#build-package)
    - [Install the package](#install-the-package)
        - [Download feeds](#download-feeds-1)
        - [Access openvas](#access-openvas)
    - [Reference](#reference)

<!-- /TOC -->

## Info

![module](res/openvas-modules.svg)

### openvas modules

| module                                                          | type             | description                                                                        |
| --------------------------------------------------------------- | ---------------- | ---------------------------------------------------------------------------------- |
| [gvm-libs](https://github.com/greenbone/gvm-libs)               | C Library        | Greenbone Vulnerability Management Libraries                                       |
| [openvas-smb](https://github.com/greenbone/openvas-smb)         | C Library        | SMB module for openvas Scanner                                                     |
| [ospd](https://github.com/greenbone/ospd)                       | Python Library   | a framework for vulnerability scanners which share the same communication protocol |
| [ospd-openvas](https://github.com/greenbone/ospd-openvas)       | Python Service   | an OSP server implementation to allow GVM to remotely control an openvas Scanner   |
| [gvmd](https://github.com/greenbone/gvmd)                       | C Service        | Greenbone Vulnerability Manager                                                    |
| [gsa](https://github.com/greenbone/gsa)                         | React-UI Service | Greenbone Security Assistant(webUI)                                                |
| [openvas-scanner](https://github.com/greenbone/openvas-scanner) | C tool           | Open Vulnerability Assessment Scanner                                              |

### openvas service

| service      | description                                                                      |
| ------------ | -------------------------------------------------------------------------------- |
| gvmd         | management server(for API and gsad)                                              |
| gsad         | web server(webUI)                                                                |
| ospd-openvas | a OSP server implementation to allow gvmd to remotely control an openvas Scanner |

-----------

## Compile

### Create build environment

install deps

intstall tools

download sources(all sources in dir `src`)

```bash
make init
```

### Build sources

build and install all modules

```bash
make build
```

### Download feeds

download NVTs and feeds, so all data can be packed into deb.

this operation will take a long time, you can omit it.

```bash
make data
```

### Build package

build `deb` package.

```bash
make deb
```

-------------

## Install the package

```bash
apt install -y libxml2  nmap snmp \
  gnutls-bin libssh-gcrypt-4 libnet1 \
  redis-server postgresql postgresql-contrib \
  libgpgme11 libical3 \
  libldap-2.4-2 libradcli4 \
  libhiredis0.14 libmicrohttpd12 \
  xml-twig-tools xsltproc

dpkg -i openvas-v21.4.0-amd64.deb
```

### Download feeds

Even if the NVTs and feeds (`make data`) are packaged into `deb`, it still will take a long time to process the datas; 

otherwise you need download data manually by commands below:

```bash
# /opt/gvm/update/update.sh
sudo -Hiu gvm /opt/gvm/bin/greenbone-nvt-sync
sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type GVMD_DATA
sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type SCAP
sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type CERT
sudo -Hiu gvm /opt/gvm/sbin/openvas --update-vt-info
```

### Access openvas

| login    | description         |
| -------- | ------------------- |
| username | admin               |
| password | admin               |
| api      | `<IP>:9390`         |
| UI       | `https://<IP>:9392` |

## Reference

[ yu210148/gvm_install - A script to install GVM 11 on Ubuntu 20.04 or Debian 10](https://github.com/yu210148/gvm_install)

https://kifarunix.com/install-and-setup-gvm-20-08-on-ubuntu/

https://sadsloth.net/post/install-gvm11-src-on-debian/
