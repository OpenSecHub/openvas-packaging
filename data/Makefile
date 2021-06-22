###############################################################################
#                                                                             #
#                     OpenVAS Feeds Packages                                  #
#                                                                             #
###############################################################################
NVT_VER=
SCAP_VER=
CERT_VER=
GVMD_DATA_VER=

# get NVTs version
NVT_FEEDFILE=/opt/gvm/var/lib/openvas/plugins/plugin_feed_info.inc
ifeq ($(wildcard ${NVT_FEEDFILE}),${NVT_FEEDFILE})
    NVT_VER=$(shell grep PLUGIN_SET ${NVT_FEEDFILE} | sed -e 's/[^0-9]//g')
endif

# get GVMD_DATA version
GVMD_DATA_FEEDFILE=/opt/gvm/var/lib/gvm/data-objects/gvmd/feed.xml
ifeq ($(wildcard ${GVMD_DATA_FEEDFILE}),${GVMD_DATA_FEEDFILE})
    GVMD_DATA_VER=$(shell grep version ${GVMD_DATA_FEEDFILE} | sed -e 's/[^0-9]//g')
endif

# get SCAP version
SCAP_FEEDFILE=/opt/gvm/var/lib/gvm/scap-data/feed.xml
ifeq ($(wildcard ${SCAP_FEEDFILE}),${SCAP_FEEDFILE})
    SCAP_VER=$(shell grep version ${SCAP_FEEDFILE} | sed -e 's/[^0-9]//g')
endif

# get CERT version
CERT_FEEDFILE=/opt/gvm/var/lib/gvm/cert-data/feed.xml
ifeq ($(wildcard ${CERT_FEEDFILE}),${CERT_FEEDFILE})
    CERT_VER=$(shell grep version ${CERT_FEEDFILE} | sed -e 's/[^0-9]//g')
endif



###############################################################################
.PHONY: feeds packdata packnvt packgvmddata packcert packscap clean all

all: feeds packdata

# pack nvt and feeds
packdata:packnvt packgvmddata packcert packscap



###############################################################################
### downlaod feeds

feeds:
	chown gvm:gvm -R /opt/gvm
	sudo -Hiu gvm /opt/gvm/bin/greenbone-nvt-sync
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
	@ rm -rf build
	@ mkdir -p build
	@ cp -r debian build/
	@ sed -i 's/%NAME%/openvas-$(1)/' build/debian/DEBIAN/control
	@ sed -i 's/%VERSION%/$(2)/'      build/debian/DEBIAN/control
	@ sed -i 's/%DESCRIPTION%/$(3)/'  build/debian/DEBIAN/control
	@ chmod 0755 build/debian/DEBIAN/control

	@ mkdir -p build/debian$(4)
	@ cp -r $(4)  build/debian$(4)/..
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

clean:
	rm -f *.deb
	rm -rf build
