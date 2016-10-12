local cookie_new = require"resty.cookie".new
local cookie_bake = require"resty.cookie".bake
-- expire time set
local time          = ngx.time
local http_time     = ngx.http_time
local COOKIE_PATH = require"main.settings".COOKIE.path
local COOKIE_EXPIRES = require"main.settings".COOKIE.expires

local function before(request)
    request.cookies = cookie_new()
end


local function after(request)
    local cookies = {}
    for k, v in pairs(request.cookies) do
        -- assume type(v) is string or table
        if type(v) == 'string' then
            v = {key=k, value=v, path=COOKIE_PATH, max_age=COOKIE_EXPIRES, 
                expires=http_time(time()+COOKIE_EXPIRES)}  
        elseif v.key == nil then
            v.key = k  
        end
        cookies[#cookies+1] = cookie_bake(v)
    end
    -- assume no cookie has been set before
    ngx.header['Set-Cookie'] = cookies 
end

return { before = before, after = after}