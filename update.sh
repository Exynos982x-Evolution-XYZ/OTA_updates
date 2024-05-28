#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 folder"
    exit 1
fi

folder=$1
folder_name=$(basename "$folder")
to_replace=("filename" "timestamp" "md5" "sha256" "size" "version")

if [ ! -d "$folder" ]; then
    echo "The folder '$folder' doesn't exist."
    exit 1
fi

replace_json_values() {
    local source_json=$1
    local destination_json=$2
    local changelog_txt="./changelogs/$(basename $destination_json | sed 's/.json/.txt/g')"

    for key in "${to_replace[@]}"; do
        local value=$(jq -r ".response[0].$key" "$source_json")
        jq --arg key "$key" --arg newValue "$value" '.response[0][$key] = $newValue' "$destination_json" > tmp.$$.json && mv tmp.$$.json "$destination_json"
    done
    local filename=$(cat $source_json | jq -r ".response[0].filename")
    local value="https://download.0xsharkboy.dev/s/EvolutionX-9x/download?path=%2F${folder_name}%2F${codename}&files=${filename}"
    jq --arg key "download" --arg newValue "$value" '.response[0]["download"] = $newValue' "$destination_json" > tmp.$$.json && mv tmp.$$.json "$destination_json"
    git add $destination_json $changelog_txt
    git commit -m "$codename: $folder_name Update"
}

for sub_folder in "$folder"/*; do
    if [ -d "$sub_folder" ]; then
        codename=$(basename "$sub_folder")
        source_json="$sub_folder/$codename.json"
        destination_json="./builds/$codename.json"

        replace_json_values "$source_json" "$destination_json"
    fi
done


