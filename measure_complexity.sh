#!/bin/bash

# Iterate over each directory in implementations/*
for folder in implementations/*; do
  # Check if the item is a directory
  if [ -d "$folder" ]; then
    # Run the scc command with the appropriate arguments
    scc --no-min-gen --include-ext "py,jl,cpp,hpp,sh" --format-multi "json2:$folder/complexity.json" "$folder"
  fi
done
