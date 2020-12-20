#!/usr/bin/env bash
set -o errexit
#set -o pipefail
#set -o nounset

ROOT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

source "$ROOT_DIRECTORY/src/action.sh"

main() {
	echo "DEBUG -> action: $(github::getEventAction) merged: $(github::isPullRequestMerged) pr_number: $(github::getPullRequestNumber) title: $(github::getPullRequestTitle)"

    action::run "$@"
}

main "$@"
