.PHONY: build

build:
	@docker build --build-arg CONTEXT7_API_KEY=${CONTEXT7_API_KEY} --build-arg LINEAR_API_KEY=${LINEAR_API_KEY} -t safecode .
