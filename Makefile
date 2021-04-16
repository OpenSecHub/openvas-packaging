.PHONY: all init clean target_clean gvm-libs openvas-scanner gvmd gsa ospd ospd-openvas data cert nvt feed

BASE_VER=v20.8.1

GVM_LIBS_VER=${BASE_VER}
SCANNER_VER=${BASE_VER}
GVMD_VER=${BASE_VER}
GSA_VER=${BASE_VER}
OSPD_VER=${BASE_VER}
OSPD_OPENVAS_VER=${BASE_VER}

PWD=$(shell pwd)
# DO NOT MODIFY
INSTALL_PATH=/opt/gvm
PY3VER=$(shell python3 --version | grep -o [0-9]\.[0-9])
_PYTHONPATH=${INSTALL_PATH}/lib/python${PY3VER}/site-packages/
###############################################################################

all:build data deb

# compile all modules
build:gvm-libs openvas-scanner gvmd ospd ospd-openvas gsa

# download datas
data:cert nvt feed

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
	@ cd ${PWD}/src/$(1) && export PYTHONPATH=${_PYTHONPATH} && python3 setup.py install --prefix=${INSTALL_PATH}
endef
###############################################################################

gvm-libs:
	$(call build_c_module,$@,${GVM_LIBS_VER})

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
	echo "================= Packaging ... "
	rm -rf build/debian
	mkdir -p build
	cp -frp debian build/
	cp -frp ${INSTALL_PATH} build/debian/opt/
	echo "db_address = /run/redis-openvas/redis.sock" > build/debian/opt/gvm/etc/openvas/openvas.conf
	echo "export PYTHONPATH=${_PYTHONPATH}" >  build/debian/opt/gvm/.bashrc
	echo "export LD_LIBRARY_PATH=/opt/gvm/lib" >>  build/debian/opt/gvm/.bashrc
	echo "export PATH=\$$PATH:/opt/gvm/sbin:/opt/gvm/bin" >>  build/debian/opt/gvm/.bashrc
	rm -rf build/debian/opt/gvm/var/run/*
	chown gvm:gvm -R build/debian/opt/gvm
	chmod 0755 -R build/debian/opt/gvm/lib
	dpkg -b build/debian openvas-${BASE_VER}-amd64.deb
###############################################################################

cert:
	chown gvm:gvm /opt/gvm
	sudo -Hiu gvm /opt/gvm/bin/gvm-manage-certs -af

nvt:
	chown gvm:gvm /opt/gvm
	sudo -Hiu gvm /opt/gvm/bin/greenbone-nvt-sync

feed:
	chown gvm:gvm /opt/gvm
	sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type GVMD_DATA
	sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type SCAP
	sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type CERT

###############################################################################
init:
	@ apt update
	apt install -y \
        gcc g++ cmake pkg-config bison \
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
        libmicrohttpd-dev \
        gnutls-bin        \
        xml-twig-tools    \
        xsltproc          \
        xmltoman          \
        clang-format      \
        doxygen           \
		python3-pip

	# python
	pip3 install pip --upgrade
	pip3 install setuptools setuptools_rust

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
	mkdir -p /opt/gvm
	chown gvm:gvm /opt/gvm

clean:
	rm -rf build
	
target_clean:
	rm -rf /opt/gvm
