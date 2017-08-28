require "math.rect"

--[[
弃用，本来做场景管理实现。动态对象太多，效率不理想
]]

quad_tree = quad_tree or class()

function quad_tree:ctor(rect)
	assert(rect)
	assert(rect.left)
	assert(rect.right)
	assert(rect.bottom)
	assert(rect.top)

	self.rect = rect

	self.children = nil

	self.entity = nil --有且仅有一个
end

--四分矩形
function quad_tree:subdivide(point, entity)
	
	local top = self.rect.top
	local bottom = self.rect.bottom
	local left = self.rect.left
	local right = self.rect.right
	
	local centerX = (left + right) // 2
	local centerY = (top + bottom) // 2

	local leftTop = quad_tree.new(rectMake(left, centerX, centerY, top)) --左上
	local rightTop = quad_tree.new(rectMake(centerX, right, centerY, top)) --右上
	local leftBottom = quad_tree.new(rectMake(left, centerX, bottom, centerY)) --左下
	local rightBottom = quad_tree.new(rectMake(centerX, right, bottom, centerY)) --右下

	self.children = 
	{
		leftTop,
		rightTop,
		leftBottom,
		rightBottom,
	}

end

--从root向下查找到合适节点插入
function quad_tree:insert(point, entity)

	if not isPointInRect(point, self.rect) then
		print("not inside")
		return false
	end

	if self.entity then
		print(tostring(self).."/ "..entity.name.."/self. ".. self.entity.name)
	else
		print(tostring(self).."/ "..entity.name)
	end

	if self.children then --有节点细分过了，继续向下找
		print("step 1 find child")
		for k, child in pairs(self.children) do
			child.insert(child, point, entity)
		end
	else
		
		if self.entity then
			print("step 2 subdivide")
			self:subdivide(point, entity)

			for k, child in pairs(self.children) do
				child.insert(child, point, self.entity)
			end
			for k, child in pairs(self.children) do
				child.insert(child, point, entity)
			end

			self.entity = nil
		else
			print("step 3 entity insert "..entity.name)
			self.entity = entity --此处无限递归了。待查
		end
	end

	return true
end


function quad_tree:remove()
end

--从根节点开始遍历
function quad_tree:query(rect)
	if not isPointInRect(point, rect) then
		return
	end

	local entities = {}

	if self.children then
		for k, child in pairs(self.children) do
			child:query(rect)
		end
	else
		if self.entity then
			table.insert(entities, self.entity)
		end
	end

	return entities

end

--从根节点开始
function quad_tree:debugDraw()
	if self.children then
		for k, child in pairs(self.children) do
			child:debugDraw()
		end
	else
		DebugDrawRect(self.rect)
	end
end