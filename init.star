# meowvim-keyboard-layouts.star
#
# platforms: ["macos"]
# after:     ["@stdlib//components/hammerspoon"]
#
# Hammerspoon Spoon: switches macOS keyboard layout based on Neovim mode
# signalled via the Ghostty window title.  When a Ghostty window enters
# Insert mode the last-used input source is restored; on leaving Insert
# mode the layout switches to ABC for Neovim keybindings.

platforms = ["macos"]
after = ["@stdlib//components/hammerspoon"]

def install(ctx):
    home = ctx.env("HOME")
    ctx.link_file(
        src = "MeowvimKeyboardLayouts.spoon/init.lua",
        dst = home + "/.hammerspoon/Spoons/MeowvimKeyboardLayouts.spoon/init.lua",
    )

def verify(ctx):
    home = ctx.env("HOME")
    if not ctx.file_exists(home + "/.hammerspoon/Spoons/MeowvimKeyboardLayouts.spoon/init.lua"):
        ctx.log("meowvim-keyboard-layouts: Spoon not found")

def uninstall(ctx):
    home = ctx.env("HOME")
    ctx.remove_symlink(home + "/.hammerspoon/Spoons/MeowvimKeyboardLayouts.spoon/init.lua")
