local cjson = require("cjson")
local obj = {  
    id = 1,  
    name = "zhangsan",  
    age = nil,  
    is_male = false,  
    hobby = {"film", "music", "read"}  
}  
local str = cjson.encode(obj)
--ngx.say(str, "<br>")
ngx.say(str)
