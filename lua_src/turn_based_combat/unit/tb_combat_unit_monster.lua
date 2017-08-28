require("turn_based_combat.unit.tb_combat_unit_base")

TBCombatUnitMonster = TBCombatUnitMonster or class(TBCombatUnitBase)

function TBCombatUnitMonster:ctor(attribute, pos_index, team, monster_id)
	self.type = TBCombatUnitType.Monster
	--怪物种类id
	self.kind_id = monster_id
end

function TBCombatUnitMonster:dtor()
end

function TBCombatUnitMonster:initSkills()
	return TBCombatSkillManager.getInstance():getSkillByMonster(self, 1)
end
