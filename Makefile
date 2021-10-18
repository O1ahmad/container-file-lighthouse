filepath        :=      $(PWD)
versionfile     :=      $(filepath)/version.txt
version         :=      $(shell cat $(versionfile))
image_repo      :=      0labs/lighthouse
build_type      ?=      package

build:
	DOCKER_BUILDKIT=1 docker build --tag $(image_repo):build-$(version) --build-arg build_type=$(build_type) --build-arg lighthouse_version=$(version) .

test:
	DOCKER_BUILDKIT=1 docker build --tag lighthouse:test --target test --build-arg build_type=$(build_type) --build-arg lighthouse_version=$(version) . && docker run --env-file test/test.env lighthouse:test

release:
	DOCKER_BUILDKIT=1 docker build --tag $(image_repo):$(version) --target release --build-arg build_type=$(build_type) --build-arg lighthouse_version=$(version) .
	docker push $(image_repo):$(version)

latest:
	docker tag $(image_repo):$(version) $(image_repo):latest
	docker push $(image_repo):latest

.PHONY: test
