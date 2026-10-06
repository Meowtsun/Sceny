--!nonstrict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local pub_editor = { }
local editor = { }

editor.derived = newproxy()
pub_editor.__index = editor


local function currentDerived(reader: sceny.reader): sceny.derived
	return reader.state[editor.derived]
end


local function isDerived(value)
	if typeof(value) == 'table' then
		return value.kind == 'derived' or false
	end

	return false
end


function editor:invalidateAnscestors(derived: sceny.derived, reader: sceny.reader)
	for parent in derived.parents do
		local item = reader.derived[parent]
		item.invalid = true
		warn("invalidated", parent)
		self:invalidateAnscestors(item, reader)
	end
end


function editor:resolveItem(reader: sceny.reader, item: sceny.derived)
	if not isDerived(item) then
		return item
	end

	-- value was invalidated, recompute it
	-- update in topdown direction instead
	if item.invalid then
		for name in item.dependencies do
			local child = reader.state[name]
			if isDerived(child) and child.invalid then
				self:resolveItem(reader, child)
			end
		end

		item.value = item.recompute(self)
		item.invalid = false
	end

	return item.value
end


function editor:invalidateAllDerived(name: string, reader: sceny.reader)
	for n, derived in reader.derived do
		if derived.dependencies[name] then
			self:invalidateAnscestors(derived, reader)
			derived.invalid = true
		end
	end
end


function pub_editor.new(reader: sceny.reader)
	local this = setmetatable({ }, pub_editor)


	function this.get(name: string): (any)
		local derived = currentDerived(reader)
		if derived then -- active observer
			derived.dependencies[name] = true
		end

		local item = reader.state[name]
		return this:resolveItem(reader, item)
	end


	function this.increment(name: string, value: number?)
		reader.state[name] += (value or 1)
		this:invalidateAllDerived(name, reader)
	end


	function this.set(name: string, value: any)
		reader.state[name] = value
		this:invalidateAllDerived(name, reader)
	end


	return this
end


return pub_editor