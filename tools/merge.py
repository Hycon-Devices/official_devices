import glob
import json
import os

head = []

os.system("rm -f builds/website_api.json")

for x in glob.glob("builds/*.json"):
    with open(x, 'rb') as file:
        data = json.load(file)
        for item in data:
            item['url'] = "https://www.pling.com/p/1544683"
        head += data

with open("builds/website_api.json", 'w') as outfile:
    json.dump(head, outfile, ensure_ascii=False)