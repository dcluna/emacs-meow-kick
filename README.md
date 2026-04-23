# emacs-meow-kick

A feature-rich Emacs config using [meow](https://github.com/meow-edit/meow) for modal editing. Based on [emacs-kick](https://github.com/LionyxML/emacs-kick) but with meow's selection-first paradigm instead of evil/vim emulation.

## Requirements

- Emacs >= 30.1
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- [chemacs2](https://github.com/plexus/chemacs2) (for multi-profile setup)

## Installation

### With chemacs2

Clone into your home directory:

    git clone https://github.com/dcluna/emacs-meow-kick.git ~/.emacs-meow-kick

Add to your `.emacs-profiles.el`:

    (("meow" . ((user-emacs-directory . "~/.emacs-meow-kick"))))

Start with:

    emacs --with-profile meow

### First run

On first boot, run `M-x mk/first-install` to install tree-sitter grammars and nerd-icon fonts.

## Packages

Completion (vertico, orderless, marginalia, consult, embark, corfu), LSP (lsp-mode), git (magit, diff-hl), treesitter, UI (doom-modeline, neotree, catppuccin-theme, nerd-icons, pulsar), and more.

## Meow keybindings

Uses the [QWERTY layout preset](https://github.com/meow-edit/meow/blob/master/KEYBINDING_QWERTY.org). Press `SPC ?` in normal mode for the cheatsheet.

Keypad mode (`SPC` in normal state) translates to `C-` prefixes:
- `SPC x f` → `C-x C-f` (find-file)
- `SPC h f` → `C-h C-f` (describe-function)
- `SPC x ;` → `C-x C-;` (comment-line)
