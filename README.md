# github-runner-base
Container images with Github Actions Runner. Different flavored images with preinstalled tools and software for builds with limited internet access and non root privileges.

Ideal for building software in enterprise environments of large organizations that often restrict internet access.
Software builds can be built there using a [Nexus Repository](https://de.sonatype.com/products/repository-oss) or [JFrog Artifactory](https://jfrog.com/de/artifactory/)

Support: If you need help or a feature just open an issue!

Available Containers:
| Name (tag)              | Installed Tools/ Software                                                                                 | Description                                                                                                                      |
|-------------------------|-----------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| `base-latest`           | libffi-dev, libicu-dev, build-essential, libssl-dev, ca-certificates, jq, sed, grep, git, curl, wget, zip | Base runner with nothing fancy installed <br> [Dockerfile](images/base/Dockerfile)                                               |
| `kaniko-sidecar-latest` | kaniko                                                                                                    | Sidecar used by other runner images to build containers without root privileges                                                               |
| `ansible-k8s-latest`    | base-image + ansible, helm, kubectl                                                                       | Runner specialized for automated k8s deployments via ansible <br> For more Details see [Dockerfile](images/ansible-k8s/Dockerfile)            |
| `fullstacked-latest`    | base-image + maven, openjdk-11, nodejs, go, yarn, angular/cli, helm                                       | Runner with a bunch of tools to build your hole application<br> For more Details see [Dockerfile](images/fullstacked/Dockerfile) |

> Hint: `latest can be replaced with an spezfic release version for more stability`

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

### docker or podman

If you are using `docker` or `podman` the options and commands are basically the same.

Run registerd to an Organisation:
```bash
podman run -e GH_ORG=fullstack-devops -e GH_ACCESS_TOKEN=ghp_**** github-runner-base:latest
```

Run registerd to an Organisation and Repo:
```bash
podman run -e GH_ORG=fullstack-devops -e GH_REPO=github-runner-testing -e GH_ACCESS_TOKEN=ghp_**** github-runner-base:latest
```

> Replace the `ghp_****` with your own valid personal access token

### docker-compose

```yaml
version: "3"

services:
  github-runner:
    image: github-runner-base:latest
    environment:
      GH_ORG: fullstack-devops
      GH_ACCESS_TOKEN: ghp_****
```

Build images with kaniko:
```yaml
version: "3"

volumes:
  kaniko_workspace:
      driver: local

services:
  github-action-runner:
    image: ghcr.io/fullstack-devops/github-actions-runner:base-latest
    environment:
      GH_ORG: fullstack-devops
      GH_ACCESS_TOKEN: ghp_****
      KANIKO_ENABLED: "true"
    volumes:
      - kaniko_workspace:/kaniko/workspace

  github-action-runner-kaniko:
    image: ghcr.io/fullstack-devops/github-actions-runner:kaniko-sidecar-latest
    volumes:
      - kaniko_workspace:/kaniko/workspace
```

### kubernetes pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gha-runner-kaniko
spec:
  volumes:
    - name: workspace-volume
      emptyDir: {}
  containers:
    - name: github-actions-runner
      image: ghcr.io/fullstack-devops/github-actions-runner:base-latest
      resources: {}
      volumeMounts:
        - name: workspace-volume
          mountPath: /kaniko/workspace/    
      imagePullPolicy: Never
      tty: true
    - name: kaniko-sidecar
      image: ghcr.io/fullstack-devops/github-actions-runner:kaniko-sidecar-latest
      resources: {}
      volumeMounts:
        - name: workspace-volume
          mountPath: /kaniko/workspace/
      imagePullPolicy: Never
  restartPolicy: Never
```

### helm

tbd