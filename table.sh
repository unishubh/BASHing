#!/bin/bash

echo "Enter Number"
read n
i=0
while [ $i -ne 10 ]
do
    i=$(expr $i + 1)
    table=$(expr $i \* $n)
    echo $n "x" $i "=" $table
done