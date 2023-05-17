FROM ghcr.io/fullstack-devops/github-actions-runner:latest-base

USER root

ENV GH_RUNNER_LABELS="ubuntu-20.04,nodejs,golang,helm,ansible"
# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.12.0
# https://go.dev/dl/
ARG GO_VERSION=1.20.4

# Install helm
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short) \
  && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xzO linux-${ARCH}/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

# install build tools for golang
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short) \
  && wget https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz -O /usr/local/src/go.linux.tar.gz \
  && tar -C /usr/local/src -xzf /usr/local/src/go.linux.tar.gz \
  && rm -rf /usr/local/src/go.linux.tar.gz \
  && ln -s /usr/local/src/go/bin/go /usr/local/bin/

RUN chown -R $USERNAME /home/$USERNAME

USER $USERNAME

ENV PATH=$PATH:/home/runner/go/bin

# install helm plugins helm push, appr && diff
RUN helm plugin install --version 0.10.3 https://github.com/chartmuseum/helm-push.git \
  && helm plugin install --version 0.7.0 https://github.com/app-registry/appr-helm-plugin.git \
  && helm plugin install --version 3.6.0 https://github.com/databus23/helm-diff
