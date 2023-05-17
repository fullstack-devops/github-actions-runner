FROM ghcr.io/fullstack-devops/github-actions-runner:latest-base

USER root
# add additional packages as necessary
ARG PACKAGES="temurin-17-jdk xmlstarlet"
ARG PACKAGES_PYTHON="kubernetes"

RUN apt-get update \
  && apt-get install -y --no-install-recommends ${PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# maven version > 3.6 is still not in ubuntu package managemant
ENV MAVEN_VERSION=3.9.2
RUN curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xzC /opt/ \
  && ln -s /opt/apache-maven-3.9.0/bin/mvn /usr/bin/mvn

# make cacerts for user accessable
RUN chmod 666 /usr/lib/jvm/temurin*/lib/security/cacerts

ENV GH_RUNNER_LABELS="ubuntu-20.04,maven,temurin-17,helm,ansible"
# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.12.0

# Install helm
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short) \
  && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xzO linux-${ARCH}/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

RUN mkdir -p /home/${USERNAME}/.m2/ \
  && chown -R $USERNAME /home/$USERNAME

USER $USERNAME

# install helm plugins helm push, appr && diff
RUN helm plugin install --version 0.10.3 https://github.com/chartmuseum/helm-push.git \
  && helm plugin install --version 0.7.0 https://github.com/app-registry/appr-helm-plugin.git \
  && helm plugin install --version 3.6.0 https://github.com/databus23/helm-diff
