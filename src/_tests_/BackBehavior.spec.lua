local BackBehavior = require("../BackBehavior")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

describe("BackBehavior token tests", function()
	it("should return same object for each token for multiple calls", function()
		expect(BackBehavior.None).toBe(BackBehavior.None)
		expect(BackBehavior.InitialRoute).toBe(BackBehavior.InitialRoute)
		expect(BackBehavior.Order).toBe(BackBehavior.Order)
		expect(BackBehavior.History).toBe(BackBehavior.History)
	end)

	it("should return matching string names for symbols", function()
		expect(tostring(BackBehavior.None)).toEqual("NONE")
		expect(tostring(BackBehavior.InitialRoute)).toEqual("INITIAL_ROUTE")
		expect(tostring(BackBehavior.Order)).toEqual("ORDER")
		expect(tostring(BackBehavior.History)).toEqual("HISTORY")
	end)
end)
