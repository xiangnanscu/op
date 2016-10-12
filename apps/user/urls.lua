-- Generated by file `manage.lua` at Wed Oct 12 11:16:05 2016.  
local ClassView = require"resty.mvc.view"
local views = require"apps.user.views"
local models = require"apps.user.models"
local forms = require"apps.user.forms"

local User = models.User

return {
    {
      '^/user/create$',              
      ClassView.CreateView:as_view{
        model      = User,
        form_class = forms.UserCreateForm,
      }
    },
  
    {
      '^/user/update/(?<id>\\d+?)$',              
      ClassView.UpdateView:as_view{
        model      = User,
        form_class = forms.UserUpdateForm,
      }
    },

    {
      '^/user/list/(?<page>\\d+?)$',              
      ClassView.ListView:as_view{
        model = User,
      }
    },

    {
      '^/user/(?<id>\\d+?)$',              
      ClassView.DetailView:as_view{
        model = User,
      }
    },

    {
      '^/user/delete/(?<id>\\d+?)$',              
      ClassView.DeleteView:as_view{
        model = User,
      }
    },
}