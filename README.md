[![Create Release](https://github.com/fullstack-devops/github-actions-runner/actions/workflows/create-release.yml/badge.svg)](https://github.com/fullstack-devops/github-actions-runner/actions/workflows/create-release.yml)
[![Anchore Container Scan](https://github.com/fullstack-devops/github-actions-runner/actions/workflows/anchore.yml/badge.svg)](https://github.com/fullstack-devops/github-actions-runner/actions/workflows/anchore.yml)

# GitHub Actions Custom Runner
Container images with Github Actions Runner. Different flavored images with preinstalled tools and software for builds with limited internet access and non root privileges.

Ideal for building software in enterprise environments of large organizations that often restrict internet access.
Software builds can be built there using a [Nexus Repository](https://de.sonatype.com/products/repository-oss) or [JFrog Artifactory](https://jfrog.com/de/artifactory/)

Support: If you need help or a feature just open an issue!

Package / Images: `ghcr.io/fullstack-devops/github-actions-runner`

Available Tags:
| Name (tag)              | Installed Tools/ Software                                                                                 | Description                                                                                                                        |
|-------------------------|-----------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| `latest-base`           | libffi-dev, libicu-dev, build-essential, libssl-dev, ca-certificates, jq, sed, grep, git, curl, wget, zip | Base runner with nothing fancy installed <br> [Dockerfile](images/base/Dockerfile)                                                 |
| `latest-kaniko-sidecar` | kaniko                                                                                                    | Sidecar used by other runner images to build containers without root privileges                                                    |
| `latest-ansible-k8s`    | base-image + ansible, helm, kubectl, skopeo                                                               | Runner specialized for automated k8s deployments via ansible <br> For more Details see [Dockerfile](images/ansible-k8s/Dockerfile) |
| `latest-fullstacked`    | base-image + maven, openjdk-11, nodejs, go, yarn, angular/cli, helm                                       | Runner with a bunch of tools to build your hole application<br> For more Details see [Dockerfile](images/fullstacked/Dockerfile)   |

> Hint: `latest` can be replaced with an specific release version for more stability in your environment.

---

## Environmental variables

### Required environmental variables

| Variable          | Type   | Description                                                                                                       |
|-------------------|--------|-------------------------------------------------------------------------------------------------------------------|
| `GH_ORG`          | string | Points to the GitHub Organisation where the runner should be installed                                            |
| `GH_ACCESS_TOKEN` | string | Developer Token vor the GitHub Organisation<br> This Token can be personal and is onlv needed during installation |

### Optional environmental variables

For the helm values see the [values.yaml](helm/values.yaml), section `envValues`

| Variable          | Type   | Default                  | Description                                                          |
|-------------------|--------|--------------------------|----------------------------------------------------------------------|
| `GH_URL`          | string | `https://github.com`     | For GitHub Enterprise support                                        |
| `GH_API_ENDPOINT` | string | `https://api.github.com` | For GitHub Enterprise support eg.: `https://git.example.com/api/v3/` |
| `GH_REPO`         | string |                          | installing a runner to a spezific repository                         |
| `KANIKO_ENABLED`  | bool   | `false`                  | enable builds with kaniko (works only with kaniko-sidecar)           |

---

## Examples

### docker

If you are using `docker` or `podman` the options and commands are basically the same.

Run registerd to an Organisation:
```bash
docker run -e GH_ORG=fullstack-devops -e GH_ACCESS_TOKEN=ghp_**** github-runner-base:latest
```

Run registerd to an Organisation and Repo:
```bash
docker run -e GH_ORG=fullstack-devops -e GH_REPO=github-runner-testing -e GH_ACCESS_TOKEN=ghp_**** github-runner-base:latest
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
      image: ghcr.io/fullstack-devops/github-actions-runner:latest-kaniko-sidecar
      resources: {}
      volumeMounts:
        - name: workspace-volume
          mountPath: /kaniko/workspace/
      imagePullPolicy: IfNotPresent
      tty: true
    - name: github-actions-runner
      image: ghcr.io/fullstack-devops/github-actions-runner:latest-base
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

tbd