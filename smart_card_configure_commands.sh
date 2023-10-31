#!/usr/bin/env zsh

# Scripts below configures smart card on macOS

# Enable smart card logging
sudo defaults write /Library/Preferences/com.apple.security.smartcard Logging -bool true

# Enable smart card ONLY user authorization for login
sudo defaults write /Library/Preferences/com.apple.security.smartcard enforceSmartCard -bool true
