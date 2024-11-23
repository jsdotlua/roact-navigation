local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local React = require("@pkg/@jsdotlua/react")
local isValidScreenComponent = require("../isValidScreenComponent")

local TestComponent = React.Component:extend("TestFoo")

function TestComponent:render() end

it("should return true for valid element types", function()
	-- Function Component is valid
	expect(isValidScreenComponent(function() end)).toBe(true)
	-- Stateful Component is valid
	expect(isValidScreenComponent(TestComponent)).toBe(true)
	expect(isValidScreenComponent({
		render = function()
			return TestComponent
		end,
	})).toBe(true)
	expect(isValidScreenComponent( -- we do not test if render function returns valid component
		{ render = function() end }
	)).toBe(true)
end)

it("should return false for invalid element types", function()
	expect(isValidScreenComponent("foo")).toBe(false)
	expect(isValidScreenComponent(React.createElement("Frame"))).toBe(false)
	expect(isValidScreenComponent(5)).toBe(false)
	expect(isValidScreenComponent({ render = "bad" })).toBe(false)
	expect(isValidScreenComponent({
		notRender = function()
			return "foo"
		end,
	})).toBe(false)
end)
