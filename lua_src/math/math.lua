require ("math.vector2")

function math.round(num)
	return math.floor(num + 0.5)
end

function math.clamp(num, min, max)
	if num < min then
		num = min
	elseif num > max then
		num = max    
	end
	
	return num
end

function math.lerp(from, to, t)
	return from + (to - from) * math.clamp(t, 0, 1)
end

function math.randomRange(n, m)
	local range = m - n	
	return math.random() * range + n
end
