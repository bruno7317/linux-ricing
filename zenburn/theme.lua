-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

local themes_path = require("gears.filesystem").get_themes_dir()
local dpi = require("beautiful.xresources").apply_dpi

local function get_xrdb_color(name)
    local pipe = io.popen("xrdb -query")
    if not pipe then
        print("[XRDB] Failed to open pipe")
        return nil
    end

    local preferred, fallback = nil, nil

    for line in pipe:lines() do
        local key, val = line:match("^(%*%.[%w]+):%s*(#%x+)")
        if key and key == "*." .. name then
            fallback = val
        else
            key, val = line:match("^(%*[%w]+):%s*(#%x+)")
            if key and key == "*" .. name then
                preferred = val
            end
        end
    end

    if preferred then
        print(string.format("[XRDB] %s = %s (preferred)", name, preferred))
        return preferred
    elseif fallback then
        print(string.format("[XRDB] %s = %s (fallback)", name, fallback))
        return fallback
    else
        print(string.format("[XRDB] %s not found", name))
        return nil
    end
end

local function assign(name, fallback)
    local val = get_xrdb_color(name) or fallback
    print(string.format("[THEME] %s = %s", name, val))
    return val
end


-- {{{ Main
local theme = {}
local wallpaper = os.getenv("HOME") .. "/.cache/wal/wall.png"
local f = io.open(wallpaper, "r")
if f ~= nil then
    io.close(f)
    theme.wallpaper = wallpaper
else
    theme.wallpaper = themes_path .. "zenburn/zenburn-background.png"
end

-- }}}

-- {{{ Styles
theme.font = "Ubuntu Mono Bold 16"

-- {{{ Colors
theme.fg_normal  = assign("foreground", "#DCDCCC")
theme.fg_focus   = assign("color7",     "#F0DFAF")
theme.fg_urgent  = assign("color1",     "#CC9393")

theme.bg_normal  = assign("background", "#3F3F3F")
theme.bg_focus   = assign("color0",     "#1E2320")
theme.bg_urgent  = assign("color8",     "#3F3F3F")

theme.bg_systray = assign("background", "#3F3F3F")

theme.wibar_bg = assign("color4", "#3F3F3F")
theme.wibar_fg = assign("background", "#FFFFFF")
theme.wibar_border_width = dpi(2)
theme.wibar_border_color = assign("color7", "#3F3F3F")

theme.useless_gap   = dpi(0)
theme.border_width  = dpi(2)

theme.border_normal = assign("color7", "#3F3F3F")
theme.border_focus  = assign("color2", "#6F6F6F")
theme.border_marked = assign("color1", "#CC9393")

theme.titlebar_bg_focus  = assign("color0", "#3F3F3F")
theme.titlebar_bg_normal = assign("color0", "#3F3F3F")

theme.taglist_fg_focus    = assign("color7",     "#FFFFFF")
theme.taglist_bg_focus    = assign("color1",     "#1E2320")
theme.taglist_fg_urgent   = assign("color1",     "#CC9393")
theme.taglist_bg_urgent   = assign("color8",     "#3F3F3F")
theme.taglist_fg_occupied = assign("color7",     "#F0DFAF")
theme.taglist_bg_occupied = assign("color0",     "#3F3F3F")
theme.taglist_fg_empty    = assign("color5",     "#7F9F7F")
theme.taglist_bg_empty    = assign("background", "#3F3F3F")

theme.mouse_finder_color = assign("color4", "#CC9393")

-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = themes_path .. "zenburn/taglist/squarefz.png"
theme.taglist_squares_unsel = themes_path .. "zenburn/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = themes_path .. "zenburn/awesome-icon.png"
theme.menu_submenu_icon      = themes_path .. "default/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = themes_path .. "zenburn/layouts/tile.png"
theme.layout_tileleft   = themes_path .. "zenburn/layouts/tileleft.png"
theme.layout_tilebottom = themes_path .. "zenburn/layouts/tilebottom.png"
theme.layout_tiletop    = themes_path .. "zenburn/layouts/tiletop.png"
theme.layout_fairv      = themes_path .. "zenburn/layouts/fairv.png"
theme.layout_fairh      = themes_path .. "zenburn/layouts/fairh.png"
theme.layout_spiral     = themes_path .. "zenburn/layouts/spiral.png"
theme.layout_dwindle    = themes_path .. "zenburn/layouts/dwindle.png"
theme.layout_max        = themes_path .. "zenburn/layouts/max.png"
theme.layout_fullscreen = themes_path .. "zenburn/layouts/fullscreen.png"
theme.layout_magnifier  = themes_path .. "zenburn/layouts/magnifier.png"
theme.layout_floating   = themes_path .. "zenburn/layouts/floating.png"
theme.layout_cornernw   = themes_path .. "zenburn/layouts/cornernw.png"
theme.layout_cornerne   = themes_path .. "zenburn/layouts/cornerne.png"
theme.layout_cornersw   = themes_path .. "zenburn/layouts/cornersw.png"
theme.layout_cornerse   = themes_path .. "zenburn/layouts/cornerse.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = themes_path .. "zenburn/titlebar/close_focus.png"
theme.titlebar_close_button_normal = themes_path .. "zenburn/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = themes_path .. "zenburn/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "zenburn/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path .. "zenburn/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = themes_path .. "zenburn/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = themes_path .. "zenburn/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "zenburn/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path .. "zenburn/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = themes_path .. "zenburn/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = themes_path .. "zenburn/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = themes_path .. "zenburn/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = themes_path .. "zenburn/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = themes_path .. "zenburn/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = themes_path .. "zenburn/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = themes_path .. "zenburn/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "zenburn/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = themes_path .. "zenburn/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
