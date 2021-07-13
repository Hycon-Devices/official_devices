import glob
import json

for x in glob.glob("**/**json", recursive=True):
    try:
        data = json.loads(open(x).read())
    except Exception as e:
        print(f"{x}: {e}")
