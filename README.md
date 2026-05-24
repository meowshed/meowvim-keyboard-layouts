# meowvim-keyboard-layouts

A [meowctl](https://github.com/meowshed/meowctl) registry module — Hammerspoon Spoon that switches macOS keyboard layout based on Neovim mode.

## What it does

- Monitors Ghostty window title for Neovim mode changes
- When entering Insert mode: restores the last-used input source (e.g., Russian)
- When leaving Insert mode: switches to ABC for Neovim keybindings
- Communicates via Ghostty window title updates

## Requirements

- macOS
- [Hammerspoon](https://www.hammerspoon.org/)
- [Ghostty](https://ghostty.org/) terminal
- Neovim

## Usage

```python
component("@meowvim-keyboard-layouts//meowvim-keyboard-layouts")
```

## Files

| File | Destination |
|------|-------------|
| `MeowvimKeyboardLayouts.spoon/init.lua` | `~/.hammerspoon/Spoons/MeowvimKeyboardLayouts.spoon/init.lua` |

## Dependencies

- `@stdlib//components/hammerspoon`

## License

MIT
