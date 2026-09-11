# forgejo-cache-publisher-image

Base image for the Forgejo Actions `cache-publisher` runner (used by
`GottaPhishSystem/cache-publisher`'s `sync.yml` workflow to publish
landing-page/scenario releases to OVH S3).

It bakes in the tools that workflow used to `apt-get install` and download on
every single run (`ca-certificates`, `curl`, `git`, `jq`, `unzip`, AWS CLI v2),
so each CI job skips straight to fetching the source revision and running
`aws s3 sync` instead of reinstalling the same toolchain from scratch.

Published to `ghcr.io/thib-d/forgejo-cache-publisher-image` by the GitHub
Actions workflow in this repo on every push to `main`.

## Usage

In a Forgejo Actions workflow:

```yaml
jobs:
  publish:
    runs-on: cache-publisher
    container: ghcr.io/thib-d/forgejo-cache-publisher-image:latest
```
