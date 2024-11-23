local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local getActiveChildNavigationOptions = require("../getActiveChildNavigationOptions")

it("should return a function", function()
	expect(type(getActiveChildNavigationOptions)).toEqual("function")
end)

it("should ask router for current screen options and return them", function()
	local testInputScreenOpts = {}
	local testScreenOpts = {}

	local navigation = {
		state = {
			routes = {
				{ key = "123" },
			},
			index = 1,
		},
		router = {}, -- stub
	}

	function navigation.getChildNavigation(key)
		if key == "123" then
			return navigation
		else
			return nil
		end
	end

	local testOutputScreenOpts = nil
	function navigation.router.getScreenOptions(activeNav, screenProps)
		testOutputScreenOpts = screenProps

		if activeNav == navigation then
			return testScreenOpts
		else
			return nil
		end
	end

	expect(getActiveChildNavigationOptions(navigation, testInputScreenOpts)).toBe(testScreenOpts)
	expect(testOutputScreenOpts).toBe(testInputScreenOpts)
end)
