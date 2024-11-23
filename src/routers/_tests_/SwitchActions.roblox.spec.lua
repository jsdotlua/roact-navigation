local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

local SwitchActions = require("../SwitchActions")

it("throws when indexing an unknown field", function()
	expect(function()
		return SwitchActions.foo
	end).toThrow('"foo" is not a valid member of SwitchActions')
end)

describe("token tests", function()
	it("returns same object for each token for multiple calls", function()
		expect(SwitchActions.JumpTo).toBe(SwitchActions.JumpTo)
	end)

	it("should return matching string names for symbols", function()
		expect(tostring(SwitchActions.JumpTo)).toEqual("JUMP_TO")
	end)
end)

describe("creators", function()
	it("returns a JumpTo action for jumpTo()", function()
		local popTable = SwitchActions.jumpTo({
			routeName = "foo",
		})

		expect(popTable.type).toBe(SwitchActions.JumpTo)
		expect(popTable.routeName).toEqual("foo")
		expect(popTable.preserveFocus).toEqual(true)
	end)
end)
