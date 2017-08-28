require("turn_based_combat.unit.tb_combat_unit_base")

TBCombatUnitPet = TBCombatUnitPet or class(TBCombatUnitBase)

function TBCombatUnitPet:ctor(attribute, pos_index, team, masterPlayerId)
	self.masterPlayerId = masterPlayerId
	self.type = TBCombatUnitType.Pet
end

function TBCombatUnitPet:dtor()
end

function TBCombatUnitPet:setSkills()
	--正式应该 根据人物职业+等级来确定技能
end
