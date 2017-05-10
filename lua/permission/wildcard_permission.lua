local cjson = require "cjson"
local _M = {}

function _M.implies(req_permission, permissions) 
  for index, val in ipairs(permissions) do 
    --ngx.say("index: ", index, " val: ", cjson.encode(val))
    --ngx.say("index: ", index, " val: ", type(val))
    ngx.say(val['permission'])
  end
end

return _M


