import pytest
import json
from pathlib import Path
from blogjson import (
    getTypeFromOrgFile,
    getJsonFromOrgFile,
    getJsonForDirectory,
    createBlogJson,
)

@pytest.fixture
def org_file_content():
    return """#+TITLE: Test Title
#+DESCRIPTION: Test Description
#+DATE: <2025-11-30 21:23>
#+FILETAGS: tag1 tag2
"""

def test_getTypeFromOrgFile(org_file_content):
    assert getTypeFromOrgFile("TITLE", org_file_content) == "Test Title"
    assert getTypeFromOrgFile("DESCRIPTION", org_file_content) == "Test Description"
    assert getTypeFromOrgFile("DATE", org_file_content) == "<2025-11-30 21:23>"
    assert getTypeFromOrgFile("FILETAGS", org_file_content) == "tag1 tag2"
    assert getTypeFromOrgFile("NONEXISTENT", org_file_content) == ""

@pytest.fixture
def temp_org_files(tmp_path):
    content1 = """#+TITLE: Post 1
#+DESCRIPTION: Description 1
#+DATE: <2023-01-01>
#+FILETAGS: tech emacs
"""
    (tmp_path / "post1.org").write_text(content1)

    content2 = """#+TITLE: Post 2
#+DESCRIPTION: Description 2
#+DATE: <2023-01-02>
#+FILETAGS: python programming
#+DRAFT: t
"""
    (tmp_path / "post2.org").write_text(content2)

    content3 = """#+TITLE: Post 3
#+DESCRIPTION: Description 3
#+DATE: <2023-01-03>
"""
    (tmp_path / "post3.org").write_text(content3)

    (tmp_path / "not_an_org_file.txt").write_text("hello")

    return tmp_path

def test_getJsonFromOrgFile(temp_org_files):
    # Test with a standard file
    json_data = getJsonFromOrgFile(temp_org_files / "post1.org")
    assert json_data["title"] == "Post 1"
    assert json_data["description"] == "Description 1"
    assert json_data["date"] == "2023-01-01"
    assert json_data["filetags"] == ["tech", "emacs"]

    # Test with a draft file
    json_data = getJsonFromOrgFile(temp_org_files / "post2.org")
    assert json_data == {}

    # Test with a file with missing filetags
    json_data = getJsonFromOrgFile(temp_org_files / "post3.org")
    assert json_data["title"] == "Post 3"
    assert json_data["filetags"] == ""

    # Test with a non-existent file
    json_data = getJsonFromOrgFile(temp_org_files / "non_existent.org")
    assert json_data == {}

def test_getJsonForDirectory(temp_org_files):
    json_list = getJsonForDirectory(temp_org_files)
    assert len(json_list) == 2  # post2.org is a draft and should be skipped
    titles = {item["title"] for item in json_list}
    assert "Post 1" in titles
    assert "Post 3" in titles
    assert "Post 2" not in titles

def test_createBlogJson(temp_org_files):
    result_file = temp_org_files / "blog.json"
    createBlogJson(temp_org_files, result_file)

    assert result_file.exists()
    with open(result_file, 'r') as f:
        data = json.load(f)
        assert len(data) == 2
        titles = {item["title"] for item in data}
        assert "Post 1" in titles
        assert "Post 3" in titles
