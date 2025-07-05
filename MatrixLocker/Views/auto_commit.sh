#!/bin/bash
# Usage:
#   ./auto_commit.sh
# This script stages all changed files, commits them with a timestamped message,
# and prints a short summary of the commit.

# Add all changes
git add .

# Commit with current date and time
commit_message="Auto-commit: $(date '+%Y-%m-%d %H:%M')"
git commit -m "$commit_message"

# Print short summary of the commit
git status -s
