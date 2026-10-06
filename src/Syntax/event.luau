--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local pub_event = { }
local event = { }
pub_event.__index = event


local function isStateReader(value)
	if typeof(value) == 'table' then
		return value.class == 'Sceny.state' and value.kind == 'get'
	end

	return false
end


function pub_event.new(content: any): sceny.event
	return setmetatable({
		class = "event",
		content = content,
	}, pub_event)
end


function event:open(reader: sceny.reader)
	-- nothing as of now
end


function event:read(reader: sceny.reader)
	local this = context.new(self)
	local param = this:get('eventparam')

	if typeof(param) == 'table' then
		for key, value in param do
			if isStateReader(value) then
				param[key] = reader.editor.get(value.name)
			end
		end
	else -- check and map only one accordingly
		if isStateReader(param) then
			param = self.state.get(param.name)
		end
	end

	return context.new({
		class = "event",
		content = param,
	})
end


return pub_event.new