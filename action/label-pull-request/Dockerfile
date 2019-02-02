## FROM defines what Docker image we are starting at. A docker image is a bunch
## of files combined in a tarball.
## This image is all the files we need for an Alpine OS environment.
FROM alpine:latest

## This label defines our action name, we could have named it butts but
## I decided to be an adult.
LABEL "com.github.actions.name"="Label Pull Request Action"
## This label defines the description for our action.
LABEL "com.github.actions.description"="Label a pull request based on its status"
## We can pick from a variety of icons for our action.
## The list of icons is here: https://developer.github.com/actions/creating-github-actions/creating-a-docker-container/#supported-feather-icons
LABEL "com.github.actions.icon"="tag"
## This is the color for the action icon that shows up in the UI when it's run.
LABEL "com.github.actions.color"="blue"

## These are the packages we are installing. Since I just wrote a shitty bash
## script for our Action we don't really need all that much. We need bash,
## CA certificates and curl so we can send a request to the GitHub API
## and jq so I can easily muck with JSON from bash.
RUN	apk add --no-cache \
	bash \
	ca-certificates \
	curl \
	jq

## Now I am going to copy my shitty bash script into the image.
COPY label-pull-request /usr/bin/label-pull-request

## The cmd for the container defines what arguments should be executed when
## it is run.
## We are just going to call back to my shitty script.
CMD ["label-pull-request"]