#!/usr/bin/env bash
# Moves the lazychat formula to lazychat's newest release, or to the one
# named: its archive's url and sha256, nothing else, and a commit when they
# changed. The tap's workflow runs it every hour; run it here when GitHub
# cannot. Pushing is left to the caller.
#   ./update.sh            the newest release
#   ./update.sh 1.0.3      that release
#   ./update.sh --dry-run  say what would change, change nothing
set -euo pipefail
cd "$(dirname "$0")"

repo=Perpeer/lazychat
formula=Formula/lazychat.rb
dry=0 v=""
for a in "$@"; do
  case "$a" in
    --dry-run) dry=1 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) v="${a#v}" ;;
  esac
done

if [ -z "$v" ]; then
  # Read without a token: the repository is public.
  v="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | sed -n 's/.*"tag_name": *"v\{0,1\}\([0-9][0-9.]*\)".*/\1/p' | head -n 1)"
  [ -n "$v" ] || { echo "update.sh: GitHub named no newest release of $repo" >&2; exit 1; }
fi

url="https://github.com/$repo/archive/refs/tags/v$v.tar.gz"
have="$(sed -n 's/^  url "\(.*\)"$/\1/p' "$formula")"
if [ "$have" = "$url" ]; then
  echo "current     lazychat $v"
  exit 0
fi
was="$(sed -n 's|.*/tags/v\(.*\)\.tar\.gz|\1|p' <<<"$have")"

sum="$(curl -fsSL "$url" | shasum -a 256 | cut -d' ' -f1)" || true
empty="$(printf '' | shasum -a 256 | cut -d' ' -f1)"
if [ -z "$sum" ] || [ "$sum" = "$empty" ]; then
  echo "update.sh: GitHub has no v$v archive of $repo" >&2
  exit 1
fi

if [ "$dry" = 1 ]; then
  echo "would move  lazychat ${was:-?} → $v"
  echo "  url \"$url\""
  echo "  sha256 \"$sum\""
  exit 0
fi
tmp="$(mktemp)"
awk -v url="$url" -v sum="$sum" '
  /^  url / { print "  url \"" url "\""; next }
  /^  sha256 / { print "  sha256 \"" sum "\""; next }
  { print }
' "$formula" > "$tmp"
mv "$tmp" "$formula"
git add "$formula"
git commit -q -m "lazychat $v"
echo "moved       lazychat ${was:-?} → $v"
