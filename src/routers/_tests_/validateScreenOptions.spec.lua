local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

local validateScreenOptions = require("../validateScreenOptions")

it("should not throw when there are no problems", function()
	expect(function()
		validateScreenOptions({ title = "foo" }, { routeName = "foo" })
	end).never.toThrow()
end)

it("should throw error for options with function for title", function()
	expect(function()
		validateScreenOptions({
			title = function() end,
		}, { routeName = "foo" })
	end).toThrow()
end)
