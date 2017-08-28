require("turn_based_combat.skill.tb_combat_skill_base")

TBCombatSkillMultiple = TBCombatSkillMultiple or class(TBCombatSkillBase)

function TBCombatSkillMultiple:ctor(skillId, skillLevel, casterId, baseDamge)
    self.order = 2
	self.baseDamge = baseDamge or 100
end

function TBCombatSkillMultiple:autoSetTarget()
	local target = self.casterUnit:getRoom():getRandomEnemy(self.casterUnit)
	if target then
		self.targetId = target:getUnitId()
	end
end

function TBCombatSkillMultiple:perform()
	--不能对死亡单位释放
	if self:isTargetDead() then
		return
	end	

	local hit1 = self:createHitTarget(self.targetId, -self.baseDamge, 0)
	self:addAttack({hit1})
	self:getTargetUnit():reduceHp(self.baseDamge)

	--选2个额外的敌方单位
	local enemies = self.casterUnit:getRoom():getEnemies(self.casterUnit)
    local count = 0
	for i, v in ipairs(enemies) do
		if count == 2 then
			return
		end
		
		if v:getUnitId() ~= self.targetId then
			local hit2 = self:createHitTarget(v:getUnitId(), -self.baseDamge, 0)
			self:addAttack({hit2})
			self:getUnit(targetId2):reduceHp(self.baseDamge)
			count = count + 1
		end
	end

	self.coolDownTurn = 2
end
