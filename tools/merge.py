import glob, json

head = []
with open("website_api.json", "w") as outfile:
    for i in glob.glob("builds/*.json"):
        with open(i, 'rb') as infile:
            data = json.load(infile)
            head += data
    json.dump(head, outfile)