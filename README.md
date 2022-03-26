# github-runner-base
Base Image for github runner images in repo @fullstack-devops/github-runner. Can also be used as standalone image.

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
    image: github-action-runner:base-latest
    environment:
      GH_ORG: fullstack-devops
      GH_ACCESS_TOKEN: ghp_****
    volumes:
      - kaniko_workspace:/kaniko/workspace

  github-action-runner-kaniko:
    image: github-action-runner:kaniko-sidecar-latest
    volumes:
      - kaniko_workspace:/kaniko/workspace

```

### kubernetes pod

tbd

### helm

tbd