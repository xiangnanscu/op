-- Generated by file `manage.lua` at 2016-9-23 0:33:28.  
local Form = require"resty.mvc.form"
local widget = require"resty.mvc.widget"
local Field = require"resty.mvc.form_field"
local validator = require"resty.mvc.validator"
local models = require"app.user.models"


local User = models.User

local UserCreateForm = Form:class{model = User, 
    fields = {
        username = Field.CharField{maxlen=50},
        password = Field.CharField{maxlen=50},
    }, 
}
-- function UserCreateForm.clean_foobar(self, value)
--     -- define your form method here like this
--     return value
-- end


local UserUpdateForm = Form:class{model = User, 
    fields = {
        username = Field.CharField{maxlen=50},
        password = Field.CharField{maxlen=50},
    }, 
}
-- function UserUpdateForm.clean_foobar(self, value)
--     -- define your form method here like this
--     return value
-- end

return {
    UserCreateForm = UserCreateForm, 
    UserUpdateForm = UserUpdateForm, 
}