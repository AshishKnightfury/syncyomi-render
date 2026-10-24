#!/bin/sh
# Writes /config/config.toml from env vars, then starts SyncYomi.
# Required: SESSION_SECRET, PG_HOST, PG_USER, PG_PASSWORD
# Optional: PORT (Render sets it), PG_PORT, PG_DATABASE, PG_SSLMODE
set -eu

for var in SESSION_SECRET PG_HOST PG_USER PG_PASSWORD; do
  eval "val=\${$var:-}"
  if [ -z "$val" ]; then
    echo "Missing required env var: $var" >&2
    exit 1
  fi
done

# SyncYomi pastes the password into a postgres:// URL unescaped, so percent-encode it
# (lib/pq decodes it again). jq ships in the SyncYomi image.
PG_PASSWORD_ENC=$(jq -rn --arg v "$PG_PASSWORD" '$v|@uri')

mkdir -p /config
cat > /config/config.toml <<EOF
host = "0.0.0.0"
port = ${PORT:-8282}
sessionSecret = "${SESSION_SECRET}"
secureCookie = true
logLevel = "INFO"
checkForUpdates = false

databaseType = "postgres"
postgresHost = "${PG_HOST}"
postgresPort = ${PG_PORT:-5432}
postgresDatabase = "${PG_DATABASE:-postgres}"
postgresUser = "${PG_USER}"
postgresPass = "${PG_PASSWORD_ENC}"
postgresSslMode = "${PG_SSLMODE:-require}"
EOF

exec /usr/local/bin/syncyomi --config /config
