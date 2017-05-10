-- a demo about simulate get data from redis via openResty, and if get nothing from redis, the request will forward to the tomcat server and get data from mysql, asyn write to redis and then send back to the client

local redis = require("resty.redis")  
-- local cjson = require("cjson")  
local cjson_encode = cjson.encode
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_exit = ngx.exit
local ngx_print = ngx.print
local ngx_re_match = ngx.re.match
local ngx_var = ngx.var

local function close_redis(red)
    if not red then
        return
    end
    local pool_max_idle_time = 10000 
    local pool_size = 100 
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)

    if not ok then
        ngx_log(ngx_ERR, "set redis keepalive error : ", err)
    end
end


local function read_redis(key)
    local red = redis:new()
    red:set_timeout(1000)
    local ip = "127.0.0.1"
    local port = 6379
    local ok, err = red:connect(ip, port)
    if not ok then
        ngx_log(ngx_ERR, "connect to redis error : ", err)
        return close_redis(red)
    end

    local resp, err = red:get(key)
    if not resp then
        ngx_log(ngx_ERR, "get redis content error : ", err)
        return close_redis(red)
    end

    if resp == ngx.null then
        resp = nil
    end
    close_redis(red)

    return resp
end

local function read_http(key)
    local resp = ngx.location.capture("/tomcat/alldemo/dwz/getDataFromMysql", {
        method = ngx.HTTP_GET,
        args = {key = key}
    })

    if not resp then
        ngx_log(ngx_ERR, "request error :", err)
        return
    end

    if resp.status ~= 200 then
        ngx_log(ngx_ERR, "request error, status :", resp.status)
        return
    end

    return resp.body
end

--get key
local key = ngx_var.key

--get data from redis
local content = read_redis(key)

--get nothing，forward to the tomcat
if not content then
   ngx_log(ngx_ERR, "redis not found content, back to http, key : ", key)
    content = read_http(key)
end

if not content then
   ngx_log(ngx_ERR, "http not found content, key : ", key)
   return ngx_exit(404)
end

ngx.print("get data from server: ")
--ngx_print({content = content})
ngx_print(cjson_encode({content = content}))
