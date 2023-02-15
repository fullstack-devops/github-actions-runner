FROM ghcr.io/fullstack-devops/github-actions-runner:latest-base

USER root
# install packages along with jq so we can parse JSON
# add additional packages as necessary
ARG PACKAGES="adoptopenjdk-8-hotspot xmlstarlet maven"

## adoptopenjdk keys
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
  && echo "deb https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ focal main" >> /etc/apt/sources.list

RUN apt-get update \
  && apt-get install -y --no-install-recommends ${PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# make cacerts for user accessable
RUN chmod 666 /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/jre/lib/security/cacerts

ENV GH_RUNNER_LABELS="ubuntu-20.04,maven,openjdk-8,nodejs,go,yarn,helm,ansible"
# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.8.1

# Install helm
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short) \
  && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xzO linux-${ARCH}/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

# install npm tools: yarn
ENV NPM_CONFIG_LOGLEVEL=warn NG_CLI_ANALYTICS=false
RUN npm install --location=global yarn pnpm @angular/cli@15 \
  && npm cache clean --force
  
RUN mkdir -p /home/${USERNAME}/.m2/ \
  && chown -R $USERNAME /home/$USERNAME

USER $USERNAME

# install helm plugins helm push, appr && diff
RUN helm plugin install --version 0.10.3 https://github.com/chartmuseum/helm-push.git \
  && helm plugin install --version 0.7.0 https://github.com/app-registry/appr-helm-plugin.git \
  && helm plugin install --version 3.6.0 https://github.com/databus23/helm-diff
