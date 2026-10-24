# SyncYomi for hosts that configure apps through env vars (Render).
# SyncYomi only reads config.toml, so the entrypoint writes one from env vars at start.
FROM ghcr.io/syncyomi/syncyomi:latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
