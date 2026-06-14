#!/usr/bin/env ruby
# frozen_string_literal: true

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Obsidian Weekly Note
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📅
# @raycast.packageName Obsidian

# Documentation:
# @raycast.description Open the current week's note in Obsidian
# @raycast.author shifumin
# @raycast.authorURL https://github.com/shifumin

require "date"
require "uri"

def current_week_note_name
  today = Date.today
  year = today.year
  week_number = today.strftime("%V").to_i
  "#{year}-W#{week_number}"
end

def obsidian_vault_path
  File.expand_path("~/path/to/your-vault")
end

def weekly_note_path
  "weekly/#{current_week_note_name}"
end

def open_obsidian_note
  vault_name = "your-vault"
  note_path = weekly_note_path

  vault_encoded = URI.encode_www_form_component(vault_name)
  file_encoded = URI.encode_www_form_component(note_path)
  obsidian_uri = "obsidian://open?vault=#{vault_encoded}&file=#{file_encoded}"

  system("open", obsidian_uri)
end

open_obsidian_note
