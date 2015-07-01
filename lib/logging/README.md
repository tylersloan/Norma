# Completion for norma
> Thanks to the grunt team, specifically Tyler Kellen

To enable tasks auto-completion in shell you should add `eval "$(norma --completion=shell)"` in your `.shellrc` file.

## Bash

Add `eval "$(norma --completion=bash)"` to `~/.bashrc`.

## Zsh

Add `eval "$(norma --completion=zsh)"` to `~/.zshrc`.

## Powershell

Add `Invoke-Expression ((norma --completion=powershell) -join [System.Environment]::NewLine)` to `$PROFILE`.

## Fish

Add `norma --completion=fish | source` to `~/.config/fish/config.fish`.
