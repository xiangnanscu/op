local Form = require"resty.mvc.form"
local Widget = require"resty.mvc.widget"
local Field = require"resty.mvc.formfield"
local Validator = require"resty.mvc.validator"
local models = require"apps.account.models"
local AuthUser = require"resty.mvc.apps.auth.models".User

local ProfileCreateForm = Form:class{
    model  = models.Profile, 
    fields = {
        user = Field.ForeignKey{reference=AuthUser},
        age = Field.IntegerField{min=18},
        weight = Field.FloatField{min=10},
        height = Field.FloatField{max=220, min=10},
        money = Field.FloatField{}
    }, 
}
local ProfileUpdateForm = Form:class{
    model  = models.Profile, 
    fields = {
        user = Field.ForeignKey{reference=AuthUser},
        age = Field.IntegerField{min=18},
        weight = Field.FloatField{min=10},
        height = Field.FloatField{max=220, min=10},
        money = Field.FloatField{}
    }, 
}


return {
    ProfileCreateForm = ProfileCreateForm,
    ProfileUpdateForm = ProfileUpdateForm
}