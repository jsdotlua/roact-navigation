return function()
	local jestExpect = require("@pkg/@jsdotlua/jest-globals").expect

	local validateScreenOptions = require("../validateScreenOptions")

	it("should not throw when there are no problems", function()
		jestExpect(function()
			validateScreenOptions({ title = "foo" }, { routeName = "foo" })
		end).never.toThrow()
	end)

	it("should throw error for options with function for title", function()
		jestExpect(function()
			validateScreenOptions({
				title = function() end,
			}, { routeName = "foo" })
		end).toThrow()
	end)
end
