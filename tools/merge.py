import glob, json

head = []
with open("website_api.json", "w") as outfile:
    for i in glob.glob("builds/*.json"):
        with open(i, 'rb') as infile:
            data = json.load(infile)
            for item in data:
                item['url'] = "https://www.pling.com/p/1544683"
            head += data
    json.dump(head, outfile)