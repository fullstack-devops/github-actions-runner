[![Create Release](https://github.com/fullstack-devops/github-actions-runner/actions/workflows/create-release.yml/badge.svg)](https://github.com/fullstack-devops/github-actions-runner/actions/workflows/create-release.yml)
[![Anchore Container Scan](https://github.com/fullstack-devops/github-actions-runner/actions/workflows/anchore.yml/badge.svg)](https://github.com/fullstack-devops/github-actions-runner/actions/workflows/anchore.yml)

# GitHub Actions Custom Runner

Container images with Github Actions Runner. Different flavoured images with preinstalled tools and software for builds with limited internet access and non root privileges (exception for kaniko).
With a focus on already installed software to avoid a subsequent installation by a `setup-action`.

Ideal for building software in corporate environments of large and small organizations that often restrict Internet access.
Software builds can be built there using a [Nexus Repository](https://de.sonatype.com/products/repository-oss) or [JFrog Artifactory](https://jfrog.com/de/artifactory/)

Support: If you need help or a feature just open an issue!

Package / Images: `quay.io/fullstack-devops/github-actions-runner`

Available Tags:

| Name (tag)                | Installed Tools/ Software                                                                                                                                                                                                             | Dockerfile                                       | Description                                                                                        |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| `latest-base`             | libffi-dev, libicu-dev, build-essential, libssl-dev, ca-certificates, jq, sed, grep, git, curl, wget, zip, nodejs, ansible, [awesome-ci](https://github.com/fullstack-devops/awesome-ci), [alpaca](https://github.com/samuong/alpaca) | [Dockerfile](images/base/Dockerfile)             | Base runner with nothing fancy installed, but with internet connection more tools can be installed |
| `latest-kaniko-sidecar`   | kaniko                                                                                                                                                                                                                                | [Dockerfile](images/kaniko-sidecar/Dockerfile)   | Sidecar used by other runner images to build containers                                            |
| `latest-ansible-k8s`      | base-image + helm, kubectl, skopeo                                                                                                                                                                                                    | [Dockerfile](images/ansible-k8s/Dockerfile)      | Runner specializing in automated k8s deployments via Ansible in your cluster                       |
| `latest-maven-adopt-8-ng` | base-image + helm, maven, adoptopenjdk-8-hotspot, xmlstarlet                                                                                                                                                                          | [Dockerfile](images/maven-adopt-8-ng/Dockerfile) | Runner specialized in building Java applications that requires an older Java 8 version             |
| `latest-maven-temurin-11` | base-image + helm, maven, temurin-11, xmlstarlet,                                                                                                                                                                                     | [Dockerfile](images/maven-temurin-11/Dockerfile) | Runner specialized in building Java applications that requires Java temurin-11                     |
| `latest-maven-temurin-17` | base-image + helm, maven, temurin-17, xmlstarlet,                                                                                                                                                                                     | [Dockerfile](images/maven-temurin-17/Dockerfile) | Runner specialized in building Java applications that requires Java temurin-17                     |
| `latest-ng-cli-karma`     | base-image + helm, npm, yarn, angular/cli, chromium                                                                                                                                                                                   | [Dockerfile](images/ng-cli-karma/Dockerfile)     | Runner specialized in building Angular application and capable for testing with chromium and karma |
| `latest-golang`           | base-image + helm, go,                                                                                                                                                                                                                | [Dockerfile](images/golang/Dockerfile)           | Runner specialized in building go applications                                                     |

> Hint: `latest` can be replaced with an specific release version for more stability in your environment.

---

## Environmental variables

### Required environmental variables

| Variable                               | Type   | Description                                                                                                       |
| -------------------------------------- | ------ | ----------------------------------------------------------------------------------------------------------------- |
| `GH_ORG`, `GH_REPO` or `GH_ENTERPRISE` | string | Points to the GitHub enterprise, organisation or repo where the runner should be installed                        |
| `GH_ACCESS_TOKEN`                      | string | Developer Token vor the GitHub Organisation<br></br> This Token can be personal and is onlv needed during installation |

### Optional environmental variables

For the helm values see the [values.yaml](https://github.com/fullstack-devops/helm-charts/blob/main/charts/github-actions-runner/values.yaml), section `envValues`

| Variable                 | Type   | Default                  | Description                                                               |
| ------------------------ | ------ | ------------------------ | ------------------------------------------------------------------------- |
| `GH_URL`                 | string | `https://github.com`     | For GitHub Enterprise support                                             |
| `GH_API_ENDPOINT`        | string | `https://api.github.com` | For GitHub Enterprise support eg.: `https://git.example.com/api/v3/`      |
| `KANIKO_ENABLED`         | bool   | `false`                  | enable builds with kaniko (works only with kaniko-sidecar)                |
| `PROXY_PAC`              | string | -                        | proxy pac file url                                                        |
| `PROXY_NTLM_CREDENTIALS` | string | -                        | (required when `PROXY_PAC` is set) credentials when connecting with proxy |

---

## Proxy Support

The way out ;)

- Getting the Software to create the Credentials: https://github.com/samuong/alpaca/releases
- Creating your NTML Cerdentials `alpaca -d <windows-domain (optional)> -u <windows-user> -H`
- Set the env variables `PROXY_PAC` and `PROXY_NTLM_CREDENTIALS` in your container, pod or helm-chart
- If you want to use the proxy service in your github-action checkout the examples

## Examples

### Proxy in github actions

#### for only one step

```yaml
name: Deploy from internet

on:

jobs:
  add-helm-chart:
    runs-on: [self-hosted, ansible] # look for default tags or your own
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: check helm chart
        env:
          http_proxy: http://localhost:3128
          https_proxy: http://localhost:3128
          no_proxy: "197.0.0.0/8,*.internal.net" # replace with you internal reachable adresses
        run: |
          helm repo add fs-devops https://fullstack-devops.github.io/helm-charts/
          helm repo add sonatype https://sonatype.github.io/helm3-charts/

      - name: do something here

      - name: remove check helm chart
        if: always()
        run: |
          helm repo remove fs-devops
          helm repo remove sonatype
```

#### for whole workflow

```yaml
name: Deploy from internet

on:

env:
  http_proxy: http://localhost:3128
  https_proxy: http://localhost:3128
  no_proxy: "197.0.0.0/8,*.internal.net" # replace with you internal reachable adresses

jobs:
  add-helm-chart:
    runs-on: [self-hosted, ansible] # look for default tags or your own
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: check helm chart
        run: |
          helm repo add fs-devops https://fullstack-devops.github.io/helm-charts/
          helm repo add sonatype https://sonatype.github.io/helm3-charts/

      - name: do something here

      - name: remove check helm chart
        if: always()
        run: |
          helm repo remove fs-devops
          helm repo remove sonatype
```

### docker

If you are using `docker` or `podman` the options and commands are basically the same.

Run registerd to an Organisation:

```bash
docker run -e GH_ORG=fullstack-devops -e GH_ACCESS_TOKEN=ghp_**** quay.io/fullstack-devops/github-actions-runner:latest-base
```

Run registerd to an Organisation and Repo:

```bash
docker run -e GH_ORG=fullstack-devops -e GH_REPO=github-runner-testing -e GH_ACCESS_TOKEN=ghp_**** quay.io/fullstack-devops/github-actions-runner:latest-base
```

> Replace the `ghp_****` with your own valid personal access token

### docker-compose

```bash
cd examples/docker-compose
docker-compose up -d
```

### podman

Setup exchange directory (only nessesarry until podman supports emptyDir volumes)

```bash
mkdir /tmp/delme
```

Starting GitHub runner with podman

```bash
cd examples/podman

podman play kube deployment.yml
```

Removing GitHub runner an dumps

```bash
podman pod rm gh-runner-kaniko -f
rm -rf /tmp/delme
```

### kubernetes pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gh-runner-kaniko
spec:
  volumes:
    - name: workspace-volume
      emptyDir: {}
  containers:
    - name: kaniko
      image: quay.io/fullstack-devops/github-actions-runner:latest-kaniko-sidecar
      resources: {}
      volumeMounts:
        - name: workspace-volume
          mountPath: /kaniko/workspace/
      imagePullPolicy: IfNotPresent
      tty: true
    - name: github-actions-runner
      image: quay.io/fullstack-devops/github-actions-runner:latest-base
      resources: {}
      env:
        - name: GH_ORG
          value: "fullstack-devops"
        - name: KANIKO_ENABLED
          value: true
        - name: GH_ACCESS_TOKEN
          value: "ghp_*****"
      volumeMounts:
        - name: workspace-volume
          mountPath: /kaniko/workspace/
      imagePullPolicy: IfNotPresent
  restartPolicy: Never
```

### helm

https://github.com/fullstack-devops/helm-charts/tree/main/charts/github-actions-runner
