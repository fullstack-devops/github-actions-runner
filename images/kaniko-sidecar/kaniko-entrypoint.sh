#!/busybox/sh
while [ true ]
do
    echo "kaniko container waiting for pipe"
    while [ ! -p /kaniko/workspace/log ]; do sleep 1; done
    echo "kaniko container executing"
    /busybox/sh /kaniko/workspace/start.sh > /kaniko/workspace/log 2>&1
    echo $? > /kaniko/workspace/returncode
    if [ ! -f "/busybox/sh" ]; then
        echo "kaniko self destructed. restarting container"
        exit 1
    fi
    echo "kaniko container end"
    sleep 5
done