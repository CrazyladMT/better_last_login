local SECS_PER_DAY = 86400
local SECS_PER_HOUR = 3600
local format = string.format
local floor = math.floor

local function possessive(name)
    if name:sub(-1):lower() == "s" then
        return name .. "'"
    else
        return name .. "'s"
    end
end

local function time_ago(diff)
    if diff < SECS_PER_HOUR then
        local minutes = floor(diff / 60)
        return format("%d minute%s ago", minutes, minutes ~= 1 and "s" or "")
    elseif diff < SECS_PER_DAY then
        local hours = floor(diff / SECS_PER_HOUR)
        return format("%d hour%s ago", hours, hours ~= 1 and "s" or "")
    else
        local days = floor(diff / SECS_PER_DAY)
        if days < 30 then
            return format("%d day%s ago", days, days ~= 1 and "s" or "")
        elseif days < 365 then
            local months = floor(days / 30)
            return format("%d month%s ago", months, months ~= 1 and "s" or "")
        else
            local years = floor(days / 365)
            return format("%d year%s ago", years, years ~= 1 and "s" or "")
        end
    end
end

local function handle_last_login(name, param)
    if param == "" then
        param = name
    end

    local auth = core.get_auth_handler().get_auth(param)
    if not auth or not auth.last_login or auth.last_login == -1 then
        return false, format("%s has never logged in.", param)
    end

    local now = os.time()
    local diff = os.difftime(now, auth.last_login)
    local formatted_time = os.date("!%B %d, %Y - %H:%M UTC", auth.last_login)
    local ago_str = time_ago(diff)

    return true, format("%s last login was %s (%s)", possessive(param), formatted_time, ago_str)
end

core.override_chatcommand("last-login", {
    description = "Show when a player last logged in",
    params = "[playername]",
    func = handle_last_login,
})
