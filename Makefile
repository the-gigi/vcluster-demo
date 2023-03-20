.SILENT:
.PHONY: help

## This help screen
help:
	printf "Available targets:\n\n"
	awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-15s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)


## Create 3 virtual clusters in a kind cluster called kind-vcluster-host
provision:
	./make.sh provision

## Deploy nginx to all the virtual clusters
deploy: provision
	./make.sh deploy

## Check the logs of all participants in the leader election
check-logs:
	./make.sh check-logs


