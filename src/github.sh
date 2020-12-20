#!/usr/bin/env bash

github::getReference() {
  jq --raw-output .pull_request.head.ref "$GITHUB_EVENT_PATH"
}

github::getRepoOwner() {
  jq --raw-output .pull_request.head.repo.owner.login "$GITHUB_EVENT_PATH"
}

github::getRepoName() {
  jq --raw-output .pull_request.head.repo.name "$GITHUB_EVENT_PATH"
}

github::getEventAction() {
  jq --raw-output .action "$GITHUB_EVENT_PATH"
}

github::isPullRequestMerged() {
  jq --raw-output .pull_request.merged "$GITHUB_EVENT_PATH"
}

github::getPullRequestNumber() {
  jq --raw-output .number "$GITHUB_EVENT_PATH"
}

github::getPullRequestTitle() {
  jq --raw-output .pull_request.title "$GITHUB_EVENT_PATH"
}

github::getPullRequestAuthor() {
  jq --raw-output .pull_request.user.login "$GITHUB_EVENT_PATH"
}

github::excludeAuthorFromReviewers() {
    local all_reviewers=( "$@" )

    valid_reviewers=( "${all_reviewers[@]}/${pr_author}/" )

    echo "${valid_reviewers[@]}"
}

github::addReviewersToThePR() {
    local reviewers_array
    reviewers_array=$(echo "$REVIEWERS" | tr "," "\n")
    reviewers_array=$(github::excludeAuthorFromReviewers "$reviewers_array")

    local reviewers_to_add_in_json_format
    reviewers_to_add_in_json_format=$(printf '%s\n' "${reviewers_array[@]}" | jq -R . | jq -s .)

    local path
    path='/pulls/'$(github::getPullRequestNumber)'/requested_reviewers'

    local GITHUB_URI='https://api.github.com'
    local API_VERSION='v3'
    local API_HEADER="Accept: application/vnd.github.${API_VERSION}+json"
    local AUTH_HEADER='Authorization: token '$(action::input::githubToken)

    curl -X POST \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -d '{"reviewers": '"${reviewers_to_add_in_json_format}"'}' \
    "${GITHUB_URI}/repos/$(github::getRepoOwner)/$(github::getRepoName)/pulls/'$(github::getPullRequestNumber)'/requested_reviewers"
}

github::addLabelsToThePR() {
    local all_raw_labels=$@
    local labels_array=$(echo $all_raw_labels | tr "," "\n")
    local labels_to_add_in_json_format=$(printf '%s\n' "${labels_array[@]}" | jq -R . | jq -s .)

    local GITHUB_URI='https://api.github.com'
    local API_VERSION='v3'
    local API_HEADER="Accept: application/vnd.github.${API_VERSION}+json"
    local AUTH_HEADER='Authorization: token '$(action::input::githubToken)

    curl -X POST \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -d '{"labels": '"${labels_to_add_in_json_format}"'}' \
    "${GITHUB_URI}/repos/$(github::getRepoOwner)/$(github::getRepoName)/issues/'$(github::getPullRequestNumber)'/labels"
}
