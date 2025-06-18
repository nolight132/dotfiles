#!/bin/bash

declare -a stow_dirs
declare -a successful_stow
for item in *; do
  if [[ -d "$item" ]]; then
    stow_dirs+=("$item")
  fi
done

find . -name ".DS_Store" -type f -delete

for item in "${stow_dirs[@]}"; do
  if [[ -d "$item" ]]; then
    printf "Stowing %s...\n" "$item"
    stow -S $item

    if [ $? -ne 0 ]; then
      echo "ERROR: Failed to stow '$item'."
    else
      successful_stow+=("$item")
    fi
  fi
done

successful_count=${#successful_stow[@]}
if [ "$successful_count" -gt 0 ]; then
  echo "Successfully stowed "$successful_count" directories."
else
  echo "No directories were stowed."
fi
