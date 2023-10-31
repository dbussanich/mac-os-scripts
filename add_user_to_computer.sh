#!/usr/bin/env zsh

# Parses a JSON of users and adds those users to a macOS computer

while IFS=, read -r EMAIL FULLNAME NEWUSER
do
    # Create a new user with a username
    PASS=uuidgen
    sysadminctl -addUser $NEWUSER -fullName $FULLNAME -password $PASS
    echo "Added user $NEWUSER"
    sleep 1
    dscl . -append /Users/${NEWUSER} dsAttrTypeNative:smartCardIdentity "$EMAIL"
    echo "Added email $EMAIL to $NEWUSER dsattribute"
done