#!/usr/bin/env bash

jira::getIssueByCode() {
    local issue_code=$1
    local jira_token
    local jira_uri
    local cached_issue_code_file
    cached_issue_code_file="$issue_code"_$(date +"%Y-%m-%d-%H%M").json

    if [[ -e $cached_issue_code_file ]]; then
      cat "$cached_issue_code_file"
      exit 0
    fi

    local jira_issue_payload
    jira_issue_payload=$(jira::makeRequest)

    if [[ $jira_issue_payload == false ]]; then
      echo false
    else
      echo "$jira_issue_payload" > "$cached_issue_code_file"
      echo "$jira_issue_payload"
    fi
}

jira::makeRequest() {
    jira_uri=$(action::input::jiraUri)
    jira_token=$(action::input::jiraEncodedToken)

    local endpoint="${jira_uri}/rest/api/2/issue/${issue_code}"

    local bodyAndHttpCodeDelimiter
    bodyAndHttpCodeDelimiter="``,###`` "

    local response
    response=$(
        curl -X GET \
          -H "Content-type: application/json" \
          -H "Authorization: Basic ${jira_token}" \
          --write-out "${bodyAndHttpCodeDelimiter}%{http_code}" \
          --silent \
          "$endpoint"
    )

    local jira_issue
    jira_issue=$(echo "$response" | awk -F "$bodyAndHttpCodeDelimiter" '{print $1}')
    local http_code
    http_code=$(echo "$response" | awk -F "$bodyAndHttpCodeDelimiter" '{print $2}')

    if [[ $http_code -eq 200 ]];then
      echo "$jira_issue"
    else
      echo false
    fi
}

jira::getPriorityOf() {
    local issue_code=$1

    local issue
    issue=$(jira::getIssueByCode "$issue_code")

    if [[ $issue == false ]];then
      echo false
      exit 0
    fi

    echo "$issue" | jq --raw-output .fields.priority.name
}
