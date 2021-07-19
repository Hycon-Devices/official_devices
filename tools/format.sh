#!/bin/bash

PR_NUM=$(jq --raw-output .pull_request.number "${GITHUB_EVENT_PATH}")
COMMIT_AUTHOR="$(git log -1 --pretty='%an <%ae>')"
COMMIT_MESSAGE="$(git log -1 --pretty=%B)"
REPO="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"

function sendTG() {
    curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendmessage" --data "text=${*}&chat_id=-1001367433218&parse_mode=Markdown"
}

git config --global user.email "rzlamrr.dvst@protonmail.com"
git config --global user.name "rzlamrr"


if python tools/validate.py; then
    if [[ "${PR_NUM}" != "null" ]]; then
        sendTG "*PR ${PR_NUM} can be merged.* [PR Link](${REPO}/pull/${PR_NUM})"
        exit 0
    fi
else
    if [[ "${PR_NUM}" != "null" ]]; then
        sendTG "\*PR ${PR_NUM} is failing. Maintainer is requested to check it!*
Failed File:
\`$(cat /tmp/failedfile)\`

[PR Link](${REPO}/pull/${PR_NUM})"
        exit 1
    else
        sendTG "*Someone have merged broken json! Please take a look ASAP!*
Failed File:
\`$(cat brokenjson.txt)\`"
    exit 1
    fi
fi

rm -f brokenjson.txt

python tools/merge.py

for i in $(find . -type f -iname '*.json')
do
    mkdir tmp
    python -m json.tool < $i > tmp/format.json
    mv tmp/format.json $i
    rm -rf tmp
done

if [[ ! "${COMMIT_MESSAGE}" =~ "[Hycon-CI]" ]]; then
    git reset HEAD~1
    git add .
    git commit -m "[Hycon-CI]: ${COMMIT_MESSAGE}" --author="${COMMIT_AUTHOR}" --signoff || true
    sendTG "JSON Linted and Force Pushed!"
fi
