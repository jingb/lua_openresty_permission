local url = ngx.var.request_uri
local reg = '([a-z]+)/(create|query|update|delete)/?(\\d*)'
local m, err = ngx.re.match(url, reg)

ngx.say(m[0])
ngx.say(m[1])
ngx.say(m[2])
