#!/usr/local/bin/python3
import argparse
import re
import shutil
import os

debug = False
verbose = False

##################################################
# Step 0: Wrapper
##################################################

def initializeArgs():
    """Sets global flags and passes args"""
    parser = argparse.ArgumentParser(description='Helper to clean python files')
    parser.add_argument("command", choices=["mimdir","morg", "corg", "dev"], help="Select a command: move, listlinks")
    parser.add_argument('file', type=str, help='The file to be processed - different per command mode')
    parser.add_argument('destination', type=str, help='Secondary arguments')
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug mode")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose mode")
    args = parser.parse_args()
    global verbose
    global debug
    verbose = args.verbose
    debug = args.debug
    return args

def main():
    args = initializeArgs()
    match args.command:
        case "mimdir":
            if verbose: print("Move image-dir")
            moveImageDir(args.file, args.destination)
        case "corg":
            if verbose: print("Copy org-file")
            print("Function not yet implemented")
            # copyOrgFile(args.file, args.destination)
        case "morg":
            if verbose: print("Move org-file")
            moveOrgFile(args.file, args.destination)
        case "dev":
            if verbose: print("Develop mode")
            print("Hello World")

##################################################
# Step 0.5: General Purpose Functions
##################################################

def fileIsOrg(fileInCheck):
    """Returns true if the file is an org-mode file"""
    if re.search(r'\.org$', fileInCheck):
        return True
    return False

def fileIsImage(fileInCheck):
    """Returns true if the file is an org-mode file"""
    if re.search(r'\.(png|jpg)$', fileInCheck):
        return True
    return False

def fileLinkRegex(file):
    if debug: print("regex: "+ fr'\[\[file:({file})\](\[(.+)\])*\]')
    return re.compile(rf'\[\[file:({file})\](\[(.+)\])*\]')
    
def imageLinkRegex(image=r'\S+'):
    return re.compile(rf'\[\[file:({image})\]\]')

def getRegexMatchesInFile(fileInCheck, reg):                      
    """More of a macro than an actual function"""
    with open(fileInCheck, 'r') as file:
        matches = reg.findall(file.read())
        if verbose: print(matches)
        return matches

def rmdir(dir):
    """ Wrapper for rmdir"""
    # if os.path.isdir(dir) and os.listdir(dir) == []:
    # os.rmdir(dir)
    try: 
        os.rmdir(path) 
    except OSError as error: 
        return 1

##################################################
# Step 1: Links in Files
##################################################

def getLinksInFile(fileInCheck, fileInLink=r'\S+'):
    """Returns the links in an array in the form of [path,
    description]. A file link is in the following form
    [[file:path][description]]. If no description exists then the link
    is [[file:path]]. That is the case for images.

    """
    if fileIsOrg(fileInCheck):  
        if verbose: print(f"Checking for {fileInLink} in {fileInCheck}")
        return getRegexMatchesInFile(fileInCheck, imageLinkRegex())

def fileContainsLinkTo(fileInCheck, fileInLink):
    """Checks whether B exists inside a link in A."""
    if os.path.isfile(fileInCheck) and \
        isImageInFile(fileInCheck, fileInLink):
        return True
    return False

def isOnlyFileToLinkTo(fileToCheck, filesList, fileInLink):
    """Checks if fileToCheck is the only file pointing to fileInLink,
    amongst files in filesList. fileToCheck should be among the files
    in filesList

    """
    filesWithLink = getFilesLinkinToFile(filesList, fileInLink)
    if  len(filesWithLink) == 1 and filesWithLink[0] == fileToCheck:
        return True
    return False

##################################################
# Step 2: Move Images
##################################################

def isImageInFile(searchFile, filePath):
    """Checking whether filePath exists in searchFile"""
    try:
        with open(searchFile, 'r') as file:
            content = file.read()
            return filePath in content
    except FileNotFoundError:
        print(f"The file {searchFile} does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")
    return False

def moveImage(imageFile, targetDirectory="."):
    """Moves imageFile to the proper subdirectory of images inside of
    targetDirectory. Also updates links one directory "up" from its
    location.Returns the path, relative to targetDirectory

    """
    targetDir = os.path.realpath(targetDirectory)
    orgDir = os.path.dirname(os.path.dirname(os.path.realpath(imageFile)))

    if os.path.basename(targetDir) != "images":
        targetDir = os.path.join(targetDir, 'images')

    imageTPath = os.path.join(targetDir, os.path.basename(imageFile))

    if verbose: print(f"Moving image: {imageFile} to {targetDir}")

    if not os.path.exists(targetDir):
        if verbose: print("Images subdir does not exist.")
        os.makedirs(targetDir)

    for file in getFilesLinkinToFile(orgDir, imageFile):
        updateChangedPath(file, imageFile, os.path.relpath(imageTPath, os.path.dirname(targetDir)))

    shutil.move(imageFile, targetDir)
    rmDir(os.path.dirname(imageFile))


    return 0

def moveImageDir(dir, targetDirectory="."):
    """Wrapper for moveImg: given a dir move all image files in it to
    targetDirectory"""
    if os.path.exists(dir):
        for file in os.listdir(dir):
            file = os.path.join(dir,file)
            if os.path.isfile(file) and fileIsImage(file):
                if verbose: print(f"Moving file {file}")
                moveImage(file, targetDirectory)
    elif verbose: print(f"Error target path does not exist")

def updateChangedPath(orgFile, oldPath, newPath):
    """Updates the occurences of oldPath in orgFile, with newPath.
    Works with relative paths.

    """
    if verbose: print(f"Updating {orgFile}, {oldPath}, {newPath}")
    with open(orgFile, 'r') as file:
        content = file.read()
    updated_content = re.compile(rf"{oldPath}").sub(newPath, content)
    with open(orgFile, 'w') as file:
        file.write(updated_content)

##################################################
# Step 3: Move Files
##################################################

def getFilesLinkinToFile(filesToCheck, fileInLink):
    """Returns a list of files (out of filesToCheck) that have a link
    pointing to fileInLink

    """
    if not type(filesToCheck) == list:
        filesToCheck = os.listdir(filesToCheck)
    if debug: print(f"Searching for {fileInLink} in {filesToCheck}")
    return [file for file in filesToCheck if fileContainsLinkTo(file, fileInLink)]

##################################################
# Step 3: Move Files
##################################################

def copyOrgFile(fileToMove, newLocation, delete=False):
    """Moves fileToMove, along with all of its images to newLocation.
    Images there reside in subdirectories of ./images, and links are
    updated as necessary"""
    links = getLinksInFile(fileToMove)
    for link in links: # pair: path/description - usually null
        if fileIsOrg(link):
            print("[ERROR]: Org-path will break - absolute paths not implemented")
            continue
        if os.path.isfile(link):
            moveImage(link, newLocation) # move image handles updating links
        else:
            print("[ERROR]: Not a file")
            return
    if delete:
        shutil.move(fileToMove, newLocation)
    else:
        shutil.copy(fileToMove, newLocation)

def moveOrgFile(fileToMove, newLocation):
    """ Macro Wrapper for simplified usage """
    copyOrgFile(fileToMove, newLocation, True)

##################################################
# Step 4: 
##################################################

if __name__ == '__main__':
    main()
