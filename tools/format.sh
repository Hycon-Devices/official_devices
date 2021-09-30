#!/bin/bash

git config --global user.email "HyconBot@gmail.com"
git config --global user.name "HyconBot"

COMMIT_AUTHOR="$(git log -1 --pretty='%an <%ae>')"
COMMIT_MESSAGE="$(git log -1 --pretty=%B)"
COMMIT_HASH="$(git log -1 --pretty=%h)"

git reset HEAD~1
if [[ -z "$(git status | grep json)" ]]; then
    echo "Last commit has no json changes, Skipped!"
    exit 0
fi

git reset ${COMMIT_HASH}

[[ -z "${TELEGRAM_TOKEN}" ]] && echo "No tg token!" && exit 1
[[ -z "${GITHUB_TOKEN}" ]] && echo "No gh token!" && exit 1

function sendTG() {
    curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendmessage" --data "text=${*}&chat_id=-1001367433218&disable_web_page_preview=true&parse_mode=Markdown"
}

if python tools/validate.py; then
    if [[ -n "${CIRCLE_PR_NUMBER}" ]]; then
        sendTG "*PR #${CIRCLE_PR_NUMBER} can be merged.* [PR Link](${CIRCLE_PULL_REQUEST})"
        exit 0
    fi
else
    if [[ -n "${CIRCLE_PR_NUMBER}" ]]; then
        sendTG "*PR #${CIRCLE_PR_NUMBER} is failing. Maintainer is requested to check it!*
Failed File:
\`$(cat brokenjson.txt)\`

[PR Link](${CIRCLE_PULL_REQUEST})"
        exit 1
    else
        sendTG "*Someone have merged broken json! Please take a look ASAP!*
Failed File:
\`$(cat brokenjson.txt)\`"
    exit 1
    fi
fi

rm -rf brokenjson.txt

if python tools/merge.py; then
    echo "Merged!"
else
    echo "Merge failed!"
    sendTG "*Can't merge json!!*
\`$(cat brokenjson.txt)\`"
    exit 1
fi

rm -rf brokenjson.txt tmp

rm -rf tmp; mkdir tmp
for i in $(find . -type f -iname '*.json')
do
    jq . < $i > tmp/format.json
    mv tmp/format.json $i
done
rm -rf tmp

GIT_CHECK="$(git status | grep "json")"

if [[ ! "${COMMIT_MESSAGE}" =~ "[Hycon-CI]" ]] && [[ -n "$GIT_CHECK" ]]; then
    if [[ "${COMMIT_MESSAGE}" =~ "Merge pull request" ]]; then
        sendTG "JSON formatted, but merge commit has been found!
*Can't format commit message!*"
    else
        git reset HEAD~1
        git add .
        git commit -m "[Hycon-CI]: ${COMMIT_MESSAGE}" --author="${COMMIT_AUTHOR}" --signoff
        git remote set-url origin "https://HyconBot:${GITHUB_TOKEN}@github.com/Hycon-Devices/official_devices"
        git push origin ${CIRCLE_BRANCH} -f
        sendTG "JSON Linted and Force Pushed!"
    fi
fi
