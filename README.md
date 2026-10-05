# Perpeer's Homebrew tap

Homebrew formulae for Perpeer's tools.

## lazychat

[lazychat](https://github.com/Perpeer/lazychat) is one terminal for all
your AI coding agents, with Lazy, its mascot, in the menu bar.

```sh
brew install perpeer/tap/lazychat
brew services start lazychat   # Lazy in the menu bar at every login
```

Homebrew builds it from source on your Mac, so macOS opens it without a
warning. `brew upgrade lazychat` takes a new release; `brew uninstall
lazychat` takes it away.

## Keeping it current

`update.sh` moves the formula to lazychat's newest release (its archive's
url and sha256) and commits; `--dry-run` says what it would change. The
`update` workflow runs it every hour, so a release reaches `brew upgrade`
within the hour; `gh workflow run update -R Perpeer/homebrew-tap` runs it
at once.
