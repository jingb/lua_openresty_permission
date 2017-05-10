local redis = require "lib.redis_iresty"
local cjson = require "cjson"
-- local pre_utils = require "permission.wildcard_permission"
local http_utils = require "lib.http_utils"
-- local args = ngx.req.get_uri_args()
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_exit = ngx.exit

local req_model = ngx.var.model
local req_action = ngx.var.action
local req_instance = ngx.var.instance

local utils = require "lib.db_utils"
local sql = [[
  select t.name, t.permission, t.url
  from sys_resource t 
  join sys_role t1 on FIND_IN_SET(t.id, t1.resource_ids) 
  join sys_user t2 on FIND_IN_SET(t1.id, t2.role_ids)
  where t2.username = '%s';
]];
local user_name = ngx.var.http_username

if not user_name then
  ngx.say("username header is required")
  ngx_exit(ngx.HTTP_OK)
end

local red = redis:new()
local resources
local user_permission_key = user_name .. "permissions"
local resources_from_redis, err = red:get(user_permission_key)
if not resources_from_redis then 
  resources = utils.db(function(db)
    -- local row, err = db:selectOne("select * from user where id = %d", user_id) 
    local rows, err = db:select(sql, user_name) 
    if not rows then 
	ngx_log(ngx_ERR, "err: ", err)
    end
    return rows
  end)
  local ok, err = red:set(user_permission_key, cjson.encode(resources), 'EX', 3)
  if not ok then
    ngx_log(ngx_ERR, "fail to set permissions to redis", err)
    return
  end
  ngx_log(ngx_ERR, "get permissions from mysql")
else 
  resources = cjson.decode(resources_from_redis)
  ngx_log(ngx_ERR, "get permissions from redis")
end

if type(resources) ~= 'table' or _G.next(resources) == nil then
  ngx.say("user ", user_name, " has no permissions")
  ngx_exit(ngx.HTTP_OK)
end

for i=1, table.maxn(resources) do  
    resources[i] = resources[i]['permission']
end 

--local reqs = {req = 'reqValue'}
local url = "/tomcat/alldemo/permission/isPermitted"
local req_permission = req_model .. ':' .. req_action
if req_instance then req_permission = req_permission .. ":" .. req_instance end

-- local reqs = {reqPermissions = {req_permission}, hasPermissions = cjson.empty_array}
-- ngx_log(ngx_ERR, "resources type: ", type(resources))
-- ngx_log(ngx_ERR, "resources type: ", cjson.encode(resources))
local reqs = {reqPermissions = {req_permission}, hasPermissions = resources}

local resp = http_utils.req(url, cjson.encode(reqs), ngx.HTTP_POST, true)

if not resp then
  ngx.say("server inner error! ")
  return
end

if resp['code'] == '00' and not resp['data'] then
  ngx.exit(ngx.HTTP_FORBIDDEN)
else 
  ngx_log(ngx_ERR, "passed the permissions check")
end


