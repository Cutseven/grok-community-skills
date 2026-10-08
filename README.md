# Grok Community Skills

Ten free, MIT-licensed agent skills for Grok Build. The skills are instructions only: no MCP servers and no scripts. Each skill uses whatever tools your agent already has (email/calendar connectors, file access, shell) and asks before doing anything irreversible. The plugin also ships two optional [Grok edition exclusive](#grok-edition-exclusive) extras: a safety hook and a read-only subagent.

Using Claude, Codex, Cursor, Copilot, Gemini CLI or a plain chatbot? The same ten skills are available in the open Agent Skills format, with copy-paste prompts, at [Cutseven/community-agent-skills](https://github.com/Cutseven/community-agent-skills).

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

From the xAI plugin marketplace, once it's listed there (submitted in [xai-org/plugin-marketplace#1276](https://github.com/xai-org/plugin-marketplace/pull/1276), pending review):

```bash
grok plugin install grok-community-skills --trust
```

Or straight from this repository:

```bash
grok plugin install Cutseven/grok-community-skills --trust
```

Grok asks for `--trust` because the plugin includes a hook (see below). Plugins are off until enabled: press `Space` on it in the Plugins tab (`/plugins`), or add it to `[plugins].enabled`. See [Skills, Plugins, and Marketplaces](https://docs.x.ai/build/features/skills-plugins-marketplaces).

```
.grok-plugin/plugin.json             # manifest
skills/<slug>/SKILL.md               # one skill per folder (name + description frontmatter)
hooks/hooks.json                     # Grok edition exclusive: confirm-destructive hook
hooks/confirm-destructive.sh         #   the hook script (POSIX sh, optional jq)
hooks/confirm-destructive.test.sh    #   its tests: sh hooks/confirm-destructive.test.sh
agents/untrusted-content-reader.md   # Grok edition exclusive: read-only subagent
```

## Safety

Every skill follows the same rules: it never sends, posts, deletes, moves, or overwrites anything until you've seen exactly what will happen and said yes. Content from emails, files, and web pages is treated as data, never as instructions.

## Grok edition exclusive

These two extras use Grok Build plugin features and are not part of the open Agent Skills standard, so they aren't in the [any-agent edition](https://github.com/Cutseven/community-agent-skills). They don't change how the ten skills behave; they back up the same safety rules.

### Confirm-destructive hook

A `PreToolUse` hook on shell commands ([`hooks/hooks.json`](hooks/hooks.json), [`hooks/confirm-destructive.sh`](hooks/confirm-destructive.sh)). When a command looks like it deletes, overwrites, force-pushes or sends something, the hook answers `ask`, so Grok shows its permission prompt with the reason, even in always-approve or auto mode. Examples: `rm`, `find -delete`, `shred`, `truncate`, `dd of=`, `mkfs`, `git reset --hard`, `git clean -f`, `git push --force`, `rsync --delete`, `rclone sync/purge`, `restic forget/prune`, `aws s3 rm`, `wrangler … delete`, `curl -X DELETE`, `terraform destroy`, `sendmail`/`mail -s`.

- It never blocks or rewrites a command. Approving the prompt runs it as normal; for every other command it gives no opinion.
- It applies to every shell command while the plugin is enabled and trusted, not only to these skills. It may occasionally ask about a harmless command (for example `git rm`).
- It is a safety net, not a sandbox: pattern matching can't catch every destructive command, and Grok hooks fail open (if the script errors or times out, the command proceeds). A client that auto-answers every prompt (full YOLO mode) still auto-approves, and in `dontAsk` mode an `ask` becomes a denial.
- It makes no network calls and reads nothing but the hook event on stdin. It uses `jq` when available and falls back to plain `grep`/`sed` otherwise.
- Turn it off any time: open `/hooks`, select it and press `Space`.

Docs: [Hooks](https://docs.x.ai/build/features/hooks), and the Grok Build user guide on [`ask` decisions and plugin hook variables](https://github.com/xai-org/grok-build/blob/main/crates/codegen/xai-grok-pager/docs/user-guide/10-hooks.md).

### Untrusted-content reader subagent

A plugin subagent ([`agents/untrusted-content-reader.md`](agents/untrusted-content-reader.md)) for reading web pages, downloaded files, email exports and documents from other people. Its tool allowlist is `read_file`, `list_dir`, `grep`, `web_fetch` and `web_search`; shell, file edits, MCP connectors (`search_tool`/`use_tool`, `mcpInheritance: none`) and spawning other agents are disallowed. It returns a neutral summary or the facts you asked for, quotes any instructions hidden in the content, and lists phishing or scam signals, so prompt-injection text has nothing to act through.

Ask for it by name, for example: "Use the untrusted-content-reader agent to summarise https://example.com/article and tell me if it asks me to do anything." Grok may also choose it on its own (it sees the agent's description) when a skill like `context-translator-summarizer` or `smart-inbox-triage` needs to read untrusted content. Plugin agents can be spawned as `grok-community-skills:untrusted-content-reader`.

Docs: [Subagents](https://docs.x.ai/build/features/subagents), the user guide on [subagents and plugin agents](https://github.com/xai-org/grok-build/blob/main/crates/codegen/xai-grok-pager/docs/user-guide/16-subagents.md), and the [agent definition reference](https://github.com/xai-org/grok-build/blob/main/crates/codegen/xai-grok-agent/README.md).

## Disclaimer

These are unofficial community skills. They are not made by, affiliated with, or endorsed by xAI, Cloudflare, Google, or any other company whose products they mention. Product names are used only to describe what a skill works with.

The skills are provided as-is, without warranty (see [LICENSE](LICENSE)). Review a skill before you use it, and take extra care before letting any AI agent act on live accounts, production infrastructure, or important data. You are responsible for what your agent does with them.

Built by Gustavo Cadena with help from AI tools.

## License

MIT © Gustavo Cadena. See [LICENSE](LICENSE).
