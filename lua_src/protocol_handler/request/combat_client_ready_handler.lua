local skynet = require "skynet"

local function handler(session, protoName, request)
    local room = TBCombatRoomManager.getInstance():getRoomByPlayer((session:get("player_id")))
    room:setStatus(TBCombatRoomStatus.Start)
end

return handler