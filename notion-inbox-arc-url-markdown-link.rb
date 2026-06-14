#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Notion Inbox Arc URL Markdown Link
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Notion

# Documentation:
# @raycast.description Notion Inbox URL Markdown from Arc Browser
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "json"
require "net/http"
require "uri"

NOTION_VERSION = "2022-06-28"
NOTION_TOKEN = "YOUR_NOTION_TOKEN"
BLOCK_ID = "YOUR_BLOCK_ID"

def name
  `osascript -e 'tell application "Arc" to get title of active tab of first window'`
end

def url
  `osascript -e 'tell application "Arc" to get URL of active tab of first window'`
end

def object
  {
    children: [
      {
        object: "block",
        type: "bulleted_list_item",
        bulleted_list_item: {
          rich_text: [{
            type: "text",
            text: {
              content: name.strip.force_encoding("UTF-8"),
              link: {
                type: "url",
                url: url
              }
            }
          }]
        }
      }
    ]
  }
end

def send_notion_page
  url = URI.parse("https://api.notion.com/v1/blocks/#{BLOCK_ID}/children")
  request = Net::HTTP::Patch.new(url)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{NOTION_TOKEN}"
  request["Notion-Version"] = NOTION_VERSION

  request.body = JSON.dump(object)
  Net::HTTP.start(url.hostname, url.port, use_ssl: true) do |http|
    http.request(request)
  end
end

send_notion_page
