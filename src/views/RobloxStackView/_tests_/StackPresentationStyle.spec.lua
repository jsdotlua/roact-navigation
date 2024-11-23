local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

local StackPresentationStyle = require("../StackPresentationStyle")

describe("StackPresentationStyle token tests", function()
	it("should return same object for each token for multiple calls", function()
		expect(StackPresentationStyle.Default).toBe(StackPresentationStyle.Default)
		expect(StackPresentationStyle.Modal).toBe(StackPresentationStyle.Modal)
		expect(StackPresentationStyle.Overlay).toBe(StackPresentationStyle.Overlay)
	end)

	it("should return matching string names for symbols", function()
		expect(tostring(StackPresentationStyle.Default)).toBe("DEFAULT")
		expect(tostring(StackPresentationStyle.Modal)).toBe("MODAL")
		expect(tostring(StackPresentationStyle.Overlay)).toBe("OVERLAY")
	end)
end)
