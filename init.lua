local modname = core.get_current_modname()
local S, PS = core.get_translator(modname)

local date_format = core.settings:get("better_last_login_date_format") or "mdy"

local SECS_PER_DAY = 86400
local SECS_PER_HOUR = 3600
local floor = math.floor

local months = {
    S("January"), S("February"), S("March"), S("April"), S("May"), S("June"),
    S("July"), S("August"), S("September"), S("October"), S("November"), S("December")
}

local function time_ago(diff)
    if diff < SECS_PER_HOUR then
        local minutes = floor(diff / 60)
        return PS("@1 minute ago", "@1 minutes ago", minutes, tostring(minutes))
    elseif diff < SECS_PER_DAY then
        local hours = floor(diff / SECS_PER_HOUR)
        return PS("@1 hour ago", "@1 hours ago", hours, tostring(hours))
    else
        local days = floor(diff / SECS_PER_DAY)
        if days < 30 then
            return PS("@1 day ago", "@1 days ago", days, tostring(days))
        elseif days < 365 then
            local months_count = floor(days / 30)
            return PS("@1 month ago", "@1 months ago", months_count, tostring(months_count))
        else
            local years = floor(days / 365)
            return PS("@1 year ago", "@1 years ago", years, tostring(years))
        end
    end
end

local function format_date(timestamp)
    local year = tonumber(os.date("!%Y", timestamp))
    local month_num = tonumber(os.date("!%m", timestamp))
    local day = tonumber(os.date("!%d", timestamp))

    local month_name = months[month_num]

    if date_format == "dmy" then
        -- 14 June 2026 (international style)
        return S("@1 @2 @3", day, month_name, year)
    else
        -- June 14, 2026 (default US style)
        return S("@1 @2, @3", month_name, day, year)
    end
end

local normalize_name = core.get_modpath("canonical_name") and canonical_name.get or function () end

local function handle_last_login(name, param)
    if param == "" then
        param = name
    end

    param = normalize_name(param) or param

    local auth = core.get_auth_handler().get_auth(param)
    if not auth or not auth.last_login or auth.last_login == -1 then
        return false, S("@1 has never logged in.", param)
    end

    local now = os.time()
    local diff = os.difftime(now, auth.last_login)
    local formatted_time = format_date(auth.last_login) .. os.date("! - %H:%M UTC", auth.last_login)
    local ago_str = time_ago(diff)

    return true, S("@1 last logged in on @2 (@3)", param, formatted_time, ago_str)
end

core.override_chatcommand("last-login", {
    func = handle_last_login,
})
