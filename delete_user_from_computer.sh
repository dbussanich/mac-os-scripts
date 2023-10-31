#!/usr/bin/env zsh

# # Parses a CSV of users and deletes those users from a macOS computer
while IFS=, read -r EMAIL FULLNAME NEWUSER ADMIN 
    do 
        sysadminctl -deleteUser $NEWUSER -secure 
    done