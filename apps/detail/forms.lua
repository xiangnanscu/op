-- Generated by file `manage.lua` at Wed Oct 12 11:16:56 2016.  
local Form = require"resty.mvc.form"
local Widget = require"resty.mvc.widget"
local Field = require"resty.mvc.formfield"
local Validator = require"resty.mvc.validator"
local models = require"apps.detail.models"
local Moreinfo = require"apps.moreinfo.models".Moreinfo

local Detail = models.Detail

local DetailCreateForm = Form:class{
    model  = Detail, 
    fields = {
        sex = Field.BooleanField{},
        age = Field.IntegerField{},
        info = Field.ForeignKey{Moreinfo}
    }, 
}
-- function DetailCreateForm.clean_fieldname(self, value)
--     -- define your form method here
--     return value
-- end


local DetailUpdateForm = Form:class{
    model  = Detail, 
    fields = {
        sex = Field.BooleanField{},
        age = Field.IntegerField{},
        info = Field.ForeignKey{Moreinfo}
    }, 
}
-- function DetailUpdateForm.clean_fieldname(self, value)
--     -- define your form method here
--     return value
-- end

return {
    DetailCreateForm = DetailCreateForm, 
    DetailUpdateForm = DetailUpdateForm, 
}