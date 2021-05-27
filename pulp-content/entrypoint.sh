#!/bin/bash -e

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

exec gunicorn pulpcore.content:server \
              "${args[@]}" \
              --bind "0.0.0.0:${PULP_CONTENT_BIND_PORT}" \
              --worker-class 'aiohttp.GunicornWebWorker' \
              -w "${PULP_CONTENT_WORKERS}" \
              --access-logfile -
