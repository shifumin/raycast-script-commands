#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "json"
require "net/http"
require "uri"

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Append to Obsidian Inbox Chrome URL Markdown Link
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.packageName Append to Obsidian Inbox Chrome URL Markdown Link

# Documentation:
# @raycast.description Obsidian の inbox.md に Chrome の URL の Markdown リンクを追記する
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

GITHUB_TOKEN = "YOUR_GITHUB_TOKEN"
REPO = "YOUR_GITHUB_USER/your-vault"
FILE_PATH = "inbox.md"
BRANCH = "main"
GITHUB_API = "https://api.github.com"
GITHUB_API_VERSION = "2022-11-28"
VAULT_PATH = File.join(Dir.home, "path/to/your-vault")

# Chrome のアクティブタブのタイトルを取得する
# @return [String] ページタイトル
def chrome_page_title
  script = 'tell application "Google Chrome" to get title of active tab of first window'
  `osascript -e '#{script}'`.strip.force_encoding("UTF-8")
end

# Chrome のアクティブタブのURLを取得する
# @return [String] ページURL
def page_url
  `osascript -e 'tell application "Google Chrome" to get URL of active tab of first window'`.strip
end

# URLがYouTubeかどうかを判定する
# @param [String] url 判定対象のURL
# @return [Boolean] YouTubeのURLの場合true
def youtube_url?(url)
  uri = URI.parse(url)
  host = uri.host&.downcase || ""
  host.end_with?("youtube.com", ".youtube.com") || host == "youtu.be"
rescue URI::InvalidURIError
  false
end

# YouTube oEmbed APIを使用して動画タイトルを取得する
# @param [String] url YouTubeの動画URL
# @return [String, nil] 動画タイトル、取得失敗時はnil
def fetch_youtube_title(url)
  oembed_url = URI.parse("https://www.youtube.com/oembed?url=#{URI.encode_www_form_component(url)}&format=json")
  response = Net::HTTP.get_response(oembed_url)
  return nil unless response.is_a?(Net::HTTPSuccess)

  data = JSON.parse(response.body)
  data["title"]
rescue StandardError
  nil
end

# ページタイトルを取得する（YouTubeの場合はoEmbed APIを使用）
# @param [String] url ページURL
# @return [String] ページタイトル
def page_title(url)
  if youtube_url?(url)
    fetch_youtube_title(url) || chrome_page_title
  else
    chrome_page_title
  end
end

# Markdown リンク形式のテキストを生成する
# @param [String] title ページタイトル
# @param [String] url ページURL
# @return [String] Markdown リンク形式のテキスト
def markdown_link(title, url)
  escaped_title = title.gsub("[", "\\[").gsub("]", "\\]")
  escaped_url = url.gsub(")", "%29")
  "[#{escaped_title}](#{escaped_url})"
end

# 現在時刻を取得する
# @return [String] フォーマットされた現在時刻
def current_time
  Time.now.strftime("%Y-%m-%d %H:%M")
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

# GitHub Contents API 経由で inbox.md に Markdown リンクを追記する
# @param [String] link Markdown リンク
# @param [String] time 現在時刻
# @raise [SystemExit] エラー発生時は exit 1
def append_via_github_api(link, time)
  file_data = fetch_inbox
  current_content = Base64.decode64(file_data["content"]).force_encoding("UTF-8")
  new_line = "- #{link}\n".dup.force_encoding("UTF-8") # rubocop:disable Style/RedundantInterpolationUnfreeze
  update_inbox(current_content + new_line, file_data["sha"], time)
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

url = page_url
title = page_title(url)
link = markdown_link(title, url)
append_via_github_api(link, current_time)
pull_local
