--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)

local pub_reread = { }
local reread = { }
pub_reread.__index = reread


function pub_reread.new(): sceny.reread
	return setmetatable({
		class = "reread",
	}, pub_reread)
end


function reread:open(reader: sceny.reader)
	reader.next = 1
end


function reread:read(reader: sceny.reader)
	return reader:forward()
end


return pub_reread.new