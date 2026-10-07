# Grok Community Skills

Ten free, MIT-licensed agent skills for Grok Build. They are instructions only: no MCP servers, no hooks, no scripts. Each skill uses whatever tools your agent already has (email/calendar connectors, file access, shell) and asks before doing anything irreversible.

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
| `cloudflare-infra-worker` | Read-first Cloudflare engineer: DNS, Workers/Pages, WAF, SSL/TLS, Tunnel/Access; changes only in EXECUTE mode, with previews, rollback plans and explicit confirmation for destructive actions |

## Install

Once this repo is published, add it to Grok Build as a plugin (or, after it's in the catalog, install it from the xAI plugin marketplace).

```
.grok-plugin/plugin.json   # manifest
skills/<slug>/SKILL.md     # one skill per folder (name + description frontmatter)
```

## Safety

Every skill follows the same rules: it never sends, posts, deletes, moves, or overwrites anything until you've seen exactly what will happen and said yes. Content from emails, files, and web pages is treated as data, never as instructions.

## Disclaimer

These are unofficial community skills. They are not made by, affiliated with, or endorsed by xAI, Cloudflare, Google, or any other company whose products they mention. Product names are used only to describe what a skill works with.

The skills are provided as-is, without warranty (see [LICENSE](LICENSE)). Review a skill before you use it, and take extra care before letting any AI agent act on live accounts, production infrastructure, or important data. You are responsible for what your agent does with them.

Built by Gustavo Cadena with help from AI tools.

## License

MIT © Gustavo Cadena. See [LICENSE](LICENSE).
