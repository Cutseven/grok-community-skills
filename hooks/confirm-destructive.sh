#!/bin/sh
# grok-community-skills (Grok edition exclusive): confirm-destructive PreToolUse hook.
#
# Reads the PreToolUse event JSON on stdin. If the shell command looks like it
# deletes, overwrites, force-pushes or sends something, it prints
#   {"decision":"ask","reason":"..."}
# so Grok shows its permission prompt, even in always-approve or auto mode.
# Anything else gets no output (no opinion), so the normal permission flow applies.
#
# It never denies, never rewrites the command, makes no network calls, and
# reads nothing but stdin. Any error exits 0 with no output (Grok hooks fail open).
# Turn it off in the /hooks tab (select it, press Space).

payload=$(cat 2>/dev/null) || exit 0
[ -n "$payload" ] || exit 0

cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$payload" | jq -r '.toolInput.command // .tool_input.command // empty' 2>/dev/null) || cmd=""
fi
# Without jq (or if parsing failed), match against the raw event JSON instead.
# Escaped newlines and tabs become spaces so command boundaries still match.
[ -n "$cmd" ] || cmd=$(printf '%s\n' "$payload" | sed 's/\\[nt]/ /g')

# A command word starts the string or follows whitespace, ; & | ( ` " ' or =.
B='(^|[[:space:];&|(`"'"'"'=])'
S='[[:space:]]'

reason=""
check() {
  [ -n "$reason" ] && return 0
  if printf '%s\n' "$cmd" | grep -Eq -- "$2"; then
    reason=$1
  fi
}

# Local files and disks
check "deletes files (rm)"                       "${B}rm${S}"
check "deletes files (find -delete / -exec rm)"  "${B}find${S}.*(${S}-delete|-exec${S}+rm${S})"
check "securely erases data"                     "${B}(shred|srm|wipe|wipefs)${S}"
check "truncates a file"                         "${B}truncate${S}"
check "writes raw data with dd"                  "${B}dd${S}.*of="
check "formats or repartitions a disk"           "${B}(mkfs(\.[a-z0-9]+)?|fdisk|sfdisk|parted)${S}|${B}diskutil${S}+(erase[A-Za-z]*|partitionDisk|zeroDisk|secureErase|apfs${S}+delete[A-Za-z]*)"
check "deletes files (Windows)"                  "${B}(Remove-Item|rd|rmdir|del|erase)${S}+.*(-Recurse|/s|/q|-Force)"
# Git history and working tree
check "discards git changes (reset --hard)"      "${B}git${S}+(.*${S})?reset${S}+(.*${S})?--hard"
check "deletes untracked files (git clean)"      "${B}git${S}+(.*${S})?clean${S}+(.*${S})?-[a-zA-Z]*[fdx]"
check "force-pushes git history"                 "${B}git${S}+(.*${S})?push${S}+(.*${S})?(--force|--mirror|--delete|-[a-zA-Z]*f(${S}|$)|:[^[:space:]]|\+[^[:space:]])"
check "deletes a git branch"                     "${B}git${S}+(.*${S})?branch${S}+(.*${S})?(-D|--delete${S}+--force)"
check "drops git stashes"                        "${B}git${S}+(.*${S})?stash${S}+(drop|clear)"
# Backups, sync and cloud storage
check "may delete files at the destination (rsync --delete)" "${B}rsync${S}.*--(delete|remove-source-files)"
check "deletes or mirrors with rclone"           "${B}rclone${S}+(.*${S})?(sync|move|delete|deletefile|purge|rmdir|rmdirs|cleanup|dedupe)(${S}|$)"
check "removes backup snapshots"                 "${B}(restic${S}+(.*${S})?(forget|prune)|borg${S}+(.*${S})?(delete|prune|compact)|tmutil${S}+delete[A-Za-z]*)"
check "deletes cloud storage objects"            "${B}(aws${S}+s3${S}+(rm|rb)|aws${S}+s3${S}+sync${S}.*--delete|aws${S}+s3api${S}+delete-[a-z-]+|gsutil${S}+(.*${S})?(rm|rb)|gcloud${S}+storage${S}+(rm|buckets${S}+delete)|az${S}+storage${S}+.*delete)"
# Cloudflare and other APIs
check "deletes Cloudflare resources (wrangler)"  "${B}wrangler${S}.*${S}(delete|purge|rollback)(${S}|$)"
check "sends an HTTP DELETE request"             "${B}(curl|http|https|xh)${S}.*(-X${S}*DELETE|--request${S}*=?DELETE|${S}DELETE${S})"
check "destroys infrastructure"                  "${B}(terraform|tofu)${S}+(.*${S})?(destroy|apply${S}.*-destroy)|${B}kubectl${S}+(.*${S})?delete${S}"
# Sending messages
check "sends email"                              "${B}(sendmail|mutt|mailx|msmtp|swaks)${S}|${B}mail${S}+-s"

[ -n "$reason" ] || exit 0

msg="grok-community-skills safety hook: this command $reason. Approve only if you meant to do this."
if command -v jq >/dev/null 2>&1; then
  jq -cn --arg r "$msg" '{decision:"ask",reason:$r}' 2>/dev/null && exit 0
fi
# The message has no quotes or backslashes, so it is safe to print as JSON.
printf '{"decision":"ask","reason":"%s"}\n' "$msg"
exit 0
