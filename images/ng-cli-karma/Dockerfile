FROM ghcr.io/fullstack-devops/github-actions-runner:latest-base

USER root
# install packages along with jq so we can parse JSON
# add additional packages as necessary
ARG PACKAGES="chromium python3-selenium xvfb"
ARG PACKAGES_PYTHON="kubernetes"

## helper for karma and chromium
ENV CHROME_BIN="/usr/bin/chromium"
ADD xvfb-chromium /usr/bin/xvfb-chromium
ADD xvfb-chromium-webgl /usr/bin/xvfb-chromium-webgl
ADD display-chromium /usr/bin/display-chromium

RUN chmod +x /usr/bin/display-chromium /usr/bin/xvfb-chromium-webgl /usr/bin/xvfb-chromium

RUN apt-get update \
  && add-apt-repository -y --update ppa:xtradeb/apps \
  && apt-get install -y --no-install-recommends ${PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

ENV GH_RUNNER_LABELS="ubuntu-20.04,nodejs,yarn,karma,chrome,helm,ansible"
# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.8.1
# https://go.dev/dl/
ARG GO_VERSION=1.18

# Install helm
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short) \
  && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xzO linux-${ARCH}/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

RUN chown -R $USERNAME /home/$USERNAME

# install npm tools: yarn
ENV NPM_CONFIG_LOGLEVEL=warn NG_CLI_ANALYTICS=false
RUN npm install --location=global yarn pnpm @angular/cli@15 \
  && npm cache clean --force

USER $USERNAME

# install helm plugins helm push, appr && diff
RUN helm plugin install --version 0.10.3 https://github.com/chartmuseum/helm-push.git \
  && helm plugin install --version 0.7.0 https://github.com/app-registry/appr-helm-plugin.git \
  && helm plugin install --version 3.6.0 https://github.com/databus23/helm-diff
