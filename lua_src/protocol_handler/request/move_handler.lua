local skynet = require "skynet"

local function handler(session, protoName, request)
    local player = SceneManager.getInstance():getOnlinePlayer(session:get("player_id"))
    local path = skynet.call(MapPathfindingService, "lua", "findPath", player.scene.scene_id, Vector2Serialize(player.position), SerializableVector2Make(request.x, request.y))
    
    if path ~= nil and path[1] then
        local path2 = {}
        for i, v in ipairs(path) do
            table.insert(path2, Vector2Unserialize(v))
        end
        player:moveBasePath(path2, function ( ... )
            print(player.entity_id, "move end, pos=", player.position)
        end)

        return {path=path}
    end
end

return handler