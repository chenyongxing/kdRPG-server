EntityType = 
{
	Unkown = 1,
	Monster = 2,
    Npc = 3,
	Player = 4,	
}

Entity = Entity or class()

function Entity:ctor()
    self.type = EntityType.Unkown
end

function Entity:dtor()
end

function Entity:setScene(scene)
    self.scene = scene
end

function Entity:getScene()
    return self.scene
end

function Entity:setEntityId(entity_id)
    self.entity_id = entity_id
end

function Entity:getEntityId()
    return self.entity_id
end

function Entity:setPosition(vector2)
    self.position = vector2
end

function Entity:getPosition()
    return self.position
end

function Entity:reset()
    self.scene = nil
    self.position = nil
end

function Entity:onEnterScene(scene)
end

function Entity:onLeaveScene(scene)
end