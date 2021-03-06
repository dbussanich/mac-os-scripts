#!/usr/bin/env zsh

function smartCardPrompt() {
  osascript <<EOT
    tell app "System Events"
      display dialog "$1" buttons {"OK"} default button 1 with title "PIV Pair Utility"
      return  -- Suppress result
    end tell
EOT
}


# If /etc/SmartcardLogin.plist does not exist, copy to /etc
SC_PLIST=/etc/SmartcardLogin.plist

if [ ! -f $SC_PLIST ]; then
    cp ./SmartcardLogin.plist /etc
    chmod 644 $SC_PLIST
fi

# Prompt to insert smart card. Sleep to allow time for PIV card to be read.
smartCardPrompt "Please insert PIV card."
sleep 4

# Get PIV fingerprint hash
HASH=`/usr/bin/security list-smartcards | awk -F ':' '/com.apple.pivtoken/{print $2}'`

# If PIV card is not initially read, enter while loop.
while [ -z "$HASH" ]; do 
    sleep 4
    HASH=`/usr/bin/security list-smartcards | awk -F ':' '/com.apple.pivtoken/{print $2}'`
    if [ -z "$HASH" ]; then
        smartCardPrompt "PIV Card not read, please try again."
    fi
done

# Get user certificate keyed off of fingerprint hash
/usr/sbin/system_profiler SPSmartCardsDataType | grep -A8 "$HASH" \
    | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/ {print; count++; if (count==3) exit}' \
    | fold -w67 > /tmp/temp.pem

# Get UPN and Common Name from the certificate
UPN=`/usr/bin/openssl x509 -noout -text -in /tmp/temp.pem | awk -F ':' '/email/ {print $2}'`
CURRENT_OPEN_DIRECTORY_VALUE=`dscl . -read /Users/m1dab01 dsAttrTypeNative:smartCardIdentity | awk '{print $2}'`

if [ "$UPN" = "$CURRENT_OPEN_DIRECTORY_VALUE" ]; then
    smartCardPrompt "Pairing already complete."
    return 0
fi    

# Add attribute to user's Open Directory account for smartcard attribute matching
dscl . -append /Users/${USERNAME} dsAttrTypeNative:smartCardIdentity "$UPN"

# Ensure that attribute was successfully added to user's account
POST_PAIR_VALUE=`dscl . -read /Users/${USERNAME} dsAttrTypeNative:smartCardIdentity | awk '{print $2}'`

if [ "$UPN" != "$POST_PAIR_VALUE" ]; then
    smartCardPrompt "Pairing failed, please contact Board Help Desk."
    return 1
fi  

# If successful, prompt complete
smartCardPrompt "PIV pairing complete."