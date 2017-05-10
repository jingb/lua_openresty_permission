local mysql_conf = ngx.shared.address
mysql_conf:set("mysql.host", "127.0.0.1")
mysql_conf:set("mysql.port", "3306")
mysql_conf:set("mysql.db", "shiro2")
mysql_conf:set("mysql.user", "root")
mysql_conf:set("mysql.pass", "jingb")

require "routes"
