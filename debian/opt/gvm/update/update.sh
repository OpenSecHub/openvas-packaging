#!/usr/bin/bash

LOGFILE=/opt/gvm/update/update.log

function show_msg() {
    ovtime=$(date +%Y-%m-%d\ %H:%M:%S)
    echo "[$ovtime][update] $1" >> ${LOGFILE}
}

show_msg "start"

show_msg "NVTs ..."
sudo -Hiu gvm /opt/gvm/bin/greenbone-nvt-sync                       >/dev/null 2>>${LOGFILE}
show_msg "GVMD_DATA ..."
sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type GVMD_DATA    >/dev/null 2>>${LOGFILE}
show_msg "SCAP ..."
sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type SCAP         >/dev/null 2>>${LOGFILE}
show_msg "CERT ..."
sudo -Hiu gvm /opt/gvm/sbin/greenbone-feed-sync --type CERT         >/dev/null 2>>${LOGFILE}

sudo -Hiu gvm /opt/gvm/sbin/openvas --update-vt-info                >/dev/null 2>>${LOGFILE}

show_msg "end"

