#!/bin/bash

#run run.sh in each subdir of implementations. Catch errors and continue
for folder in implementations/*; do
  if [ -d "$folder" ]; then
    echo "Running tests in $folder"
    if [ -f "$folder/run.sh" ]; then
      cd $folder
      echo "Running run.sh in $folder"
      ./run.sh ../../config_test.yaml
      cd ../..
    else
      echo "No run.sh found in $folder"
    fi
  fi
done

python3 test.py