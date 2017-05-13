local table_utils = require "lib.table_utils"
local _M = {}
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR

local function query(instance)
  ngx_log(ngx_ERR, "do book query business, and instance is: ", instance)
end

local function delete(instance)
  ngx_log(ngx_ERR, "do book deletion business, and instance is: ", instance)
end

function _M.handle() 
  ngx_log(ngx_ERR, "request uri is: ", ngx.var.request_uri, " and we can parse the model, action and instance from the request uri")
  -- simulate the action and instance id
  local action = "query"
  query(1)
end

return _M
