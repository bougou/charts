# Developer Guide

## Automated publish (recommended)

Each project keeps its chart source in its own repository, for example:

```text
alertmanager-webhook-adapter/deploy/charts/alertmanager-webhook-adapter/
```

Publishing is handled by GitHub Actions in the project repository:

1. Bump `Chart.yaml` version in the project repo
2. Commit and push to `main`
3. Create and push a release tag, for example `chart-1.1.0`
4. CI will:
   - run `helm lint` and `helm template`
   - push the packaged chart to `oci://registry-1.docker.io/bougoucharts`
   - copy the `.tgz` into this repo
   - regenerate `index.yaml` and `README.md`
   - commit and push this repo

Manual fallback from a project repo:

```bash
export DOCKERHUB_CHARTS_USER=...   # bougoucharts Docker Hub account
export DOCKERHUB_CHARTS_PASS=...   # bougoucharts PAT
export CHARTS_REPO_TOKEN=...
make chart-publish
```

## Manual publish

Use this only when CI is unavailable:

1. Login with the **bougoucharts** Docker Hub account and push the chart:

   ```bash
   helm registry login registry-1.docker.io -u "$DOCKERHUB_CHARTS_USER" -p "$DOCKERHUB_CHARTS_PASS"
   helm package deploy/charts/alertmanager-webhook-adapter -d /tmp
   helm push /tmp/alertmanager-webhook-adapter-<version>.tgz oci://registry-1.docker.io/bougoucharts
   ```

2. Copy the `.tgz` into `charts/` in this repository

3. Regenerate repository metadata:

   ```bash
   ./scripts/make-index.sh
   ./scripts/generate-charts-doc.sh
   ```

4. Commit and push:

   ```bash
   git add charts/ index.yaml README.md
   git commit -m "add <chart-name> <version> chart"
   git push
   ```

## Required secrets in project repositories

Docker Hub uses **two separate accounts**:

| Secret | Docker Hub account | Purpose |
|--------|-------------------|---------|
| `DOCKERHUB_USER` | bougou | Push application images |
| `DOCKERHUB_PASS` | bougou PAT | Push application images |
| `DOCKERHUB_CHARTS_USER` | bougoucharts | Push Helm chart OCI artifacts |
| `DOCKERHUB_CHARTS_PASS` | bougoucharts PAT | Push Helm chart OCI artifacts |
| `CHARTS_REPO_TOKEN` | GitHub PAT | Write access to `bougou/charts` |

## Notes

- Chart versions should use plain semver in `Chart.yaml`, for example `1.1.0`
- `index.yaml` URLs point to OCI artifacts on the **bougoucharts** account
- Application images referenced by charts live on the **bougou** account
- This repository is the Helm repo index; OCI is the chart artifact source
