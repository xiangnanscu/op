-- luajit manage.lua user -app_name accounts -fields username password 
-- luajit manage.lua profile -fields user::User age:int weight:float height:float money:float
-- luajit manage.lua detail -fields sex:bool age:int info::Moreinfo
-- luajit manage.lua product -fields name price:float
-- luajit manage.lua record -fields buyer::User seller::User product::Product count:int time:datetime

local default = {
  output_path = 'apps',
  package_prefix = 'apps.',
  app_name = nil,
  layout = 'base.html',
  block = 'main',
}

local field_map = {
  string = "CharField", 
  int = "IntegerField", 
  text = "TextField", 
  float = "FloatField", 
  datetime = "DateTimeField", 
  date = "DateField", 
  time = "TimeField", 
  bool = 'BooleanField', 
} 

local function make_file(fn, content, context)
  for k, v in pairs(context or {}) do
    content = content:gsub('<%*'..k..'%*>', v)
  end
  local f, e = io.open(fn, "w+")
  if not f then
    return nil, e
  end
  local res, err = f:write(content)
  if not res then
    return nil, err
  end
  local res, err = f:close()
  if not res then
    return nil, err
  end
  return true
end

local make_dir
if package.config:sub(1,1) == '\\' then
  -- its windows
  function make_dir(s)
    local line = string.format('mkdir -p %s', s:gsub('/', '\\'))
    return os.execute(line)
  end
else
  function make_dir(s)
    local line = string.format('mkdir -p %s', s:gsub('\\', '/'))
    return os.execute(line)
  end
end

local head = [[-- Generated by file `manage.lua` at %s.  
]]
head = string.format(head, os.date())
local lua_files = {
  urls = [[local ClassView = require"resty.mvc.view"
local views = require"<*package_prefix*><*app_name*>.views"
local models = require"<*package_prefix*><*app_name*>.models"
local forms = require"<*package_prefix*><*app_name*>.forms"

local <*model_name*> = models.<*model_name*>

return {
    {
      '/<*app_name*>/<*name*>/create',              
      ClassView.CreateView:as_view{
        model      = <*model_name*>,
        form_class = forms.<*model_name*>CreateForm,
      }
    },
  
    {
      '/<*app_name*>/<*name*>/update',              
      ClassView.UpdateView:as_view{
        model      = <*model_name*>,
        form_class = forms.<*model_name*>UpdateForm,
      }
    },

    {
      '/<*app_name*>/<*name*>/list',              
      ClassView.ListView:as_view{
        model = <*model_name*>,
      }
    },

    {
      '/<*app_name*>/<*name*>',              
      ClassView.DetailView:as_view{
        model = <*model_name*>,
      }
    },

    {
      '/<*app_name*>/<*name*>/delete',              
      ClassView.DeleteView:as_view{
        model = <*model_name*>,
      }
    },
}]], 
  views = [[local json = require "cjson.safe"
local Response = require"resty.mvc.response"
local ClassView = require"resty.mvc.view"
local query = require"resty.mvc.query".single
local models = require"<*package_prefix*><*app_name*>.models"
local forms = require"<*package_prefix*><*app_name*>.forms"

local <*model_name*> = models.<*model_name*>

-- function <*name*>_home(request)
--     return Response.Template(request, "<*name*>/home.html")
-- end

return {
    --  <*name*>_home = <*name*>_home,
}
]], 
  models = [[local Model = require"resty.mvc.model"
local Field = require"resty.mvc.modelfield"
<*require_hooks*>

local <*model_name*> = Model:class{
    meta   = {

    },
    fields = {
        <*fields*>
    }
}
-- define your model methods here
-- function <*model_name*>.render(self)
--     return 
-- end

return {
  <*model_name*> = <*model_name*>, 
}]], 
  forms = [[local Form = require"resty.mvc.form"
local Widget = require"resty.mvc.widget"
local Field = require"resty.mvc.formfield"
local Validator = require"resty.mvc.validator"
local models = require"<*package_prefix*><*app_name*>.models"
<*require_hooks*>

local <*model_name*> = models.<*model_name*>

local <*model_name*>CreateForm = Form:class{
    model  = <*model_name*>, 
    fields = {
        <*fields*>
    }, 
}
-- custom form initialization
-- function <*model_name*>CreateForm.instance(cls, attrs)
--     local self = Form.instance(cls, attrs)
--     return self
-- end

-- define your form clean method here
-- function <*model_name*>CreateForm.clean_fieldname(self, value)
--     return value
-- end


local <*model_name*>UpdateForm = Form:class{
    model  = <*model_name*>, 
    fields = {
        <*fields*>
    }, 
}

return {
    <*model_name*>CreateForm = <*model_name*>CreateForm, 
    <*model_name*>UpdateForm = <*model_name*>UpdateForm, 
}]], 
}

