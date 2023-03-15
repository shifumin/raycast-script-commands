#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Navigate to the shortest Amazon URL
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Amazon

# Documentation:
# @raycast.description Navigate to the shortest Amazon URL
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

# Get the current URL from the active Chrome tab
url=$(osascript -e 'tell application "Google Chrome" to get URL of active tab of window 1')

# Extract the Amazon product ID from the URL using regular expressions
regex='dp/([A-Z0-9]{10})'
if [[ $url =~ $regex ]]; then
    product_id=${BASH_REMATCH[1]}
    amazon_url="https://www.amazon.co.jp/dp/$product_id"
    echo "Opening $amazon_url"
    osascript -e "tell application \"Google Chrome\" to tell front window to set URL of active tab to \"$amazon_url\""
else
    echo "No Amazon product ID found in URL: $url"
fi
