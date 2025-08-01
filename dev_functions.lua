-- To display the names of each screen on the respective screen
function display_screen_names()
    local screens = hs.screen.allScreens()
    for i, screen in ipairs(screens) do
        local name = screen:name()
        hs.alert.show("Screen " .. i .. ": " .. name, screen, 4)
    end
end
-- To output the names and applications of all windows in the console
function list_open_windows()
    local windows = hs.window.filter.new():getWindows()
    for i, window in ipairs(windows) do
        print("Window " .. i .. ": " .. window:application():name() .. " - " .. window:title())
    end
    hs.alert.show("Check console for window names and applications", 4)
end
-- To display a dialog with options to run dev functions
function show_dev_functions_menu()
    local choices = {
        { option = 1, text = "1. Display Screen Names", 
            subText = "Display names of all screens" },
        { option = 2, text = "2. List Open Window Names", 
            subText = "Output names and applications of all open windows to console" },
        { option = 3, text = "3. Reload Hammerspoon Config", 
            subText = "Reload the Hammerspoon configuration" },
    }

    hs.chooser.new(function(choice)
        if not choice then return end
        if choice.option == 1 then 
            display_screen_names()
        elseif choice.option == 2 then 
            list_open_windows()
        elseif choice.option == 3 then 
            hs.reload()
            hs.alert.show("Config reloaded")
        end
    end):choices(choices):show()
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "D", function()
    show_dev_functions_menu()
end)