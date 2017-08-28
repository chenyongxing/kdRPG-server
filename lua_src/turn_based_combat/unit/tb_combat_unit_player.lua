require("turn_based_combat.unit.tb_combat_unit_base")

local skynet = require "skynet"

TBCombatUnitPlayer = TBCombatUnitPlayer or class(TBCombatUnitBase)

function TBCombatUnitPlayer:ctor(attribute, pos_index, team, playerId)
	self.type = TBCombatUnitType.Player
	self.playerId = playerId

	local playerInfo = skynet.call(DataAccessorService, "lua", "player", "getPlayerById", playerId)
	--职业id
	self.kind_id = playerInfo.carrer
end

function TBCombatUnitPlayer:dtor()
end

function TBCombatUnitBase:initSkills()
	return TBCombatSkillManager.getInstance():getSkillByCareer(self, 1, 1)
end