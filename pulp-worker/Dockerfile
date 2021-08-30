FROM evanshawn/pulpcore:based
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
