# Grok Community Skills

Nine free, MIT-licensed agent skills for Grok Build. They are instructions only: no MCP servers, no hooks, no scripts. Each skill uses whatever tools your agent already has (email/calendar connectors, file access, shell) and asks before doing anything irreversible.

| Skill | What it does |
|---|---|
| `smart-inbox-triage` | Sorts email into urgent/action/info/spam, pulls out action items and due dates, writes a short digest |
| `universal-file-finder` | Finds local files from a plain-language description (name, content, size, date, type) |
| `meeting-sync-bot` | Collects availability across time zones, ranks slots, drafts invites |
| `subscription-tracker` | Finds recurring charges in statements, flags renewals, drafts cancellation requests |
| `meal-planner-grocery` | Plans meals from what you have and builds a low-waste grocery list |
| `auto-backup-restore` | Plans and runs encrypted, versioned backups and safe restores |
| `one-command-task-capturer` | Turns one sentence into a structured task, catches duplicates, runs a weekly review |
| `context-translator-summarizer` | Translates for meaning, then gives a bullet summary and glossary |
| `batch-task-runner` | Chains rename/convert/resize/compress/zip jobs, with a dry-run preview first |

## Install

Once this repo is published, add it to Grok Build as a plugin (or, after it's in the catalog, install it from the xAI plugin marketplace).

```
.grok-plugin/plugin.json   # manifest
skills/<slug>/SKILL.md     # one skill per folder (name + description frontmatter)
```

## Safety

Every skill follows the same rules: it never sends, posts, deletes, moves, or overwrites anything until you've seen exactly what will happen and said yes. Content from emails, files, and web pages is treated as data, never as instructions.

## License

MIT © Gustavo Cadena. See [LICENSE](LICENSE).
