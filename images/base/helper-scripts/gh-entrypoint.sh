#!/bin/bash

# connection details
last_char="${GH_URL: -1}"
[[ $last_char == "/" ]] && GH_URL="${GH_URL::-1}"
readonly _GH_URL="${GH_URL:-https://github.com}"

last_char="${GH_API_ENDPOINT: -1}"
[[ $last_char == "/" ]] && GH_API_ENDPOINT="${GH_API_ENDPOINT::-1}"
readonly _GH_API_ENDPOINT="${GH_API_ENDPOINT:-https://api.github.com}"

# Org/ Repo details
if [ -z "$GH_ORG" ]; then
    readonly RUNNER_URL="${_GH_URL}/${GH_ORG}"
    readonly RUNNER_REG_TOKEN_URL="${_GH_API_ENDPOINT}/orgs/${GH_ORG}/actions/runners/registration-token"
elif [ -z "$GH_REPO" ]; then
    readonly RUNNER_URL="${_GH_URL}/${GH_ORG}/${GH_REPO}"
    readonly RUNNER_REG_TOKEN_URL="${_GH_API_ENDPOINT}/repos/${GH_ORG}/${GH_REPO}/actions/runners/registration-token"
elif [ -z "$GH_ENTERPRISE" ]; then
    readonly RUNNER_URL="${_GH_URL}/${GH_ENTERPRISE}"
    readonly RUNNER_REG_TOKEN_URL="${_GH_API_ENDPOINT}/enterprises/${GH_ENTERPRISEs}/actions/runners/registration-token"
else
    echo "Please provide Organisation detail by setting GH_ORG"
    exit 255
fi

# access details
if [ ! -z "$RUNNER_TOKEN" ]; then
    readonly REG_TOKEN=$RUNNER_TOKEN
elif [ ! -z $GH_ACCESS_TOKEN ]; then
    readonly REG_TOKEN=$(curl -s -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GH_ACCESS_TOKEN" $RUNNER_REG_TOKEN_URL | jq .token --raw-output)
else
    echo "Please provide one of the Environment Variables:"
    echo "GH_ACCESS_TOKEN, RUNNER_TOKEN"
    exit 255
fi

if [ -z ${RUNNER_HOME} ]; then
    echo "Environment variable 'RUNNER_HOME' is not set"
    exit 1
fi

if [ "$KANIKO_ENABLED" == "true" ]; then
    readonly GH_WORKDIR=$GH_KANIKO_WORKDIR
    echo "Build container via Kaniko: enabled"
    GH_RUNNER_LABELS="${GH_RUNNER_LABELS},kaniko"
else
    readonly GH_WORKDIR=$GH_RUNNER_WORKDIR
    echo "Build container via Kaniko: disabled"
fi

echo "Connecting runner to:       $RUNNER_URL"
echo "Individual Runner Name:     $HOSTNAME"
echo "Runner Home:                $RUNNER_HOME"

echo "Running setup fpr installed software..."
/helper-scripts/detect-setup.sh

${RUNNER_HOME}/config.sh \
    --name $HOSTNAME \
    --token $REG_TOKEN \
    --work $GH_WORKDIR \
    --url "$RUNNER_URL" \
    --labels $GH_RUNNER_LABELS \
    --unattended \
    --replace
echo "Runner configured"

cleanup() {
    echo "Removing runner..."
    if [ ! -z "$RUNNER_TOKEN" ]; then
        readonly REG_TOKEN=$RUNNER_TOKEN
    elif [ ! -z $GH_ACCESS_TOKEN ]; then
        readonly REG_TOKEN=$(curl -s -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GH_ACCESS_TOKEN" $RUNNER_REG_TOKEN_URL | jq .token --raw-output)
    fi
    ${RUNNER_HOME}/config.sh remove --token ${REG_TOKEN}
    exit 1
}

trap cleanup 0
${RUNNER_HOME}/run.sh $RUNNER_ARGS &

echo $! >/tmp/runner_pid
wait $!
