-- Table that shows space groupings for each monitor
-- Note:  Preview windows don't seem to be movable using the techniques here.
--        I can't seem to get a window object to manipulate.
local app_layout = {
    L={{"Firefox", "Obsidian"}, {"Postgres", "Beekeeper Studio", "Postico"}},
    C={{"Maps", "Calendar"}, {"Excel", "Evernote", "Code", "Preview", "iTerm", "Word", "Books", "Photoshop"}},
    R={{"Messages", "Slack", "Messenger"}, {"Mail"}},
}

-- -- For debugging
-- local app_layout = {
--     R={{"Messages"}, {"Mail"}},
-- }

local cmd_alt = {"cmd", "alt"}
local cmd_alt_ctrl = {"cmd", "alt", "ctrl"}

-- local monitor_left = "DELL U2717D"
-- local monitor_center = "LG Ultra HD"
-- local monitor_right = "Built-in Retina Display"


-- Interrogate the display configuration to get the arrangement of screens and
-- spaces.  Create a table that looks like this:
-- {
--    ["L"] = { screen_uuid, screen_num, { space_id, ...} },
--    ["C"] = { screen_uuid, screen_num, { space_id, ...} },
--    ["R"] = { screen_uuid, screen_num, { space_id, ...} },
--    ...
-- }
function get_layout()
    local layout = {}
    -- Get screens
    local screens = hs.spaces.missionControlSpaceNames(true)

    -- Get spaces for each screen
    for uuid, screen_info in pairs(screens) do
        local pos = "C"
        local scr = hs.screen.find(uuid)
        local x = scr:position() -- returns x, y
        -- print("Position: ", x)
        if x < 0 then
            pos = "L"
        elseif x > 0 then
            pos = "R"
        end
        local spaces = hs.spaces.spacesForScreen(uuid)
        layout[pos] = {screen_uuid=uuid, screen_num=scr:id(), spaces=spaces}
    end

    return layout
end

-- If the monitor ("L", "C", or "R") has fewer than num_spaces spaces, add
-- spaces
function ensure_spaces_on_monitor(num_spaces, monitor)
    local layout = get_layout()

    local mon_layout = layout[monitor]
    local num_spaces_needed = num_spaces - #mon_layout["spaces"]

    if num_spaces_needed > 0 then
        for i=1,num_spaces_needed do
            -- Add a space to the screen
            if not hs.spaces.addSpaceToScreen(mon_layout["screen_uuid"], true) then
                hs.alert.show("Failed to add Space to " .. monitor .. " monitor")
            else
                hs.alert.show("Added Space to " .. monitor .. " monitor")
            end
        end
    end
end

-- Arrange windows in spaces in screens, based on app_layout.  app_layout is
-- hardcoded for now.
function arrange()
    -- Get the current screen and space layout
    local layout = get_layout()
    local starting_center_space = hs.spaces.activeSpaceOnScreen(layout["C"]["screen_uuid"])

    -- print("app_layout", dump(app_layout))
    for mon,spaces in pairs(app_layout) do
        ensure_spaces_on_monitor(#spaces, mon)
        for i=1,#spaces do
            local apps = spaces[i]
            for app=1,#apps do
                mv_app_to_space(apps[app], layout[mon]["spaces"][i])
            end
        end
    end

    hs.spaces.closeMissionControl()

    -- Attempt to display the done message on the center monitor (doesn't work)
    activate_space(starting_center_space)
    hs.alert.show("Done rearranging windows", nil, hs.screen.find(layout["L"]["screen_uuid"]))
end

-- Move a window to a specific monitor
--   win : object   a window object
--   mon : string   a monitor identifier ("L", "C", "R")
function mv_win_to_monitor(win, mon)
    local layout = get_layout()
    local screen_uuid = layout[mon]["screen_uuid"]
    if win ~= nil then
        mv_win_to_screen(win, screen_uuid)
    end
end

-- Move a window to a screen
--   win   : object
--   screen: string   a uuid
function mv_win_to_screen(win, screen_uuid)
    if win ~= nil then
        win:moveToScreen(screen_uuid, false, true, 0)
    end
end

-- Get window object from app_name
function app_win(app_name)
    -- print("app_win(" .. app_name .. ")")
    local app = hs.application.find(app_name)
    local win = app:mainWindow()
    -- print("win = " .. tostring(win))
    if win == nil then
        hs.alert.show("Failed to get main window for " .. app_name)
    end
    return win
end

-- Expose a space.  There is animation involved, so we do a 1 second delay
function activate_space(space)
    hs.spaces.gotoSpace(space)  -- opens, closes Mission Control
    hs.timer.usleep(1500000) -- delay for 1.5 second
    -- hs.spaces.closeMissionControl()
end

-- Move an application to a specific space
--   app_name : string  e.g. "Mail"
--   space    : int     e.g. 215
function mv_app_to_space(app_name, space)
    -- print("mv_app_to_space(" .. app_name .. ", " .. space .. ")")
    local win = app_win(app_name)
    -- print("win = " .. tostring(win))
    if win ~= nil then
        mv_win_to_space(win, space)
    end
end

-- Move a window to a Space
--   win   : object    a window object
--   space : integer   a space id; e.g. 215
function mv_win_to_space(win, space)
    -- If the window is already where it needs to be, just return
    local win_spaces = hs.spaces.windowSpaces(win)
    for i=1, #win_spaces do
        if win_spaces[i] == space then return nil end
    end

    -- If FROM space and TO space are on the same monitor, then move to another
    -- monitor first
    local from_screen = win:screen():getUUID()
    local to_screen = hs.spaces.spaceDisplay(space)
    if from_screen == to_screen then
        -- Find a space on a different screen
        local alt_screen = win:screen():next()
        local alt_space = hs.spaces.activeSpaceOnScreen(alt_screen)
        mv_win_to_space(win, alt_space)
    end

    if win ~= nil then
        -- Move the window to the space directly (doesn't seem to work)
        -- if not hs.spaces.moveWindowToSpace(win, space) then
        --     hs.alert.show(app_name .. " window not moved")
        -- end

        -- We have to bring the space to the front of its screen,
        -- then move the window to the screen.  This results in a lot
        -- of extraneous window motion that it would be nice to avoid.
        win:focus()
        hs.timer.usleep(1500000) -- delay for 1.5 second for animation
        activate_space(space)
        mv_win_to_screen(win, hs.spaces.spaceDisplay(space))

        -- win:focus()
        -- hs.timer.usleep(1500000) -- delay for 1.5 second
        -- hs.spaces.moveWindowToSpace(win, space)
        -- hs.timer.usleep(1500000) -- delay for 1.5 second

        -- hs.spaces.gotoSpace(space)
    end
end

-- Call the arrange() function to rearrange the windows
hs.hotkey.bind(cmd_alt_ctrl, "A", function()
    arrange()
end)


-- Automatically reload the Hammerspoon init.lua file when it changes
-- function reloadConfig(files)
--     doReload = false
--     for _,file in pairs(files) do
--         if file:sub(-4) == ".lua" then
--             doReload = true
--         end
--     end
--     if doReload then
--         hs.reload()
--     end
-- end
-- myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
-- hs.alert.show("Hammerspoon init.lua loaded")


-- Convert object to string for debugging
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
