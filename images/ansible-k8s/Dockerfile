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
ARG KUBECTL_VERSION=1.21.0
ARG HELM_VERSION=3.6.3

# Install kubectl
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl

# Install helm
RUN wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
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
