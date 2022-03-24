#!/bin/bash

if [ -z ${GH_ACCESS_TOKEN} ];
then
    echo "Environment variable 'GH_ACCESS_TOKEN' is not set"
    exit 1
fi

if [ -z ${GH_URL} ];
then
    echo "Environment variable 'GH_URL' is not set"
    echo "Using public github.com!"
    GH_URL="https://github.com/"
fi
### Add trailing slash to GH_URL if needed
last_char="${GH_URL: -1}"
[[ $last_char != "/" ]] && GH_URL="$GH_URL/"; :

if [ -z ${GH_API_URL} ];
then
    echo "Environment variable 'GH_API_URL' is not set"
    echo "Using public github.com!"
    GH_API_URL="https://api.github.com/"
fi
### Add trailing slash to GH_API_URL if needed
last_char="${GH_API_URL: -1}"
[[ $last_char != "/" ]] && GH_API_URL="$GH_API_URL/"; :

ACCESS_TOKEN=$GH_ACCESS_TOKEN
unset GH_ACCESS_TOKEN

if [ -z ${GH_ORGANIZATION} ];
then
    echo "Environment variable 'GH_ORGANIZATION' is not set"
    exit 1
fi

if [ -z ${RUNNER_HOME} ];
then
    echo "Environment variable 'RUNNER_HOME' is not set"
    exit 1
fi

REG_TOKEN=$(curl -s -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $ACCESS_TOKEN" ${GH_API_URL}orgs/${GH_ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)

echo "Individual Runner Name: $HOSTNAME"
echo "Runner Home: $RUNNER_HOME"

${RUNNER_HOME}/config.sh \
    --name ${HOSTNAME} \
    --token ${REG_TOKEN} \
    --work ${GH_WORKDIR} \
    --url "${GH_URL}${GH_ORGANIZATION}" \
    --labels ${GH_RUNNER_LABELS} \
    --unattended \
    --replace
echo "Runner configured"

cleanup() {
    echo "Removing runner..."
    REG_TOKEN=$(curl -s -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${ACCESS_TOKEN}" ${GH_API_URL}orgs/${GH_ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)
    ${RUNNER_HOME}/config.sh remove --token ${REG_TOKEN}
    exit 1
}

trap cleanup 0
${RUNNER_HOME}/run.sh & 

echo $! > /tmp/runner_pid
wait $!