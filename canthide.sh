#!/bin/bash

#Dependency check 
command -v unzip &>/dev/null || { echo "Error: 'unzip' is not installed." >&2; exit 1; } 
command -v 7z &>/dev/null || { echo "Error: '7z' is not installed." >&2; exit 1; } 
command -v ar &>/dev/null || { echo "Error: 'ar' is not installed." >&2; exit 1; }
command -v cpio &>/dev/null || { echo "Error: 'cpio' is not installed." >&2; exit 1; }
command -v bzip2 &>/dev/null || { echo "Error: 'bzip2' is not installed." >&2; exit 1; }
command -v tar &>/dev/null || { echo "Error: 'tar' is not installed." >&2; exit 1; }
command -v lzip &>/dev/null || { echo "Error: 'lzip' is not installed." >&2; exit 1; }
command -v lz4 &>/dev/null || { echo "Error: 'lz4' is not installed." >&2; exit 1; }
command -v lzma &>/dev/null || { echo "Error: 'lzma' is not installed." >&2; exit 1; }
command -v lzop &>/dev/null || { echo "Error: 'lzop' is not installed." >&2; exit 1; }
command -v xz &>/dev/null || { echo "Error: 'xz' is not installed." >&2; exit 1; }
command -v gzip &>/dev/null || { echo "Error: 'gzip' is not installed." >&2; exit 1; }
command -v steghide &>/dev/null || { echo "Error: 'steghide' is not installed." >&2; exit 1; } 
command -v exiftool &>/dev/null || { echo "Error: 'exiftool' is not installed." >&2; exit 1; }

target=$1

info=$(file "$target" | cut -d ":" -f 2 | cut -c 2- | cut -d "," -f 1)
filename=$(basename "$target")
echo "File type is $info"

# Unzips if archvie 

if [[ $info == *"Zip"* ]]; then
    unzip -o "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"7-zip"* ]]; then
    7z x "$target" -aoa >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"ar archive"* ]]; then 
    ar -x "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"cpio archive"* ]]; then
    cpio -idu < "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"bzip2"* ]]; then
    bzip2 -df "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"tar"* ]]; then
    tar -xf "$target" --overwrite >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"lzip"* ]]; then 
    lzip -df "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"LZ4"* ]]; then 
    lz4 -df "$target" "$target.out" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"LZMA"* ]]; then 
    if [[ "${target##*.}" != "lzma" ]]; then
        mv "$target" "${target}.lzma"
        target="${target}.lzma"
    fi
    lzma -df "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"lzo"* ]]; then 
    if [[ "${target##*.}" != "lzo" ]]; then
        mv "$target" "${target}.lzo"
        target="${target}.lzo"
    fi
    lzop -df "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"XZ"* ]]; then 
    if [[ "${target##*.}" != "xz" ]]; then
        mv "$target" "${target}.xz"
        target="${target}.xz"
    fi
    xz -df "$target" >/dev/null 2>&1
    echo "Unzipped $target"

elif [[ $info == *"gzip"* ]]; then 
    if [[ "${target##*.}" != "gz" ]]; then
        mv $target "${target}.gz"
        target="${target}.gz"
    fi
    gzip -df "$target" >/dev/null 2>&1
    echo "Unzipped $target"

else 
    # Attempts to use steghide with or without passphrase and output strings to file
    read -p "Enter a passphrase if supplied (leave blank if not provided): " passphrase
    echo "Trying steghide..."
    steghide --extract --passphrase "$passphrase" -sf "$target" -f 

    # Extract the strings and metadata to respective files
    echo "Exporting strings..."
    strings "$target" > "$filename"_strings.txt
    echo "Exporting metadata..." 
    exiftool "$target" > "$filename"_metadata.txt
fi


