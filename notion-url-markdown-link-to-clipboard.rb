#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy Notion URL Markdown Link
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Notion

# Documentation:
# @raycast.description Copy the current Notion app page's URL as a Markdown link to the clipboard
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

# Notion's Mac app is an Electron app without an AppleScript dictionary, so the
# page URL cannot be read directly. Instead we trigger Notion's "Copy link"
# shortcut (Cmd+L), which puts the URL on the clipboard, then read it back.
# Requires Accessibility permission for the runner (Raycast.app in production).

SENTINEL = "__notion_md_link_sentinel__"
POLL_TIMEOUT = 2.0
POLL_INTERVAL = 0.05

def notion_running?
  `osascript -e 'tell application "System Events" to (name of processes) contains "Notion"'`.strip == "true"
end

def clipboard
  `pbpaste`.force_encoding("UTF-8")
end

def copy_to_clipboard(content)
  IO.popen({ "LANG" => "ja_JP.UTF-8" }, "pbcopy", "w") { |clipboard| clipboard.write(content) }
end

def trigger_copy_link
  `osascript \
    -e 'tell application "Notion" to activate' \
    -e 'delay 0.3' \
    -e 'tell application "System Events" to keystroke "l" using {command down}'`
end

# Poll until the clipboard changes away from the sentinel, or time out.
def wait_for_url
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + POLL_TIMEOUT
  loop do
    value = clipboard
    return value unless value == SENTINEL
    break if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline

    sleep POLL_INTERVAL
  end
  nil
end

def notion_url?(value)
  value.match?(%r{\Ahttps?://[^/]*notion\.}i)
end

def clean_url(url)
  url.strip.split("?").first
end

def page_title
  `osascript -e 'tell application "System Events" to tell process "Notion" to get name of front window'`
    .force_encoding("UTF-8").strip
end

def abort_with(message)
  puts message
  exit 1
end

abort_with("Notion is not running") unless notion_running?

original = clipboard
copy_to_clipboard(SENTINEL)
trigger_copy_link
url = wait_for_url

unless url && notion_url?(url)
  copy_to_clipboard(original)
  abort_with("Could not get the Notion page URL")
end

markdown_link = "[#{page_title}](#{clean_url(url)})"
copy_to_clipboard(markdown_link)
puts "Copied: #{markdown_link}"
