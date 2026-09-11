# --- builder: fetch and verify the AWS CLI v2 installer, then install it ---
FROM ubuntu:24.04 AS builder

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSLo /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
    && curl -fsSLo /tmp/awscliv2.zip.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig \
    && curl -fsSLo /tmp/aws-cli-public-key.asc https://awscli.amazonaws.com/aws-cli-public-key.asc \
    && gpg --import /tmp/aws-cli-public-key.asc \
    && gpg --verify /tmp/awscliv2.zip.sig /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/awscliv2.zip.sig /tmp/aws-cli-public-key.asc /tmp/aws

# --- final: only what the workflow actually runs at job time ---
FROM ubuntu:24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates git jq \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/aws-cli /usr/local/aws-cli
COPY --from=builder /usr/local/bin/aws /usr/local/bin/aws
COPY --from=builder /usr/local/bin/aws_completer /usr/local/bin/aws_completer
