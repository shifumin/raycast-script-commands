#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Notion DB読書引用メモ (タイトル)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "text" }
# @raycast.packageName Notion

# Documentation:
# @raycast.description Notion DB読書引用メモ (タイトル)
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "json"
require "net/http"
require "uri"

NOTION_VERSION = "2022-06-28"
NOTION_TOKEN = "YOUR_NOTION_TOKEN"
DATABASE_ID = "YOUR_DATABASE_ID" # 読書引用メモを記録するデータベースのID
BOOK_TITLE = "BOOK TITLE"
AUTHOR = "AUTHOR NAME"

def build_request(uri)
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{NOTION_TOKEN}"
  request["Notion-Version"] = NOTION_VERSION
  request
end

def properties(content)
  {
    "📙  Book Title": { select: { name: BOOK_TITLE } },
    "✍🏼  Author": { select: { name: AUTHOR } },
    "📝  Highlight": {
      title: [
        { text: { content: content.dup.force_encoding("UTF-8") } }
      ]
    }
  }
end

def body(content)
  {
    parent: {
      type: "database_id",
      database_id: DATABASE_ID
    },
    properties: properties(content)
  }
end

def send_notion_db(content)
  uri = URI.parse("https://api.notion.com/v1/pages")
  request = build_request(uri)
  request.body = JSON.dump(body(content))
  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
end

send_notion_db(ARGV[0])
