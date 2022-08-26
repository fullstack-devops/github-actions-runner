FROM ubuntu:20.04

ARG UBUNTU_VERSION=20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG PACKAGES="libffi-dev libicu-dev build-essential libssl-dev ca-certificates software-properties-common jq sed grep git curl wget zip python3-pip"

ENV USERNAME="runner"
ENV USERID=1000
ENV UBUNTU_VERSION=20.04
ENV RUNNER_HOME="/home/${USERNAME}/runner"

ENV GH_RUNNER_WORKDIR="/home/${USERNAME}"
ENV GH_KANIKO_WORKDIR="/kaniko/workspace"

# https://github.com/actions/runner/releases
ENV GH_RUNNER_VERSION=2.296.0
ENV GH_RUNNER_LABELS=ubuntu-20.04

# https://github.com/fullstack-devops/awesome-ci/releases
ENV AWESOME_CI_VERSION 0.11.6
# https://github.com/samuong/alpaca/releases
ENV ALPACA_VERSION 1.3.1

# making nessecarry directories
RUN mkdir /helper-scripts \
  && mkdir -p /kaniko/workspace

# Copy image helper scripts
ADD ./helper-scripts/detect-setup.sh /helper-scripts/detect-setup.sh
ADD ./helper-scripts/gh-entrypoint.sh /helper-scripts/gh-entrypoint.sh
ADD ./helper-scripts/kaniko-wrapper.sh /helper-scripts/kaniko-wrapper.sh
ADD ./helper-scripts/translate-aarch.sh /helper-scripts/translate-aarch.sh

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

# install alpaca
RUN curl -L -O https://github.com/samuong/alpaca/releases/download/v${ALPACA_VERSION}/alpaca_v${ALPACA_VERSION}_linux-amd64 \
  && mv alpaca_v${ALPACA_VERSION}_linux-amd64 /usr/local/src/alpaca \
  && chmod +x /usr/local/src/alpaca \
  && ln -s /usr/local/src/alpaca /usr/local/bin/

WORKDIR /home/${USERNAME}/runner

# add a non-sudo user
RUN useradd -m -u $USERID $USERNAME \
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
