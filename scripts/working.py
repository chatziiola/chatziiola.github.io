#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""Docstring
Working python document - not much to see:
- code here will gradually be migrated into specific scripts, properly documented.
"""

__author__ = "Lamprinos Chatziioannou"
__license__ = "MIT License"
__version__ = "0.0.1"

# --- your code below this line --- #

import json
import sys,os
import configparser

# value = config.get('section', 'value')
def setup_config():
    config = configparser.ConfigParser()
    config.read("scripts/config.ini")
    return config


# get list of json.objects with filepath    
def get_posts_with_tag(TAG):
    with open(jsonFilename, 'r') as file:
        data = json.load(file)
    files = []
    for obj in data:
        if TAG in obj.get("filetags"):
            files.append(obj)
    return files

# get a list of all different tags
def get_tag_list():
    with open(jsonFilename, 'r') as file:
        data = json.load(file)
    return set(value for obj in data for value in obj.get("filetags", []))
# Example of reading values
config = setup_config()
jsonFilename = config.get('JSON','filename')
# print(get_posts_with_tag("blog"))


def fix_full_tag_index():
    os.makedirs("content/tags",exist_ok=True)
    with open("content/tags/index.org",'w') as indexFile:
        indexFile.write(f"#+TITLE: Tags Collection\n")
        indexFile.write(f"#+DESCRIPTION: Collection of all posts, based on tags\n")
        for tag in get_tag_list():
            indexFile.write(f"* {tag}  :{tag}:\n")
            for post in get_posts_with_tag(tag):
                publicPath = post.get('filepath')
                indexFile.write(f"- [[../{publicPath[len('content'):]}][{post.get('title')}]]\n")

fix_full_tag_index()
