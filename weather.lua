-- ~/.config/awesome/weather.lua
local http       = require("socket.http")
local json       = require("dkjson")
local gears      = require("gears")
local wibox      = require("wibox")
local fs         = gears.filesystem
local dpi        = require("beautiful.xresources").apply_dpi
local beautiful  = require("beautiful")

beautiful.init(os.getenv("HOME") .. "/.config/awesome/zenburn/theme.lua")

local api_key = os.getenv("OPENWEATHER_API_KEY")
if not api_key or api_key == "" then
    return wibox.widget.textbox("No API key")
end

local city, units = "Calgary", "metric"
local url = string.format(
    "https://api.openweathermap.org/data/2.5/weather?q=%s&units=%s&appid=%s",
    city, units, api_key
)

local weather_text = wibox.widget {
    widget = wibox.widget.textbox,
    align  = "center",
    valign = "center",
    font   = beautiful.font or "Ubuntu Mono Bold 13",
    markup = "<span>Loading...</span>"
}

local weather_widget = wibox.widget {
    {
        weather_text,
        margins = dpi(6),
        widget  = wibox.container.margin,
    },
    bg     = beautiful.fg_normal .. "AA",
    shape  = gears.shape.rounded_bar,
    widget = wibox.container.background,
    forced_width  = dpi(180),
    forced_height = dpi(36),
}

local function update_weather()
    local body, code = http.request(url)
    if code ~= 200 or not body then return end

    local data, _, err = json.decode(body, 1, nil)
    if err or not data or not data.weather then return end

    local feels_like = math.floor((data.main.feels_like or 0) + 0.5)
    local wind_kmh   = math.floor(((data.wind and data.wind.speed) or 0) * 3.6 + 0.5)

    local temp_color = beautiful.bg_focus
    local wind_color = beautiful.bg_normal

    weather_text.markup = string.format(
        "<span foreground='%s'>%d°C</span>   <span foreground='%s'>%dkm/h</span>",
        temp_color,
        feels_like,
        wind_color,
        wind_kmh
    )
end

update_weather()
gears.timer {
    timeout   = 900,
    autostart = true,
    call_now  = true,
    callback  = update_weather,
}

return weather_widget
