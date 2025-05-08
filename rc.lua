pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
package.loaded["naughty.dbus"] = {}
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

local THEME = os.getenv("HOME") .. "/.config/awesome/zenburn/theme.lua"

modkey = "Mod4"
terminal = "gnome-terminal"

local dpi           = require("beautiful.xresources").apply_dpi
local GAP           = dpi(10)
local BAR_HEIGHT    = dpi(50)
local BORDER_RADIUS = dpi(15)


local function key(mod, key, action, desc, group)
    return awful.key(mod, key, action, { description = desc, group = group })
end

local function notify_error(message)
    naughty.notify({ preset = naughty.config.presets.critical, title = "Error!", text = message })
end

local function setAvailableLayouts()
    awful.layout.layouts = {
        awful.layout.suit.spiral
    }
end

local function setWallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

local function createClientKeys()
    return gears.table.join(
        key({modkey}, "c", function (c) c:kill() end, "close", "client"),
        key({modkey}, "o", function (c) c:move_to_screen() end, "move to screen", "client")
    )
end

local function setKeyboardShortcuts()
    local globalkeys = gears.table.join(
        key({modkey}, "s", hotkeys_popup.show_help, "show help", "awesome"),
        key({modkey}, "Left", awful.tag.viewprev, "view previous", "tag"),
        key({modkey}, "Right", awful.tag.viewnext, "view next", "tag"),
        key({modkey, "Control"}, "j", function () awful.screen.focus_relative(1) end, "focus the next screen", "screen"),
        key({modkey, "Control"}, "k", function () awful.screen.focus_relative(-1) end, "focus the previous screen", "screen"),
        key({modkey}, "`", function () awful.spawn(terminal) end, "open a terminal", "launcher"),
        key({modkey, "Control"}, "r", awesome.restart, "reload awesome", "awesome"),
        key({modkey}, "r", function () awful.screen.focused().mypromptbox:run() end, "run prompt", "launcher"),
        key({modkey, "Shift"}, "s", function () awful.spawn("flameshot gui --accept-on-select --clipboard") end, "take screenshot","custom"),
        key({}, "XF86AudioRaiseVolume", function () awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +3%") end, "increase volume", "media"),
        key({}, "XF86AudioLowerVolume", function () awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -3%") end, "decrease volume", "media"),
        key({}, "XF86AudioMute", function () awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end, "mute volume", "media"),
        key({modkey}, "F5", function() awful.spawn.with_shell("~/.config/awesome/zenburn/cycle_wallpaper.sh") end, "cycle theme", "awesome"),
        key({modkey}, "l", function () awful.spawn("betterlockscreen -l dimblur") end, "lock screen", "awesome")

    )
    for i = 1, 9 do
        globalkeys = gears.table.join(globalkeys,
            -- View tag only.
            key({modkey}, "#" .. i + 9,
                function ()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then
                        tag:view_only()
                    end
                end,
                "view tag #"..i,
                "tag"
            ),
            -- Move client to tag.
            key({modkey, "Shift"}, "#" .. i + 9,
                function ()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then
                            client.focus:move_to_tag(tag)
                        end
                    end
                end,
                "move focused client to tag #"..i,
                "tag"
            )
        )
    end

    root.keys(globalkeys)
end

local function setRules()
    awful.rules.rules = {
        {
            rule = { },
            properties = {
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                keys = createClientKeys(),
                screen = awful.screen.preferred,
                placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                floating = false,
                size_hints_honor = false,
                maximized = false,
                maximized_horizontal = false,
                maximized_vertical = false
            }
        },
        {
            rule_any = {
                type = { "normal", "dialog" }
            },
            properties = { titlebars_enabled = true }
        }
    }
end

local function createTaglistButtons()
    return gears.table.join(
        awful.button({ }, 1, function(t) t:view_only() end),
        awful.button({ modkey }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end)
    )
end

local function initTaglist(s)
    awful.tag({ "1", "2", "3", "4" }, s, awful.layout.layouts[1])

    for _, t in ipairs(s.tags) do
        t.gap               = GAP
        t.gap_single_client = true
    end
end

local function buildTaglist(s)
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = createTaglistButtons()
    }
end

local function createPromptbox(s)
    s.mypromptbox = awful.widget.prompt()
    return s.mypromptbox
end

local function initGapBar(s)
    --------------------------------------------------------------------
    --  Reserve outer gap + bar height
    --------------------------------------------------------------------
    awful.screen.padding(s, {
        top    = 2*GAP + BAR_HEIGHT,
        left   = 0,
        right  = 0,
        bottom = 0,
    })

    --------------------------------------------------------------------
    --  Create the bar (note the geometry block!)
    --------------------------------------------------------------------
    s.mywibox = wibox {
        screen  = s,
        height  = BAR_HEIGHT,
        visible = true,
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, BORDER_RADIUS) end,
        border_width = beautiful.wibar_border_width,
        border_color = beautiful.wibar_border_color
    }

    -- Absolute positioning that respects multi‑head offsets
    s.mywibox:geometry({
        x      = s.geometry.x + 2*GAP,
        y      = s.geometry.y + 2*GAP,
        width  = s.geometry.width - 4 * GAP - 2*dpi(2),
        height = BAR_HEIGHT,
    })

    -- Keep it in place if the monitor layout changes
    s:connect_signal("property::geometry", function()
        s.mywibox:geometry({
            x      = s.geometry.x + 2*GAP,
            y      = s.geometry.y + 2*GAP,
            width  = s.geometry.width - 4 * GAP - 2*dpi(20),
            height = BAR_HEIGHT,
        })
    end)

    --------------------------------------------------------------------
    --  Widgets (unchanged)
    --------------------------------------------------------------------
    s.mypromptbox = awful.widget.prompt()

    s.left_widgets = {
        layout = wibox.layout.fixed.horizontal,
        s.mytaglist,
        s.mypromptbox,
    }

    s.right_widgets = {
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.textclock(),
    }

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        s.left_widgets,
        nil,
        s.right_widgets,
    }
