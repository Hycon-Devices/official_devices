#!/bin/bash

[[ -z "${TELEGRAM_TOKEN}" ]] && echo "No tg token!" && exit 1
[[ -z "${GITHUB_TOKEN}" ]] && echo "No gh token!" && exit 1

git config --global user.email "HyconBot@gmail.com"
git config --global user.name "HyconBot"

function sendTG() {
    curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendmessage" --data "text=${*}&chat_id=-1001367433218&disable_web_page_preview=true&parse_mode=Markdown"
}

if ! python tools/validate.py; then
    sendTG "*Someone have merged broken json! Please take a look ASAP!*
Failed File:
\`$(cat brokenjson.txt)\`"
    exit 1
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

mkdir tmp
for i in $(find . -type f -iname '*.json')
do
    jq . < $i > tmp/format.json
    mv tmp/format.json $i
done
rm -rf tmp

GIT_CHECK="$(git status | grep "json")"

if [[ -n "$GIT_CHECK" ]]; then
    git add .
    git commit -m "[Hycon-CI]: lint $(date '+%a %b %d %T %Z')" --signoff
    git remote set-url origin "https://HyconBot:${GITHUB_TOKEN}@github.com/Hycon-Devices/official_devices"
    git push origin ${CIRCLE_BRANCH}
    sendTG "[CRON] JSON has been Linted and Pushed!"
fi
