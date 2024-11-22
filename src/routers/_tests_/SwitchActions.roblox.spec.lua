return function()
	local jestExpect = require("@pkg/@jsdotlua/jest-globals").expect

	local SwitchActions = require("../SwitchActions")

	it("throws when indexing an unknown field", function()
		jestExpect(function()
			return SwitchActions.foo
		end).toThrow('"foo" is not a valid member of SwitchActions')
	end)

	describe("token tests", function()
		it("returns same object for each token for multiple calls", function()
			jestExpect(SwitchActions.JumpTo).toBe(SwitchActions.JumpTo)
		end)

		it("should return matching string names for symbols", function()
			jestExpect(tostring(SwitchActions.JumpTo)).toEqual("JUMP_TO")
		end)
	end)

	describe("creators", function()
		it("returns a JumpTo action for jumpTo()", function()
			local popTable = SwitchActions.jumpTo({
				routeName = "foo",
			})

			jestExpect(popTable.type).toBe(SwitchActions.JumpTo)
			jestExpect(popTable.routeName).toEqual("foo")
			jestExpect(popTable.preserveFocus).toEqual(true)
		end)
	end)
end
