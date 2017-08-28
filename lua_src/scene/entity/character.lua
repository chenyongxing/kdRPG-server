require "scene.entity.entity"

local skynet = require "skynet"

Character = Character or class(Entity)

function Character:ctor()
    self.type = EntityType.Unkown
end

function Character:dtor()
end

function Character:reset()
    Entity.reset(self)
end

function Character:update()
    if self.moving then
        if not self.oneStepCallbackFlag then
            self.oneStepCallbackFlag = true
            
            if self.movePathIndex <= #self.path then
                self.moveStartPos = self.position
                self.moveTargetPos = self.path[self.movePathIndex]
                self.moveVector = (self.moveTargetPos - self.moveStartPos):normalize()
                self.moveStartTime = skynet.time()
                self.moveTime = Vector2.distance(self.moveStartPos, self.moveTargetPos) / self.move_speed
            else
                self.moving = false
                if self.moveCallback then
                    self.moveCallback()
                end
            end
        end

        local passTime = skynet.time() - self.moveStartTime
        if passTime >= self.moveTime then
            self.position = self.moveTargetPos
            self.movePathIndex = self.movePathIndex + 1
            self.oneStepCallbackFlag = false
        else
            self.position = self.moveStartPos + self.moveVector * (self.move_speed * passTime)
        end
    end
end

function Character:moveBasePath(path, callback)
	assert(path)
	assert(path[2])
	--第一个位置是自身位置，就不参与计算了
	self.path = path
	self.movePathIndex = 2
	self.moving = true
    self.oneStepCallbackFlag = false
    
	self.moveCallback = callback
end

function Character:move(targetPos, callback)
    self:moveBasePath({{}, targetPos}, callback)
end
