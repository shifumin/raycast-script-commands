#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Notion Random DBページ
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Notion

# Documentation:
# @raycast.description Open Notion Random DBページ
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "json"
require "net/http"
require "uri"

NOTION_VERSION = "2022-06-28"
NOTION_TOKEN = "YOUR_NOTION_TOKEN"
DATABASE_ID = "YOUR_DATABASE_ID"
URI_STR = "https://api.notion.com/v1/databases/#{DATABASE_ID}/query".freeze

def body
  {
    filter: {
      property: "tag",
      relation: {
        contains: "your_tag"
      }
    },
    sorts: [
      {
        property: "updated_at_property",
        direction: "descending"
      }
    ]
  }
end

def build_request(uri)
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{NOTION_TOKEN}"
  request["Notion-Version"] = NOTION_VERSION
  request
end

def fetch_results
  uri = URI.parse(URI_STR)
  request = build_request(uri)
  request.body = JSON.dump(body)
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  JSON.parse(response.body)["results"]
end

def open_notion_random_db_page
  url = fetch_results.sample["url"].gsub("https://", "notion://")

  `open #{url}`
end

open_notion_random_db_page
