#!/bin/bash
set -e
set -o pipefail

GITHUB_TOKEN=$1
JIRA_URI=$2
JIRA_ENCODED_TOKEN=$3
regexp_jira_issue_code_on_pr_title=$4
issue_properties=$6

# This is populated by our secret from the Workflow file.
if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "Set the GITHUB_TOKEN env variable."
	exit 1
fi

# This one is populated by GitHub for free :)
if [[ -z "$GITHUB_REPOSITORY" ]]; then
	echo "Set the GITHUB_REPOSITORY env variable."
	exit 1
fi

GITHUB_URI=https://api.github.com
API_VERSION=v3
API_HEADER="Accept: application/vnd.github.${API_VERSION}+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

ref=$(jq --raw-output .pull_request.head.ref "$GITHUB_EVENT_PATH")
owner=$(jq --raw-output .pull_request.head.repo.owner.login "$GITHUB_EVENT_PATH")
repo=$(jq --raw-output .pull_request.head.repo.name "$GITHUB_EVENT_PATH")

exclude_author_from_reviewers() {
    local all_reviewers=$@

    valid_reviewers=( "${all_reviewers[@]/$pr_author/}" )

    echo $valid_reviewers
}

add_reviewers_to_the_pr() {
    local reviewers_array=$(echo $REVIEWERS | tr "," "\n")
    local reviewers_array=$(exclude_author_from_reviewers $reviewers_array)
    local reviewers_to_add_in_json_format=$(printf '%s\n' "${reviewers_array[@]}" | jq -R . | jq -s .)

    curl -X POST \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -d '{"reviewers": '"${reviewers_to_add_in_json_format}"'}' \
    "${GITHUB_URI}/repos/${owner}/${repo}/pulls/${pr_number}/requested_reviewers"
}

add_labels_to_the_pr() {
    local all_raw_labels=$@
    local labels_array=$(echo $all_raw_labels | tr "," "\n")
    local labels_to_add_in_json_format=$(printf '%s\n' "${labels_array[@]}" | jq -R . | jq -s .)

    curl -X POST \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -d '{"labels": '"${labels_to_add_in_json_format}"'}' \
    "${GITHUB_URI}/repos/${owner}/${repo}/issues/${pr_number}/labels"
}

get_jira_priority_of() {
    local issue_code=$1
    curl -X GET \
    -H "Authorization: Basic ${JIRA_ENCODED_TOKEN}" \
    "${JIRA_URI}/rest/api/latest/issue/${issue_code}"| \
    jq --raw-output .fields.priority.name
}

get_jira_code_from_pr_title() {
    local pr_title=$@
    echo $pr_title | sed -E "s/$regexp_jira_issue_code_on_pr_title/\1/"
}

set_default_env_variables_if_needed() {
    if [[ -z $regexp_jira_issue_code_on_pr_title ]]; then
        regexp_jira_issue_code_on_pr_title = '^([A-Z]{4}-[0-9]{4})'
    fi

    if [[ -z $LABELS_ON_PULL_REQUEST_OPENED ]]; then
        LABELS_ON_PULL_REQUEST_OPENED="needs feedback"
    fi
}

main() {
    set_default_env_variables_if_needed;

    # In every runtime environment for an Action you have the GITHUB_EVENT_PATH
    # populated. This file holds the JSON data for the event that was triggered.
    # From that we can get the status of the pull request and if it was merged.
    # In this case we only care if it was closed and it was merged.
	action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
	merged=$(jq --raw-output .pull_request.merged "$GITHUB_EVENT_PATH")
	pr_number=$(jq --raw-output .number "$GITHUB_EVENT_PATH")
	pr_title=$(jq --raw-output .pull_request.title "$GITHUB_EVENT_PATH")
	pr_author=$(jq --raw-output .pull_request.user.login "$GITHUB_EVENT_PATH")

	echo "DEBUG -> action: $action merged: $merged pr_number: $pr_number title: $pr_title"

	if [[ "$action" == 'opened' || "$action" == 'synchronize' ]]; then
	    echo "Adding reviewers to the PR..."
	    add_reviewers_to_the_pr
	    echo "Retrieving the JIRA issue code from the PR title..."
	    local issue_code=$(get_jira_code_from_pr_title $pr_title)
	    echo "Retrieving the priority of the issue code $issue_code from JIRA..."
	    local priority=$(get_jira_priority_of $issue_code)
        echo "Appending the priority label $priority to the labels to add when PR is opened..."
	    LABELS_ON_PULL_REQUEST_OPENED+=",$priority"
        echo "Adding labels $LABELS_ON_PULL_REQUEST_OPENED to the PR..."
	    add_labels_to_the_pr $LABELS_ON_PULL_REQUEST_OPENED
	fi
}

main "$@"