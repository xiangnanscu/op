-- lua manage.lua user -fields username password avatar openid
-- lua manage.lua thread -fields user::User title content:text 
local function make_dir(s)
  local cmd, dmt, e;
  if package.config:sub(1,1) == '\\' then
    cmd = 'md'
    dmt = '\\'
    e = '/'
  else
    cmd = 'mkdir'
    dmt = '/'  
    e = '\\' 
  end
  local line = string.format('%s %s', cmd, s:gsub(e, dmt))
  return os.execute(line)
end
local date = os.date("*t",os.time())
date = string.format('%s-%s-%s %s:%s:%s', date.year, date.month, date.day, date.hour, date.min, date.sec)
local head = [[-- Generated by file `manage.lua` at %s. Inspired by Django. 
-- Modify it as you wish.
]]
head = string.format(head, date)
local file_map = {
  urls = [[local ClassView = require"resty.mvc.view"
local views = require"app.{*name*}.views"
local models = require"app.{*name*}.models"
local forms = require"app.{*name*}.forms"

local {*model_name*} = models.{*model_name*}

return {
  {'^/{*name*}/create$',              ClassView.CreateView:as_view{model={*model_name*},form_class=forms.{*model_name*}CreateForm}}, 
  {'^/{*name*}/update/(?<id>\\d+?)$', ClassView.UpdateView:as_view{model={*model_name*},form_class=forms.{*model_name*}UpdateForm}}, 
  {'^/{*name*}/list/(?<page>\\d+?)$', ClassView.ListView:as_view{model={*model_name*}}}, 
  {'^/{*name*}/(?<id>\\d+?)$',        ClassView.DetailView:as_view{model={*model_name*}}}, 
}]], 
  views = [[local json = require "cjson.safe"
local query = require"resty.mvc.query".single
local response = require"resty.mvc.response"
local ClassView = require"resty.mvc.view"
local models = require"app.{*name*}.models"
local forms = require"app.{*name*}.forms"

local {*model_name*} = models.{*model_name*}
local views = {}

-- function views.foobar(request, kwargs)
--     return response.Template("/")
-- end

return views
]], 
  models = [[local Model = require"resty.mvc.model"
local Field = require"resty.mvc.field"
{*require_hooks*}

local {*model_name*} = Model:class{table_name = "{*name*}", 
    fields = {
        create_time = Field.DateTimeField{},
        update_time = Field.DateTimeField{},
        {*fields*}
    }
}
-- function {*model_name*}.foobar(self)
--   -- define your model methods here like this
-- end

return {
  {*model_name*} = {*model_name*}, 
}]], 
  forms = [[local Form = require"resty.mvc.form"
local Field = require"resty.mvc.field"
local validator = require"resty.mvc.validator"
local models = require"app.{*name*}.models"
{*require_hooks*}

local {*model_name*} = models.{*model_name*}

local {*model_name*}CreateForm = Form:class{model = {*model_name*}, 
    fields = {
        create_time = Field.DateTimeField{},
        update_time = Field.DateTimeField{},
        {*fields*}
    }, 
}
-- function {*model_name*}CreateForm.clean_foobar(self, value)
--     -- define your form method here like this
--     return value
-- end


local {*model_name*}UpdateForm = Form:class{model = {*model_name*}, 
    fields = {
        create_time = Field.DateTimeField{},
        update_time = Field.DateTimeField{},
        {*fields*}
    }, 
}
-- function {*model_name*}UpdateForm.clean_foobar(self, value)
--     -- define your form method here like this
--     return value
-- end

return {
    {*model_name*}CreateForm = {*model_name*}CreateForm, 
    {*model_name*}UpdateForm = {*model_name*}UpdateForm, 
}]], 
}

local html_map = {
  create = [[
<form method="post">
  {*form:render()*}
  <button type="submit">create</button>
</form>]], 
  update = [[
<form method="post">
  {*form:render()*}
  <button type="submit">update</button>
</form>]], 
  detail = [[
<table class="table">
{%for k,v in pairs(object) do%}
  <tr>
    <th>{{k}}</th>
    <td>{{v}}</td>
  </tr>
{% end%}
</table>]], 
  list = [[
<table class="table">
  {% if object_list[1] then %}
    <tr>
      {%for k,v in pairs(object_list[1]) do%}
      <th>{{k}}</th>
      {% end%}
    </tr>
    {% for i, u in ipairs(object_list) do%}
    <tr>
      {%for k,v in pairs(u) do%}
      <td> {{v}} </td>
      {% end%}
    </tr>
    {% end%}
  {% else%}
    no records
  {% end%}
</table>]], 
}

