# Hammerspoon Window Arranger

A [Hammerspoon](https://github.com/Hammerspoon) script to rearrange windows to a
fixed configuration on MacOS, when you have multiple Spaces and multiple
monitors.  There are other solutions out there, but they generally don't handle
moving windows between Spaces.


## Why
I connect my MacBook Pro to two external monitors on my desk.  At the end of the
day I close the lid and disconnect all cables from it.  When I connect it back
up and it wakes up, about half the time it does not put the windows back on the
same monitor, so I need to spend time dragging them all back to their original
locations.  Very irritating!  And surprising.  The Mac should be able to
remember the last window configuration, and when it sees the same monitor
configuration on waking, it should restore the window configuration.


## What it does

The key binding `⌃⌥⌘ A`  (`Ctrl-Option-Cmd A`) calls the `arrange()` function
which moves windows to Spaces on Screens as specified by the Lua table
`app_layout`.

```lua
local app_layout = {
    L={{"Firefox", "Obsidian"}},
    C={{"Maps"}, {"Excel", "Evernote", "Code", "Preview", "iTerm"}},
    R={{"Messages", "Slack", "Messenger"}, {"Mail"}},
}
```

This `app_layout` says move *Firefox* and *Obsidian* to the first Space on the
Left Screen (monitor).  Move *Maps* to the first Space on the Center Screen.
Move *Excel*, *Evernote*, *Code* (VScode), *Preview*, and *iTerm* to the second
Space on the Center Screen.  Move *Messages*, *Slack*, and *Messenger* to the
first Space on the Right Screen.  Move *Mail* to the second Space on the Right
screen.

Some of the operations on Spaces cause Mission Control to open and close, which
creates a lot of motion.  You just have to ignore it for now.


## What it doesn't do
- Preserve the window size and position
- Correctly move apps with multiple windows that may be on different Screens or
  in different Spaces
- Move apps like Preview


## To Do
- Make it work faster and without so much animation
  - Figure out how to move a window to a Space without exposing the Space
  - Figure out how to move a window to a different Space on the same Screen
    without first moving it to a different Screen
- Make it work right for apps like Preview which don't seem to have a main
  window
- Make it work for apps that have multiple windows that may be on different
  Screens or in different Spaces
- Save the current window configuration so it can be restored
- Save window size and position information so it can be restored
- Detect different monitor configurations and restore the windows accordingly
- Delete empty spaces
- Move unmentioned windows to a specific Space


## See Also
- [A nifty window layout switcher for macOS using Hammerspoon](https://shantanugoel.com/2020/08/21/hammerspoon-multiscreen-window-layout-macos/)
  - Tiles windows in quadrants
  - Doesn't handle Spaces
- [Hammerspoon: Handling Windows and Layouts](https://evantravers.com/articles/2020/06/12/hammerspoon-handling-windows-and-layouts/)
  - Has trigger for docking/undocking the laptop
  - Also does tiling
  - Also doesn't handle Spaces
  - Makes Lua look like Javascript; mine makes Lua look like Python
- [AppWindowSwitcher Spoon](https://www.hammerspoon.org/Spoons/AppWindowSwitcher.html)
  - Also doesn't handle Spaces
- [Next/Previous 'Space' in Hammerspoon](https://blog.jverkamp.com/2023/01/30/next/previous-space-in-hammerspoon/)
  - Claims that you can move a window to a Space simply by
    ```lua
    hs.spaces.moveWindowToSpace(win, space)
    hs.spaces.gotoSpace(space)
    ```
    If I could get that to work, I could simplify my code significantly.
