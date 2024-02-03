import json

def process_json(json_file_path):
    with open(json_file_path, 'r') as file:
        data = json.load(file)

    for obj in data:
        myproperty = 'filetags'
        if myproperty in obj:
            # Split the value of the MYPROPERTY myproperty into a list of words
            words = obj[myproperty].split()

            # Replace the MYPROPERTY myproperty with the list of words
            obj[myproperty] = words

    # Write the modified data back to the json file
    with open(json_file_path, 'w') as file:
        json.dump(data, file, indent=2)

# Replace 'your_json_file.json' with the actual file path
json_file_path = 'summary.json'
process_json(json_file_path)
