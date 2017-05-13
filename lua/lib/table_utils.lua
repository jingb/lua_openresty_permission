local _M = {}
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR

function _M.log(table) 
  for i, v in pairs(table) do 
    if type(v) == "table" then 
        for new_table_index, new_table_value in pairs(v) do 
          ngx_log(ngx_ERR, "parent key is: ", i , " key is: ", new_table_index, " value is: ", new_table_value)  
        end 
    else 
      ngx_log(ngx_ERR, "key is: ", i, " value is: ", v)  
    end 
  end 
end
 
return _M
