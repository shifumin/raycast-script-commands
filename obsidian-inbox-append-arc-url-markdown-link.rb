#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Append to Obsidian Inbox Arc URL Markdown Link
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.packageName Append to Obsidian Inbox Arc URL Markdown Link

# Documentation:
# @raycast.description Obsidian の inbox.md に Arc Browser の URL の Markdown リンクを追記する
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

# Configuration: Update this path to your Obsidian vault
VAULT_PATH = "/path/to/your/obsidian/vault"
INBOX_FILE = "inbox.md"
INBOX_PATH = File.join(VAULT_PATH, INBOX_FILE)

# Arc Browser のアクティブタブのタイトルを取得する
# @return [String] ページタイトル
def page_title
  `osascript -e 'tell application "Arc" to get title of active tab of first window'`.strip.force_encoding("UTF-8")
end

# Arc Browser のアクティブタブのURLを取得する
# @return [String] ページURL
def page_url
  `osascript -e 'tell application "Arc" to get URL of active tab of first window'`.strip
end

# Markdown リンク形式のテキストを生成する
# @param [String] title ページタイトル
# @param [String] url ページURL
# @return [String] Markdown リンク形式のテキスト
def markdown_link(title, url)
  "[#{title}](#{url})"
end

# 現在時刻を取得する
# @return [String] フォーマットされた現在時刻
def current_time
  Time.now.strftime("%Y-%m-%d %H:%M")
end

# Obsidian の Inbox ノートに Markdown リンクを追記する
# @param [String] link Markdown リンク
# @raise [StandardError] ファイル書き込み中にエラーが発生した場合
def append_to_inbox(link)
  unless File.exist?(INBOX_PATH)
    puts "Error: Inbox file not found at #{INBOX_PATH}"
    puts "Please update the VAULT_PATH constant to point to your Obsidian vault"
    exit 1
  end

  File.open(INBOX_PATH, "a") do |file|
    file.puts "- #{link}"
  end
rescue StandardError => e
  puts "エラーが発生しました: #{e.message}"
  exit 1
end

# inbox.mdをgit管理下に追加、コミット、プッシュする
# @param [String] time 現在時刻
# @raise [RuntimeError] git操作が失敗した場合
def commit_and_push_inbox(time)
  commit_message = "chore: update inbox.md #{time}"

  Dir.chdir(VAULT_PATH) do
    system("git", "pull") || raise("git pull failed")
    system("git", "add", INBOX_FILE) || raise("git add failed")
    system("git", "commit", "-m", commit_message) || raise("git commit failed")
    system("git", "push") || raise("git push failed")
  end
rescue StandardError => e
  puts "Git操作中にエラーが発生しました: #{e.message}"
  exit 1
end

link = markdown_link(page_title, page_url)
append_to_inbox(link)
commit_and_push_inbox(current_time)
