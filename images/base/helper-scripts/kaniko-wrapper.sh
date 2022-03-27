#!/bin/sh
logpipe=/kaniko/workspace/log
returnpipe=/kaniko/workspace/returncode
if [ -p $logpipe ]; then
    cat 0<> "$logpipe" <"$logpipe"
    rm $logpipe
    echo "Warning: removed stale communication file with kaniko"
fi
if [ -p $returnpipe ]; then
    cat 0<> "$returnpipe" <"$returnpipe"
    rm $returnpipe
    echo "Warning: removed stale communication returncode file with kaniko"
fi
echo "cd ${PWD}" > /kaniko/workspace/start.sh
echo "/kaniko/executor --cleanup --force $@" >> /kaniko/workspace/start.sh
mkfifo $returnpipe
mkfifo $logpipe
cat $logpipe
rm $logpipe
returncode=`cat $returnpipe | tr -d "\n"`
rm $returnpipe
echo ${returncode}
exit ${returncode}