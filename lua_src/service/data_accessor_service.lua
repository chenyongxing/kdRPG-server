local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local sharedata = require "skynet.sharedata"

require("utils.utils")

local user = require("dao.user_dao")
local player = require("dao.player_dao")
local mail = require("dao.mail_dao")

local function registerDb(db)
    user.setDB(db)
    player.setDB(db)
    mail.setDB(db)
end

skynet.start(function () 
    local mysql_config = CopyTable(sharedata.query("server_config").mysql_db)
    mysql_config.max_packet_size = 1024 * 1024
    mysql_config.on_connect = function ( ... )
        skynet.error("Mysql连接成功")
    end
    
    local mysql_db = mysql.connect(mysql_config)
    registerDb(mysql_db)

    skynet.dispatch("lua", function(session, source, cmd, sub_cmd, ...)
        if cmd == "user" then
            skynet.ret(skynet.pack(user[sub_cmd](...)))
        elseif cmd == "player" then
            skynet.ret(skynet.pack(player[sub_cmd](...)))
        elseif cmd == "mail" then
            skynet.ret(skynet.pack(mail[sub_cmd](...)))
        end
	end)
end)

function checkError(res)
    if res.err then
        print(DumpTable(res))
        error()
    end
end
