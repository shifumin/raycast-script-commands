#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy URL Markdown Link
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Clipboard

# Documentation:
# @raycast.description Copy the active Google Chrome tab's URL as a Markdown link to the clipboard
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "shellwords"

def name
  puts `echo $LANG`
  `osascript -e 'tell application "Google Chrome" to get Name of active tab of first window'`.strip
end

def url
  `osascript -e 'tell application "Google Chrome" to get URL of active tab of first window'`.strip
end

def markdown_link
  "[#{name}](#{url})"
end

def copy_to_clipboard(content)
  IO.popen({ "LANG" => "ja_JP.UTF-8" }, "pbcopy", "w") { |clipboard| clipboard.write(content) }
end

copy_to_clipboard(markdown_link)
