ORG ?=
TAG ?= latest
DOCKER_BUILDKIT=1

ifeq ($(strip $(ORG)),)
	prefix=
else
	prefix=$(ORG)/
endif

# if we're running from github actions, always cache_from tag latest
ifeq ($(GITHUB_ACTIONS),true)
	CACHE_TAG ?= latest
	cache_tag=$(CACHE_TAG)
	ifdef IS_PREBUILD
		extra_arg=--build-arg BUILDKIT_INLINE_CACHE=1
	else
		extra_arg=
	endif
else
	cache_tag=$(TAG)
	extra_arg=
endif

.EXPORT_ALL_VARIABLES:

images: build-pulp-core \
        build-pulp-api \
        build-pulp-content \
        build-pulp-resource-manager \
        build-pulp-worker

release: release-pulp-core \
         release-pulp-api \
         release-pulp-content \
         release-pulp-resource-manager \
         release-pulp-worker

build-%:
	$(eval IMAGE := $(patsubst build-%,%,$@))
	cp -v .dockerignore $(IMAGE)/
	cd $(IMAGE) && docker buildx build --build-arg FROM_ORG="$(prefix)" --build-arg FROM_TAG="$(TAG)" $(extra_arg) --cache-from $(prefix)$(IMAGE):$(cache_tag) -t $(prefix)$(IMAGE):$(TAG) .

release-%:
	$(eval IMAGE := $(patsubst release-%,%,$@))
	cd $(IMAGE) && docker push $(prefix)$(IMAGE):$(TAG)

tmp_image=tmp-pulp-core-build
storages_release_branch=release/kong-prod
update-requirements:
	cd pulp-core && \
	sed -Ei 's/(django-storages)(=|[[:space:]]+@)/\1[boto3]\2/; s~(django-storages)@[[:alnum:]]+$$~\1@$(storages_release_branch)~; /^## The following requirements.*/,$$d' requirements.txt && \
	docker build --target build -t $(tmp_image) . && \
	docker run --rm $(tmp_image) /opt/pulp/bin/pip freeze -l \
		-r /opt/pulp/pulp-requirements.txt > requirements.txt
	docker rmi $(tmp_image)
