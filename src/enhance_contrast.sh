#!/bin/bash

files=`find /scratch/cobecore/aerial_photographs/png -name "*.png"`

for i in $files;do
    file=`basename $i`
    output=`echo /scratch/cobecore/aerial_photographs/png_clahe/$file`
    echo processing: $output
    ./clahe.py -i $i -o $output -w 32 -c 1.5
done
