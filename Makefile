.PHONY: all init clean gvm-libs openvas-smb openvas-scanner gvmd gsa data nvt feed

PACKVER=21.4.0
BASE_VER=v${PACKVER}

GVM_LIBS_VER=${BASE_VER}
SMB_VER=${BASE_VER}
SCANNER_VER=${BASE_VER}
GVMD_VER=${BASE_VER}
GSA_VER=${BASE_VER}
OSPD_VER=${BASE_VER}
OSPD_OPENVAS_VER=${BASE_VER}


PWD=$(shell pwd)
# DO NOT MODIFY
INSTALL_PATH=/opt/gvm

###############################################################################
# get NVTs and feeds version
NVT_FEEDFILE=/opt/gvm/var/lib/openvas/plugins/plugin_feed_info.inc
ifeq ($(wildcard ${NVT_FEEDFILE}),${NVT_FEEDFILE})
    NVT_VER=$(shell grep PLUGIN_SET ${NVT_FEEDFILE} | sed -e 's/[^0-9]//g')
else
    NVT_VER=
endif

GVMD_DATA_FEEDFILE=/opt/gvm/var/lib/gvm/data-objects/gvmd/feed.xml
ifeq ($(wildcard ${GVMD_DATA_FEEDFILE}),${GVMD_DATA_FEEDFILE})
    GVMD_DATA_VER=$(shell grep version ${GVMD_DATA_FEEDFILE} | sed -e 's/[^0-9]//g')
else
    GVMD_DATA_VER=
endif

CERT_FEEDFILE=/opt/gvm/var/lib/gvm/cert-data/feed.xml
ifeq ($(wildcard ${CERT_FEEDFILE}),${CERT_FEEDFILE})
    CERT_VER=$(shell grep version ${CERT_FEEDFILE} | sed -e 's/[^0-9]//g')
else
    CERT_VER=
endif

SCAP_FEEDFILE=/opt/gvm/var/lib/gvm/scap-data/feed.xml
ifeq ($(wildcard ${SCAP_FEEDFILE}),${SCAP_FEEDFILE})
    SCAP_VER=$(shell grep version ${SCAP_FEEDFILE} | sed -e 's/[^0-9]//g')
else
    SCAP_VER=
endif
###############################################################################

all:build data deb

# compile all modules
build:gvm-libs openvas-smb openvas-scanner gvmd gsa ospd ospd-openvas

# download datas
data:nvt feed

# pack nvt and feeds
packdata:packnvt packgvmddata packcert packscap

###############################################################################
# $1 module name
# $2 moudle version
define build_c_module
	@ echo "================= $(1) Building ... "
	@ cd ${PWD}/src/$(1) && git checkout $(2)
	@ rm -rf build/$(1)
	@ mkdir -p build/$(1)
	@ cd build/$(1) && \
			export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH && \
			cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} ${PWD}/src/$(1)
	@ cd build/$(1) && make install
endef


# $1 module name
# $2 moudle version
define build_python_module
	@ echo "================= $(1) Building ... "
	@ cd ${PWD}/src/$(1) && git checkout $(2)
	@ cd ${PWD}/src/$(1) && /opt/gvm/py3venv/bin/python setup.py install
endef
###############################################################################

gvm-libs:
	$(call build_c_module,$@,${GVM_LIBS_VER})

openvas-smb:
	$(call build_c_module,$@,${SMB_VER})
	
openvas-scanner:
	$(call build_c_module,$@,${SCANNER_VER})

gvmd:
	$(call build_c_module,$@,${GVMD_VER})

gsa:
	$(call build_c_module,$@,${GSA_VER})

ospd:
	$(call build_python_module,$@,${OSPD_VER})

ospd-openvas:
	$(call build_python_module,$@,${OSPD_OPENVAS_VER})
###############################################################################

