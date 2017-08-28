require "base.priority_queue"
require "pathfinding.astar_node"

AstarPathfinding = AstarPathfinding or class()

--[[
	基于网格节点的A*寻路算法
	F(cost) = G(开始点到当前点距离) + H(当前点到结束点距离)
]]
function AstarPathfinding:ctor()
	self.closeList = {}
	
	--以f为判断标准的最小堆
	local cmpFunc = function (node1, node2)
		return node1.f <= node2.f
	end
	self.openList = PriorityQueue.new(cmpFunc)
end

function AstarPathfinding:setMapInfo(width, height, obstructInfo)
	self.width = width
	self.height = height
	
 	self.obstructInfo = {}
 	for i = 0, self.width do
 		self.obstructInfo[i] = {}
 		for j = 0, self.height do
	       	local isObstruct = false
			for k, v in ipairs(obstructInfo) do
				if i == v.x and j == v.y then
					isObstruct = true
				end
		   	end
		   self.obstructInfo[i][j] = isObstruct
	    end
 	end
end

function AstarPathfinding:checkPos(pos)
	assert(self.width)
	assert(self.height)
	assert(self.obstructInfo)

	if pos.x < 0 or pos.y < 0 or pos.x > self.width or pos.y > self.height then
		return false
	end

	return not self.obstructInfo[pos.x][pos.y]
end

--检测两个点连线直接是否有阻挡格
function AstarPathfinding:checkLine(startPos, endPos)
	startPos = startPos:clone()
	endPos = endPos:clone()

	--保证startPos.x < endPos.x并且startPos.y < endPos.y
	if startPos.x > endPos.x then
		startPos.x, endPos.x = endPos.x, startPos.x
	end

	if startPos.y > endPos.y then
		startPos.y, endPos.y = endPos.y, startPos.y
	end

	local dx = endPos.x - startPos.x
    local dy = endPos.y - startPos.y
	
	for i = 1, math.max(dx, dy) do
		local x = math.min(startPos.x + i, endPos.x)
		local y = math.min(startPos.y + i, endPos.y)
		if not self:checkPos(Vector2.new(x, y)) then
			return false
		end
	end

	return true
end

--八个方向可对角线移动，采用契比雪夫距离
function AstarPathfinding:getH(nodePos, goalPos)
    local dx = math.abs(goalPos.x - nodePos.x)
    local dy = math.abs(goalPos.y - nodePos.y)
    
	return math.max(dx, dy)
end

--[[
	路径自然问题
	1.检测连线是否有阻挡格没有就去除掉中间的点【这里的办法】
	2.Theta* or Lazy Theta*
]]
function AstarPathfinding:find(startPos, goalPos)
	if not self:checkPos(startPos) then
		return false
	end

	if not self:checkPos(goalPos) then
		return false
	end
	
	self.openList:clear()
	self.closeList = {}

	local startNode = AstarNode.new(startPos)
	startNode.f = startNode.g + self:getH(startNode.pos, goalPos)
	self.openList:push(startNode)

	local q = nil
	local successed = false

	while self.openList.size ~= 0 do
		q = self.openList:pop()
		
		if q.pos.x == goalPos.x and q.pos.y == goalPos.y then
			successed = true
			break --查找成功
		end

		table.insert(self.closeList, q)
		--print(self.openList.size.."出列："..self:getPosString(q))

		local successors = self:generateSuccessors(q)
		for k, successor in pairs(successors) do
			--print(self:getPosString(q).."的附近可行走:"..self:getPosString(successor))
			if not self:isInCloseList(successor) then --排除已经在close表中的
				local newG = q.g + Vector2.distance(successor.pos, q.pos)

				--1.不在open直接添加
				local isInOpen, nodeIndex = self:isInOpenList(successor)
				if not isInOpen then
					successor.g = newG
					successor.f = newG + self:getH(successor.pos, goalPos)
					self.openList:push(successor)
					--print("入列:"..self:getPosString(successor)..".f = "..tostring(successor.f))
				else --2.在open，且新g值小，更新node.f值
					if newG < successor.g then
						local node = self.openList.array[nodeIndex] --取出已经在openList的节点
						node.g = newG
						node.f = newG + self:getH(node.pos, goalPos)
						--print("更新:"..self:getPosString(node)..".f = "..tostring(node.f))
					end
				end
			end
		end

	end

	local reversePath = {}
	local node = q
	while node do
		--print("["..tostring(node.pos.x).."]["..tostring(node.pos.y).."] -> ")
		table.insert(reversePath, node.pos)
		node = node.parent
	end
	
	local path = {}
	table.insert(path, reversePath[#reversePath])
	for i = #reversePath-1, 2, -1 do
		if not self:checkLine(path[#path], reversePath[i]) then
			table.insert(path, reversePath[i])
		end
	end
	table.insert(path, reversePath[1])

	return successed, path
end

--当前节点的可行走邻近点
function AstarPathfinding:generateSuccessors(node)
	local successors = {}
	
	local left = Vector2.new(node.pos.x - 1, node.pos.y)
	if self:checkPos(left) then
		self:insertNewSuccessor(node, successors, left)
	end

	local right = Vector2.new(node.pos.x + 1, node.pos.y)
	if self:checkPos(right) then
		self:insertNewSuccessor(node, successors, right)
	end

	local bottom = Vector2.new(node.pos.x, node.pos.y - 1)
	if self:checkPos(bottom) then
		self:insertNewSuccessor(node, successors, bottom)
	end

	local up = Vector2.new(node.pos.x, node.pos.y + 1)
	if self:checkPos(up) then
		self:insertNewSuccessor(node, successors, up)
	end

	local leftBottom = Vector2.new(node.pos.x - 1, node.pos.y - 1)
	if self:checkPos(leftBottom) then
		self:insertNewSuccessor(node, successors, leftBottom)
	end

	local leftUp = Vector2.new(node.pos.x - 1, node.pos.y + 1)
	if self:checkPos(leftUp) then
		self:insertNewSuccessor(node, successors, leftUp)
	end

	local rightBottom = Vector2.new(node.pos.x + 1, node.pos.y - 1)
	if self:checkPos(rightBottom) then
		self:insertNewSuccessor(node, successors, rightBottom)
	end

	local rightUp = Vector2.new(node.pos.x + 1, node.pos.y + 1)
	if self:checkPos(rightUp) then
		self:insertNewSuccessor(node, successors, rightUp)
	end

	return successors
end

function AstarPathfinding:insertNewSuccessor(node, successors, pos)
	local successor = AstarNode.new(pos)
	successor.parent = node
	table.insert(successors, successor)
end

function AstarPathfinding:isInCloseList(node)
	for k, v in pairs(self.closeList) do
		if v:equals(node) then
			return true
		end
	end
	return false
end

function AstarPathfinding:isInOpenList(node)
	for k, v in pairs(self.openList.array) do
		if v:equals(node) then
			return true, k
		end
	end
	return false
end

function AstarPathfinding:getPosString(node)
	return "["..tostring(node.pos.x).."]["..tostring(node.pos.y).."]"
end
