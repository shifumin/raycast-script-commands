#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Append to Obsidian Inbox
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.argument1 { "type": "text", "placeholder": "inboxを追加" }
# @raycast.packageName Append to Obsidian Inbox

# Documentation:
# @raycast.description Obsidian の inbox.md に追記する
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "base64"
require "json"
require "net/http"
require "uri"

GITHUB_TOKEN = "YOUR_GITHUB_TOKEN"
REPO = "YOUR_GITHUB_USER/your-vault"
FILE_PATH = "inbox.md"
BRANCH = "main"
GITHUB_API = "https://api.github.com"
GITHUB_API_VERSION = "2022-11-28"
VAULT_PATH = File.join(Dir.home, "path/to/your-vault")

# 現在時刻を取得する
# @return [String] フォーマットされた現在時刻
def current_time
  Time.now.strftime("%Y-%m-%d %H:%M")
end

# 現在時刻とテキストを結合してフォーマットする
# @param [String] text テキスト
# @param [String] time 現在時刻
# @return [String] 現在時刻とテキストを結合したフォーマット済文字列
# @example
#   formatted_text("テキスト", "2023-04-01 15:30") #=> "2023-04-01 15:30 テキスト"
def formatted_text(text, time)
  "#{time} #{text}".dup.force_encoding("UTF-8") # rubocop:disable Style/RedundantInterpolationUnfreeze
end

# GitHub API リクエストに共通ヘッダを設定する
# @param [Net::HTTPRequest] request リクエストオブジェクト
# @return [void]
def apply_github_headers(request)
  request["Authorization"] = "Bearer #{GITHUB_TOKEN}"
  request["Accept"] = "application/vnd.github+json"
  request["X-GitHub-Api-Version"] = GITHUB_API_VERSION
end

# Contents API で inbox.md の現状を取得する
# @return [Hash] sha と base64 エンコードされた content を含むレスポンス
# @raise [RuntimeError] リクエストが失敗した場合
# @see https://docs.github.com/en/rest/repos/contents#get-repository-content
def fetch_inbox
  uri = URI.parse("#{GITHUB_API}/repos/#{REPO}/contents/#{FILE_PATH}?ref=#{BRANCH}")
  request = Net::HTTP::Get.new(uri)
  apply_github_headers(request)
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  raise "GitHub get contents failed: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)
end

# Contents API で inbox.md を上書き更新する
# @param [String] new_content 新しいファイル全体の内容（プレーンテキスト）
# @param [String] sha 直前の取得で得た blob の sha
# @param [String] time コミットメッセージに使う現在時刻
# @return [void]
# @raise [RuntimeError] リクエストが失敗した場合
# @see https://docs.github.com/en/rest/repos/contents#create-or-update-file-contents
def update_inbox(new_content, sha, time)
  uri = URI.parse("#{GITHUB_API}/repos/#{REPO}/contents/#{FILE_PATH}")
  request = Net::HTTP::Put.new(uri)
  request.content_type = "application/json"
  apply_github_headers(request)
  request.body = JSON.dump(
    message: "chore: update inbox.md #{time}",
    content: Base64.strict_encode64(new_content),
    sha: sha,
    branch: BRANCH
  )
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  raise "GitHub put contents failed: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)
end

# GitHub Contents API 経由で inbox.md に追記する
# @param [String] text 追記するテキスト
# @param [String] time 現在時刻
# @raise [SystemExit] エラー発生時は exit 1
def append_via_github_api(text, time)
  file_data = fetch_inbox
  current_content = Base64.decode64(file_data["content"]).force_encoding("UTF-8")
  updated_content = "#{current_content}- #{formatted_text(text, time)}\n"
  update_inbox(updated_content, file_data["sha"], time)
rescue StandardError => e
  puts "GitHub API操作中にエラーが発生しました: #{e.message}"
  exit 1
end

# ローカル vault をリモートと同期する
# @return [void]
# @raise [SystemExit] git pull が失敗した場合は exit 1
def pull_local
  Dir.chdir(VAULT_PATH) do
    system("git", "pull", "--quiet") || raise("git pull failed")
  end
rescue StandardError => e
  puts "git pull 中にエラーが発生しました: #{e.message}"
  exit 1
end

time = current_time
append_via_github_api(ARGV[0], time)
pull_local
