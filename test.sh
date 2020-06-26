#!/bin/zsh

# Get PIV fingerprint hash
HASH=`/usr/bin/security list-smartcards` | awk -F ':' '/com.apple.pivtoken/{print$2}'

if [ -z "$HASH" ]; then 
    return 1
fi