canthide.sh is a versatile file analysis and extraction tool designed for uncovering hidden data within different file formats. It supports Zip and 7-zip archives and extracts plain text from binary files. Ideal for data forensics and cybersecurity, the script automates data extraction, simplifying the process of revealing concealed information.

Installation
Dependencies

Before running CantHide.sh, you need to install the following dependencies:
unzip
p7zip
steghide
exiftool

For Debian-based systems (Ubuntu, etc.):
`sudo apt-get update && sudo apt-get install -y unzip p7zip-full steghide libimage-exiftool-perl`

For Red Hat-based systems (Fedora, CentOS, etc.):

`sudo yum install -y unzip p7zip p7zip-plugins steghide perl-Image-ExifTool`

Usage

To use canthide.sh, simply provide the target file as an argument:
`./canthide.sh target_file`

The script will automatically detect the file type and perform the necessary extraction, revealing any hidden data within the file.

Features

Supports extraction of Zip and 7-zip archives.
Extracts plain text from binary files.
Attempts to use steghide to extract hidden data from files, with or without a passphrase.
Exports extracted strings and metadata to separate files for further analysis.

License

This project is licensed under the MIT License. See the LICENSE file for details.
