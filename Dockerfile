# Build whosthere from upstream (https://github.com/ramonvermeulen/whosthere)
FROM golang:bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ARG WHOSTHERE_REF=main
WORKDIR /src
RUN git clone --depth 1 --branch "${WHOSTHERE_REF}" https://github.com/ramonvermeulen/whosthere.git .

ENV CGO_ENABLED=0
RUN go build -ldflags="-s -w" -o /whosthere .

# ttyd: not in Debian bookworm main; copy official multi-arch binary from upstream image
FROM ghcr.io/tsl0922/ttyd:latest AS ttyd-upstream

# Runtime: CA certs for HTTPS OUI lookups etc.; ttyd serves browser TTY (no -c => no HTTP auth)
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ttyd-upstream /usr/bin/ttyd /usr/local/bin/ttyd

COPY --from=builder /whosthere /usr/local/bin/whosthere

ENV TERM=xterm-256color

EXPOSE 7681

# -W: allow client keyboard input (required for the whosthere TUI)
ENTRYPOINT ["ttyd", "-W", "-p", "7681", "whosthere"]
