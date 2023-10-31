#!/usr/bin/env zsh

# Parses a JSON of users and adds those users to a macOS computer

while IFS=, read -r col1 col2 col3
do
    echo "Email: $col1"
    echo "Full Name: $col2"
    echo "Username: $col3"
    echo ""
done

