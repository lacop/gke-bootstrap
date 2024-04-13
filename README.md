# Slack yt-dlp integration

## Dev environment

Requires `nix` and flakes enabled. Then just `nix develop --no-write-lock-file` to enter the dev shell.

### GKE initial bootstrap

```shell
# Configure gcloud CLI
gcloud config set project <id>
gcloud config set compute/region europe-west1

# Enable GKE.
gcloud services enable container.googleapis.com
```
