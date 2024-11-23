local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

local createConfigGetter = require("../createConfigGetter")

it("should return a function", function()
	local result = createConfigGetter({}, {})
	expect(result).toEqual(expect.any("function"))
end)

it("should override default config with component-specific config", function()
	local getScreenOptions = createConfigGetter({
		Home = {
			screen = {
				render = function() end,
				navigationOptions = { title = "ComponentHome" },
			},
		},
		defaultNavigationOptions = { title = "DefaultTitle" },
	})

	expect(getScreenOptions({ state = { routeName = "Home" } }).title).toEqual("ComponentHome")
end)

it("should override component-specific config with route-specific config", function()
	local getScreenOptions = createConfigGetter({
		Home = {
			screen = {
				render = function() end,
				navigationOptions = { title = "ComponentHome" },
			},
			navigationOptions = { title = "RouteHome" },
		},
		defaultNavigationOptions = { title = "DefaultTitle" },
	})

	expect(getScreenOptions({ state = { routeName = "Home" } }).title).toEqual("RouteHome")
end)
