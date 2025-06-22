#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Notion Inbox DB
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "text" }
# @raycast.packageName Notion Inbox DB

# Documentation:
# @raycast.description Notion Inbox DB
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "json"
require "net/http"
require "uri"

NOTION_VERSION = "2022-06-28"
NOTION_TOKEN = "YOUR_NOTION_TOKEN"
DATABASE_ID = "YOUR_DATABASE_ID"

def send_notion_db(title)
  uri = URI.parse("https://api.notion.com/v1/pages")
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{NOTION_TOKEN}"
  request["Notion-Version"] = NOTION_VERSION

  obj = {
    parent: {
      type: "database_id",
      database_id: DATABASE_ID
    },
    properties: {
      Name: {
        title: [
          {
            type: "text",
            text: {
              content: title.dup.force_encoding("UTF-8")
            }
          }
        ]
      }
    }
  }

  request.body = JSON.dump(obj)
  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
end

send_notion_db(ARGV[0])
