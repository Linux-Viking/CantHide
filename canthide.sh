#!/bin/bash
# Authored by Linux Viking (https://github.com/Linux-Viking)

# Target file and directory

target=$1
target_dir=${2:-$(dirname "$target")}


# Dependency array 

dependencies=(unzip 7z shar ar cpio bzip2 tar lzip lz4 lzma lzop xz gzip steghide exiftool binwalk)

# Help message check 

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    help_message
fi

# Functions

# Banner

display_banner () {
    cat << "EOF"
 ██████╗ █████╗ ███╗   ██╗████████╗    
██╔════╝██╔══██╗████╗  ██║╚══██╔══╝    
██║     ███████║██╔██╗ ██║   ██║       
██║     ██╔══██║██║╚██╗██║   ██║       
╚██████╗██║  ██║██║ ╚████║   ██║       
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       
                                       
██╗  ██╗██╗██████╗ ███████╗            
██║  ██║██║██╔══██╗██╔════╝            
███████║██║██║  ██║█████╗              
██╔══██║██║██║  ██║██╔══╝              
██║  ██║██║██████╔╝███████╗            
╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝            
                                       
                by Linux Viking
                
EOF
}




# Help message output

help_message () {
    echo "Usage: ./canthide.sh target_file [target_directory]"
    echo "If target_directory is not provided, the directory of target_file will be used."
    exit 0
}

# Makes sure target is not empty and exists 

target_check () {
    if [[ -z "$target" || ! -f "$target" ]]; then
        echo "Error: Target file is not provided or does not exist."
        exit 1
    fi
}

# Checks for dependencies 

dependency_check () {
    for dependency in ${dependencies[@]}; do 
        command -v "$dependency" &>/dev/null || { echo "Error: '$dependency' is not installed." >&2; exit 1; }
    done 
}

# Makes sure target directory exists 

dir_check () {
    if [[ ! -d "$target_dir" ]]; then
        echo "Error: Target directory does not exist."
        exit 1
    fi
}

# Gather file info, retrieve basename, assigns the canthide_dir

file_check () {
    info=$(file "$target" | cut -d ":" -f 2 | cut -c 2- | cut -d "," -f 1)
    filename=$(basename "$target")
    canthide_dir="$target_dir/CantHide_${filename%.*}"
    echo "File type is $info"
}

# Creates directory for all output

stage_directory () {
    rm -rf "$target_dir/CantHide_${filename%.*}"
    mkdir -p "$target_dir/CantHide_${filename%.*}" || { echo "Error: Could not create CantHide directory in target_dir. Do you have permission?" >&2; exit 1; }
}

# Unzips if supported archive

archive_check () {
    if [[ $info == *"Zip"* ]]; then
        unzip -o "$target" -d "$canthide_dir" >/dev/null 2>&1
        echo "Unzipped $filename to $canthide_dir"
        
    elif [[ $info == *"7-zip"* ]]; then
        7z x "$target" -aoa -o "$canthide_dir" >/dev/null 2>&1
        echo "Unzipped $filename to $canthide_dir"

    elif [[ $info == *"ar archive"* ]]; then 
        pushd "$canthide_dir" >/dev/null 2>&1
        ar -x "$filename" >/dev/null 2>&1
        echo "Unzipped $filename to $canthide_dir"
        popd >/dev/null 2>&1

    elif [[ $info == *"cpio archive"* ]]; then
        pushd "$canthide_dir" >/dev/null 2>&1
        cpio -idu < "$target" >/dev/null 2>&1
        echo "Unzipped $filename to $canthide_dir"
        popd >/dev/null 2>&1

    elif [[ $info == *"bzip2"* ]]; then
        pushd "$canthide_dir" >/dev/null 2>&1
        bzip2 -df "$target" >/dev/null 2>&1
        echo "Unzipped $filename to $canthide_dir"
        popd >/dev/null 2>&1

    elif [[ $info == *"tar"* ]]; then
        tar -xf "$target" -C "$canthide_dir" --overwrite >/dev/null 2>&1
        echo "Unzipped $filename to $canthide_dir"

    elif [[ $info == *"lzip"* ]]; then 
        lzip -df "$target" > "$canthide_dir/${filename%.lz}" 2>dev/null
        echo "Unzipped $filename to $canthide_dir"

    elif [[ $info == *"LZ4"* ]]; then 
        lz4 -df "$target" "$canthide_dir/${filename%.lz4}" >/dev/null 2>&1
        echo "Unzipped $filename to $canthide_dir"

    elif [[ $info == "shell archive text" ]]; then 
        shar -x "$target" > "$canthide_dir/$filename.sh" 2>&1
        echo "Unzipped $filename to $canthide_dir"

    # Last four archives require respective extensions 

    elif [[ $info == *"LZMA"* ]]; then 
        if [[ "${target##*.}" != "lzma" ]]; then
            mv "$target" "${target}.lzma"
            target="${filename}.lzma"
        fi
        lzma -df "$target" > "$canthide_dir/${filename%.lzma}" 2>/dev/null
        echo "Unzipped $filename to $canthide_dir"
            
    elif [[ $info == *"lzo"* ]]; then 
        if [[ "${target##*.}" != "lzo" ]]; then
            mv "$target" "${target}.lzo"
            target="${filename}.lzo"
        fi
        lzop -df "$target" > "$canthide_dir/${filename%.lzo}" 2>/dev/null
        echo "Unzipped $filename to $canthide_dir"
            
    elif [[ $info == *"XZ"* ]]; then 
        if [[ "${target##*.}" != "xz" ]]; then
            mv "$target" "${target}.xz"
            target="${filename}.xz"
        fi
        xz -df "$target" > "$canthide_dir/${filename%.xz}" 2>/dev/null
        echo "Unzipped $filename to $canthide_dir"

        elif [[ $info == *"gzip"* ]]; then 
            if [[ "${target##*.}" != "gz" ]]; then
                mv $target "${target}.gz"
                target="${filename}.gz"
            fi
        gzip -df "$target" > "$canthide_dir/${filename%.gz}" 2>/dev/null
        echo "Unzipped $filename to $canthide_dir"

    else 
        echo "$filename is not a supported archive" 
    fi
}

# Attempts steghide with or without a passphrase

try_steghide () {
    read -p "Enter a passphrase if supplied (leave blank if not provided): " passphrase
    echo "Trying steghide..."
    pushd "$canthide_dir" >/dev/null 2>&1
    steghide --extract --passphrase "$passphrase" -sf "$target" -f &>/dev/null || { echo "Steghide: $filename is not a supported format."; }
    popd >/dev/null 2>&1
}

# Attemps to use binwalk

try_binwalk () {
    echo "Trying binwalk..."
    binwalk -e "$target"
}

# Exports strings and exiftool data to respective files

export_data () {   
    strings "$target" > "$canthide_dir/$filename"_strings.txt
    echo "Exporting strings to $canthide_dir"
    exiftool "$target" > "$canthide_dir/$filename"_metadata.txt
    echo "Exporting metadata to $canthide_dir"
}

# Function calls and exit

display_banner
dependency_check
target_check
dir_check
file_check
stage_directory
archive_check
try_steghide
try_binwalk
export_data
exit 0   



