require("base.stack")

ObjectPoolPreCreatedType =
{
    Immediately = 1,
    Not = 2,
    Splitting = 3,
}

ObjectPool = ObjectPool or class()

--[[
    @type
    1.预先直接创建多个 number
    2.不预先创建
    3.预先摊帧创建 number second[每帧多少个]
]]
function ObjectPool:ctor(class, type, number, second)
    self.class = class
    
    type = type or ObjectPoolPreCreatedType.Immediately
    number = number or 10

    self.stack = Stack.new()

    if type == ObjectPoolPreCreatedType.Immediately then
        for i=1, number do
            self.stack:push(class.new())
        end
    elseif type == ObjectPoolPreCreatedType.Splitting then
        error()
    end
end

function ObjectPool:dtor()
    self.stack:delete()
end

function ObjectPool:size()
    return self.stack:size()
end

function ObjectPool:get()
    if self.stack:size() == 0 then
        return self.class.new()
    else
        return self.stack:pop()
    end
end

function ObjectPool:release(obj)
    if obj.reset then
        obj:reset()
    end
    self.stack:push(obj)
end

function ObjectPool:shrink()
end

function ObjectPool:expand()
end