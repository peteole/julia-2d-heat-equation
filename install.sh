#!/bin/bash

#run run.sh in each subdir of implementations. Catch errors and continue
for folder in implementations/*; do
  if [ -d "$folder" ]; then
    echo "Installing in $folder"
    if [ -f "$folder/install.sh" ]; then
      cd $folder
      echo "Running install.sh in $folder"
      ./install.sh
      cd ../..
    else
      echo "No install.sh found in $folder"
    fi
  fi
done
