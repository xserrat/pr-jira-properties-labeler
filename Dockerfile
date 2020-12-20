FROM alpine:3.10

## We need bash, CA certificates and curl so we can send a request to the GitHub API
## and jq so I can easily access to JSON key/values from bash.
RUN	apk add --no-cache \
	bash \
	ca-certificates \
	curl \
	jq

COPY entrypoint.sh /entrypoint.sh
COPY src /src

ENTRYPOINT ["/entrypoint.sh"]
