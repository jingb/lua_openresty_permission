local route = require "resty.route".new()
ngx.log(ngx.ERR, "come into router")  

route:get ("=/org/query", function(self)
  ngx.log(ngx.ERR, "match =/org/query")  
end)

-- route {"get", "post"} "~^/book/(update|create|delete|query)/?([0-9]*)$" (function(self) 
--   ngx.log(ngx.ERR, "come in book")  
-- end) 

route {"get", "post"} "~^/book/(update|create|delete|query)/?([0-9]*)$" 
(function(self) 
  ngx.log(ngx.ERR, "$1 is: ", ngx.var.$1)  
end)

return route
