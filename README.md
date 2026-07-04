# dotfiles

Machine setup + configs for new Mac and Linux boxes, managed with
[chezmoi](https://chezmoi.io). One `chezmoi apply` installs the toolchain and
lays down every config file.

## What it sets up

| Tool | mac | linux | notes |
|------|-----|-------|-------|
| Claude Code | native installer | native installer | `~/.local/bin/claude`, auto-updates |
| Zed | `zed.dev/install.sh` | `zed.dev/install.sh` | official channel (not brew); workstations only |
| Starship | brew | install script | prompt config in `dot_config/starship.toml` |
| fish | brew | apt | shell config in `dot_config/fish/config.fish.tmpl` |
| 1Password | GUI cask + CLI | CLI (`op`) | GUI is workstation-only; servers get the CLI |
| Rust + cargo | rustup | rustup | all machines; `~/.cargo/bin` on PATH |
| FiraCode Nerd Font | brew cask | nerd-fonts release | workstations only; used by Zed + terminal |
| Homebrew | bootstrapped | workstation only | package manager; on Linux only on workstations |
| just | brew | just.systems script | command runner; recipes in `./justfile` |
| Neovim | brew | official tarball | apt too old; + ripgrep; kickstart config in `dot_config/nvim/` |
| git | `~/.config/git/config` | `~/.config/git/config` | identity + aliases (XDG) |
| Node + pnpm | brew | NodeSource + corepack | all machines |
| Containers | Apple Silicon: podman; Intel: colima+docker | podman + podman-compose | mac: workstation; linux: all |
| gh (GitHub CLI) | brew | apt repo | all machines |
| ruff | brew | astral installer | Python LSP for Zed + nvim |
| uv + ty | brew (uv) + `uv tool install ty` | astral installer + uv | Python pkg manager + type checker (Zed) |
| git-absorb | brew | cargo | all machines |

## Run the setup

Clone this repo, then run the bootstrap script **in a real terminal** (it
prompts for your password on macOS for Homebrew / app installs):

```sh
git clone <this-repo> ~/Documents/git/dotfiles
cd ~/Documents/git/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs chezmoi (into `~/.local/bin`, no admin needed), then
**shows a diff of everything it will change and asks you to confirm** before
installing tools or writing configs — so existing configs aren't clobbered
blindly. You'll be asked once whether this machine is a `workstation` or
`server` — servers skip the GUI apps (Zed, 1Password GUI, FiraCode,
Homebrew-on-Linux).

**Fresh machine, one-liner** (once this repo is on GitHub as `dotfiles`):

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-username>
```

On a **non-interactive / CI** run (no TTY), the machine-type prompt silently
defaults to `workstation` (which then tries GUI/cask installs). For a **server**,
pass `--promptString machineType=server` to the `init` command.

**Preview before applying** anytime:

```sh
chezmoi diff        # show every file change + the install script
```

## Everyday use — `just`

Once set up, `just` (installed as part of the toolchain) wraps the common
chezmoi operations. Run `just` with no args to list them:

```sh
just                 # list all recipes
just setup           # full machine setup (runs ./bootstrap.sh)
just diff            # preview pending changes
just apply           # apply configs + run installers
just update          # git pull + apply (sync a machine)
just add ~/.config/foo   # capture a file into the repo
just edit ~/.config/starship.toml   # edit a managed file, then apply
just install-packages    # re-run only the package installer
just fish-default        # make fish your default shell
```

Each is a thin wrapper over the equivalent `chezmoi` command if you'd rather
run those directly.

## GitHub authentication (1Password SSH agent)

Workstations authenticate git/SSH through **1Password's SSH agent** — one key,
stored in 1Password, works on every machine; nothing private touches disk or the
repo. The managed `~/.ssh/config` points SSH at the agent socket. One-time setup:

1. **1Password app** → create or import an SSH key (New Item → SSH Key).
2. **Settings → Developer → Use the SSH agent** → turn on.
3. Copy the item's public key → **GitHub → Settings → SSH and GPG keys → New SSH key**.
4. Test: `ssh -T git@github.com` (expect "Hi &lt;user&gt;! You've successfully authenticated").

**Servers** (no 1Password GUI): run `just gh-login` — `gh auth login` +
`gh auth setup-git` routes git over HTTPS with your GitHub token, no SSH key needed.

## Make fish your default shell

Not automated (it needs your password and is easy to undo):

```sh
which fish | sudo tee -a /etc/shells    # register fish
chsh -s "$(which fish)"                 # set as login shell
```

## Layout

```
.chezmoiroot                           # points chezmoi at home/ as its source
README.md  bootstrap.sh  justfile      # repo helpers — NOT applied to $HOME
home/                                  # chezmoi source (mirrors your $HOME)
  .chezmoi.toml.tmpl                   # per-machine prompt (workstation/server)
  run_onchange_before_install-packages.sh.tmpl   # OS-aware installer
  dot_zshrc.tmpl                       # -> ~/.zshrc         (brew, PATH, starship)
  dot_bashrc.tmpl                      # -> ~/.bashrc        (same, for bash/servers)
  dot_bash_profile                     # -> ~/.bash_profile  (login shells source .bashrc)
  private_dot_ssh/private_config.tmpl  # -> ~/.ssh/config    (1Password SSH agent)
  dot_config/
    git/config                         # -> ~/.config/git/config  (identity + aliases)
    fish/config.fish.tmpl              # -> ~/.config/fish/config.fish
    starship.toml                      # -> ~/.config/starship.toml
    zed/settings.json                  # -> ~/.config/zed/settings.json
    zed/keymap.json                    # -> ~/.config/zed/keymap.json
    nvim/                              # -> ~/.config/nvim  (kickstart config)
```

`~/.zshrc`, `~/.bashrc`, and fish's config all set up the same PATH
(`~/.local/bin`, `~/.cargo/bin`), Homebrew `shellenv`, and the starship prompt
— so tooling works in zsh (mac default), bash (typical server login shell), or
fish.

Everything chezmoi manages lives under `home/` (via `.chezmoiroot`), so the repo
root stays clean — just docs and scripts. Within `home/`, `dot_` becomes `.`,
`private_` sets `0600`/`0700` perms, and `.tmpl` files are rendered per machine
(`{{ .chezmoi.os }}`, `{{ .machineType }}`).
