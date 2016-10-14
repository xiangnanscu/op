-- Generated by file `manage.lua` at Fri Oct 14 13:25:50 2016.  
local ClassView = require"resty.mvc.view"
local views = require"apps.product.views"
local models = require"apps.product.models"
local forms = require"apps.product.forms"

local Product = models.Product

return {
    {
      '^/product/create$',              
      ClassView.CreateView:as_view{
        model      = Product,
        form_class = forms.ProductCreateForm,
      }
    },
  
    {
      '^/product/update/(?<id>\\d+?)$',              
      ClassView.UpdateView:as_view{
        model      = Product,
        form_class = forms.ProductUpdateForm,
      }
    },

    {
      '^/product/list/(?<page>\\d+?)$',              
      ClassView.ListView:as_view{
        model = Product,
      }
    },

    {
      '^/product/(?<id>\\d+?)$',              
      ClassView.DetailView:as_view{
        model = Product,
      }
    },

    {
      '^/product/delete/(?<id>\\d+?)$',              
      ClassView.DeleteView:as_view{
        model = Product,
      }
    },
}