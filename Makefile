###############################################################################
# only support Tag Version
PACKVER=21.4.1

GVM_LIBS_VER=${PACKVER}
SMB_VER=21.4.0
SCANNER_VER=${PACKVER}
GVMD_VER=${PACKVER}
GSA_VER=21.4.0
OSPD_VER=21.4.0
OSPD_OPENVAS_VER=21.4.0


PWD=$(shell pwd)
# DO NOT MODIFY
INSTALL_PATH=/opt/gvm
PYTHONVENV=${INSTALL_PATH}/python3

include build.mk
include install.mk
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
	@ dpkg -b build/debian build/openvas-v${PACKVER}-amd64.deb
	@ ls ${PWD}/build/*.deb

###############################################################################
# create build environment
init:
	@ apt update -y
	@ apt upgrade -y
	apt install -y ${BUILD_DEPS}
        

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
install:
	@ apt install -y ${INSTALL_DEPS}

	@ echo "db_address = /run/redis-openvas/redis.sock" > /opt/gvm/etc/openvas/openvas.conf

	@ cp -r debian/opt/gvm/.config    /opt/gvm/
	@ cp -r debian/opt/gvm/update     /opt/gvm/
	@ cp debian/opt/gvm/.bashrc       /opt/gvm/
	@ cp debian/opt/gvm/.profile      /opt/gvm/
	@ cp debian/etc/redis/*           /etc/redis/
	@ cp debian/etc/cron.d/*          /etc/cron.d/
	@ cp debian/etc/ld.so.conf.d/*    /etc/ld.so.conf.d/
	@ cp debian/etc/sudoers.d/*       /etc/sudoers.d/
	@ cp debian/etc/sysctl.d/*        /etc/sysctl.d/
	@ cp debian/etc/systemd/system/*  /etc/systemd/system/

	@ chown gvm:gvm -R /opt/gvm
	@ chmod 0755 -R    /opt/gvm/lib

	@ bash debian/DEBIAN/postinst

###############################################################################
clean:
	rm -rf build