local html_files = {
  create = [[
<form method="post">
  {*form:render()*}
  <button type="submit">create</button>
</form>]], 
  update = [[
<form method="post">
  {*form:render()*}
  <button type="submit">update></button>
</form>]], 
  detail = [[
<table class="table table-hover table-striped">
{% for k, v in pairs(object) do %}
  <tr>
    <th>{{k}}</th>
    {% local fk = object.__model.foreignkeys[k] %}
    {% if fk then %}
      <td><a href="{{v:get_url()}}">{{v}}</a></td>
    {% else %}
      <td>{{v}}</td>
    {% end %}
  </tr>
{% end %}
</table>
<a href="/<*app_name*>/{{object.__model.meta.url_model_name}}/update/{{object.id}}" class="btn btn-default">edit</a>
]], 
  list = [[
<table class="table table-hover table-striped">
  {% if object_list[1] then %}
    <tr>
      {%for k, v in pairs(object_list[1]) do%}
        <th>{{k}}</th>
      {% end%}
      <th>Actions</th>
    </tr>
    {% for i, object in ipairs(object_list) do%}
    {% local url_model_name = object.__model.meta.url_model_name %}
    <tr>
      {%for k, v in pairs(object) do%}
        {% local fk = object.__model.foreignkeys[k] %}
        {% if fk then %}
          <td><a href="/{{fk.meta.app_name}}/{{fk.meta.url_model_name}}/update/{{v.id}}">{{v}}</a></td>
        {% else %}
          <td>{{v}}</td>
        {% end %}
      {% end %}
      <td>
        <a href="/<*app_name*>/{{url_model_name}}/{{object.id}}" class="btn btn-default">detail</a>
        <a href="/<*app_name*>/{{url_model_name}}/update/{{object.id}}" class="btn btn-default">edit</a>
        <a href="/<*app_name*>/{{url_model_name}}/delete/{{object.id}}" class="btn btn-default">delete</a>
      </td>
    </tr>
    {% end %}
  {% else %}
    <p>No records</p>
  {% end %}
</table>]], 
}
local function capitalize(name)
  return name:sub(1, 1):upper()..name:sub(2)
end

local user_defined = {}
local name = arg[1]
local model_name = capitalize(name)

local i = 2
if arg[2] == '-fields' then
  i = i + 1
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
      user_defined[key] = v
      STATE = 'key'
    end
    i = i+1
  end
end
for k, v in pairs(user_defined) do
  default[k] = v
end
if not default.app_name then
  default.app_name = name
end
-- it does not matter the output_path exists
make_dir(default.output_path)

-- make app dir
local dir = string.format('%s/%s',default.output_path, default.app_name)
local res, err = make_dir(dir)
assert(res, string.format('fail to create `%s`: %s.',dir, err))
print('create dir : '..dir)

-- make template dir
local template_dir = string.format('%s/html/%s', dir, default.app_name)
local res, err = make_dir(template_dir)
assert(res, string.format('fail to create `%s`: %s.',template_dir, err))
print('create dir : '..template_dir)

local layout = default.layout or default.l 
local block = default.block or default.b
-- make html template files
for k, v in pairs(html_files) do
  if block then
    v = string.format('{-%s-}\n%s\n{-%s-}', block, v, block)
  end
  if layout then
    v = string.format('{%% layout = "%s" %%}\n\n', layout)..v
  end
  local fn = string.format('%s/%s.html',template_dir, k) 
  local res, err = make_file(fn, v, 
    { name=name, 
      app_name=default.app_name,
    })
  assert(res, string.format('fail to create `%s`: %s.',fn, err))
  print('create file: '..fn)
end

-- MAKE LUA FILES
local fields = {}
local indent = '        ' --8 spaces
local require_hooks = {}
local foreignkeys = {} -- register foreignkey already defined
while true do
  local s = arg[i]
  if not s then
    break
  end
  local coln, colt, colapp 
  local foreignkey = false
  coln = string.match(s, [[^([%w_]+)$]])
  if coln then -- shortcuts for string type
    colt = 'string'
  else
    coln, colt  = string.match(s, [[^([%w_]+):([%w_]+)$]])
    if not coln then --check foreign key
      -- user::User
      coln, colt  = string.match(s, [[^([%w_]+)::([%w_]+)$]])
      if not coln then
        -- user::accounts::User
        coln, colapp, colt  = string.match(s, [[^([%w_]+)::([%w_]+)::([%w_]+)$]])
        assert(coln, string.format(
          'fail to parse `%s`, valid form is `name:type` or `foreignkey::modelname` or `foreignkey::appname::modelname` ', s))
      end
      if not colapp then
        colapp = colt:lower() 
      end
      foreignkey = true
    end
  end
  local field_string = ''
  if foreignkey then
    local model = colt -- User
    local model_module = colapp..'.'..model
    field_string = string.format('%s = Field.ForeignKey{%s}', coln, model)
    if not foreignkeys[model_module] then
      foreignkeys[model_module] = true
      require_hooks[#require_hooks+1] = string.format('local %s = require"%s%s.models".%s', 
        model, default.package_prefix, colapp, model)
    end
  else
    local field_template;
    if colt == 'string' or colt == 'text' then
      field_template = '%s = Field.%s{maxlen=50}'
    else
      field_template = '%s = Field.%s{}'
    end
    field_string = string.format(field_template, coln, field_map[colt] or 'CharField')
  end
  fields[#fields+1] = field_string
  i = i+1
end
local context = {
  name=name, 
  model_name=model_name, 
  app_name=default.app_name,
  fields=table.concat(fields, ',\n'..indent), 
  require_hooks = table.concat(require_hooks, '\n'), 
  package_prefix=default.package_prefix,
}
for k, template in pairs(lua_files) do
  local fn = string.format('%s/%s.lua',dir, k)
  local res, err = make_file(fn, head..template, context)
  assert(res, string.format('fail to create `%s`: %s.',fn, err))
  print('create file: '..fn)  
end

