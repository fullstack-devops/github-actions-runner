FROM golang:1.16 AS build
WORKDIR $GOPATH/src/github.com/containers/skopeo
ENV CGO_ENABLED=0
ENV BUILDTAGS=containers_image_openpgp
ENV DISABLE_DOCS=1
RUN git clone --depth 1 --branch v1.7.0 https://github.com/containers/skopeo $GOPATH/src/github.com/containers/skopeo
RUN make bin/skopeo

FROM ghcr.io/fullstack-devops/github-actions-runner:latest-base

USER root

ENV GH_RUNNER_LABELS="ubuntu-20.04,ansible-k8s"
# https://github.com/kubernetes/kubernetes/releases/
ARG KUBECTL_VERSION=1.23.5
# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.12.0

COPY --from=build /go/src/github.com/containers/skopeo/bin/skopeo /usr/local/bin/skopeo
COPY --from=build /go/src/github.com/containers/skopeo/default-policy.json /etc/containers/policy.json

# Install kubectl
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short)  \
  && wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl -O /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl

# Install helm
RUN export ARCH=$(/helper-scripts/translate-aarch.sh a-short)  \
  && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xzO linux-${ARCH}/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

RUN chown -R $USERNAME /home/$USERNAME

USER $USERNAME

# install helm plugins helm push, appr && diff
RUN helm plugin install --version 0.10.3 https://github.com/chartmuseum/helm-push.git \
  && helm plugin install --version 0.7.0 https://github.com/app-registry/appr-helm-plugin.git \
  && helm plugin install --version 3.6.0 https://github.com/databus23/helm-diff
