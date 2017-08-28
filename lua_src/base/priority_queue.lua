require("base.class")

PriorityQueue = PriorityQueue or class()

--[[
	最小二叉堆实现。父节点小于子节点，可以快速拿到最小值
	存储方式：根节点位于1；某元素位于n，子节点2n和2n+1
	已知子节点位于n，父节点位于n/2
]]
function PriorityQueue:ctor(cmpFunc)
	--比较函数，小于返回true
	self.cmpFunc = cmpFunc
	self.array = {}
	self.size = 0
end

--插入尾部，然后和父节点比较，小就交换位置
function PriorityQueue:push(item)
	self.size = self.size + 1
	self.array[self.size] = item

	local i = self.size
	while i > 1 do
		local parentIndex = math.floor(i / 2)
		if self.cmpFunc(self.array[i], self.array[parentIndex]) then
			local temp = self.array[i]
			self.array[i] = self.array[parentIndex]
			self.array[parentIndex] = temp
		end

		i = parentIndex
	end

end

--删除根节点，最后一个元素填上根节点，然后和子节点比较，大就交换
function PriorityQueue:pop()
	if self.size == 0 then
		return nil
	end

	local root = self.array[1]
	
	self.array[1] = self.array[self.size]
	self.array[self.size] = nil
	self.size = self.size - 1

	local i = 1
	while (2 * i) < self.size do
		local childIndex1 = 2 * i
		local childIndex2 = (2 * i) + 1
		--选择小的节点树
		local chooseIndex = childIndex1
		if self.array[childIndex2] ~= nil and not self.cmpFunc(self.array[childIndex1], self.array[childIndex2]) then
			chooseIndex = childIndex2
		end

		if not self.cmpFunc(self.array[i], self.array[chooseIndex]) then
			local temp = self.array[i]
			self.array[i] = self.array[chooseIndex]
			self.array[chooseIndex] = temp
		end

		i = chooseIndex
	end

	return root
end

function PriorityQueue:clear()
	self.array = {}
	self.size = 0
end

function PriorityQueue:printAll()
	local str = ""
	for k,v in pairs(self.array) do
		str = str.."["..tostring(v).."],"
	end
	print(str.."size="..tostring(self.size))
end