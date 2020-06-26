#!/bin/zsh

# Get PIV fingerprint hash
HASH=`/usr/bin/security list-smartcards` | awk -F ':' '/com.apple.pivtoken/{print$2}'

# Get user certificate keyed off of fingerprint hash
/usr/sbin/system_profiler SPSmartCardsDataType | grep -A8 "$HASH" | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/ {print; count++; if (count==3) exit}' | fold -w67 > /tmp/temp.pem

# Get UPN and Common Name from the certificate
UPN=`/usr/bin/openssl x509 -noout -text -in /tmp/temp.pem | awk -F ':' '/email/ {print $2}'`
COMMON_NAME=$(/usr/bin/openssl asn1parse -i -dump -in /tmp/temp.pem | awk -F ':' '/commonName/ {getline; print $4}')

# To do
# Use dscl command to find user name with grep
# dscl . -list /Users | grep mxxxx
# Need to figure out grep command and it uses regex