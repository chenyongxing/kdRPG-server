--http://blog.codingnow.com/cloud/LuaOO

-- 保存类类型的虚表
local _class = {}
 
function class(super)
	-- 生成一个类类型
	local class_type = {}
	-- 在创建对象的时候自动调用
	class_type.ctor = false
	class_type.dtor = false
	class_type.super = super
	class_type.new = function(...)
		-- 生成一个类对象
		local obj = {}
		obj._class_type = class_type

		-- 在初始化之前注册基类方法
		setmetatable(obj, { __index = _class[class_type] })

		-- 调用初始化方法
		do
			local create 
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.ctor then
					c.ctor(obj, ...)
				end
			end

			create(class_type, ...)
		end

		-- 注册一个delete方法，调用时执行dtor
		obj.delete = function(self)
			local now_super = self._class_type 
			while now_super ~= nil do	
				if now_super.dtor then
					now_super.dtor(self)
				end
				now_super = now_super.super
			end
		end

		return obj
	end

	local vtbl = {}
	_class[class_type] = vtbl
 
	setmetatable(class_type, {__newindex =
		function(t,k,v)
			vtbl[k] = v
		end
		, 
		__index = vtbl, --For call parent method
	})
 
	if super then
		setmetatable(vtbl, {__index =
			function(t,k)
				local ret = _class[super][k]
				--do not do accept, make hot update work right!
				--vtbl[k] = ret
				return ret
			end
		})
	end
 
	return class_type
end
