require("turn_based_combat.skill.tb_combat_skill_base")

TBCombatSkillOnceSingle = TBCombatSkillOnceSingle or class(TBCombatSkillBase)

function TBCombatSkillOnceSingle:ctor(skillId, skillLevel, casterId, baseDamge)
	self.baseDamge = baseDamge or 200
end

function TBCombatSkillOnceSingle:autoSetTarget()
	local target = self.casterUnit:getRoom():getRandomEnemy(self.casterUnit)
	if target then
		self.targetId = target:getUnitId()
	end
end

function TBCombatSkillOnceSingle:perform()
	--不能对死亡单位释放
	if self:isTargetDead() then
		return
	end

	local hit1 = self:createHitTarget(self.targetId, -self.baseDamge, 0)
	self:addAttack({hit1})
	
	self:getTargetUnit():reduceHp(self.baseDamge)
end
