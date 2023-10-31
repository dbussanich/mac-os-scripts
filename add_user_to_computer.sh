#!/usr/bin/env zsh

# Parses a CSV of users and adds those users to a macOS computer

while IFS=, read -r EMAIL FULLNAME NEWUSER ADMIN
do
    # Create a new user with a username
    sysadminctl -addUser $NEWUSER -fullName $FULLNAME -adminassword $PASS
    echo "Added user admin $NEWUSER"
    # Append NT Principal Name to user's account as ds Attribute
    dscl . -append /Users/${NEWUSER} dsAttrTypeNative:smartCardIdentity "$EMAIL"
    echo "Added email $EMAIL to $NEWUSER dsattribute"
done