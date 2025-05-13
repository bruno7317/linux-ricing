-- ~/.config/awesome/weather.lua
------------------------------------------------------------
local http  = require("socket.http")
local json  = require("dkjson")
local gears = require("gears")
local wibox = require("wibox")
local fs    = gears.filesystem

------------------------------------------------------------
-- Config
------------------------------------------------------------
local api_key = os.getenv("OPENWEATHER_API_KEY")
if not api_key or api_key == "" then
    return wibox.widget.textbox("No API key")
end

local city  = "Calgary"
local units = "metric"  -- or "imperial"

local url = string.format(
    "https://api.openweathermap.org/data/2.5/weather?q=%s&units=%s&appid=%s",
    city, units, api_key
)

------------------------------------------------------------
-- Background image mapping
------------------------------------------------------------
local images_dir = fs.get_configuration_dir() .. "weather_images/"
local default_bg = images_dir .. "default.jpg"  -- fallback image

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() end
    return f ~= nil
end

local function icon_to_image(icon_code)
    local path = images_dir .. icon_code .. ".jpg"
    if file_exists(path) then
        return path
    else
        return default_bg
    end
end

------------------------------------------------------------
-- Widgets
------------------------------------------------------------
local weather_text = wibox.widget {
    widget = wibox.widget.textbox,
    align  = "center",
    valign = "center",
    font   = "Iosevka Nerd Font Bold 14"
}

local bg_image = wibox.widget {
    id         = "bg",
    widget     = wibox.widget.imagebox,
    resize     = true,
    clip_shape = gears.shape.rounded_bar
}

local weather_widget = wibox.widget {
    {
        layout = wibox.layout.stack,
        bg_image,
        {
            weather_text,
            left   = 10,
            right  = 10,
            top    = 5,
            bottom = 5,
            widget = wibox.container.margin
        }
    },
    shape  = gears.shape.rounded_bar,
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

    local feels_like = data.main.feels_like or 0
    local wind_ms    = data.wind and data.wind.speed or 0
    local wind_kmh   = math.floor(wind_ms * 3.6 + 0.5)

    local icon_code = data.weather[1].icon or ""
    bg_image.image = icon_to_image(icon_code)

    weather_text.markup = string.format(
        "<span foreground='#ffb86c'>%d°C</span>  " ..
        "<span foreground='#8be9fd'>%dkm/h</span>",
        math.floor(feels_like + 0.5),
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
