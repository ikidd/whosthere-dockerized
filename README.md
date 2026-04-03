# whosthere (Docker + web TTY)

This repository packages **[whosthere](https://github.com/ramonvermeulen/whosthere)** — a LAN discovery tool with an interactive terminal UI — so you can run it in Docker and use it from a browser.

Whosthere is written by [ramonvermeulen/whosthere](https://github.com/ramonvermeulen/whosthere) (Apache-2.0). This repo only adds container wiring; all application behavior comes from upstream.

## What this adds

- **Image build**: clones upstream at build time, compiles a static `whosthere` binary (`CGO_ENABLED=0`), and runs it under **[ttyd](https://github.com/tsl0922/ttyd)** so the TUI is available over HTTP on port **7681**.
- **Docker Compose**: default service uses **host networking** (Linux) so mDNS, SSDP, and ARP-style discovery can see your real LAN. An optional **bridge** profile publishes `7681` when host mode is impractical (with weaker discovery from inside the container).

There is **no authentication** on the web terminal by design; only expose it on networks you trust.

## Usage

Build and start (host network — recommended on Linux for accurate scans):

```bash
docker compose up -d --build
```

Open **http://127.0.0.1:7681/** on the host (or `http://<this-machine>:7681/` from another device on your LAN).

Bridge networking and explicit port mapping:

```bash
docker compose --profile bridge up -d --build
```

Then use **http://127.0.0.1:7681/** via the published port.

Stop:

```bash
docker compose down
```

### Pin an upstream version

Override the Git ref when building (Compose passes `WHOSTHERE_REF` by default as `main`):

```bash
docker compose build --build-arg WHOSTHERE_REF=v0.7.0
docker compose up -d
```

## Upgrading

Whosthere is fetched **when the image is built**, not at container start. To move to a newer upstream release or the latest `main`:

1. **Update this repo** (if you use git): `git pull` in your clone so you have any Dockerfile or Compose changes.
2. **Rebuild without cache** so the builder stage re-clones upstream instead of reusing an old layer:

   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

   If you use the **bridge** profile, add `--profile bridge` to both commands.

3. **Optional**: remove the old image to free disk space after you are happy with the new one, for example `docker image prune` or `docker rmi` on the previous `whosthere-webtty:local` ID.

If you **pin** a tag with `WHOSTHERE_REF`, bump it to the new tag (or set it back to `main` in `docker-compose.yml` / build args), then run the same `build --no-cache` and `up -d` steps.

To refresh **ttyd** only, rebuild still pulls the latest `ghcr.io/tsl0922/ttyd:latest` used in the Dockerfile when that stage is not cached; use `--no-cache` if you want to force that as well.

## Upstream

- **Whosthere**: [github.com/ramonvermeulen/whosthere](https://github.com/ramonvermeulen/whosthere) — features, CLI/TUI usage, configuration, and disclaimer apply to the application itself.
