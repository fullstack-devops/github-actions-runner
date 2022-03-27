# github-runner-base
Base Image for github runner images in repo @fullstack-devops/github-runner. Can also be used as standalone image.

Available Containers:
| Name                                                                   | Description                                                                                                            |
|------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `ghcr.io/fullstack-devops/github-actions-runner:base-latest`           | Base runner with nothing fancy installed                                                                               |
| `ghcr.io/fullstack-devops/github-actions-runner:kaniko-sidecar-latest` | Sidecar used by Runner to build containers without root privileges                                                     |
| `ghcr.io/fullstack-devops/github-actions-runner:ansible-k8s-latest`    | Rrunner with ansible, kubectl and helm installed <br> For more Details see [Dockerfile](images/ansible-k8s/Dockerfile) |

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