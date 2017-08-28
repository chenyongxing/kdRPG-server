require("turn_based_combat.skill.tb_combat_skill_base")

TBCombatSkillOnceAOE = TBCombatSkillOnceAOE or class(TBCombatSkillBase)

function TBCombatSkillOnceAOE:ctor(skillId, skillLevel, casterId, baseDamge)
    self.order = 1
	self.baseDamge = baseDamge or 100
end

function TBCombatSkillOnceAOE:autoSetTarget()
	local target = self.casterUnit:getRoom():getRandomEnemy(self.casterUnit)
	if target then
		self.targetId = target:getUnitId()
	end
end

function TBCombatSkillOnceAOE:perform()
	--不能对死亡单位释放
	if self:isTargetDead() then
		return
	end
	
	local hitList = {}
	local hit1 = self:createHitTarget(self.targetId, -self.baseDamge, 0)
	table.insert(hitList, hit1)

	local targetId2 = self.targetId + 1
	if not self:isUnitDead(self.targetId + 1) then
		local hit2 = self:createHitTarget(targetId2, -self.baseDamge, 0)
		table.insert(hitList, hit2)
	end

	local targetId3 = self.targetId - 1
	if not self:isUnitDead(self.targetId - 1) then
		local hit3 = self:createHitTarget(targetId3, -self.baseDamge, 0)
		table.insert(hitList, hit3)
	end

	self:addAttack(hitList)

	self:getTargetUnit():reduceHp(self.baseDamge)
	self:getUnit(targetId2):reduceHp(self.baseDamge)
	self:getUnit(targetId3):reduceHp(self.baseDamge)

	self.coolDownTurn = 1
end
