#!/bin/bash
dir=$(dirname $0)
source=$(readlink -f $dir)
backup=$source/bu

echo "Using as backup: $backup"
mkdir -p $backup

while read file; do
    echo $file
    if [ ! -L ~/.$file ]; then
        mv ~/.$file $backup/$file
    
        # If source file does not exist, copy it here
        if [ ! -e $source/$file ]; then
            cp -R $backup/$file $source/$file
        fi
    fi

    # Create the link - delete if already broken
    if [ ! -e "~/.$file" ]; then
        rm ~/.$file
    fi
    ln -s $source/$file ~/.$file
done < maintain.txt
