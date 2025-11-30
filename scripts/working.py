#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""Docstring
Working python document - not much to see:
- code here will gradually be migrated into specific scripts, properly documented.
"""

__author__ = "Lamprinos Chatziioannou"
__license__ = "MIT License"
__version__ = "0.0.1"


import json
import sys,os
import configparser
import re

from datetime import datetime
from blogjson import *


# value = config.get('section', 'value')
def setup_config():
    config = configparser.ConfigParser()
    config.read("scripts/config.ini")
    return config

# get list of json.objects with filepath
def getAllPosts(jsonFilename):
    with open(jsonFilename, 'r') as file:
        data = json.load(file)
    return data

# get list of json.objects with a certain filetag
def getPostsWithTag(TAG,jsonFilename):
    files = []
    for obj in getAllPosts(jsonFilename):
        if TAG in obj.get("filetags"):
            files.append(obj)
    return files

# get a list of all different tags, in alphabetical order
def getAllTags(jsonFilename):
    with open(jsonFilename, 'r') as file:
        data = json.load(file)
    return sorted(list(set(value for obj in data for value in obj.get("filetags", []))))

def createTagsIndexOrg(jsonFilename):
    os.makedirs("content/tags",exist_ok=True)
    with open("content/tags/index.org",'w') as indexFile:
        indexFile.write(f"#+TITLE: Tags Collection\n")
        indexFile.write(f"#+DESCRIPTION: Collection of all posts, based on tags\n")
        for tag in getAllTags(jsonFilename):
            if tag.lower() in tag_blacklist: continue
            indexFile.write(f"* {tag}  :{tag}:\n")
            for post in sorted(getPostsWithTag(tag,jsonFilename), key=lambda x:x['date'], reverse=True):
                publicPath = post.get('filepath')
                indexFile.write(f"- [[..{publicPath[len('content'):]}][{post.get('title')}]]\n")

def orgDottedLink(path, title, date):
    return f"- {date}: [[{path}][{title}]]"
    # return f"- [[{path}][{title}]]".ljust(80+len(linkpath),'.')+date

def createRecentsIndexOrg(jsonFile):
    data = sorted(getAllPosts(jsonFile), key=lambda x: x['date'])
    # Newest to oldest
    recents = "\n\n"
    # TODO add number of posts to config.ini
    # TODO add starting/end strings to config.ini
    start="# posts start"
    end="# posts end"
    for post in reversed(data):
        if re.search(r"index.org$",post['filepath']) or re.search(r"recents.org$", post['filepath']):
            continue
        linkpath = f"..{post['filepath'][len('content'):]}"
        recents += orgDottedLink(linkpath,post['title'],post['date'])+'\n'
    overwriteBetweenABinFile(recents, start, end, "content/posts/recents.org")

def addRecentsToIndex(jsonFile):
    data = sorted(getAllPosts(jsonFile), key=lambda x: x['date'], reverse=True)
    # Newest to oldest
    recents = "\n"
    # TODO add number of posts to config.ini
    # TODO add starting/end strings to config.ini
    start="# recents start"
    end="# recents end"
    entries = 0
    maxentries = 6
    for post in data:
        if post['filepath'].endswith("index.org") or "index" in post['filetags']:
            continue
        linkpath = f"..{post['filepath'][len('content'):]}"
        recents += orgDottedLink(linkpath,post['title'],post['date'])+'\n'
        entries += 1
        if entries == maxentries:
            break
    overwriteBetweenABinFile(recents, start, end, "content/index.org")
    # print(recents)


def overwriteBetweenABinFile(newText, stringA, stringB, filePath):
    try:
        with open(filePath, 'r') as file:
            content = file.read()

        start_index = content.find(stringA)
        end_index = content.find(stringB)

        if start_index != -1 and end_index != -1 and start_index < end_index:
            updated_content = content[:start_index + len(stringA)] + newText + content[end_index:]

            with open(filePath, 'w') as file:
                file.write(updated_content)

            # print(f"Text between '{stringA}' and '{stringB}' replaced successfully.")
        else:
            print(f"Error: Couldn't find '{stringA}' and '{stringB}' in the file or the order is incorrect.")

    except FileNotFoundError:
        print(f"Error: File '{filePath}' not found.")
    except Exception as e:
        print(f"Error: {e}")


# Example of reading values
config = setup_config()
myjson = config.get('JSON','filename')
blogdirectory = "content/posts"
tag_blacklist = [ "index", "lecture", "noexport" ]

createBlogJson(blogdirectory, myjson)

# data = sorted(getAllPosts(myjson), key=lambda x: x['date'])
# for post in data[-5:]:
#     print(f"{post['title']}:\n\t {post['date']}")


# print(getAllTags(myjson))
createTagsIndexOrg(myjson)
createRecentsIndexOrg(myjson)
addRecentsToIndex(myjson)
