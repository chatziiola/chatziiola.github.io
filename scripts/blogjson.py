#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""collection of functions to help with the creation (preferably once)
and management of a json file for an org-based blog"""

__author__ = "Lamprinos Chatziioannou"
__license__ = "MIT License"
__version__ = "0.0.1"

# --- your code below this line --- #


import os
import re
import json
import sys
from pathlib import Path

def getTypeFromOrgFile(type, file):
    try:
        with open(file, 'r') as f:
            content = f.read()
            mymatch = re.search(f"\#\+{type}: .*\n",content,flags=re.IGNORECASE)
            if mymatch: 
                return mymatch.group()[len(f"#+{type}:"):].strip()
    except FileNotFoundError:
        pass
    return ""

def getJsonFromOrgFile(file):
    title = getTypeFromOrgFile("title",file)
    description = getTypeFromOrgFile("description",file)

    # Parse Date
    date = getTypeFromOrgFile("DATE", file)
    if date:
        parsedtime = date[1:len("<2019-02-14")]
    else:
        parsedtime = ""

    # Parse filetags
    filetags  = getTypeFromOrgFile("filetags", file)
    if filetags:
        taglist = filetags.split()
    else:
        taglist = filetags

    json_entry = {
        "filepath": str(file),
        "title": title,
        "description": description,
        "filetags": taglist,
        "date": parsedtime
    }
    return json_entry

def getJsonForDirectory(directory):
    if not os.path.isdir(directory):
        print("Directory does not exist.")
        sys.exit(1)
    org_files = list(Path(directory).rglob('*.org'))
    return [getJsonFromOrgFile(file) for file in org_files]

# Process the directory and create a list of JSON entries
# Write JSON entries to a temporary file
def createBlogJson(directory, result_file):
    with open(result_file, 'w') as f:
        json.dump(getJsonForDirectory(directory), f, indent=2)
