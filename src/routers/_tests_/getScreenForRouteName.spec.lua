local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

local getScreenForRouteName = require("../getScreenForRouteName")

it("should throw if requested route is not present within table", function()
	local function shouldThrow()
		getScreenForRouteName({
			notMyRoute = function()
				return "foo"
			end,
		}, "myRoute")
	end

	expect(shouldThrow).toThrow("There is no route defined for key myRoute.\nMust be one of: 'notMyRoute'")
end)

it("should return raw table if screen and getScreen are not props", function()
	local screenComponent = {
		render = function()
			return nil
		end,
	}
	local result = getScreenForRouteName({
		myRoute = screenComponent,
	}, "myRoute")

	expect(result).toBe(screenComponent)
end)

it("should return screen prop if it is set in route data table", function()
	local screenComponent = {
		render = function()
			return nil
		end,
	}
	local result = getScreenForRouteName({
		myRoute = {
			screen = screenComponent,
		},
	}, "myRoute")

	expect(result).toBe(screenComponent)
end)

it("should return object returned by getScreen function if object is valid Roact element", function()
	local screenComponent = {
		render = function()
			return nil
		end,
	}
	local result = getScreenForRouteName({
		myRoute = {
			getScreen = function()
				return screenComponent
			end,
		},
	}, "myRoute")

	expect(result).toBe(screenComponent)
end)

it("should throw if getScreen does not return a valid Roact element", function()
	local errorExpected = "The getScreen defined for route 'myRoute' didn't return a valid "
		.. "screen or navigator.\n\n"

	expect(function()
		getScreenForRouteName({
			myRoute = {
				getScreen = function()
					return nil
				end,
			},
		}, "myRoute")
	end).toThrow(errorExpected)
end)

it("should throw if screen is not a valid Roact element", function()
	expect(function()
		getScreenForRouteName({
			myRoute = {
				screen = 5,
			},
		}, "myRoute")
	end).toThrow("screen for key 'myRoute' must be a valid Roact component.")
end)
