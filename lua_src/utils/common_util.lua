--所有lua项目都可以用的通用工具方法

function PrintTable(_table)
    print(DumpTable(_table))
end

function DumpTable(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

--移除table中某个值
function TableRemoveValue(_table, value)
	local removeIndex = nil
	
	for i, v in ipairs(_table) do
		if v == value then
			removeIndex = i
		end
	end

	if removeIndex ~= nil then
		table.remove(_table, removeIndex)
		return true
	end

	return false
end

--移除table中某个值，只适用key为数字
function TableRemoveValue2(_table, value)
	for i = #_table, 1, -1 do
		if _table[i] == value then
			table.remove(_table, i)
			return true
		end
	end

	return false
end

function TableLength(_table)
    local count = 0
	for k, v in pairs(_table) do
	    count = count + 1  
	end

	return count
end

function CopyTable(st)
    if st == nil then return nil end
    if type(st) ~= "table" then
        return st
    end
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = CopyTable(v)
        end
    end
    return tab
end
