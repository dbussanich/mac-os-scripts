#!/bin/zsh

# Get PIV fingerprint hash
HASH=`/usr/bin/security list-smartcards` | awk -F ':' '/com.apple.pivtoken/{print$2}'

if [ -z "$HASH" ]; then 
    return 1
fi

# Get user certificate keyed off of fingerprint hash
/usr/sbin/system_profiler SPSmartCardsDataType | grep -A8 "$HASH" \
    | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/ {print; count++; if (count==3) exit}' \
    | fold -w67 > /tmp/temp.pem

# Get UPN and Common Name from the certificate
UPN=`/usr/bin/openssl x509 -noout -text -in /tmp/temp.pem | awk -F ':' '/email/ {print $2}'`
COMMON_NAME=$(/usr/bin/openssl asn1parse -i -dump -in /tmp/temp.pem | awk -F ':' '/commonName/ {getline; print $4}')

# Use dscl command to query Open Directory to find user name with grep
# Then, get real name from user name
USERNAME=$(dscl . -list /Users | grep -E "m(1|3)\w\w\w\d\d")
REAL_NAME=$(dscl . -read /Users/${USERNAME} RealName)

# Convert user name to all upper case
# Then compare Common Name to real name upper. If not equivalent, then wrong smart card is entered
REAL_NAME_UPPER=`echo $REAL_NAME | awk '/RealName/{getline; print}' | sed 's/^ *//g' | tr '[:lower:]' '[:upper:]'`

if [ "$COMMON_NAME" != "$REAL_NAME_UPPER" ]; then
    return 1
fi

# Add attribute to user's Open Directory account for smartcard attribute matching
dscl . -append /Users/${USERNAME} dsAttrTypeNative:smartCardIdentity "$COMMON_NAME - $UPN"
