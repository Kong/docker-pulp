ARG FROM_ORG
ARG FROM_TAG=latest
FROM ${FROM_ORG}pulp-core:$FROM_TAG

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