end

local function preventOffscreenOnStartup(c)
    c.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, BORDER_RADIUS)
    end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        awful.placement.no_offscreen(c)
    end
end

local function createTitlebarButtons(c)
    return gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end)
    )
end

local function setTitlebar(c)
    local buttons = createTitlebarButtons(c)

    awful.titlebar(c) : setup {
        {
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {
            {
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end

local function focusClientOnMouseEnter(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end

local function setBorderColor(c, focused)
    if focused then
        c.border_color = beautiful.border_focus
    else
        c.border_color = beautiful.border_normal
    end
end

local function loadTheme()
    beautiful.init(THEME)
end

local function reloadTheme()
    loadTheme()

    for s in screen do
        setWallpaper(s)

        buildTaglist(s)

        initGapBar(s)
    end
end

local function setSignals()
    client.connect_signal("manage", preventOffscreenOnStartup)
    client.connect_signal("request::titlebars", setTitlebar)
    client.connect_signal("mouse::enter", focusClientOnMouseEnter)
    client.connect_signal("focus", function(c) setBorderColor(c, true) end)
    client.connect_signal("unfocus", function(c) setBorderColor(c, false) end)

    screen.connect_signal("property::geometry", setWallpaper)

    awesome.connect_signal("theme::reload", reloadTheme)
end

local function setupErrorHandling()
    if awesome.startup_errors then
        notify_error(awesome.startup_errors)
    end

    do
        local in_error = false
        awesome.connect_signal("debug::error", function (err)
            if in_error then return end
            in_error = true

            notify_error(tostring(err))
            in_error = false
        end)
    end
end

local function setupScreens()
    awful.screen.connect_for_each_screen(function(s)

        setWallpaper(s)

        initTaglist(s)
        buildTaglist(s)

        createPromptbox(s)

        initGapBar(s)
    end)
end

setupErrorHandling()

loadTheme()

setAvailableLayouts()

setupScreens()

setKeyboardShortcuts()

setRules()

setSignals()
