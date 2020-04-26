#!/usr/bin/env bash

jira::get_issue_by_code() {
    local issue_code=$1

    if [[ -z $JIRA_ISSUE ]]; then
        local jira_token=$(action::input::jiraEncodedToken)
        local jira_uri=$(action::input::jiraUri)
        JIRA_ISSUE=$(curl -X GET \
        -H "Authorization: Basic ${jira_token}" \
        "${jira_uri}/rest/api/latest/issue/${issue_code}")
    fi

    echo $JIRA_ISSUE
}

jira::get_priority_of() {
    local issue_code=$1
    local issue=$(jira::get_issue_by_code $issue_code)
    echo $issue|jq --raw-output .fields.priority.name
}