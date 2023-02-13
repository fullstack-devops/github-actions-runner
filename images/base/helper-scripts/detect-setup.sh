#!/bin/bash

CA_FILE="/etc/ssl/certs/ca-certificates.crt"

# yarn
if command -v yarn -v &> /dev/null; then
    echo ""
    echo "add $CA_FILE to yarn"
    yarn config set cafile $CA_FILE
fi

# java
if command -v java --version &> /dev/null; then
    echo ""
    javacerts=/tmp/javacerts
    echo "add $CA_FILE to java keystore"
    echo "generating single certs at $javacerts/"
    mkdir -p $javacerts
    cat $CA_FILE | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > ("/tmp/javacerts/cert" n ".crt")}'
    
    for f in $javacerts/*.crt ; do
        # delete empty lines in files
        sed -i '/^$/d' $f
    done
    # delete empty files to prevent errors at import
    find $javacerts -empty -delete
    
    java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    for x in $javacerts/*.crt ; do
        alias=$(openssl x509 -noout -subject -in "$x" | awk -F= '{print $NF}' | sed -e 's/^[ \t]*//' | sed -e 's/ /_/g')
        echo "importing cert of $alias"
        if [[ "$java_version" > "1.8" ]]; then
            echo "using java greater 1.8"
            keytool -importcert -alias $alias -cacerts -storepass changeit -file $x -noprompt
        else
            echo "using java lower 1.8"
            keytool -importcert -alias $alias -keystore /usr/lib/jvm/adopt*/jre/lib/security/cacerts -storepass changeit -file $x -noprompt
        fi
    done
    rm -rf $javacerts
fi

# maven
if command -v mvn -v &> /dev/null; then
    if [ -f /mnt/dynamic/settings.xml ]; then
        echo ""
        echo "linking settings.xml from /mnt/dynamic/settings.xml to ${HOME}/.m2/settings.xml"
        ln -s /mnt/dynamic/settings.xml ${HOME}/.m2/settings.xml
    fi
fi