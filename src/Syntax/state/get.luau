--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local pub_get = { }
local get = { }
pub_get.__index = get


local function isStateReader(element)
	if typeof(element) == 'table' then
		return element.class == 'state' and element.kind == 'get'
	end

	return false
end


function pub_get.new(name: string)
	return setmetatable({
		class = "state",
		name = name,
		kind = "get",
	}, pub_get)
end


function get:open(reader: sceny.reader)
	-- nothing as of now
end


function get:read(reader: sceny.reader)
	return reader:forward()
end


return pub_get.new