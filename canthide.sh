#!/bin/bash

command -v unzip &>/dev/null || { echo "Error: 'unzip' is not installed." >&2; exit 1; } && command -v 7z &>/dev/null || { echo "Error: '7z' is not installed." >&2; exit 1; } && command -v steghide &>/dev/null || { echo "Error: 'steghide' is not installed." >&2; exit 1; } && command -v exiftool &>/dev/null || { echo "Error: 'exiftool' is not installed." >&2; exit 1; }

target=$1

info=$(file "$target" | cut -d ":" -f 2 | cut -c 2- | cut -d "," -f 1)
filename=$(basename "$target")
echo "File type is $info"

# Unzips if archvie 

if [[ $info == *"Zip"* ]]; then
    unzip "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"7-zip"* ]]; then
    7z x "$target" -aoa >/dev/null 2>&1
    echo "Unzipped $target"
else 
# Attempts to use steghide with or without passphrase and output strings to file
    read -p "Enter a passphrase if supplied (leave blank if not provided): " passphrase
    echo "Trying steghide..."
    steghide --extract --passphrase "$passphrase" -sf "$target" -f 
fi

# Extract the strings and metadata to respective files
echo "Exporting strings..."
strings "$target" > "$filename"_strings.txt
echo "Exporting metadata..." 
exiftool "$target" > "$filename"_metadata.txt
