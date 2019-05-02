#!/bin/bash
echo "Converting RARs to ZIPs"

# Separate files using ␜ http://graphemica.com/%E2%90%9C.
IFS="␜"

# Use RAM disk for temporary files.
WORKDIR="/dev/shm/"

# Set name for the temp dir. This directory will be created under WORKDIR
TEMPDIR="rar2zip"

# Run using "./rar2zip.sh /full/path/to/files/"
# If no directory is specified, then use the current working directory (".").

if test -z $1; then
   SOURCEDIR=`pwd`
else
   SOURCEDIR="$1"
fi

echo "Using $SOURCEDIR"

# Create an temporary directory to work in.
cd $WORKDIR
mkdir $TEMPDIR
cd $TEMPDIR

# Find all the .rar files in the specified directory.
# Using -iname means it will find .rar .RAR .RaR etc.
# "-printf "%p␜" will cause the file names to be separated by the ␜ symbol,
# rather than the default newline.

for OLDFILE in `find $SOURCEDIR -iname "*.rar" -printf "%p␜"`; do

   # Get the file name without the extension
   BASENAME=`basename "${OLDFILE%.*}"`

   # Path for the file. The ".zip" file will be moved there.
   DIRNAME=`dirname $OLDFILE`

   # Name of the .zip file
   NEWNAME="$BASENAME.zip"

   # Create a temporary folder for unRARed files
   echo "Extracting $OLDFILE"
   mkdir "$BASENAME"
   7z x "$OLDFILE" -O"$BASENAME"
   cd "$BASENAME"

   # Zip the files with maximum compression
   7z a -tzip -mx=9 "$NEWNAME" *
   # Alternative. MUCH SLOWER, but better compression
   # 7z a -mm=Deflate -mfb=258 -mpass=15 -r "$NEWNAME" *

   # Move the new .zip to the directory containing the original ".rar" file
   mv "$NEWNAME" $DIRNAME/"$NEWNAME"

   # Delete the temporary directory
   cd $WORKDIR
   rm -r "$BASENAME"

   # OPTIONAL. Delete the RAR file
   # cd $DIRNAME
   # rm "$OLDFILE"

done

# Delete the temporary directory
cd $WORKDIR
rm -r $TEMPDIR

echo "Conversion Done"
