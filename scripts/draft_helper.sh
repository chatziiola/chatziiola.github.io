#!/bin/env zsh

# --- Configuration ---
# Set the base directory for source files
BASE_DIR=~/Github/chatziiola.github.io
CONTENT_DIR=$BASE_DIR/content
DOCS_DIR=$BASE_DIR/docs
BLACKLIST='index'

# Initialize an empty array for the drafts
draft_files=()
draft_html_files=()

# --- Find All Source Files ---
# Find all unique base filenames (without extension) from the content directory.
# The Zsh globbing (**) is much cleaner than a pipe-and-process chain for this.
# The 'f' glob qualifier limits it to regular files.
all_sources=($CONTENT_DIR/**/*.org(N:t:r))
typeset -U all_sources

# --- Identify Drafts ---
# Loop through the list of source base filenames
for base_name in $all_sources; do
    # Check if a corresponding output HTML file exists.
    if [[ " ${BLACKLIST[*]} " == *" $base_name "* ]]; then
        continue;
    fi
    f=$(find $DOCS_DIR -type f -name "$base_name.html")
    # if html file exists
    # and that file is tracked by git
    # and that file exists in previous commits (is not just added)
    if [[ -f $f ]] && ! git diff-index --quiet HEAD -- "$f";
    then
        continue;
    fi
    draft_files+=($base_name)
    draft_html_files+=($f)
done

# --- Output the Results ---
# echo "--- Draft Files Found (${#draft_files[@]}) ---"

# # Print each element of the array
# # The "$draft_files[@]" expansion is safe even if filenames have spaces
print_drafts()  {
    printf "%d unique files found in total\n" "${#all_sources[@]}"
    if (( ${#draft_files[@]} > 0 )); then
        printf '* %s\n' $draft_files[@]
    else
        echo "No draft files found."
    fi
}

delete_drafts() {
    for f in $draft_html_files;do
        if read -q "choice? Remove $f? (y/N) "; then
            echo "\nConfirmed. Proceeding..."
            rm $f
        fi   
    done
}
print_usage() {
    printf "Usage: %s [-d] [-p] [-h]\n" "$0"
    printf "Options:\n"
    printf "  -d \tDelete drafts (calls the delete_drafts function).\n"
    printf "  -p \tPrint drafts (calls the print_drafts function).\n"
    printf "  -h \tDisplay this help message (calls the print_usage function).\n"
    printf "\n"
    exit 0
}

while getopts "pdh" optchar; do
    case "${optchar}" in
        d) delete_drafts;;
        p) print_drafts;;
        h) print_usage;;
        *) printf "Wrong usage"
    esac
done
