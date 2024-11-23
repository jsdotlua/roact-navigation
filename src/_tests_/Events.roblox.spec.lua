local Events = require("../Events")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

describe("Events token tests", function()
	it("should return same object for each token for multiple calls", function()
		expect(Events.WillFocus).toBe(Events.WillFocus)
		expect(Events.DidFocus).toBe(Events.DidFocus)
		expect(Events.WillBlur).toBe(Events.WillBlur)
		expect(Events.DidBlur).toBe(Events.DidBlur)
		expect(Events.Action).toBe(Events.Action)
		expect(Events.Refocus).toBe(Events.Refocus)
	end)

	it("should return matching string names for symbols", function()
		expect(tostring(Events.WillFocus)).toEqual("WILL_FOCUS")
		expect(tostring(Events.DidFocus)).toEqual("DID_FOCUS")
		expect(tostring(Events.WillBlur)).toEqual("WILL_BLUR")
		expect(tostring(Events.DidBlur)).toEqual("DID_BLUR")
		expect(tostring(Events.Action)).toEqual("ACTION")
		expect(tostring(Events.Refocus)).toEqual("REFOCUS")
	end)
end)
