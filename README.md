canthide.sh is a file analysis and extraction tool developed to uncover hidden data within various file formats. It supports multiple archive formats and extracts plain text from binary files. Originally designed for use in Capture The Flag (CTF) competitions, the tool is also applicable for legitimate data forensics tasks. canthide.sh automates the data extraction process, facilitating the discovery of concealed information in both competitive and professional settings.

Installation
Dependencies

Before running canthide.sh, you need to install the following dependencies:
* unzip
* p7zip
* steghide
* exiftool
* cpio
* bzip2
* tar
* lzip
* lz4
* lzma
* lzop
* xz-utils
* gzip
* binwalk
* sharutils

For Debian-based systems (Ubuntu, etc.):
`sudo apt-get update -y && sudo apt-get install unzip 7zip cpio bzip2 tar lzip lz4 lzma lzop xz-utils gzip sharutils steghide libimage-exiftool-perl binwalk -y`

For Red Hat-based systems (Fedora, CentOS, etc.):

`sudo yum update -y && sudo yum install unzip p7zip cpio bzip2 tar lzip lz4 xz gzip shartutils steghide perl-Image-ExifTool binwalk -y`

Usage

To use canthide.sh, simply provide the target file as an argument:
`./canthide.sh target_file`

An optional secondary argument can be used to set the target directory for the output: `./canthide.sh target_file [target_directory]`

If `target_directory` is not provided, the directory of `target_file` will be used.


The script will detect the file type and prompt for extraction, revealing any hidden data within the file.

Features

* Supports extraction of mutliple archive formats.
* Extracts plain text from binary files.
* Attempts to use steghide to extract hidden data from files, with or without a  passphrase.
* Attempts to use binwalk to extract embedded files.
* Exports extracted strings and metadata to separate files for further analysis.

License

This project is licensed under the MIT License. See the LICENSE file for details.
