canthide.sh is a versatile file analysis and extraction tool designed for uncovering hidden data within different file formats. It supports multiple archive formats and extracts plain text from binary files. Ideal for data forensics and cybersecurity, the script automates data extraction, simplifying the process of revealing concealed information.

Installation
Dependencies

Before running canthide.sh, you need to install the following dependencies:
unzip
p7zip
steghide
exiftool
ar
cpio
bzip2
tar
lzip
lz4
lzma
lzop
xz-utils
gzip

For Debian-based systems (Ubuntu, etc.):
`sudo apt-get update -y && sudo apt-get install unzip 7zip cpio bzip2 tar lzip lz4 lzma lzop xz-utils gzip steghide libimage-exiftool-perl -y`

For Red Hat-based systems (Fedora, CentOS, etc.):

`sudo yum update -y && sudo yum install unzip p7zip cpio bzip2 tar lzip lz4 xz gzip steghide perl-Image-ExifTool -y`

Usage

To use canthide.sh, simply provide the target file as an argument:
`./canthide.sh target_file`

The script will automatically detect the file type and perform the necessary extraction, revealing any hidden data within the file.

Features

Supports extraction of mutliple archive formats.
Extracts plain text from binary files.
Attempts to use steghide to extract hidden data from files, with or without a passphrase.
Exports extracted strings and metadata to separate files for further analysis.

License

This project is licensed under the MIT License. See the LICENSE file for details.
