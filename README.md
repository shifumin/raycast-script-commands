# raycast-script-commands

A collection of [Raycast](https://www.raycast.com/) script commands for productivity workflows — integrating Notion, Obsidian, and macOS.

## Requirements

- macOS with [Raycast](https://www.raycast.com/)
- Ruby (version managed via [mise](https://mise.jdx.dev/) — see `mise.toml`)
- Bundler

## Installation

```bash
git clone https://github.com/shifumin/raycast-script-commands.git
cd raycast-script-commands
mise exec -- bundle install
```

Then import into Raycast:

1. Open Raycast → Settings → Extensions → Script Commands
2. Click **Add Script Directory** and select this repository

## Configuration

All credentials and paths are written as `YOUR_*` placeholders. **Replace them with your own values before use** — open each script and edit the constants near the top:

- **Notion scripts** — `NOTION_TOKEN` and a `DATABASE_ID` / `BLOCK_ID`
- **Obsidian (GitHub Contents API) scripts** — `GITHUB_TOKEN`, `REPO`, and `VAULT_PATH`
- **Obsidian launcher** — the vault name / path

Never commit real credentials.

## Script Categories

Every script has a `@raycast.description` header explaining what it does. Open each file for exact behavior.

### Notion

Ruby scripts hitting the Notion HTTP API:

- **Inbox** — append text, timestamped notes, a database entry, or a browser tab as a markdown link (`notion-inbox-*.rb`)
- **Reading memo** — create a reading-quote note (`notion-reading-memo.rb`)
- **Random page opener** — open a random page from a database (`open-notion-random-db-page.rb`)
- **Clipboard** — copy the current Notion app page as a markdown link (`notion-url-markdown-link-to-clipboard.rb`)

### Obsidian

- **Inbox** — append text or a Chrome tab as a markdown link to `inbox.md` via the GitHub Contents API (`append-to-obsidian-inbox*.rb`)
- **Weekly note** — open the current week's note (`open-obsidian-weekly-note.rb`)

### Utilities

- `url-markdown-link-to-clipboard.rb` — copy the active Chrome tab's URL as a markdown link
- `navigate-to-the-shortest-amazon-url.sh` — shorten Amazon product URLs

## Development

```bash
mise exec -- bundle exec rubocop       # lint
mise exec -- bundle exec rubocop -a    # autofix
mise exec -- ruby <script>.rb "input"  # run a Ruby script
bash <script>.sh "input"               # run a Bash script
```

Style rules live in `.rubocop.yml`. New scripts need the executable bit (`chmod +x`) and a complete `@raycast.*` metadata header.

## License

See [LICENSE](LICENSE).
