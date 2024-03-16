FROM alpine:3.19 as builder

ARG BWS_VERSION

WORKDIR /bws

# Get specified or latest version of bws, unzip, and make executable
RUN \
    apk add -q --no-cache \
        curl \
        unzip && \
    if [ -z ${BWS_VERSION+x} ]; then \
        BWS_VERSION=$( curl -s "https://api.github.com/repos/bitwarden/sdk/releases/latest" \
            | grep "tag_name" \
            | sed 's/.*\([0-9]\.[0-9]\.[0-9].*\)".*/\1/' ); \
    fi && \
    curl -sL -o "bws.zip" "https://github.com/bitwarden/sdk/releases/download/bws-v${BWS_VERSION}/bws-x86_64-unknown-linux-gnu-${BWS_VERSION}.zip" && \
    unzip -qq "bws.zip" && \
    rm -f "bws.zip" && \
    chmod +x "bws"

FROM gcr.io/distroless/cc-debian12

COPY --from=builder /bws/bws /

LABEL org.opencontainers.image.authors="Bitwarden, Inc."
LABEL org.opencontainers.image.url="https://bitwarden.com/products/secrets-manager"
LABEL org.opencontainers.image.source="https://github.com/bitwarden/sdk.git"
LABEL org.opencontainers.image.title="Bitwarden Secrets Manager SDK"

ENTRYPOINT [ "/bws" ]
CMD [ "--help" ]
