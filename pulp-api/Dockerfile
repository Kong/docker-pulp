FROM evanshawn/pulpcore:based

COPY entrypoint.sh /entrypoint.sh

EXPOSE 24817

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
