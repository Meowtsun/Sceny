--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local pub_meta = { }
local meta = { }
pub_meta.__index = meta


local function isStateReader(value)
	if typeof(value) == 'table' then
		return value.class == 'Sceny.state' and value.kind == 'get'
	end

	return false
end


function pub_meta.new(content: any): sceny.meta
	return setmetatable({
		class = "meta",
		content = content,
	}, pub_meta)
end


function meta:open(reader: sceny.reader)
	-- nothing, as of now
end


function meta:read(reader: sceny.reader)
	return reader:forward()
end


return pub_meta.new