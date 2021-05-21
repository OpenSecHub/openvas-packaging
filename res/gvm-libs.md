# gvm-libs

> https://github.com/greenbone/gvm-libs/blob/master/INSTALL.md

## General build environment:

a C compiler (e.g. gcc)
cmake >= 3.0
pkg-config

## Specific development libraries:

| bin-package     | dev-package       | deps |
| --------------- | ----------------- | ---- |
| libglib2.0-0    | libglib2.0-dev    | No   |
| libgio          |                   |      |
| zlib            |                   |      |
| libgpgme11      | libgpgme-dev      |      |
| libgnutls       | libgnutls28-dev   | Yes  |
| libuuid         | uuid-dev          |      |
| libssh-gcrypt-4 | libssh-gcrypt-dev |      |
| libhiredis0.14  | libhiredis-dev    |      |
| libxml2         | libxml2-dev       |      |
| libnet1         | libnet1-dev       |      |
| libpcap         | libpcap-dev       |      |
| libgcrypt       |                   |      |
| doxygen         | N/A               |      |
| xmltoman        | N/A               |      |
| libldap2-dev    | libldap2-dev      |      |
| libradcli-dev   | libradcli-dev     |      |