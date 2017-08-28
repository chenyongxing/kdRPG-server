require "aoi.aoi_object"

AoiSpace = AoiSpace or class()

function AoiSpace:ctor(radius, enterCallback, leaveCallback, isMoveFunc)
	--视野范围
	self.radius = radius
	self.radiusSquare = radius * radius

	self.enterCallback = enterCallback
	self.leaveCallback = leaveCallback

	--动静判断。默认移动超出视野范围的一半为动了
	self.isMoveFunc = isMoveFunc or function (pos1, pos2)
		return Vector2.sqrDistance(pos1, pos2) < self.radiusSquare * 0.25
	end

	self.objects = {}
	self.watcher_static = {}
	self.marker_static = {}
	self.watcher_move = {}
	self.marker_move = {}
	--热点链表的头
	self.hot = nil

	--每个watcher都有一个感兴趣列表，用于实现刚进入视野回调，和离开视野回调
	self.watcherInterestList = {}
end

function AoiSpace:isNear(pos1, pos2)
	--return Vector2.sqrDistance(pos1, pos2) < self.radiusSquare * 0.25
	return self.isMoveFunc(pos1, pos2)
end

--[[
@id
@mode w(watcher):观察者 m(marker):被观察者 d(drop):移除 
@pos
]]
function AoiSpace:update(id, mode, pos)
	
	local object = self.objects[id]
	if not object then
		local newObj = AoiObject.new()
		newObj.id = id
		self.objects[id] = newObj
		object = newObj
		object.lastPosition = pos:clone()
		print("Aoi new object. id="..tostring(id).."; pos:x="..tostring(pos.x)..", y="..tostring(pos.y))
	end

	local setWatcher = false
	local setMarker = false

	for char in string.gmatch(mode, ".") do
		if char == 'w' then
			setWatcher = true
			self:initInterestList(id)
		elseif char == 'm' then
			setMarker = true
		elseif char == 'd' then
			if not object.mode.drop then
				object.mode.drop = true
				self.objects[id] = nil
			end
		end
	end

	if object.mode.drop then
		object.mode.drop = false
	end
	
	object.position = pos:clone()

	local changed = self:changeMode(object, setWatcher, setMarker)
	if changed or not self:isNear(pos, object.lastPosition) then
		--1.新对象
		--2.改变了mode
		--3.位置改变过大
		-- -> version + 1
		--print(tostring(id).." has changed")
		object.lastPosition = pos:clone()
		object.mode.move = true
		object.version = object.version + 1
	end

end

function AoiSpace:message()
	self:flushHotList()

	self:flushInterestList()

	--重设static move集合
	self.watcher_static = {}
	self.marker_static = {}
	self.watcher_move = {}
	self.marker_move = {}
	for _, object in pairs(self.objects) do
		local mode = object.mode
		if mode.watcher then
			if mode.move then
				table.insert(self.watcher_move, object)
				--mode.move = false <-mark1
			else
				table.insert(self.watcher_static, object)
			end
		end

		if mode.marker then

			if mode.move then
				table.insert(self.marker_move, object)
				--mode.move = false
			else
				table.insert(self.marker_static, object)
			end
		end

		--FIX:一个物体同为watcher，marker。如果移动了，走上面mark1，身为marker会被检测不到
		mode.move = false
	end

	-- self:printhotListId("watcher_static", self.watcher_static)
	-- self:printhotListId("watcher_move", self.watcher_move)
	-- self:printhotListId("marker_static", self.marker_static)
	-- self:printhotListId("marker_move", self.marker_move)

	--生成热点列表
	self:genHotList(self.watcher_static, self.marker_move)
	self:genHotList(self.watcher_move, self.marker_static)
	self:genHotList(self.watcher_move, self.marker_move)
end

function AoiSpace:changeMode(object, setWatcher, setMarker)
	local changed = false

	if setWatcher then
		if not object.mode.watcher then
			object.mode.watcher = true
			changed = true
		end
	else
		if object.mode.watcher then
			object.mode.watcher = false
			changed = true
		end
	end

	if setMarker then
		if not object.mode.marker then
			object.mode.marker = true
			changed = true
		end
	else
		if object.mode.marker then
			object.mode.marker = false
			changed = true
		end
	end

	return changed
end

function AoiSpace:flushHotList()
	local node = self.hot
	
	while node do
		local next = node.next

		if node.watcher.version ~= node.watcher_version or 
			node.marker.version ~= node.marker_version or
			node.watcher.mode.drop or
			node.marker.mode.drop then
			self.hot = next
		else
			local distanceSquare = Vector2.sqrDistance(node.watcher.position, node.marker.position)

			if distanceSquare > self.radiusSquare * 4 then
				self.hot = next
			elseif distanceSquare < self.radiusSquare then
				self.enterCallback(node.watcher.id, node.marker.id)
				self.hot = next
			else
				self.hot = node.next
			end
		end

		node = next
	end
end

function AoiSpace:genHotList(watchers, markers)

	for _, watcher in pairs(watchers) do
		for _k, marker in pairs(markers) do
			
			self:genHot(watcher, marker)

		end
	end
end

function AoiSpace:genHot(watcher, marker)
	
	if watcher == marker then
		return
	end
	
	local distanceSquare = Vector2.sqrDistance(watcher.position, marker.position)
	
	if distanceSquare < self.radiusSquare then
		self:addInterestObj(watcher.id, marker.id)
		return
	end

	if distanceSquare > self.radiusSquare * 4 then
		return
	end

	local node = {}
	node.watcher = watcher
	node.marker = marker
	node.watcher_version = watcher.version
	node.marker_version = marker.version
	node.next = self.hot

	self.hot = node
end

function AoiSpace:initInterestList(watcherId)
	for k, v in pairs(self.watcherInterestList) do
		if k == watcherId then
			return
		end
	end

	table.insert(self.watcherInterestList, watcherId, {})
end

--marker进入视野，就添加到兴趣列表
function AoiSpace:addInterestObj(watcherId, markerId)
	local interestList = self.watcherInterestList[watcherId]

	for k, v in pairs(interestList) do
		if v == markerId then
			return
		end
	end

	table.insert(interestList, markerId)

	self.enterCallback(watcherId, markerId)
end

--检查watcher和marker的距离，超过视野就从兴趣列表移除
function AoiSpace:flushInterestList()
	for watcherId, v in pairs(self.watcherInterestList) do
		local watcher = self.objects[watcherId]
		for k, markerId in pairs(v) do
			local marker = self.objects[markerId]
			if marker ~= nil and watcher ~= nil then
				local distanceSquare = Vector2.sqrDistance(watcher.position, marker.position)
				if distanceSquare > self.radiusSquare then
					self.leaveCallback(watcherId, markerId)
					table.remove(v, k)
				end
			end
		end

	end
end

function AoiSpace:printhotListId(pre, list)
	local str = pre
	for k, v in pairs(list) do
		str = str.." , id="..tonumber(v.id)
	end
	print(str)
end
