-- Generated by file `manage.lua` at 2016-9-9 0:44:1. Inspired by Django. 
-- Modify it as you wish.
local Model = require"resty.mvc.model"
local Field = require"resty.mvc.field"


local User = Model:class{table_name = "user", 
    meta = {auto_create_time=false,auto_update_time=false},
    fields = {
        username = Field.CharField{maxlen=3,default=''},
        password = Field.CharField{maxlen=6,default=''},
    }
}
-- function User.foobar(self)
--   -- define your model methods here like this
-- end

return {
  User = User, 
}