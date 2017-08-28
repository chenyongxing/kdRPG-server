local accessor = {}

local DB
function accessor.setDB(db)
    DB = db
end

function accessor.getMail(mail_id)
    local res = DB:query("select * from mail where mail_id='"..mail_id.."'")
    checkError(res)
    return res[1]
end

function accessor.getPlayerMail(name)
    local res = DB:query("select * from mail where player_name='"..name.."'")
    checkError(res)
    return res
end

return accessor