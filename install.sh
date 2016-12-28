#!/bin/bash
source=$(basename $0)
backup=$source/bu

mkdir -p $backup

while read file; do
    mv ~/$file $backup
    
    # If source file does not exist, copy it here
    if [ ! -e $source/$file ]; then
        cp $backup/$file $source/$file
    fi

    # Create the link
    ln -s $source/$file ~/$file
done < maintain.txt
