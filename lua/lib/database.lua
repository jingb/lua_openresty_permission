local address = ngx.shared.address
local mysql = require "resty.mysql"
local _M = {}
local mt = {
    __index = _M,
    -- to prevent use of casual module global variables
    __newindex = function(table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end,
}

function _M.new(self)
    local db, err = mysql:new()
    if not db then
        return nil, err
    end
    return setmetatable({db = db}, mt)
end

function _M.set_timeout(self, timeout)
    local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    return db:set_timeout(timeout)
end

function _M.set_keepalive(self, ...)
    local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    return db:set_keepalive(...)
end

function _M.connect(self)
    local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    local res, err, errno, sqlstate = db:connect{
		    host = address:get('mysql.host'),
		    port = address:get('mysql.port'),
		    database = address:get('mysql.db'),
		    user = address:get('mysql.user'),
		    password = address:get('mysql.pass'),
		    max_packet_size = 1024 * 1024
		}
	if not res then
		return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
	end
	res, err, errno, sqlstate = db:query('set names utf8')
	if not res then
		return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
	end
	return 'connected', nil
end

function _M.close(self)
    local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    return db:close()
end

local function format(sql, ...)
    sql = string.format(sql, ...)
    sql = sql:gsub("\\", "\\\\")
    return sql
end

function _M.selectOne(self, sql, ...)
	local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    local res, err, errno, sqlstate = db:query(format(sql, ...), 1)
    if not res then
        return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
    end
    return res[1] or ngx.null, nil
end

function _M.select(self, sql, ...)
    local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    local res, err, errno, sqlstate = db:query(format(sql, ...))
    if not res then
        return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
    end
    if next(res) then
        return res, nil
    else
        return ngx.null, nil
    end
end

function _M.update(self, sql, ...)
	local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    local res, err, errno, sqlstate = db:query(format(sql, ...))
    if not res then
        return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
    end
    return res.affected_rows, nil
end

function _M.delete(self, sql, ...)
    return self:update(sql, ...)
end

function _M.insert(self, sql, ...)
	local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    local res, err, errno, sqlstate = db:query(format(sql, ...))
    if not res then
        return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
    end
    return res.insert_id, nil
end

function _M.procedure(self, sql, ...)
    local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    local res, err, errno, sqlstate = db:query(format(sql, ...))
    if not res then
        return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
    end
    local result = res
    while err == "again" do
        res, err, errno, sqlstate = db:read_result()
        if not res then
            return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
        end
    end
    if not next(result) then result = ngx.null end
    return result, nil
end

-- Usage:
--[[
res, err = db:transaction(function()
	local res, err = db:insert(...)
	if not res then
		error(err)
	end
	res, err = db:insert(...)
	if not res then
		error(err)
	end
	res, err = db:update(...)
	if not res then
		error(err)
	end
end)

if not res then
	return ngx.say('transaction execute failed->', err)
end
]]

function _M.transaction(self, fn)
	local db = self.db
    if not db then
        return nil, "db not initialized"
    end
    local res, err, errno, sqlstate = db:query('START TRANSACTION')
    if not res then
        return nil, 'SQL Error: '..errno..'('..sqlstate..'):'..err
    end
    local ok, err = pcall(fn)
    if ok then 
	   db:query('COMMIT') 
	else 
	   db:query('ROLLBACK') 
	end
	return ok, err
end

return _M
