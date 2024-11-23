local NavigationActions = require("../NavigationActions")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

it("throws when indexing an unknown field", function()
	expect(function()
		return NavigationActions.foo
	end).toThrow('"foo" is not a valid member of NavigationActions')
end)

describe("NavigationActions token tests", function()
	it("should return same object for each token for multiple calls", function()
		expect(NavigationActions.Back).toEqual(NavigationActions.Back)
		expect(NavigationActions.Init).toEqual(NavigationActions.Init)
		expect(NavigationActions.Navigate).toEqual(NavigationActions.Navigate)
		expect(NavigationActions.SetParams).toEqual(NavigationActions.SetParams)
	end)

	it("should return matching string names for symbols", function()
		expect(tostring(NavigationActions.Back)).toEqual("BACK")
		expect(tostring(NavigationActions.Init)).toEqual("INIT")
		expect(tostring(NavigationActions.Navigate)).toEqual("NAVIGATE")
		expect(tostring(NavigationActions.SetParams)).toEqual("SET_PARAMS")
	end)
end)

describe("NavigationActions function tests", function()
	it("should return a back action with matching data for a call to back()", function()
		local backTable = NavigationActions.back({
			key = "the_key",
			immediate = true,
		})

		expect(backTable.type).toEqual(NavigationActions.Back)
		expect(backTable.key).toEqual("the_key")
		expect(backTable.immediate).toEqual(true)
	end)

	it("should return an init action with matching data for call to init()", function()
		local initTable = NavigationActions.init({
			params = "foo",
		})

		expect(initTable.type).toEqual(NavigationActions.Init)
		expect(initTable.params).toEqual("foo")
	end)

	it("should return a navigate action with matching data for call to navigate()", function()
		local navigateTable = NavigationActions.navigate({
			routeName = "routeName",
			params = "foo",
			action = "action",
			key = "key",
		})

		expect(navigateTable.type).toEqual(NavigationActions.Navigate)
		expect(navigateTable.routeName).toEqual("routeName")
		expect(navigateTable.params).toEqual("foo")
		expect(navigateTable.action).toEqual("action")
		expect(navigateTable.key).toEqual("key")
	end)

	it("should return a set params action with matching data for call to setParams()", function()
		local setParamsTable = NavigationActions.setParams({
			key = "key",
			params = "foo",
		})

		expect(setParamsTable.type).toEqual(NavigationActions.SetParams)
		expect(setParamsTable.key).toEqual("key")
		expect(setParamsTable.params).toEqual("foo")
	end)
end)
