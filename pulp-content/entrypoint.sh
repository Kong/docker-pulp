#!/bin/bash -e

mkdir -p /var/lib/pulp/tmp

PULP_CONTENT_BIND_PORT=${PULP_CONTENT_BIND_PORT:-24816}
PULP_CONTENT_WORKERS=${PULP_CONTENT_WORKERS:-2}

echo "[INFO] Collecting static files"
pulpcore-manager collectstatic --noinput

echo "[INFO] Starting content server"

declare -a args=()
for arg in "$@"
do
  eval "args[${#args[*]}]=$arg"
done

exec pulp-content
