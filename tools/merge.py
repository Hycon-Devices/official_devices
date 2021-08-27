import glob
import json
import os

head = []
dropped = ["wayne", "ysl"]

os.system("rm -f builds/website_api.json")

for x in glob.glob("builds/*.json"):
    with open(x, 'rb') as file:
        data = json.load(file)
        print(x)
        for item in data:
            item['url'] = "https://www.pling.com/p/1544683"
            for d in dropped:
                if d in item["filename"]:
                    item["version"] = item["version"] + ", Dropped"
        head += data

with open("builds/website_api.json", 'w') as outfile:
    json.dump(head, outfile, ensure_ascii=False)
