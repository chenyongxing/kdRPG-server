local accessor = {}

local DB
function accessor.setDB(db)
    DB = db
end

function accessor.getUser(name, password)
    local res = DB:query("select * from user where name='"..name.."' and password='"..password.."'")
    checkError(res)
    return res[1]
end

function accessor.createUser(name, password)
    local res =DB:query("insert into user (name, password) values ('"..name.."','"..password.."')")
    checkError(res)
end

function accessor.getLastServer(user_id)
    local res =DB:query("select last_server_id from user where id = "..user_id)
    checkError(res)
    return res[1].last_server_id
end

function accessor.saveUserInfo(user_id, server_id)
    local res =DB:query("update user set last_server_id = "..server_id.." where id = "..user_id)
    checkError(res)
end

return accessor