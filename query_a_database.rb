# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

NOTION_VERSION = '2022-06-28'
NOTION_TOKEN = 'YOUR_NOTION_TOKEN'
DATABASE_ID = 'YOUR_DATABASE_ID'

uri = URI.parse("https://api.notion.com/v1/databases/#{DATABASE_ID}/query")
request = Net::HTTP::Post.new(uri)
request['Authorization'] = "Bearer #{NOTION_TOKEN}"
request['Notion-Version'] = NOTION_VERSION
request['accept'] = 'application/json'
request['content-type'] = 'application/json'

body = {
  filter: {
    property: 'tag',
    relation: {
      contains: 'your_tag'
    }
  }
}

request.body = JSON.dump(body)
response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end

puts response.body
