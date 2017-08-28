local skynet = require "skynet"

local function handler(session, protoName, request)
    TBCombatRoomManager.getInstance():setPlayerSkillCast((session:get("player_id")), request.skill_index, request.target_id)
end

return handler