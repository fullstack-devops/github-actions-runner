FROM ghcr.io/fullstack-devops/github-actions-runner:base-latest

USER root
# install packages along with jq so we can parse JSON
# add additional packages as necessary
ARG PACKAGES="openjdk-11-jdk maven nodejs"

RUN apt-get update \
  && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get install -y --no-install-recommends ${PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

ENV GH_RUNNER_LABELS="ubuntu-20.04,maven,openjdk-11,nodejs,go,yarn,helm"
# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.8.1
# https://go.dev/dl/
ARG GO_VERSION=1.18

# Install helm
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short) \
  && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xzO linux-${ARCH}/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

# install build tools for golang
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short) \
  && wget https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz -O /usr/local/src/go.linux.tar.gz \
  && tar -xf /usr/local/src/go.linux.tar.gz \
  && rm -rf /usr/local/src/go.linux.tar.gz \
  && ln -s /usr/local/src/go/bin/go /usr/local/bin/

# install npm tools: yarn
RUN npm install --global yarn @angular/cli@13

RUN mkdir -p /home/${USERNAME}/.m2/ \
  && chown -R ${USERNAME} /home/${USERNAME}
USER ${USERNAME}

# install helm plugins helm push, appr && diff
RUN helm plugin install --version 0.10.2 https://github.com/chartmuseum/helm-push.git \
  && helm plugin install --version 0.7.0 https://github.com/app-registry/appr-helm-plugin.git \
  && helm plugin install --version 3.4.2 https://github.com/databus23/helm-diff
