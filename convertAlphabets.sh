#!/bin/bash

echo -n "Enter File Name : "
read fileName

echo -n "TO Convert to caps press : 2 "
echo -n "TO Convert to small press : 1 "
read choice

#echo choice

if [ ! -f $fileName ]; then
  echo "Filename $fileName does not exists"
  exit 1
fi

if [ choice == '1' ]; then 
    tr '[A-Z]' '[a-z]' < $fileName >> small.txt
else 
    tr '[a-z]' '[A-Z]' < $fileName >> caps.txt
fi