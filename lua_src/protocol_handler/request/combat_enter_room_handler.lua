local skynet = require "skynet"

local function handler(session, protoName, request)
    local room = TBCombatRoomManager.getInstance():createRoom(session:get("player_id"), request.monster_id)

    local unit_list = {}
    for id, unit in ipairs(room:getCombatUnits()) do
        local unitInfo = {}
        unitInfo.unit_id = id
        unitInfo.pos_index = unit.pos_index
        unitInfo.team = unit.team
        unitInfo.kind_id = unit.kind_id
        unitInfo.unit_type = unit.type
        table.insert(unit_list, unitInfo)
    end

    return {unit_list=unit_list}
end

return handler