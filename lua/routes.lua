local route = require "resty.route".new()
local user = require "user.user"
local book = require "book.book"

-- ngx.log(ngx.ERR, "come into router")  

route {"get", "post"} "~^/book/(update|create|delete|query)/?([0-9]*)$" 
(book.handle)

return route
