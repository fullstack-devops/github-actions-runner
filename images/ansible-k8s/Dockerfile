FROM ghcr.io/fullstack-devops/github-actions-runner:base-latest

USER root
# install packages along with jq so we can parse JSON
# add additional packages as necessary
ARG PACKAGES="ansible"

RUN apt-get update \
  && apt-get install -y --no-install-recommends ${PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

ENV GH_RUNNER_LABELS="ubuntu-20.04,ansible-k8s"
# https://github.com/kubernetes/kubernetes/releases/
ARG KUBECTL_VERSION=1.23.5
# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.8.1

# Install kubectl
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short)  \
  && wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl -O /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl

# Install helm
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short)  \
  && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xzO linux-${ARCH}/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

ENV TMP_DIR=/home/${USERNAME}/tmp

RUN mkdir /home/${USERNAME}/.ansible
RUN mkdir ${TMP_DIR}

COPY requirements.yml ${TMP_DIR}/requirements.yml

RUN chown -R ${USERNAME} /home/${USERNAME}

USER ${USERNAME}

RUN ansible-galaxy install -c -r ${TMP_DIR}/requirements.yml
RUN ansible-galaxy collection install -c -r ${TMP_DIR}/requirements.yml

# install helm plugins helm push, appr && diff
RUN helm plugin install --version 0.10.2 https://github.com/chartmuseum/helm-push.git \
  && helm plugin install --version 0.7.0 https://github.com/app-registry/appr-helm-plugin.git \
  && helm plugin install --version 3.4.2 https://github.com/databus23/helm-diff
