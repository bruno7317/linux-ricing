local http  = require("socket.http")
local json  = require("dkjson")
local gears = require("gears")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local api_key = os.getenv("OPENWEATHER_API_KEY")
if not api_key or api_key == "" then
    return function() return { widget = wibox.widget.textbox("No API key") } end
end

local city, units = "Calgary", "metric"
local url = string.format(
    "https://api.openweathermap.org/data/2.5/weather?q=%s&units=%s&appid=%s",
    city, units, api_key
)

------------------------------------------------------------
--  Factory
------------------------------------------------------------
return function(opts)
    opts = opts or {}
    local text_color = opts.text  or "#FFFFFF"
    local bg_color   = opts.bg    or "#000000AA"

    --------------------------------------------------------
    -- Widgets
    --------------------------------------------------------
    local weather_text = wibox.widget {
        widget = wibox.widget.textbox,
        align  = "center",
        valign = "center",
        font   = opts.font or "Ubuntu Mono Bold 16",
    }

    local weather_widget = wibox.widget {
        {
            weather_text,
            margins = dpi(6),
            widget  = wibox.container.margin,
        },
        bg           = bg_color,
        shape        = gears.shape.rounded_bar,
        widget       = wibox.container.background,
        forced_width = dpi(180),
        forced_height= dpi(36),
    }

    --------------------------------------------------------
    -- State + helpers
    --------------------------------------------------------
    local feels_like, wind_kmh = 0, 0
    local function redraw()
        weather_text.markup = string.format(
            "<span foreground='%s'>%d°C</span>   " ..
            "<span foreground='%s'>%dkm/h</span>",
            text_color, feels_like, text_color, wind_kmh
        )
        weather_widget.bg = bg_color
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

    -- Start timer
    gears.timer {
        timeout   = 900,
        autostart = true,
        call_now  = true,
        callback  = update_weather,
    }

    --------------------------------------------------------
    -- Public API
    --------------------------------------------------------
    local function refresh(new_opts)
        if new_opts then
            text_color = new_opts.text or text_color
            bg_color   = new_opts.bg   or bg_color
        end
        redraw()
    end

    redraw()  -- initial draw
    return { widget = weather_widget, refresh = refresh }
end
