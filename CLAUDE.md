# CLAUDE.md

Guidance for Claude Code when working in this repository. See `README.md` for human-facing setup and script overview.

## Repository Overview

A collection of Raycast script commands for productivity workflows. Scripts are written in Ruby and Bash, integrating with Notion (HTTP API), Obsidian (filesystem / GitHub Contents API), and macOS (AppleScript).

## Development Commands

Ruby tooling runs through `mise exec --` (required).

```bash
mise exec -- bundle install                    # install deps
mise exec -- bundle exec rubocop               # lint
mise exec -- bundle exec rubocop -a            # autofix
mise exec -- ruby <script>.rb "test input"     # run a Ruby script
bash <script>.sh "test input"                  # run a bash script
```

There is no test suite — verify changes by running the script directly.

## Invariants Not Obvious From Code

- **Raycast metadata is required.** Every script starts with `@raycast.schemaVersion`, `@raycast.title`, `@raycast.mode`, and usually `@raycast.icon` / `@raycast.argument1` / `@raycast.description`. Missing metadata breaks Raycast import.
- **Scripts must be executable** (`chmod +x`). New scripts need the executable bit before Raycast will run them.
- **Secrets are placeholders.** Notion tokens, GitHub tokens, database / block IDs, and vault paths are written as `YOUR_*` placeholders. Replace them with your own values before use. Never commit real credentials.
- **Obsidian vault path** is a placeholder (`YOUR_*` / `path/to/your-vault`). Point it at your own vault.
- **Ruby scripts use `# frozen_string_literal: true`** at the top.
- **Style rules are enforced by RuboCop** (`.rubocop.yml`). Do not restate them here — run `rubocop` and trust it.

## Commit Conventions

- Conventional Commits in English (`feat:`, `fix:`, `refactor:`, `chore:`, etc.)
- **Never include the Claude Code attribution footer** in commit messages
- Keep messages focused on the "why"
