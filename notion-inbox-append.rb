#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Notion Inbox Page
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "text" }
# @raycast.packageName Notion Inbox Page

# Documentation:
# @raycast.description Notion Inbox Page
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "json"
require "net/http"
require "uri"

NOTION_VERSION = "2022-06-28"
NOTION_TOKEN = "YOUR_NOTION_TOKEN"
BLOCK_ID = "YOUR_BLOCK_ID"

# @param [String] text テキスト
# @return [Hash] Notion APIのpatch-block-childrenに送信するためのHashオブジェクト
# @see https://developers.notion.com/reference/patch-block-children
def object(text)
  {
    children: [
      object: "block",
      type: "bulleted_list_item",
      bulleted_list_item: {
        rich_text: [{
          type: "text",
          text: {
            content: text.dup.force_encoding("UTF-8")
          }
        }]
      }
    ]
  }
end

# @param [String] text Notionのページに追加するテキスト
# @return [Net::HTTPResponse] NotionのAPIからのレスポンス
# @see https://developers.notion.com/reference/patch-block-children
def send_notion_page(text)
  uri = URI.parse("https://api.notion.com/v1/blocks/#{BLOCK_ID}/children")
  request = Net::HTTP::Patch.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{NOTION_TOKEN}"
  request["Notion-Version"] = NOTION_VERSION

  request.body = JSON.dump(object(text))
  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
end

send_notion_page(ARGV[0])
