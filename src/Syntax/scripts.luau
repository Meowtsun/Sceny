--!nonstrict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)

local pub_scripts = { }
local scripts = { }
pub_scripts.__index = scripts


function pub_scripts.new(fn: (content: sceny.content) -> (sceny.controls)): sceny.scripts
	return setmetatable({
		class = "scripts",
		content = fn,
	}, pub_scripts)
end


function scripts:open(reader: sceny.reader)
	local item = self.content(reader.editor)
	if item ~= nil then
		reader.queued = item
	end

	-- TODO parent validity check?
end


function scripts:read(reader: sceny.reader)
	return reader:forward()
end


return pub_scripts.new