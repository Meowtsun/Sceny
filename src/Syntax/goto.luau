--!nonstrict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)

local pub_goto = { }
local goto = { }
pub_goto.__index = goto


-- I'm not sure if this will work for all situations but..
local function resolvepath(path)
	local source = debug.info(2, 's')
	source = string.gsub(source, '%.', '/')
	source = string.gsub(source, '@self', '.')
	return '@game/' .. source .. '/../' .. path
end


function pub_goto.new(content: string | ModuleScript): sceny.goto
	if typeof(content) == "string" then
		content = resolvepath(content)
	end

	local module = require(content)
	if typeof(module) ~= 'table' or module.class ~= 'scene' then
		error('[Sceny]: goto() expect given ModuleScript to return scene', 2)
	end

	return setmetatable({
		class = "goto",
		content = module,
	}, pub_goto)
end


function goto:open(reader: sceny.reader)
	reader:readscene(self.content)
end


function goto:read(reader: sceny.reader)
	return reader:forward()
end


return pub_goto.new :: typeof(require)