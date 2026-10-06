--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local pub_map = { }
local map = { }
pub_map.__index = map


local function isStateReader(element)
	if typeof(element) == 'table' then
		return element.class == 'state' and element.kind == 'get'
	end

	return false
end


function pub_map.new(name: string)
	return function (value: any)
		return setmetatable({
			class = "state",
			name = name,
			kind = "map",
			compute = value,
		}, pub_map)
	end
end


function map:open(reader: sceny.reader)
	reader.editor.set(self.name, self.compute(reader.editor))
end


function map:read(reader: sceny.reader)
	return reader:forward()
end


return pub_map.new