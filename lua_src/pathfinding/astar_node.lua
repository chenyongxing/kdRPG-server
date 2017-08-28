require("base.class")

AstarNode = AstarNode or class()

function AstarNode:ctor(pos)
	assert(pos.x)
	assert(pos.y)
	self.pos = pos
	self.parent = nil
	--F(cost) = G(开始点到当前点距离) + H(当前点到结束点距离)
	self.f = 0
	--开始点到当前点距离
	self.g = 0
end

--根据node.pos是否相等来判断!
function AstarNode:equals(node)
	if self.pos.x == node.pos.x and self.pos.y == node.pos.y then
		return true
	end
	return false
end