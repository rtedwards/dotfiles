#!/usr/bin/env bash
#
# One-shot machine setup. Run this yourself in a real terminal:
#
#     ./bootstrap.sh
#
# It installs chezmoi (no admin needed), PREVIEWS every change, then — only
# after you confirm — installs the toolchain and writes configs. The preview +
# confirm step protects any configs already on the machine from silent clobber.
#
# You'll be asked once whether this machine is a "workstation" or "server".
# On macOS you'll be prompted for your password (Homebrew / app installs) —
# that's why this must run in an interactive terminal, not via a tool.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. chezmoi — installs to ~/.local/bin, no sudo required
if command -v chezmoi >/dev/null 2>&1; then
  CHEZMOI="$(command -v chezmoi)"
elif [ -x "$HOME/.local/bin/chezmoi" ]; then
  CHEZMOI="$HOME/.local/bin/chezmoi"
else
  echo "==> Installing chezmoi to ~/.local/bin"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  CHEZMOI="$HOME/.local/bin/chezmoi"
fi

# 2. Init (generate config, prompt workstation/server) WITHOUT applying yet
echo "==> Initializing chezmoi from $REPO_DIR"
"$CHEZMOI" init --source="$REPO_DIR"

# 3. Persist the source dir so a later plain `chezmoi apply` finds this repo
CFG="$HOME/.config/chezmoi/chezmoi.toml"
if [ -f "$CFG" ] && ! grep -q '^sourceDir' "$CFG"; then
  printf 'sourceDir = "%s"\n\n%s\n' "$REPO_DIR" "$(cat "$CFG")" > "$CFG"
fi

# 4. Preview everything that will change — files it would overwrite + installer
echo "==> Preview of pending changes (nothing applied yet):"
"$CHEZMOI" diff || true

# 5. Confirm before touching the machine (protects existing configs)
printf '\nApply these changes — install tools and write/overwrite the configs above? [y/N] '
read -r reply || reply=""   # non-interactive stdin -> default No (not an abort)
case "$reply" in
  [Yy]*) "$CHEZMOI" apply -v ;;
  *) echo "Aborted. Review the diff, then run:  chezmoi apply -v"; exit 0 ;;
esac

echo
echo "==> Done. Open a new terminal (or run: exec fish)."
echo "    Make fish your default shell:"
echo "      which fish | sudo tee -a /etc/shells && chsh -s \"\$(which fish)\""
