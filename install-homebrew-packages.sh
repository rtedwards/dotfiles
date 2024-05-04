#!/bin/zsh

brew install ruff-lsp
brew install cargo
brew install lazyvim
brew install neovim

# Fish
brew install fish

# Nerdfont
brew tap homebrew/cask-fonts
brew install font-hack-nerd-font

# Startship prompt
brew install starship
echo "starship init fish | source" >> ~/.config/fish/config.fish
echo "eval \"$(starship init zsh)\"" >> ~/.zshrc 
