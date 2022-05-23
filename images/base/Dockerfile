FROM ubuntu:20.04

ARG UBUNTU_VERSION=20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG PACKAGES="libffi-dev libicu-dev build-essential libssl-dev ca-certificates software-properties-common jq sed grep git curl wget zip python3-pip"

ENV USERNAME="runner"
ENV UBUNTU_VERSION=20.04
ENV RUNNER_HOME="/home/${USERNAME}/runner"

ENV GH_RUNNER_WORKDIR="/home/${USERNAME}"
ENV GH_KANIKO_WORKDIR="/kaniko/workspace"

# https://github.com/actions/runner/releases
ENV GH_RUNNER_VERSION=2.291.1
ENV GH_RUNNER_LABELS=ubuntu-20.04

ENV AWESOME_CI_VERSION 0.11.6

# making nessecarry directories
RUN mkdir /helper-scripts \
  && mkdir -p /kaniko/workspace

# Copy image helper scripts
COPY ./helper-scripts/gh-entrypoint.sh /helper-scripts/gh-entrypoint.sh
COPY ./helper-scripts/kaniko-wrapper.sh /helper-scripts/kaniko-wrapper.sh
COPY ./helper-scripts/translate-aarch.sh /helper-scripts/translate-aarch.sh

RUN chmod -R 755 /helper-scripts

# install packages along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get update \
  && apt-get install -y ${PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# install awesoeme ci
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short)  \
  && curl -L -O https://github.com/fullstack-devops/awesome-ci/releases/download/${AWESOME_CI_VERSION}/awesome-ci_${AWESOME_CI_VERSION}_${ARCH} \
  && mv awesome-ci_${AWESOME_CI_VERSION}_${ARCH} /usr/local/src/awesome-ci \
  && chmod +x /usr/local/src/awesome-ci \
  && ln -s /usr/local/src/awesome-ci /usr/local/bin/

WORKDIR /home/${USERNAME}/runner

# add a non-sudo user
RUN useradd -m $USERNAME \
  && usermod -aG sudo $USERNAME \
  && chown -R $USERNAME $GH_RUNNER_WORKDIR \
  && chown -R $USERNAME $GH_KANIKO_WORKDIR \
  && mkdir -p ${RUNNER_HOME}

# Install github runner
RUN export ARCH=$(/helper-scripts/translate-aarch.sh x-short) \
  && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-${ARCH}-${GH_RUNNER_VERSION}.tar.gz \
  && tar -zxf actions-runner-linux-${ARCH}-${GH_RUNNER_VERSION}.tar.gz \
  && rm -f actions-runner-linux-${ARCH}-${GH_RUNNER_VERSION}.tar.gz \
  && ./bin/installdependencies.sh \
  && cd ./bin \
  && apt-get clean

RUN chown -R $USERNAME /home/${USERNAME}

# set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["/helper-scripts/gh-entrypoint.sh"]

USER $USERNAME
