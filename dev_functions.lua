-- To display the names of each screen on the respective screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function()
    local screens = hs.screen.allScreens()
    for i, screen in ipairs(screens) do
        local name = screen:name()
        hs.alert.show("Screen " .. i .. ": " .. name, screen, 4)
    end
end)