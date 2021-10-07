filepath        :=      $(PWD)
versionfile     :=      $(filepath)/version.txt
version         :=      $(shell cat $(versionfile))
image_repo      :=      0labs/lighthouse

build:
	docker build --tag $(image_repo):build-$(version) --build-arg lighthouse_version=$(version) .

test:
	docker build --target test --build-arg lighthouse_version=$(version) --tag lighthouse:test . && docker run --env-file test/test.env lighthouse:test

release:
	docker build --target release --tag $(image_repo):$(version) --build-arg lighthouse_version=$(version) .
	docker push $(image_repo):$(version)

latest:
	docker tag $(image_repo):$(version) $(image_repo):latest
	docker push $(image_repo):latest

.PHONY: test
