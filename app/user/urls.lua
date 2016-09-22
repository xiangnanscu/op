-- Generated by file `manage.lua` at 2016-9-22 15:21:48. Inspired by Django. 
local ClassView = require"resty.mvc.view"
local views = require"app.user.views"
local models = require"app.user.models"
local forms = require"app.user.forms"

local User = models.User

return {
  {'^/user/create$',              ClassView.CreateView:as_view{model=User,form_class=forms.UserCreateForm}}, 
  {'^/user/update/(?<id>\\d+?)$', ClassView.UpdateView:as_view{model=User,form_class=forms.UserUpdateForm}}, 
  {'^/user/list/(?<page>\\d+?)$', ClassView.ListView:as_view{model=User}}, 
  {'^/user/(?<id>\\d+?)$',        ClassView.DetailView:as_view{model=User}}, 
  {'^/user/delete/(?<id>\\d+?)$', ClassView.DeleteView:as_view{model=User}}, 
}