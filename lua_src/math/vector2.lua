Vector2 = Vector2 or {}

Vector2.__index = Vector2

function Vector2.new(x, y)
	assert(x)
	assert(y)

	local v = {x = x, y = y}
	setmetatable(v, Vector2)
	return v
end

function Vector2:magnitude()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

--可用于比较。优化了平方根操作
function Vector2:sqrMagnitude()
	return self.x * self.x + self.y * self.y
end

function Vector2.distance(vec1, vec2)
	return math.sqrt((vec1.x - vec2.x) * (vec1.x - vec2.x) + (vec1.y - vec2.y) * (vec1.y - vec2.y))
end

--可用于比较。优化了平方根操作
function Vector2.sqrDistance(vec1, vec2)
	return (vec1.x - vec2.x) * (vec1.x - vec2.x) + (vec1.y - vec2.y) * (vec1.y - vec2.y)
end

function Vector2:normalize()
	local vec = self:clone()
	local magnitude = vec:magnitude()
	if magnitude == 1 then
		return vec
	elseif magnitude > 1e-05 then    
		return vec / magnitude
	else    
		return Vector2.new(0, 0)
	end 
end

--用于求角度
function Vector2.dot(va, vb)
	return va.x * va.x + vb.y * vb.y
end

function Vector2.angle(va, vb)
	return math.acos( Vector2.dot(va, vb) / (va:magnitude() * vb:magnitude()) )
end

function Vector2:clone()
	return Vector2.new(self.x, self.y)
end

Vector2.__eq = function(va, vb)
	return va.x == vb.x and va.y == vb.y
end

Vector2.__unm = function(va)
	return Vector2.new(-va.x, -va.y)
end

Vector2.__add = function(va, vb)
	return Vector2.new(va.x + vb.x, va.y + vb.y)
end

Vector2.__sub = function(va, vb)
	return Vector2.new(va.x - vb.x, va.y - vb.y)
end

Vector2.__mul = function(va, d)
	return Vector2.new(va.x * d, va.y * d)
end

Vector2.__div = function(va, d)
	return Vector2.new(va.x / d, va.y / d)
end

Vector2.__tostring = function(self)
	return string.format("[%f,%f]", self.x, self.y)
end
