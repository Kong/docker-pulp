pulp config create --username admin --base-url https://repo.motofans.club --password admin

pulp rpm repository create --name epel-7-local

pulp rpm remote create --name epel-7-remote --url https://dl.fedoraproject.org/pub/epel/7/x86_64/ --policy on_demand

pulp rpm repository sync --name epel-7-local --remote epel-7-remote

pulp rpm publication create --repository epel-7-local --version 1

PUBLICATION_HREF=$(pulp rpm publication list | jq -r .[0].pulp_href)

pulp rpm distribution create --name epel-7 --base-path epel-7 --publication "$PUBLICATION_HREF"

pulp rpm repository update --name epel-7-local --autopublish

pulp rpm distribution update --name epel-7 --repository epel-7-local
