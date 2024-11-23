local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local lerp = require("../lerp")

it("should return bottom of range for bottom input", function()
	expect(lerp(0, 1, 0)).toEqual(0)
	expect(lerp(1, 0, 0)).toEqual(1)
	expect(lerp(-1, 0, 0)).toEqual(-1)
end)

it("should return middle of range for middle input", function()
	expect(lerp(0, 1, 0.5)).toEqual(0.5)
	expect(lerp(1, 0, 0.5)).toEqual(0.5)
	expect(lerp(-1, 0, 0.5)).toEqual(-0.5)
end)

it("should return top of range for top input", function()
	expect(lerp(0, 1, 1)).toEqual(1)
	expect(lerp(1, 0, 1)).toEqual(0)
	expect(lerp(-1, 0, 1)).toEqual(0)
end)
