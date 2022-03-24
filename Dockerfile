FROM ubuntu:20.04

COPY export-aarch-infos.sh /export-aarch-infos.sh
RUN chmod +x /export-aarch-infos.sh

ARG DEBIAN_FRONTEND=noninteractive

ENV USERNAME="runner"
ENV RUNNER_HOME="/home/${USERNAME}/runner"
ENV GH_WORKDIR="/home/${USERNAME}"

# https://github.com/actions/runner/releases
ENV GH_RUNNER_VERSION=2.289.1
ENV GH_RUNNER_LABELS=ubuntu-20.04

ENV AWESOME_CI_VERSION 0.11.1

# install packages along with jq so we can parse JSON
# add additional packages as necessary
ARG PACKAGES="libffi-dev libicu-dev build-essential libssl-dev ca-certificates jq sed grep git curl wget zip"

RUN apt-get update \
  && apt-get install -y ${PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# install awesoeme ci
RUN export ARCH=$(/export-aarch-infos.sh a-short)  \
  && curl -L -O https://github.com/eksrvb/awesome-ci/releases/download/${AWESOME_CI_VERSION}/awesome-ci_${AWESOME_CI_VERSION}_${ARCH} \
  && mv awesome-ci_${AWESOME_CI_VERSION}_${ARCH} /usr/local/src/awesome-ci_${AWESOME_CI_VERSION}_${ARCH} \
  && chmod +x /usr/local/src/awesome-ci_${AWESOME_CI_VERSION}_${ARCH} \
  && ln -s /usr/local/src/awesome-ci_${AWESOME_CI_VERSION}_${ARCH} /usr/local/bin/

WORKDIR /home/${USERNAME}/runner

# add a non-sudo user
RUN useradd -m $USERNAME \
  && usermod -aG sudo $USERNAME \
  && chown -R $USERNAME /home/${USERNAME} \
  && mkdir -p ${RUNNER_HOME}

# Install github runner
RUN export ARCH=$(/export-aarch-infos.sh x-short)  \
  && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-${ARCH}-${GH_RUNNER_VERSION}.tar.gz \
  && tar -zxf actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
  && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
  && ./bin/installdependencies.sh \
  && cd ./bin \
  && apt-get clean

# copy over the start script
COPY gh-entrypoint.sh /gh-entrypoint.sh
# make the script executable
RUN chmod +x /gh-entrypoint.sh

RUN chown -R $USERNAME /home/${USERNAME}
RUN chown -R $USERNAME /gh-entrypoint.sh

# set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["/gh-entrypoint.sh"]

USER $USERNAME