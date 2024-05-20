#!/bin/bash

# Iterate over each directory in implementations/*
for folder in implementations/*; do
  # Check if the item is a directory
  if [ -d "$folder" ]; then
    # Run the scc command with the appropriate arguments
    scc --cocomo-project-type organic --format-multi "json:$folder/complexity.json" "$folder"
  fi
done
