#!/bin/bash
# Authored by Linux Viking (https://github.com/Linux-Viking)

# Target file and directory

target=$1
target_dir=${2:-$(dirname "$target")}


# Dependency array 

dependencies=(steghide exiftool binwalk)

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

# Identifies if supported archive and recommends unarchiving tool

archive_check () {
    if [[ $info == *"Zip"* ]]; then
        echo "File is a Zip archive. Recommend unarchiving with 'unzip'."
        
    elif [[ $info == *"7-zip"* ]]; then
        echo "File is a 7-zip archive. Recommend unarchiving with '7z'."

    elif [[ $info == *"ar archive"* ]]; then 
        echo "File is an ar archive. Recommend unarchiving with 'ar'."

    elif [[ $info == *"cpio archive"* ]]; then
        echo "File is a cpio archive. Recommend unarchiving with 'cpio'."

    elif [[ $info == *"bzip2"* ]]; then
        echo "File is a bzip2 compressed file. Recommend unarchiving with 'bzip2'."

    elif [[ $info == *"tar"* ]]; then
        echo "File is a tar archive. Recommend unarchiving with 'tar'."

    elif [[ $info == *"lzip"* ]]; then 
        echo "File is an lzip compressed file. Recommend unarchiving with 'lzip'."

    elif [[ $info == *"LZ4"* ]]; then 
        echo "File is an LZ4 compressed file. Recommend unarchiving with 'lz4'."

    elif [[ $info == "shell archive text" ]]; then 
        echo "File is a shell archive. Recommend unarchiving with 'shar'."

    elif [[ $info == *"LZMA"* ]]; then 
        echo "File is an LZMA compressed file. Recommend unarchiving with 'lzma'."
            
    elif [[ $info == *"lzo"* ]]; then 
        echo "File is an lzo compressed file. Recommend unarchiving with 'lzop'."
            
    elif [[ $info == *"XZ"* ]]; then 
        echo "File is an XZ compressed file. Recommend unarchiving with 'xz'."

    elif [[ $info == *"gzip"* ]]; then 
        echo "File is a gzip compressed file. Recommend unarchiving with 'gzip'."

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
    binwalk -Me --directory="$canthide_dir/" "$target"
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



