FROM evanshawn/pulpcore:based

COPY entrypoint.sh /entrypoint.sh

EXPOSE 24816

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
