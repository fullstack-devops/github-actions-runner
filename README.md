# github-runner-base
Base Image for github runner images in repo @fullstack-devops/github-runner. Can also be used as standalone image.

---

## Environmental variables

### Required environmental variables

| Variable          | Type   | Description                                                                                                       |
|-------------------|--------|-------------------------------------------------------------------------------------------------------------------|
| `GH_ORGANIZATION` | string | Points to the GitHub Organisation where the runner should be installed                                            |
| `GH_ACCESS_TOKEN` | string | Developer Token vor the GitHub Organisation<br> This Token can be personal and is onlv needed during installation |

### Optional environmental variables

For the helm values see the [values.yaml](helm/values.yaml), section `envValues`

| Variable     | Type   | Default                  | Description                                                          |
|--------------|--------|--------------------------|----------------------------------------------------------------------|
| `GH_URL`     | string | `https://github.com`     | For GitHub Enterprise support                                        |
| `GH_API_URL` | string | `https://api.github.com` | For GitHub Enterprise support eg.: `https://git.example.com/api/v3/` |
