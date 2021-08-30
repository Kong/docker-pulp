#!/bin/bash -e

GPG_KEY=/etc/gpg/gpg_key

if [[ -r "$GPG_KEY" ]]; then
    echo "[INFO] Enabling Signing API"
    # Import private key
    gpg --import $GPG_KEY
    # Export public key
    gpg --export -a > /tmp/public.key
    # Export key fingerprint
    gpg --with-fingerprint --with-colons /tmp/public.key 2>/dev/null | grep fpr: | head -n1 | cut -d: -f10 > /tmp/public.fpr

    echo -e "5\ny\n" | gpg --batch --pinentry-mode loopback --yes --no-tty --command-fd 0 --expert --edit-key "$(cat /tmp/public.fpr)" trust

    pulpcore-manager shell < /app/venv/lib/register-signing-api.py
fi

exec pulpcore-worker
