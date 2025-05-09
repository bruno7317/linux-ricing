-- ~/.config/awesome/weather.lua
------------------------------------------------------------
local http  = require("socket.http")
local json  = require("dkjson")
local gears = require("gears")
local wibox = require("wibox")

------------------------------------------------------------
-- Config
------------------------------------------------------------
local api_key = os.getenv("OPENWEATHER_API_KEY")
if not api_key or api_key == "" then
    return wibox.widget.textbox("No API key")
end

local city = "Calgary"
local units = "metric"  -- or "imperial"
local url = string.format(
    "https://api.openweathermap.org/data/2.5/weather?q=%s&units=%s&appid=%s",
    city, units, api_key
)

------------------------------------------------------------
-- Wind direction → arrow
------------------------------------------------------------
local function wind_arrow(deg)
    if not deg then return "·" end
    local arrows = { "↑", "↗", "→", "↘", "↓", "↙", "←", "↖" }
    local index = math.floor(((deg + 22.5) % 360) / 45) + 1
    return arrows[index]
end

------------------------------------------------------------
-- Weather icon code → emoji
------------------------------------------------------------
local icon_map = {
    ["01d"] = "☀️", ["01n"] = "🌙",
    ["02d"] = "🌤", ["02n"] = "🌤",
    ["03d"] = "⛅", ["03n"] = "⛅",
    ["04d"] = "☁️", ["04n"] = "☁️",
    ["09d"] = "🌧", ["09n"] = "🌧",
    ["10d"] = "🌦", ["10n"] = "🌧",
    ["11d"] = "🌩", ["11n"] = "🌩",
    ["13d"] = "❄️", ["13n"] = "❄️",
    ["50d"] = "🌫", ["50n"] = "🌫"
}

------------------------------------------------------------
-- Widget setup
------------------------------------------------------------
local weather_text = wibox.widget {
    widget = wibox.widget.textbox,
    align  = "center",
    valign = "center",
    font   = "Ubuntu Mono Bold 16"
}

local weather_widget = wibox.widget {
    {
        weather_text,
        left   = 10,
        right  = 10,
        top    = 5,
        bottom = 5,
        widget = wibox.container.margin
    },
    shape  = gears.shape.rounded_bar,
    bg     = "#282a36AA", -- semi-transparent dark background
    widget = wibox.container.background
}

------------------------------------------------------------
-- Weather updater
------------------------------------------------------------
local function update_weather()
    local body, code = http.request(url)
    if code ~= 200 or not body then
        weather_text.markup = "<span foreground='#ff5555'>Weather N/A</span>"
        return
    end

    local data, _, err = json.decode(body, 1, nil)
    if err or not data or not data.main or not data.weather then
        weather_text.markup = "<span foreground='#ff5555'>Parse error</span>"
        return
    end

    local temp     = data.main.temp or 0
    local wind_ms  = data.wind and data.wind.speed or 0
    local wind_deg = data.wind and data.wind.deg or 0
    local wind_kmh = math.floor(wind_ms * 3.6 + 0.5)

    local icon_code = data.weather[1].icon or ""
    local icon      = icon_map[icon_code] or "❔"
    local arrow     = wind_arrow(wind_deg)

    weather_text.markup = string.format(
        "<span foreground='#f1fa8c'>%s</span> " ..
        "<span foreground='#ffb86c'>%d°C</span>  " ..
        "<span foreground='#8be9fd'>%s %dkm/h</span>",
        icon,
        math.floor(temp + 0.5),
        arrow,
        wind_kmh
    )
end

update_weather()

gears.timer {
    timeout   = 900,
    autostart = true,
    call_now  = true,
    callback  = update_weather
}

return weather_widget
