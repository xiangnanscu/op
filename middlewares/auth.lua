local Query = require"resty.model".RawQuery

local function before(req, kwargs)
    req.user = req.session.user
end

return { before = before}