deb:
	@ echo "================= Packaging ... "
	@ rm -rf build/debian
	@ mkdir -p build
	@ cp -frp debian build/
	@ sed -i "s/%VERSION%/${PACKVER}/" build/debian/DEBIAN/control
	@ cp -frp ${INSTALL_PATH} build/debian/opt/
	@ echo "db_address = /run/redis-openvas/redis.sock" > build/debian/opt/gvm/etc/openvas/openvas.conf
	@ rm -rf build/debian/opt/gvm/var/run/*
	@ rm -rf build/debian/opt/gvm/var/log/gvm/*
	@ chown gvm:gvm -R build/debian/opt/gvm
	@ chmod 0755 -R build/debian/opt/gvm/lib
	@ dpkg -b build/debian openvas-${BASE_VER}-amd64.deb

###############################################################################
### downlaod vnt and feeds

nvt:
	chown gvm:gvm -R /opt/gvm
	sudo -Hiu gvm /opt/gvm/bin/greenbone-nvt-sync

feed:
	chown gvm:gvm -R /opt/gvm
	sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type GVMD_DATA
	sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type SCAP
	sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type CERT

###############################################################################
### pack vnt and feeds
# $1 Package Name
# $2 Package Version
# $3 Package Description
# $4 Package Data Path
define packdatafn
	@ echo "================= Packaging openvas-$(1)... "
	@ rm -rf build/debian
	@ mkdir -p build
	@ cp -frp data/debian build/
	@ sed -i 's/%NAME%/openvas-$(1)/' build/debian/DEBIAN/control
	@ sed -i 's/%VERSION%/$(2)/'      build/debian/DEBIAN/control
	@ sed -i 's/%DESCRIPTION%/$(3)/'  build/debian/DEBIAN/control
	@ chmod 0755 build/debian/DEBIAN/control

	@ mkdir -p build/debian$(4)
	@ cp -frp $(4)  build/debian$(4)/..
	@ chown gvm:gvm -R build/debian/opt/gvm
	@ dpkg -b build/debian openvas-$(1)-$(2)-amd64.deb
endef


packnvt:
ifeq (${NVT_VER},)
	@ echo "no NVTs data found !"
else
	$(call packdatafn,nvts,${NVT_VER},NVTs data,/opt/gvm/var/lib/openvas/plugins)
endif


packgvmddata:
ifeq (${GVMD_DATA_VER},)
	@ echo "no GVMD_DATA data found !"
else
	$(call packdatafn,gvmd-data,${GVMD_DATA_VER},GVMD_DATA,/opt/gvm/var/lib/gvm/data-objects/gvmd)
endif

packcert:
ifeq (${CERT_VER},)
	@ echo "no GVMD_CERT data found !"
else
	$(call packdatafn,cert,${CERT_VER},GVMD_CERT,/opt/gvm/var/lib/gvm/cert-data)
endif

packscap:
ifeq (${SCAP_VER},)
	@ echo "no GVMD_SCAP data found !"
else
	$(call packdatafn,scap,${SCAP_VER},GVMD_SCAP,/opt/gvm/var/lib/gvm/scap-data)
endif


###############################################################################
# create build environment
init:
	@ apt update
	@ apt upgrade
	apt install -y \
        gcc g++ cmake pkg-config bison \
        gcc-mingw-w64 \
        postgresql-server-dev-all \
        libxml2-dev       \
        libglib2.0-dev    \
        libgpgme-dev      \
        libgcrypt20-dev   \
        libgnutls28-dev   \
        libssh-gcrypt-dev \
        libpcap-dev       \
        libsnmp-dev       \
        libradcli-dev     \
        libldap2-dev      \
        libhiredis-dev    \
        libksba-dev       \
        uuid-dev          \
        libpq-dev         \
        libical-dev       \
        libnet-dev        \
        libmicrohttpd-dev \
        heimdal-dev       \
        libpopt-dev       \
        libunistring-dev  \
        gnutls-bin        \
        xml-twig-tools    \
        xsltproc          \
        xmltoman          \
        clang-format      \
        doxygen           \
        python3-pip       \
        python3-venv


	# python venv
	pip3 install pip --upgrade
	mkdir -p /opt/gvm/
	python3 -m venv /opt/gvm/py3venv
	/opt/gvm/py3venv/bin/pip3 install setuptools 
	/opt/gvm/py3venv/bin/pip3 install setuptools_rust

	# install yarn
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
	apt update
	apt install -y yarn
	cd /tmp && yarn install
	cd /tmp && yarn upgrade

	# install nodejs
	curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
	apt install -y nodejs

	# download source
	git submodule init
	git submodule update

	# create user gvm
	useradd -r -d /opt/gvm -c "GVM (OpenVAS) User" -s /bin/bash gvm
	chown gvm:gvm -R /opt/gvm

###############################################################################
clean:
	rm -rf build
