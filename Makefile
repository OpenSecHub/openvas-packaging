###############################################################################
# only support Tag Version
PACKVER=21.4.0

GVM_LIBS_VER=${PACKVER}
SMB_VER=${PACKVER}
SCANNER_VER=${PACKVER}
GVMD_VER=${PACKVER}
GSA_VER=${PACKVER}
OSPD_VER=${PACKVER}
OSPD_OPENVAS_VER=${PACKVER}


PWD=$(shell pwd)
# DO NOT MODIFY
INSTALL_PATH=/opt/gvm
PYTHONVENV=${INSTALL_PATH}/python3
###############################################################################
.PHONY: all init clean gvm-libs openvas-smb openvas-scanner gvmd gsa ospd ospd-openvas

# compile all modules
build:gvm-libs openvas-smb openvas-scanner gvmd gsa ospd ospd-openvas

all:build deb

###############################################################################
# $1 module name
# $2 moudle version
define build_c_module
	@ echo "================= $(1) Building ... "
	@ rm -rf build/$(1)
	@ mkdir -p build/$(1)/build
	@ cd build/$(1) && wget https://github.com/greenbone/$(1)/archive/refs/tags/v$(2).tar.gz
	@ cd build/$(1) && tar xf v$(2).tar.gz
	@ cd build/$(1)/build && \
			export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH && \
			cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} ../$(1)-$(2) 2>&1 | tee ../config.log 
	@ cd build/$(1)/build && make install 2>&1 | tee ../build.log
endef


# $1 module name
# $2 moudle version
define build_python_module
	@ echo "================= $(1) Building ... "
	@ rm -rf build/$(1)
	@ mkdir -p build/$(1)
	@ cd build/$(1) && wget https://github.com/greenbone/$(1)/archive/refs/tags/v$(2).tar.gz
	@ cd build/$(1) && tar xf v$(2).tar.gz
	@ cd build/$(1)/$(1)-$(2) && ${PYTHONVENV}/bin/python setup.py install 2>&1 | tee ../install.log
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
	@ rm -rf build/debian/opt/gvm/include
	@ rm -rf build/debian/opt/gvm/etc/default
	@ rm -rf build/debian/opt/gvm/lib/systemd
	@ rm -rf build/debian/opt/gvm/lib/pkgconfig
	@ rm -rf build/debian/opt/gvm/var/run/*
	@ rm -rf build/debian/opt/gvm/var/log/gvm/*
	@ chown gvm:gvm -R build/debian/opt/gvm
	@ chmod 0755 -R build/debian/opt/gvm/lib
	@ dpkg -b build/debian openvas-v${PACKVER}-amd64.deb

###############################################################################
# create build environment
init:
	@ apt update -y
	@ apt upgrade -y
	apt install -y \
        build-essential cmake pkg-config bison  \
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
        graphviz          \
        python3-pip       \
        python3-venv


	# python venv
	pip3 install pip --upgrade
	mkdir -p /opt/gvm/
	python3 -m venv ${PYTHONVENV}
	${PYTHONVENV}/bin/pip3 install setuptools 
	${PYTHONVENV}/bin/pip3 install setuptools_rust

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

	# create user gvm
	useradd -r -d /opt/gvm -c "GVM (OpenVAS) User" -s /bin/bash gvm
	chown gvm:gvm -R /opt/gvm

###############################################################################
clean:
	rm -rf build
