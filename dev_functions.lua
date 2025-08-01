-- To display the names of each screen on the respective screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function()
    local screens = hs.screen.allScreens()
    for i, screen in ipairs(screens) do
        local name = screen:name()
        hs.alert.show("Screen " .. i .. ": " .. name, screen, 4)
    end
end)
-- To output the names and applications of all windows in the console
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "N", function()
    hs.alert.show("Listing window names and applications...", 2)
    local windows = hs.window.filter.new():getWindows()
    for i, window in ipairs(windows) do
        print("Window " .. i .. ": " .. window:application():name() .. " - " .. window:title())
    end
    hs.alert.show("Check console for window names and applications", 4)
end)