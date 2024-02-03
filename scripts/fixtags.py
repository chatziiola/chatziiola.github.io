#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""Docstring
Small file to properly format tags in my blogs json file:
- [X] Break down filetags into single word tags
- [X] Properly add multiple tags in posts

Sample Usage:
python3 fixtags.py output.json
"""

__author__ = "Lamprinos Chatziioannou"
__license__ = "MIT License"
__version__ = "0.0.1"

# --- your code below this line --- #
import json
import sys

def process_json(json_file_path):

    with open(json_file_path, 'r') as file:
        data = json.load(file)

    myproperty = 'filetags'
    for obj in data:
        if myproperty in obj and isinstance(obj.get(myproperty), str):
            # Split the value of the MYPROPERTY myproperty into a list of words
            words = obj[myproperty].split()
            # Replace the MYPROPERTY myproperty with the list of words
            obj[myproperty] = words

    # Write the modified data back to the json file
    with open(json_file_path, 'w') as file:
        json.dump(data, file, indent=2)

# Replace 'your_json_file.json' with the actual file path
json_file_path = sys.argv[1]
# print(f"The filepath: {json_file_path}")
process_json(json_file_path)
