#!/usr/bin/env bash

FILE_PATH=$1
SIGNATURE_PATH="$FILE_PATH.asc"
PUBLIC_KEY=/tmp/public.key

export GNUPGHOME=/var/lib/pulp/.gnupg
ADMIN_ID=$(gpg --list-keys --with-colons | grep fpr: | head -n1 | cut -d: -f10)

# Create a detached signature
gpg --quiet --batch --pinentry-mode loopback --yes --detach-sign -u "$ADMIN_ID" \
   --armor --output "$SIGNATURE_PATH" "$FILE_PATH"

# Check the exit status
STATUS=$?
if [[ $STATUS -eq 0 ]]; then
    printf '{"file": "%s", "signature": "%s", "key" : "%s"}\n' "$FILE_PATH" "$SIGNATURE_PATH" "$PUBLIC_KEY"
else
    exit $STATUS
fi
