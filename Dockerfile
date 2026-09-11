# --- builder: fetch and verify the AWS CLI v2 installer, then install it ---
FROM debian:12-slim AS builder

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg unzip \
    && rm -rf /var/lib/apt/lists/*

COPY aws-cli-public-key.asc /tmp/aws-cli-public-key.asc

RUN curl -fsSLo /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
    && curl -fsSLo /tmp/awscliv2.zip.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig \
    && gpg --import /tmp/aws-cli-public-key.asc \
    && gpg --verify /tmp/awscliv2.zip.sig /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/awscliv2.zip.sig /tmp/aws-cli-public-key.asc /tmp/aws

# --- final: only what the workflow actually runs at job time, as a non-root user ---
FROM debian:12-slim

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends ca-certificates git jq \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 --shell /bin/sh runner

# Recreate the /usr/local/bin symlinks natively instead of COPYing them: COPY
# dereferences a single symlinked file across build stages, which strands the
# PyInstaller-bundled aws binary without its sibling libpython*.so (both live
# together under aws-cli/v2/*/dist, not in /usr/local/bin).
COPY --from=builder /usr/local/aws-cli /usr/local/aws-cli
RUN ln -s /usr/local/aws-cli/v2/current/bin/aws /usr/local/bin/aws \
    && ln -s /usr/local/aws-cli/v2/current/bin/aws_completer /usr/local/bin/aws_completer

USER runner
WORKDIR /home/runner
