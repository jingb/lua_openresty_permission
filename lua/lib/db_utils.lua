local database = require "lib.database"
local _M = {}


function _M.db(fn, ...)
    local db, err = database:new()
    if not db then 
        return nil, err
    end
    db:set_timeout(1000)
    local ok, err = db:connect()
    if not ok then
        return nil, err
    end
    local success, result = pcall(fn, db, ...)
    ok, err = db:set_keepalive(10000, 100)
    if not ok then
        return nil, err
    end
    if not success then return nil, result end
    return result
end


return _M