local field_map = {
  string = "CharField", 
  int = "IntergerField", 
  text = "TextField", 
  float = "FloatField", 
  datetime = "DateTimeField", 
  date = "DateField", 
  foreignkey = "ForeignKey", 
} 
local config = {}
local name = arg[1]
local model_name = name:sub(1, 1):upper()..name:sub(2)

local i = 2
if arg[2] == '-fields' then
  config.layout = 'layout/c10.html'
  config.block = 'content'
  i = i+1
else
  local STATE = 'key'
  local key, value;
  while true do
    local v = arg[i]
    if STATE == 'key' then
      key = v:sub(2)
      if key == 'fields' then
        i = i+1
        break
      end
      STATE = 'value'
    else
      config[key] = v
      STATE = 'key'
    end
    i = i+1
  end
end
local dir = 'app/'..name..'/'
local res, err = make_dir(dir)
if not res then
  print('FAIL to create dir: '..dir..' '..err)
  return
else
  print('create dir : '..dir)
end
local template_dir = string.format('%shtml/%s/', dir, name)
local res, err = make_dir(template_dir)
if not res then
  print('FAIL to create dir: '..template_dir..' '..err)
  return
else
  print('create dir : '..template_dir)
end
local layout = config.layout or config.l 
local block = config.block or config.b
for k,v in pairs(html_map) do
  local fn = template_dir..k..'.html'
  local f, e = io.open(fn, "w+")
  if not f then
    return nil, e
  end
  if block then
    v = string.format('{-%s-}\n%s\n{-%s-}', block, v, block)
  end
  if layout then
    v = string.format('{%% layout = "%s" %%}\n\n', layout)..v
  end
  f:write(v)
  local res, err = f:close()
  if not res then
    print('FAIL to create file: '..fn..' '..err)
    return
  else
    print('create file: '..fn)
  end
end
local fields = {}
local indent = '        ' --8 spaces
local require_hooks = {}
while true do
  local s = arg[i]
  if not s then
    break
  end
  local column_name,column_type 
  local foreignkey = false
  column_name = string.match(s, [[^([%w_]+)$]])
  if column_name then
    column_type = 'string'
  else
    column_name,column_type  = string.match(s, [[^([%w_]+):([%w_]+)$]])
    if not column_name then --check foreign key
      column_name,column_type  = string.match(s, [[^([%w_]+)::([%w_]+)$]])
      assert(column_name, string.format('fail to parse `%s`, valid form is `column_name:column_type`', s))
      foreignkey = true
    end
  end
  local field_string = ''
  if foreignkey then
    local model = column_type
    field_string = string.format('%s = Field.ForeignKey{%s}', column_name, model)
    require_hooks[#require_hooks+1] = string.format('local %s = require"app.%s.models".%s', model, column_name, model)
  else
    local field_template;
    if column_type == 'string' or column_type == 'text' then
      field_template = '%s = Field.%s{maxlen=50}'
    else
      field_template = '%s = Field.%s{}'
    end
    field_string = string.format(field_template, column_name, field_map[column_type] or 'CharField')
  end
  fields[#fields+1] = field_string
  i = i+1
end
local context = {name=name, model_name=model_name, fields=table.concat(fields, ',\n'..indent), 
  require_hooks = table.concat(require_hooks, '\n'), 
}
for name, template in pairs(file_map) do
  for k,v in pairs(context) do
    template = template:gsub('{%*'..k..'%*}', v)
  end
  local fn = dir..name..'.lua'
  local f, e = io.open(fn, "w+")
  if not f then
    return nil, e
  end
  f:write(head..template)
  local res, err = f:close()
  if not res then
    print('FAIL to create file: '..fn..' '..err)
    return
  else
    print('create file: '..fn)
  end
end

