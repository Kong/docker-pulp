#!/bin/bash -e

PULP_API_BIND_PORT=${PULP_API_BIND_PORT:-24817}

echo "[INFO] Updating database schema"
pulpcore-manager migrate --noinput

if [[ -n $PULP_ADMIN_PASSWORD ]]; then
    echo "[INFO] Setting admin password"
    pulpcore-manager reset-admin-password --password ${PULP_ADMIN_PASSWORD}
fi

echo "[INFO] Collecting static files"
pulpcore-manager collectstatic --noinput

echo "[INFO] Starting API server"
gunicorn pulpcore.app.wsgi:application \
          --bind "0.0.0.0:${PULP_API_BIND_PORT}" \
          --access-logfile -
