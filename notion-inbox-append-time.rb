#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Notion Inbox Append Time
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "text" }
# @raycast.packageName Notion Inbox Append Time

# Documentation:
# @raycast.description Notion Inbox Append Time
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "json"
require "net/http"
require "uri"

NOTION_VERSION = "2022-06-28"
NOTION_TOKEN = "YOUR_NOTION_TOKEN"
BLOCK_ID = "YOUR_BLOCK_ID"

# @param [String] text テキスト
# @return [String] 現在時刻とテキストを結合したフォーマット済文字列
# @example
#   formatted_text("テキスト") #=> "2023-04-01 15:30 テキスト"
def formatted_text(text)
  current_time = Time.now.strftime("%Y-%m-%d %H:%M")
  "#{current_time} #{text}".dup.force_encoding("UTF-8") # rubocop:disable Style/RedundantInterpolationUnfreeze
end

# @param [String] text テキスト
# @return [Hash] Notion APIのpatch-block-childrenに送信するためのHashオブジェクト
# @see https://developers.notion.com/reference/patch-block-children
def object(text)
  {
    children: [
      {
        object: "block",
        type: "bulleted_list_item",
        bulleted_list_item: {
          rich_text: [{
            type: "text",
            text: {
              content: formatted_text(text)
            }
          }]
        }
      }
    ]
  }
end

# @param [String] text Notionのページに追記するテキスト
# @return [Net::HTTPResponse] Notion APIからのレスポンス
# @see https://developers.notion.com/reference/patch-block-children
def send_notion_block(text)
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

send_notion_block(ARGV[0])
