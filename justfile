# dotfiles command runner — run `just` (no args) to list recipes.
# https://just.systems

# Show all recipes
default:
    @just --list

# Full setup for a new machine: install chezmoi + all tools, write configs.
# Zero-dependency entry point (installs `just` itself along the way).
setup:
    ./bootstrap.sh

# Preview what `apply` would change (config files + the install script)
diff:
    chezmoi diff

# Apply configs and run installers (prompts for your password on macOS)
apply:
    chezmoi apply -v

# Pull the latest dotfiles from git and apply them
update:
    chezmoi update -v

# Capture a file from this machine INTO the repo (e.g. `just add ~/.config/foo`)
add path:
    chezmoi add {{ path }}

# Edit a managed file through chezmoi, then apply it
edit path:
    chezmoi edit --apply {{ path }}

# Re-run ONLY the package installer (renders the template and runs it directly)
install-packages:
    chezmoi execute-template < home/run_onchange_before_install-packages.sh.tmpl | bash

# Jump into the chezmoi source dir (this repo) in a subshell
cd:
    chezmoi cd

# Test that SSH auth to GitHub works (after the 1Password SSH-agent setup)
ssh-test:
    ssh -T git@github.com || true

# Authenticate GitHub CLI + route git over HTTPS (good for servers w/o 1Password)
gh-login:
    gh auth login
    gh auth setup-git

# Make fish your default login shell (needs your password)
fish-default:
    #!/usr/bin/env bash
    set -euo pipefail
    which fish | sudo tee -a /etc/shells
    chsh -s "$(which fish)"
