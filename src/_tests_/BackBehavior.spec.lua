return function()
	local BackBehavior = require("../BackBehavior")
	local jestExpect = require("@pkg/@jsdotlua/jest-globals").expect

	describe("BackBehavior token tests", function()
		it("should return same object for each token for multiple calls", function()
			jestExpect(BackBehavior.None).toBe(BackBehavior.None)
			jestExpect(BackBehavior.InitialRoute).toBe(BackBehavior.InitialRoute)
			jestExpect(BackBehavior.Order).toBe(BackBehavior.Order)
			jestExpect(BackBehavior.History).toBe(BackBehavior.History)
		end)

		it("should return matching string names for symbols", function()
			jestExpect(tostring(BackBehavior.None)).toEqual("NONE")
			jestExpect(tostring(BackBehavior.InitialRoute)).toEqual("INITIAL_ROUTE")
			jestExpect(tostring(BackBehavior.Order)).toEqual("ORDER")
			jestExpect(tostring(BackBehavior.History)).toEqual("HISTORY")
		end)
	end)
end
