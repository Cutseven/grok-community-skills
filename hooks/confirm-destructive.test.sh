#!/bin/sh
# Tests for confirm-destructive.sh. Run: sh hooks/confirm-destructive.test.sh
# Set NO_JQ=1 to exercise the fallback path that works without jq.
here=$(cd "$(dirname "$0")" && pwd)
hook="$here/confirm-destructive.sh"
pass=0; fail=0

json_cmd() {
  # JSON-encode a command string (escape backslashes and double quotes).
  esc=$(printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
  printf '{"hookEventName":"pre_tool_use","hook_event_name":"PreToolUse","cwd":"/tmp/project","toolName":"run_terminal_command","toolInput":{"command":"%s"}}' "$esc"
}

run_hook() {
  if [ -n "$NO_JQ" ]; then
    # Hide jq by running with a PATH that only has core utilities.
    d=$(mktemp -d)
    for t in cat grep sed printf; do p=$(command -v "$t" 2>/dev/null) && [ -n "$p" ] && [ "${p#/}" != "$p" ] && ln -s "$p" "$d/$t"; done
    json_cmd "$1" | PATH="$d" /bin/sh "$hook"
    rm -r "$d"
  else
    json_cmd "$1" | sh "$hook"
  fi
}

expect_ask() {
  out=$(run_hook "$1")
  case "$out" in
    *'"decision":"ask"'*) pass=$((pass+1)) ;;
    *) fail=$((fail+1)); echo "FAIL (expected ask): $1 -> $out" ;;
  esac
}

expect_none() {
  out=$(run_hook "$1")
  if [ -z "$out" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (expected no output): $1 -> $out"; fi
}

# Should ask
expect_ask 'rm -rf build'
expect_ask 'rm notes.txt'
expect_ask 'sudo rm -r /var/tmp/x'
expect_ask 'cd ~/Downloads && rm old.zip'
expect_ask 'find . -name "*.tmp" -delete'
expect_ask 'find /tmp -type f -exec rm {} \;'
expect_ask 'shred -u secret.txt'
expect_ask 'truncate -s 0 app.log'
expect_ask 'dd if=/dev/zero of=/dev/sdb bs=1M'
expect_ask 'mkfs.ext4 /dev/sdb1'
expect_ask 'diskutil eraseDisk APFS Backup disk4'
expect_ask 'git reset --hard HEAD~3'
expect_ask 'git clean -fdx'
expect_ask 'git push --force origin main'
expect_ask 'git push -f origin main'
expect_ask 'git push origin +main'
expect_ask 'git push origin :old-branch'
expect_ask 'git branch -D feature'
expect_ask 'git stash clear'
expect_ask 'rsync -a --delete ~/Photos/ /Volumes/Backup/Photos/'
expect_ask 'rclone sync ~/Documents remote:docs'
expect_ask 'rclone purge remote:old'
expect_ask 'restic -r /srv/repo forget --keep-last 3 --prune'
expect_ask 'borg prune --keep-daily 7 /backup'
expect_ask 'aws s3 rm s3://bucket/key'
expect_ask 'aws s3 sync . s3://bucket --delete'
expect_ask 'npx wrangler r2 bucket delete my-bucket'
expect_ask 'wrangler kv key delete --binding=KV mykey'
expect_ask 'curl -X DELETE https://api.cloudflare.com/client/v4/zones/abc/dns_records/def'
expect_ask 'curl --request DELETE https://example.com/item/1'
expect_ask 'terraform destroy'
expect_ask 'kubectl delete pod web-1'
expect_ask 'sendmail bob@example.com < msg.txt'
expect_ask 'echo hi | mail -s "Hello" bob@example.com'
expect_ask 'echo done; rm -f a.txt'
expect_ask 'bash -c "rm -rf dist"'

# Should not ask
expect_none 'ls -la'
expect_none 'git status'
expect_none 'git push origin main'
expect_none 'git push -u origin feature/rm-old'
expect_none 'git commit -m "update docs"'
expect_none 'npm install'
expect_none 'find . -name "*.md"'
expect_none 'rsync -a ~/Photos/ /Volumes/Backup/Photos/'
expect_none 'rclone copy ~/Documents remote:docs'
expect_none 'restic -r /srv/repo snapshots'
expect_none 'wrangler deploy'
expect_none 'wrangler r2 bucket list'
expect_none 'curl -s https://example.com/form'
expect_none 'grep -r "delete" src/'
expect_none 'cat ~/.bashrc'
expect_none 'python3 farm.py --dry-run'
expect_none 'echo "Trash folder"'

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
