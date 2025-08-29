import sys
import json
import requests
import hashlib
import zipfile
from pathlib import Path

RECORD_ID = "14733834"
URL=f"https://zenodo.org/api/records/{RECORD_ID}"

locations = {
    "methscan_data.zip": {
        "dir": "data/references",
        "unzip": "methscan_data"
    },
    "bulk_beds.zip": {
        "dir": "data/wgbs/bulk/biscuit",
        "unzip": "canary"
    },
    "sc_beds.zip": {
        "dir": "data/wgbs/sc/biscuit",
        "unzip": "snmcseq2"
    },
    "canary_dmrs.bed": {
        "dir": "data/references",
        "unzip": ""
    },
    "genes.bed": {
        "dir": "data/references",
        "unzip": ""
    },
}

res = requests.get(URL)
if res.status_code != 200:
    print("Bad request")
    exit(1)

data = res.json()
files = sorted(data["files"], key = lambda item: item['size'])

def unzip_file(filepath, unzip_path):
    with zipfile.ZipFile(filepath) as zip:
        for file in zip.infolist():
            if file.filename.endswith((".gz", ".tbi")):
                file.filename = Path(file.filename).name
                zip.extract(file, unzip_path)

def download_dataset(dataset):
    url       = dataset["links"]["self"]
    file      = dataset["key"]
    checksum  = dataset["checksum"]
    dldir     = locations[file]["dir"]
    unzip_dir = Path(dldir, locations[file]["unzip"])

    print(f"Getting {file}...")
    print("Retrieving URL...")
    res = requests.get(url, stream = True)
    filesize = int(res.headers.get('content-length'))

    dlpath = Path(dldir, file)
    Path.mkdir(dlpath.parent, parents = True, exist_ok = True)
    print(f"Downloading to {dlpath}...")
    with open(dlpath, mode = "wb") as outfile:
        dl = 0
        hashmd5 = hashlib.md5()
        for chunk in res.iter_content(chunk_size = 4096):
            outfile.write(chunk)
            hashmd5.update(chunk)
            dl += len(chunk)
            done = int(50 * dl / filesize)
            sys.stdout.write("\r[%s%s]" % ('=' * done, ' ' * (50-done)) )    
    print()
    if f"md5:{hashmd5.hexdigest()}" == checksum:
        print("MD5 checksum valid")
    else:
        print(f"Warning: MD5 checksum invalid for {dlpath} - download may have failed")

    if zipfile.is_zipfile(dlpath):
        print(f"Unzipping to {unzip_dir}...")
        unzip_file(dlpath, unzip_dir)
    print()

for file in [files[i] for i in range(3)]:
    download_dataset(file)
