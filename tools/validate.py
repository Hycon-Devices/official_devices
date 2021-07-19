import glob
import json
import os

os.system("rm -f brokenjson.txt")

for x in glob.glob("**/**json", recursive=True):
    try:
        data = json.loads(open(x).read())
    except Exception as e:
        print(f'{x}: {e}\n')
        with open('brokenjson.txt', 'a') as file:
            file.write(f'- {x}: {e}\n')

if os.path.isfile("brokenjson.txt"):
    exit(1)
