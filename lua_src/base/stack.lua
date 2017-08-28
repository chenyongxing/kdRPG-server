Stack = class()

function Stack:ctor()
    self.stack_table = {}
end

function Stack:dtor()
    for k, v in pairs(self.stack_table) do
        v:delete()
    end
end

function Stack:push(element)
    local size = self:size()
    self.stack_table[size + 1] = element
end

function Stack:pop()
    local size = self:size()
    if size == 0 then
        return
    end

    return table.remove(self.stack_table, size)
end

function Stack:top()
    local size = self:size()
    if size == 0 then
        return
    end
    return self.stack_table[size]
end

function Stack:size()
    return TableLength(self.stack_table)
end

function Stack:clear()
    self.stack_table = {}
end
