# feeds mirror



### build feeds dirs

```bash
FEED_DIR=/data/openvas-feeds

mkdir -p ${FEED_DIR}/{nvt-feed,data-objects,cert-data,scap-data}

```

### sync feeds

```bash
#!/usr/bin/bash

FEED_DIR=/data/openvas-feeds
RSYNCOPT="-ltvrP --delete --perms --chmod=Fugo+r,Fug+w,Dugo-s,Dugo+rx,Dug+w"

rsync ${RSYNCOPT} rsync://feed.community.greenbone.net:/nvt-feed ${FEED_DIR}/nvt-feed
sleep 10

rsync ${RSYNCOPT} rsync://feed.community.greenbone.net:/data-objects/gvmd ${FEED_DIR}/data-objects
sleep 10

rsync ${RSYNCOPT} rsync://feed.community.greenbone.net:/cert-data ${FEED_DIR}/cert-data
sleep 10

rsync ${RSYNCOPT} rsync://feed.community.greenbone.net:/scap-data ${FEED_DIR}/scap-data
```

### feeds services

`/etc/rsyncd.conf`

```ini
[nvt-feed]
comment = openvas-nvt-feed
path = /data/openvas-feeds/nvt-feed
read only = yes
list = yes

[cert-data]
comment = cert-data
path = /data/openvas-feeds/cert-data
read only = yes
list = yes

[scap-data]
comment = scap-data
path = /data/openvas-feeds/scap-data
read only = yes
list = yes

[gvmd-data]
comment = data-objects/gvmd
path = /data/openvas-feeds/data-objects/gvmd
read only = yes
list = yes
```

### modify scripts

`/opt/gvm/bin/greenbone-nvt-sync` and `/opt/gvm/sbin/greenbone-feed-sync`