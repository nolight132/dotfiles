#!/bin/bash

# Go to the nvim directory
cd "$(dirname "$0")/.." || exit 1

# Run Neovim with the version check script
nvim --headless -c "luafile scripts/check-version.lua" -c "q"
