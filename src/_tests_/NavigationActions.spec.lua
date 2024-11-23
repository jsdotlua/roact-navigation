-- upstream https://github.com/react-navigation/react-navigation/blob/72e8160537954af40f1b070aa91ef45fc02bba69/packages/core/src/__tests__/NavigationActions.test.js

local NavigationActions = require("../NavigationActions")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

describe("generic navigation actions", function()
	local params = { foo = "bar" }
	local navigateAction = NavigationActions.navigate({ routeName = "another" })

	it("exports back action and type", function()
		expect(NavigationActions.back()).toEqual({ type = NavigationActions.Back })
		expect(NavigationActions.back({ key = "test" })).toEqual({
			type = NavigationActions.Back,
			key = "test",
		})
	end)

	it("exports init action and type", function()
		expect(NavigationActions.init()).toEqual({ type = NavigationActions.Init })
		expect(NavigationActions.init({ params = params })).toEqual({
			type = NavigationActions.Init,
			params = params,
		})
	end)

	it("exports navigate action and type", function()
		expect(NavigationActions.navigate({ routeName = "test" })).toEqual({
			type = NavigationActions.Navigate,
			routeName = "test",
		})
		expect(NavigationActions.navigate({
			routeName = "test",
			params = params,
			action = navigateAction,
		})).toEqual({
			type = NavigationActions.Navigate,
			routeName = "test",
			params = params,
			action = {
				type = NavigationActions.Navigate,
				routeName = "another",
			},
		})
	end)

	it("exports setParams action and type", function()
		expect(NavigationActions.setParams({
			key = "test",
			params = params,
		})).toEqual({
			type = NavigationActions.SetParams,
			key = "test",
			preserveFocus = true,
			params = params,
		})
	end)
end)
