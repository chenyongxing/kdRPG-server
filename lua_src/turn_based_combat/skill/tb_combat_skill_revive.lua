require("turn_based_combat.skill.tb_combat_skill_base")

TBCombatSkillRevive = TBCombatSkillRevive or class(TBCombatSkillBase)

function TBCombatSkillRevive:ctor(skillId, skillLevel, casterId, baseDamge)
	self.baseDamge = baseDamge or 50
end

function TBCombatSkillRevive:autoSetTarget()
	local target = self.casterUnit:getRoom():getRandomEnemy(self.casterUnit)
	if target then
		self.targetId = target:getUnitId()
	end
end

function TBCombatSkillRevive:perform()
	if self:isTargetDead() then
		self:getTargetUnit():setDead(false)
	end

	local hit1 = self:createHitTarget(self.targetId, self.baseDamge, 0)
	self:addAttack({hit1})
end
