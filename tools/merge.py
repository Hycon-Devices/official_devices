import glob
import json

head = []
dropped = ["wayne", "ysl"]
outfile = open("website_api.json", 'w')

for x in glob.glob("builds/*.json"):
    with open(x, 'rb') as file:
        data = json.load(file)
        for item in data:
            item['url'] = "https://www.pling.com/p/1544683"
            for d in dropped:
                if d in item["filename"]:
                    item["version"] = item["version"] + ", Dropped"
        head += data

json.dump(head, outfile)
