local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

local getNavigationActionCreators = require("../getNavigationActionCreators")
local NavigationActions = require("../../NavigationActions")

it("should return a table with correct functions when called", function()
	local result = getNavigationActionCreators()
	expect(result.goBack).toEqual(expect.any("function"))
	expect(result.navigate).toEqual(expect.any("function"))
	expect(result.setParams).toEqual(expect.any("function"))
end)

describe("goBack tests", function()
	it("should return a Back action when called", function()
		local result = getNavigationActionCreators().goBack("theKey")
		expect(result.type).toBe(NavigationActions.Back)
		expect(result.key).toEqual("theKey")
	end)

	it("should throw when route.key is not a string", function()
		expect(function()
			getNavigationActionCreators({ key = 5 }).goBack()
		end).toThrow(".goBack(): key should be a string")
	end)

	it("should fall back to route.key if key is not provided", function()
		local result = getNavigationActionCreators({ key = "routeKey" }).goBack()
		expect(result.key).toEqual("routeKey")
	end)

	it("should override route.key if key is provided", function()
		local result = getNavigationActionCreators({ key = "routeKey" }).goBack("theKey")
		expect(result.key).toEqual("theKey")
	end)
end)

describe("navigate tests", function()
	it("should return a Navigate action when called", function()
		local theParams = {}
		local childAction = {}
		local result = getNavigationActionCreators().navigate("theRoute", theParams, childAction)
		expect(result.type).toBe(NavigationActions.Navigate)
		expect(result.routeName).toEqual("theRoute")
		expect(result.params).toBe(theParams)
		expect(result.action).toBe(childAction)
	end)

	it("should return a navigate action with matching properties when called with a table", function()
		local testNavigateTo = {
			routeName = "theRoute",
			params = {},
			action = {},
		}

		local result = getNavigationActionCreators().navigate(testNavigateTo)
		expect(result.type).toBe(NavigationActions.Navigate)
		expect(result.routeName).toEqual("theRoute")
		expect(result.params).toBe(testNavigateTo.params)
		expect(result.action).toBe(testNavigateTo.action)
	end)

	it("should throw when navigateTo is not a valid type", function()
		expect(function()
			getNavigationActionCreators().navigate(5)
		end).toThrow(".navigate(): navigateTo must be a string or table")
	end)

	it("should throw when params is provided with a table navigateTo", function()
		expect(function()
			getNavigationActionCreators().navigate({}, {})
		end).toThrow(".navigate(): params can only be provided with a string navigateTo value")
	end)

	it("should throw when action is provided with a table navigateTo", function()
		expect(function()
			getNavigationActionCreators().navigate({}, nil, {})
		end).toThrow(".navigate(): child action can only be provided with a string navigateTo value")
	end)
end)

describe("setParams tests", function()
	it("should return a SetParams action when called", function()
		local theParams = {}
		local result = getNavigationActionCreators({ key = "theKey" }).setParams(theParams)
		expect(result.type).toBe(NavigationActions.SetParams)
		expect(result.key).toEqual("theKey")
		expect(result.params).toBe(theParams)
	end)

	it("should throw when called by a root navigator", function()
		expect(function()
			getNavigationActionCreators({}).setParams({})
		end).toThrow(".setParams(): cannot be called by the root navigator")
	end)
end)
