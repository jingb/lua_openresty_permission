local _M = {}
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local cjson = require "cjson"

function _M.req(url, req_param, method, decode)
    local resp = ngx.location.capture(url, {
        -- method = ngx.HTTP_GET,
        method = method,
        args = {jsonparam = req_param}
    })

    if not resp then
        ngx_log(ngx_ERR, "request error :", err)
        return
    end

    if resp.status ~= 200 then
        ngx_log(ngx_ERR, "request error, status :", resp.status)
        return
    end
    
    if decode then
      --ngx_log(ngx_ERR, "type is ", type(cjson.decode(resp.body)))
      return cjson.decode(resp.body)
    end

    return resp.body
end

return _M
