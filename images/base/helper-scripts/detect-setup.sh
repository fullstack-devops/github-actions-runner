#!/bin/bash

CA_FILE="/etc/ssl/certs/ca-certificates.crt"

# yarn
if command -v yarn -v &> /dev/null; then
    echo "add $CA_FILE to yarn"
    yarn config set cafile $CA_FILE
fi

# java
if command -v java --version &> /dev/null; then
    echo "add $CA_FILE to yarn"
    keytool -importcert -alias $CA_FILE -keystore /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/jre/lib/security/cacerts -storepass changeit -file $CA_FILE -noprompt
fi

# maven
if command -v mvn -v &> /dev/null; then
    if [ -f /mnt/dynamic/settings.xml ]; then
        echo "linking settings.xml from /mnt/dynamic/settings.xml to ${HOME}/.m2/settings.xml"
        ln -s /mnt/dynamic/settings.xml ${HOME}/.m2/settings.xml
    fi
fi