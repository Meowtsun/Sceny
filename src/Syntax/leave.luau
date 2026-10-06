--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)

local pub_leave = { }
local leave = { }
pub_leave.__index = leave


function pub_leave.new(): sceny.leave
	return setmetatable({
		class = "leave",
	}, pub_leave)
end


function leave:open(reader: sceny.reader)
	-- nothing as of now
end


function leave:read(reader: sceny.reader)
	return reader:goback()
end


return pub_leave.new