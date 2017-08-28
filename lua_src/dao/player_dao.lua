local accessor = {}

local DB
function accessor.setDB(db)
    DB = db
end

function accessor.getPlayer(user_id, server_id)
    local res = DB:query("select * from player where user_id="..user_id.." and server_id="..server_id)
    checkError(res)
    return res[1]
end

function accessor.getPlayerById(id)
    local res = DB:query("select * from player where id="..id)
    checkError(res)
    return res[1]
end

function accessor.getPlayerByName(name)
    local res = DB:query("select * from player where name='"..name.."'")
    checkError(res)
    return res[1]
end

function accessor.createPlayer(user_id, server_id, name, x, y, carrer, level, experience, hp, mp)
    local sql = "insert into player (user_id, server_id, name, x, y, carrer, level, experience, hp, mp) values ("
        ..user_id..","..server_id..",'"..name.."',"..x..","..y..","..carrer..","..level..","..experience..","..hp..","..mp..")"
    local res = DB:query(sql)
    --checkError(res)
    return res
end

function accessor.savePlayerInfo(player_id, scene_id, x, y, level, experience, hp, mp)
    local sql = "update player set last_scene_id="..scene_id..",x="..x..",y="..y..",level="..level..",experience="..
        experience..",hp="..hp..",mp="..mp.." where id="..player_id
    
    local res = DB:query(sql)
    
    checkError(res)
end

function accessor.setPlayerPos(user_id, x, y)
end

function accessor.setPlayerExp(user_id, exp)
end

return accessor