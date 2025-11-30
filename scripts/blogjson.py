#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""collection of functions to help with the creation (preferably once)
and management of a json file for an org-based blog"""

__author__ = "Lamprinos Chatziioannou"
__license__ = "MIT License"
__version__ = "0.0.1"

import os
import re
import json
import sys
from pathlib import Path

DRAFT_REGEX = "^#\\+DRAFT: t$"

def getTypeFromOrgFile(type, content, prefix:str = "^#\\+"):
    mymatch = re.search(f"{prefix}{type}: (.*)", content, flags=re.IGNORECASE|re.MULTILINE)
    if mymatch:
        return mymatch.group(1).strip()
    return ""

def getJsonFromOrgFile(file):

    try:
        with open(file,'r') as f:
            content = f.read()
            isdraft = re.search(DRAFT_REGEX,content,flags=re.IGNORECASE|re.MULTILINE)
            if isdraft:
                return {}
            title = getTypeFromOrgFile("title",content)
            description = getTypeFromOrgFile("description",content)
            date = getTypeFromOrgFile("DATE", content)
            if date:
                parsedtime = date[1:len("<2019-02-14")]
            else:
                parsedtime = ""

            # Parse filetags
            filetags  = getTypeFromOrgFile("filetags", content)
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
    except FileNotFoundError:
        return {}

def getJsonForDirectory(directory):
    if not os.path.isdir(directory):
        print("Directory does not exist.")
        sys.exit(1)

    org_files = list(Path(directory).rglob('*.org'))

    results = [getJsonFromOrgFile(file) for file in org_files]
    return [item for item in results if item]

# Process the directory and create a list of JSON entries
# Write JSON entries to a temporary file
def createBlogJson(directory, result_file):
    with open(result_file, 'w') as f:
        json.dump(getJsonForDirectory(directory), f, indent=2)
