#!/bin/bash

target=$1

info=$(file "$target" | cut -d ":" -f 2 | cut -c 2- | cut -d "," -f 1)
echo "File type is $info"

#unzip if archvie 

if [[ $info == *"Zip"* ]]; then
    unzip "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"7-zip"* ]]; then
    7z x "$target" -aoa >/dev/null 2>&1
    echo "Unzipped $target"
else 
    strings "$target"
fi



# steghide --extract --passphrase "" -sf atbash.jpg -f
