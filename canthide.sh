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
        e  cho "Error: Target file is not provided or does not exist."
        exit 1
    fi
}

# Checks for dependencies 

dependency_check () {
    for dependency in ${dependencies[@]}; do 
        command -v "$dependency" &>/dev/null || { echo "Error: '$dependency' is not installed." >&2; exit 1; }
    done 
}

# Gather file info and retrieve basename

file_check () {
    info=$(file "$target" | cut -d ":" -f 2 | cut -c 2- | cut -d "," -f 1)
    filename=$(basename "$target")
    echo "File type is $info"
}

# Unzips if supported archive

archive_check () {
    while true; do
        read -p "Unzip if supported archive? Type 'yes' or 'no': " option
        if [[ $option == "yes" ]]; then
            if [[ $info == *"Zip"* ]]; then
                unzip -o "$target" -d "$target_dir" >/dev/null 2>&1
                echo "Unzipped $filename to $target_dir"
        
            elif [[ $info == *"7-zip"* ]]; then
                7z x "$target" -aoa -o "$target_dir" >/dev/null 2>&1
                echo "Unzipped $filename to $target_dir"

            elif [[ $info == *"ar archive"* ]]; then 
                pushd "$target_dir" >/dev/null 2>&1
                ar -x "$filename" >/dev/null 2>&1
                echo "Unzipped $filename to $target_dir"
                popd >/dev/null 2>&1

            elif [[ $info == *"cpio archive"* ]]; then
                pushd "$target_dir" >/dev/null 2>&1
                cpio -idu < "$filename" >/dev/null 2>&1
                echo "Unzipped $filename to $target_dir"
                popd >/dev/null 2>&1

            elif [[ $info == *"bzip2"* ]]; then
                pushd "$target_dir" >/dev/null 2>&1
                bzip2 -df "$filename" >/dev/null 2>&1
                echo "Unzipped $filename to $target_dir"
                popd >/dev/null 2>&1

            elif [[ $info == *"tar"* ]]; then
                tar -xf "$target" -C "$target_dir" --overwrite >/dev/null 2>&1
                echo "Unzipped $filename to $target_dir"

            elif [[ $info == *"lzip"* ]]; then 
                lzip -df "$target" > "$target_dir/${filename%.lz}" 2>dev/null
                echo "Unzipped $filename to $target_dir"

            elif [[ $info == *"LZ4"* ]]; then 
                lz4 -df "$target" "$target_dir/${filename%.lz4}" >/dev/null 2>&1
                echo "Unzipped $filename to $target_dir"

            elif [[ $info == "shell archive text" ]]; then 
                shar -x "$target" > "$target.sh" 2>&1
                echo "Unzipped $filename to $target_dir"

            # Last four archives require respective extensions 

            elif [[ $info == *"LZMA"* ]]; then 
                if [[ "${target##*.}" != "lzma" ]]; then
                    mv "$target" "${target}.lzma"
                    target="${filename}.lzma"
                fi
                lzma -df "$target" > "$target_dir/${filename%.lzma}" 2>/dev/null
                echo "Unzipped $filename to $target_dir"
            
            elif [[ $info == *"lzo"* ]]; then 
                if [[ "${target##*.}" != "lzo" ]]; then
                    mv "$target" "${target}.lzo"
                    target="${filename}.lzo"
                fi
                lzop -df "$target" > "$target_dir/${filename%.lzo}" 2>/dev/null
                echo "Unzipped $filename to $target_dir"
            
            elif [[ $info == *"XZ"* ]]; then 
                if [[ "${target##*.}" != "xz" ]]; then
                    mv "$target" "${target}.xz"
                    target="${filename}.xz"
                fi
                xz -df "$target" > "$target_dir/${filename%.xz}" 2>/dev/null
                echo "Unzipped $filename to $target_dir"

            elif [[ $info == *"gzip"* ]]; then 
                if [[ "${target##*.}" != "gz" ]]; then
                    mv $target "${target}.gz"
                    target="${filename}.gz"
                fi
                gzip -df "$target" > "$target_dir/${filename%.gz}" 2>/dev/null
                echo "Unzipped $filename to $target_dir"

            else 
                echo "$filename is not a supported archive"
                
            fi
            break

        elif [[ $option == "no" ]]; then
            break
        else 
            echo "Invalid input. Please type 'yes' or 'no': "
        fi
    done
}

# Attempts steghide with or without a passphrase

try_steghide () {
    while true; do
        read -p "Try steghide? Type 'yes' or 'no': " option
        if [[ $option == "yes" ]]; then
            read -p "Enter a passphrase if supplied (leave blank if not provided): " passphrase
            echo "Trying steghide..."
            pushd "$target_dir" >/dev/null 2>&1
            steghide --extract --passphrase "$passphrase" -sf "$target" -f &>/dev/null || { echo "Steghide: $filename is not a supported format."; }
            popd >/dev/null 2>&1
            break
        elif [[ $option == "no" ]]; then
            break
        else 
            echo "Invalid input. Please type 'yes' or 'no': "
        fi
    done
}

# Attemps to use binwalk

try_binwalk () {
    while true; do
        read -p "Try binwalk? Type 'yes' or 'no': " option
        if [[ $option == "yes" ]]; then
            echo "Trying binwalk..."
            pushd "$target_dir" >/dev/null 2>&1
            binwalk -e "$target"
            popd >/dev/null 2>&1
            break
        elif [[ $option == "no" ]]; then
            break
        else 
            echo "Invalid input. Please type 'yes' or 'no': "
        fi
    done
}

# Exports strings and exiftool data to respective files

export_data () {
    while true; do   
        read -p "Export data? Type 'yes' or 'no': " option
        if [[ $option == "yes" ]]; then
            echo "Exporting strings..."
            strings "$target" > "$target_dir/$filename"_strings.txt
            echo "Exporting metadata..." 
            exiftool "$target" > "$target_dir/$filename"_metadata.txt
            break
        elif [[ $option == "no" ]]; then
            break
        else 
            echo "Invalid input. Please type 'yes' or 'no': "
        fi
    done
}

# Function calls and exit

display_banner
target_check
dependency_check
file_check
archive_check
try_steghide
try_binwalk
export_data
exit 0   



