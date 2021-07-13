import glob
import json

head = []
outfile = open("website_api.json", 'w')

for x in glob.glob("builds/*.json"):
    with open(x, 'rb') as file:
        data = json.load(file)
        for item in data:
            item['url'] = "https://www.pling.com/p/1544683"
        head += data

json.dump(head, outfile)
