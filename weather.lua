local http      = require("socket.http")
local json      = require("dkjson")
local gears     = require("gears")
local wibox     = require("wibox")
local dpi       = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")

local THEME = os.getenv("HOME") .. "/.config/awesome/zenburn/theme.lua"
beautiful.init(THEME)

local api_key = os.getenv("OPENWEATHER_API_KEY")
if not api_key or api_key == "" then
    return function()
        return wibox.widget.textbox("No API key")
    end
end

local city, units = "Calgary", "metric"
local url = string.format(
    "https://api.openweathermap.org/data/2.5/weather?q=%s&units=%s&appid=%s",
    city, units, api_key
)

return function()
    local feels_like, wind_kmh = 0, 0

    local weather_text = wibox.widget {
        widget = wibox.widget.textbox,
        align  = "center",
        valign = "center",
        font   = beautiful.font or "Ubuntu Mono Bold 16",
    }

    local weather_widget = wibox.widget {
        {
            weather_text,
            margins = dpi(6),
            widget  = wibox.container.margin,
        },
        bg           = beautiful.fg_focus .. "AA",
        shape        = gears.shape.rounded_bar,
        widget       = wibox.container.background,
        forced_width = dpi(180),
        forced_height= dpi(36),
    }

    local function redraw()
        beautiful.init(THEME)
        weather_text.markup = string.format(
            "<span foreground='%s'>%d°C</span>   <span foreground='%s'>%dkm/h</span>",
            beautiful.bg_focus, feels_like,
            beautiful.bg_focus, wind_kmh
        )
        weather_widget.bg = beautiful.fg_focus .. "AA"
    end

    local function update_weather()
        local body, code = http.request(url)
        if code ~= 200 or not body then return end

        local data = json.decode(body)
        if not data or not data.weather then return end

        feels_like = math.floor((data.main.feels_like or 0) + 0.5)
        wind_kmh   = math.floor(((data.wind and data.wind.speed) or 0) * 3.6 + 0.5)
        redraw()
    end

    gears.timer {
        timeout   = 900,
        autostart = true,
        call_now  = true,
        callback  = update_weather,
    }

    awesome.connect_signal("theme::reload", redraw)

    redraw()
    return weather_widget
end
