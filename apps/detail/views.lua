-- Generated by file `manage.lua` at Wed Oct 12 11:16:56 2016.  
local json = require "cjson.safe"
local Response = require"resty.mvc.response"
local ClassView = require"resty.mvc.view"
local query = require"resty.mvc.query".single
local models = require"apps.detail.models"
local forms = require"apps.detail.forms"

local Detail = models.Detail
local views = {}

-- function views.method(request)
--     return Response.Template("/")
-- end

return views
