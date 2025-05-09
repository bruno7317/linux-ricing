-- ~/.config/awesome/weather.lua
------------------------------------------------------------
local http  = require("socket.http")
local json  = require("dkjson")
local gears = require("gears")
local wibox = require("wibox")

------------------------------------------------------------
-- Settings
------------------------------------------------------------
local api_key = "458089dc742c6ef4fa108599e3e54db4"

if not api_key then
    return wibox.widget.textbox("No API key")
end

local city  = "Calgary"
local units = "metric"      -- "imperial" for °F / mph
local url   = string.format(
    "https://api.openweathermap.org/data/2.5/weather?q=%s&units=%s&appid=%s",
    city, units, api_key
)

------------------------------------------------------------
-- Widget + updater
------------------------------------------------------------
local weather_text = wibox.widget {
    widget = wibox.widget.textbox,
    align  = "center",
    font = "Ubuntu Mono Bold 16"
}

local weather_widget = wibox.widget {
    {
        weather_text,
        left   = 8,
        right  = 8,
        top    = 4,
        bottom = 4,
        widget = wibox.container.margin
    },
    shape  = gears.shape.rounded_bar,
    bg     = "#44475a",  -- change this color as desired
    widget = wibox.container.background
}

local function update_weather()
    local body, code = http.request(url)
    if code ~= 200 or not body then
        weather_text.text = "Weather N/A"
        return
    end

    local data, pos, err = json.decode(body, 1, nil)
    if err or not data or not data.main then
        weather_text.text = "Weather err"
        return
    end

    local temp_c   = data.main.temp
    local wind_ms  = data.wind and data.wind.speed or 0
    local wind_kmh = math.floor(wind_ms * 3.6 + 0.5)
    local desc     = data.weather and data.weather[1]
                     and data.weather[1].main or ""

    weather_text.text = string.format("%d°C %dkm/h  %s",
                                        math.floor(temp_c + 0.5),
                                        wind_kmh,
                                        desc)
end

update_weather()
gears.timer {
    timeout   = 900,
    autostart = true,
    call_now  = true,
    callback  = update_weather
}

return weather_widget
