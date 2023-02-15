FROM ubuntu:20.04

ARG UBUNTU_VERSION=20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG PACKAGES_BASE="libffi-dev libicu-dev build-essential libssl-dev ca-certificates software-properties-common curl"
ARG PACKAGES_ADDITIONAL="jq sed grep git wget zip ansible python3-pip nodejs"
ARG PACKAGES_PYTHON="kubernetes"

ENV USERNAME="runner"
ENV USERID=1000
ENV UBUNTU_VERSION=20.04

ENV HOME="/home/$USERNAME"
ENV RUNNER_HOME="/home/$USERNAME/runner"
ENV USER_TMP_DIR="/home/$USERNAME/tmp"

ENV GH_RUNNER_WORKDIR="/home/$USERNAME"
ENV GH_KANIKO_WORKDIR="/kaniko/workspace"

# https://github.com/actions/runner/releases
ENV GH_RUNNER_VERSION=2.302.0
ENV GH_RUNNER_LABELS=ubuntu-20.04

# https://github.com/fullstack-devops/awesome-ci/releases
ENV AWESOME_CI_VERSION 1.1.3
# https://github.com/samuong/alpaca/releases
ENV ALPACA_VERSION 1.3.2

# making nessecarry directories
RUN mkdir /helper-scripts \
  && mkdir -p /kaniko/workspace \
  && mkdir -p $USER_TMP_DIR \
  && mkdir -p $RUNNER_HOME \
  && mkdir -p $HOME/.ansible \
  && mkdir -p /run/user/$USERID \
  && mkdir -p /etc/ssl/certs/custom

# Copy image helper scripts
ADD ./helper-scripts/ /helper-scripts/

RUN chmod -R 755 /helper-scripts

RUN apt-get update \
  && apt-get install -y $PACKAGES_BASE \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

## ansible keys
RUN curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - \
  && echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

# install packages along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get update \
  && add-apt-repository -y --update ppa:ansible/ansible \
  && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get install -y $PACKAGES_ADDITIONAL \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# install awesoeme ci
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short)  \
  && curl -L -O https://github.com/fullstack-devops/awesome-ci/releases/download/${AWESOME_CI_VERSION}/awesome-ci_${AWESOME_CI_VERSION}_linux-${ARCH} \
  && mv awesome-ci_${AWESOME_CI_VERSION}_linux-${ARCH} /usr/local/src/awesome-ci \
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
  && chown -R $USERNAME $GH_KANIKO_WORKDIR

COPY requirements.yml $USER_TMP_DIR/requirements.yml

# Install github runner
RUN export ARCH=$(/helper-scripts/translate-aarch.sh x-short) \
  && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-${ARCH}-${GH_RUNNER_VERSION}.tar.gz \
  && tar -zxf actions-runner-linux-${ARCH}-${GH_RUNNER_VERSION}.tar.gz \
  && rm -f actions-runner-linux-${ARCH}-${GH_RUNNER_VERSION}.tar.gz \
  && ./bin/installdependencies.sh \
  && cd ./bin \
  && apt-get clean

# chown userscoped directories
RUN chown -R $USERNAME $HOME \
  && chown -R $USERNAME /run/user/$USERID

# set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["/helper-scripts/gh-entrypoint.sh"]

USER $USERNAME

RUN pip3 install $PACKAGES_PYTHON --user
# RUN ansible-galaxy install -c -r ${TMP_DIR}/requirements.yml
RUN ansible-galaxy collection install -c -r $USER_TMP_DIR/requirements.yml
