import os
import subprocess
import xml.etree.ElementTree as ET

# CONFIGURATION: Change this to your site URL
BASE_URL = "https://chatziiola.github.io"
OUTPUT_DIR = "./docs"
SITEMAP_FILE = os.path.join(OUTPUT_DIR, "sitemap.xml")

def get_git_lastmod(file_path):
    """Get the last modified date of a file using Git history."""
    try:
        timestamp = subprocess.check_output(
            ["git", "log", "-1", "--format=%cd", "--date=format:%Y-%m-%d", file_path],
            stderr=subprocess.DEVNULL
        ).decode("utf-8").strip()
        return timestamp if timestamp else None
    except subprocess.CalledProcessError:
        return None

def generate_sitemap():
    """Generate a sitemap.xml file for all HTML files using Git commit timestamps."""
    urlset = ET.Element("urlset", xmlns="http://www.sitemaps.org/schemas/sitemap/0.9")

    for root, dirs, files in os.walk(OUTPUT_DIR):
        dirs[:] = [d for d in dirs if d not in excluded_dirs]
        for file in files:
            if file.endswith(".html"):
                file_path = os.path.join(root, file)
                relative_path = os.path.relpath(file_path, OUTPUT_DIR)
                url = f"{BASE_URL}/{relative_path.replace(os.sep, '/')}"
                
                lastmod = get_git_lastmod(file_path) or "2024-01-01"  # Default to a safe fallback date

                url_elem = ET.SubElement(urlset, "url")
                ET.SubElement(url_elem, "loc").text = url
                ET.SubElement(url_elem, "lastmod").text = lastmod

    # Write the XML tree to sitemap.xml
    tree = ET.ElementTree(urlset)
    ET.indent(tree)  # Python 3.9+ for pretty-printing
    tree.write(SITEMAP_FILE, encoding="utf-8", xml_declaration=True)

    print(f"Sitemap generated: {SITEMAP_FILE}")

if __name__ == "__main__":
    excluded_dirs = [ "src"]
    generate_sitemap()
