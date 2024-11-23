local React = require("@pkg/@jsdotlua/react")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

local validateRouteConfigMap = require("../validateRouteConfigMap")

local TestComponent = React.Component:extend("TestComponent")
function TestComponent:render()
	return nil
end

local INVALID_COMPONENT_MESSAGE = "The component for route 'myRoute' must be a Roact"
	.. " component or table with 'getScreen'."

-- ROBLOX TODO: this file isn't aligned to upstream, missing all tests in describe 'validateRouteConfigMap'

it("should throw if routeConfigs is empty", function()
	expect(function()
		validateRouteConfigMap({})
	end).toThrow("Please specify at least one route when configuring a navigator.")
end)

it("should throw if routeConfigs contains an invalid Roact element", function()
	expect(function()
		validateRouteConfigMap({
			myRoute = 5,
		})
	end).toThrow()
end)

it("should throw when both screen and getScreen are provided for same component", function()
	expect(function()
		validateRouteConfigMap({
			myRoute = {
				screen = "TheScreen",
				getScreen = function()
					return TestComponent
				end,
			},
		})
	end).toThrow("Route 'myRoute' should declare a screen or a getScreen, not both.")
end)

it("should throw for a simple table where screen is not a Roact component", function()
	expect(function()
		validateRouteConfigMap({
			myRoute = {
				screen = {},
			},
		})
	end).toThrow(INVALID_COMPONENT_MESSAGE)
end)

it("should throw for a non-function getScreen", function()
	expect(function()
		validateRouteConfigMap({
			myRoute = {
				getScreen = 5,
			},
		})
	end).toThrow(INVALID_COMPONENT_MESSAGE)
end)

it("should throw for a Host Component", function()
	expect(function()
		validateRouteConfigMap({
			myRoute = {
				aFrame = "Frame",
			},
		})
	end).toThrow(INVALID_COMPONENT_MESSAGE)
end)

it("should pass for valid basic routeConfigs", function()
	validateRouteConfigMap({
		basicComponentRoute = TestComponent,
		functionalComponentRoute = function() end,
	})
end)

it("should pass for valid screen prop type routeConfigs", function()
	validateRouteConfigMap({
		basicComponentRoute = {
			screen = TestComponent,
		},
		functionalComponentRoute = {
			screen = function() end,
		},
	})
end)

it("should pass for valid getScreen route configs", function()
	validateRouteConfigMap({
		getScreenRoute = {
			getScreen = function()
				return TestComponent
			end,
		},
	})
end)
