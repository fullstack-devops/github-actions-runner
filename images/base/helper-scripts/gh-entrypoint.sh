#!/bin/bash

echo "#####################"
echo "Running entrypoint.sh"
echo ""

# connection details
if [ -n "$GH_URL" ]; then
    last_char="${GH_URL: -1}"
    [[ $last_char == "/" ]] && GH_URL="${GH_URL::-1}"
    readonly _GH_URL="$GH_URL"
    echo "Using custom GitHub enterprise instance:           $_GH_URL"
else
    readonly _GH_URL="https://github.com"
    echo "Using default GitHub instance:                     $_GH_URL"
fi

if [ -n "$GH_API_ENDPOINT" ]; then
    last_char="${GH_API_ENDPOINT: -1}"
    [[ $last_char == "/" ]] && GH_API_ENDPOINT="${GH_API_ENDPOINT::-1}"
    readonly _GH_API_ENDPOINT="$GH_API_ENDPOINT"
    echo "Using custom api url:                              $_GH_API_ENDPOINT"
else
    # if GH_API_ENDPOINT not specified but GH_URL
    if [ -n "$GH_URL" ]; then
        readonly _GH_API_ENDPOINT="$_GH_URL/api/v3"
        echo "Using custom GitHub instance with default api url: $_GH_API_ENDPOINT"
    else
        readonly _GH_API_ENDPOINT="https://api.github.com"
        echo "Using default GitHub instance:                     $_GH_API_ENDPOINT"
    fi
fi

# proxy support
if [ -n "$PROXY_PAC" ]; then
    echo "Using configured Proxy PAC"
    if [ ! -n "$PROXY_NTLM_CREDENTIALS" ]; then
        echo "Please provide the Environment Variable 'PROXY_NTLM_CREDENTIALS'"
        exit 255
    fi
    NTLM_CREDENTIALS="$PROXY_NTLM_CREDENTIALS" alpaca -C "$PROXY_PAC" 2>&1 1>/dev/null &
    unset PROXY_NTLM_CREDENTIALS
    echo $! >/tmp/proxy_pid
fi

# Org/ Repo details
if [ -n "$GH_ORG" ]; then
    readonly RUNNER_URL="${_GH_URL}/${GH_ORG}"
    readonly RUNNER_REG_TOKEN_URL="${_GH_API_ENDPOINT}/orgs/${GH_ORG}/actions/runners/registration-token"
    elif [ -n "$GH_ORG" ] && [ -n "$GH_REPO" ]; then
    readonly RUNNER_URL="${_GH_URL}/${GH_ORG}/${GH_REPO}"
    readonly RUNNER_REG_TOKEN_URL="${_GH_API_ENDPOINT}/repos/${GH_ORG}/${GH_REPO}/actions/runners/registration-token"
    elif [ -n "$GH_ENTERPRISE" ]; then
    readonly RUNNER_URL="${_GH_URL}/${GH_ENTERPRISE}"
    readonly RUNNER_REG_TOKEN_URL="${_GH_API_ENDPOINT}/enterprises/${GH_ENTERPRISEs}/actions/runners/registration-token"
else
    echo "Please provide the following credentials:"
    echo "  Repository: GH_ORG and GH_REPO"
    echo "  Organisation: GH_ORG"
    echo "  Enterprise: GH_ENTERPRISE"
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
    exit 255
fi

if [ "$KANIKO_ENABLED" == "true" ]; then
    readonly GH_WORKDIR=$GH_KANIKO_WORKDIR
    echo "Build container via Kaniko:                        enabled"
    GH_RUNNER_LABELS="${GH_RUNNER_LABELS},kaniko"
else
    readonly GH_WORKDIR=$GH_RUNNER_WORKDIR
    echo "Build container via Kaniko:                        disabled"
fi

echo "Connecting runner to:                              $RUNNER_URL"
echo "Individual Runner Name:                            $HOSTNAME"
echo "Runner Home:                                       $RUNNER_HOME"
echo ""
echo "Running setup for installed software..."
/helper-scripts/detect-setup.sh

echo "configure GitHub runner"
${RUNNER_HOME}/config.sh \
--name $HOSTNAME \
--token $REG_TOKEN \
--work $GH_WORKDIR \
--url "$RUNNER_URL" \
--labels $GH_RUNNER_LABELS \
--runnergroup ${GH_RUNNER_GROUP:-'default'} \
--unattended \
--replace
echo "GitHub runner configured"

cleanup() {
    echo "Removing runner..."
    if [ ! -z "$RUNNER_TOKEN" ]; then
        readonly REG_TOKEN_RM=$RUNNER_TOKEN
        elif [ ! -z $GH_ACCESS_TOKEN ]; then
        readonly REG_TOKEN_RM=$(curl -s -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GH_ACCESS_TOKEN" $RUNNER_REG_TOKEN_URL | jq .token --raw-output)
    fi
    ${RUNNER_HOME}/config.sh remove --token ${REG_TOKEN_RM}
    exit 1
}

trap cleanup 0
${RUNNER_HOME}/run.sh $RUNNER_ARGS &

echo $! >/tmp/runner_pid
wait $!
