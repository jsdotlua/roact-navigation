local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

local StackActions = require("../StackActions")

it("throws when indexing an unknown field", function()
	expect(function()
		return StackActions.foo
	end).toThrow('"foo" is not a valid member of StackActions')
end)

describe("StackActions token tests", function()
	it("should return same object for each token for multiple calls", function()
		expect(StackActions.Pop).toBe(StackActions.Pop)
		expect(StackActions.PopToTop).toBe(StackActions.PopToTop)
		expect(StackActions.Push).toBe(StackActions.Push)
		expect(StackActions.Reset).toBe(StackActions.Reset)
		expect(StackActions.Replace).toBe(StackActions.Replace)
	end)

	it("should return matching string names for symbols", function()
		expect(tostring(StackActions.Pop)).toEqual("POP")
		expect(tostring(StackActions.PopToTop)).toEqual("POP_TO_TOP")
		expect(tostring(StackActions.Push)).toEqual("PUSH")
		expect(tostring(StackActions.Reset)).toEqual("RESET")
		expect(tostring(StackActions.Replace)).toEqual("REPLACE")
	end)
end)

describe("StackActions function tests", function()
	it("should return a pop action for pop()", function()
		local popTable = StackActions.pop({
			n = "n",
		})

		expect(popTable.type).toBe(StackActions.Pop)
		expect(popTable.n).toEqual("n")
	end)

	it("should return a pop to top action for popToTop()", function()
		local popToTopTable = StackActions.popToTop()

		expect(popToTopTable.type).toBe(StackActions.PopToTop)
	end)

	it("should return a push action for push()", function()
		local pushTable = StackActions.push({
			routeName = "routeName",
			params = "params",
			action = "action",
		})

		expect(pushTable.type).toBe(StackActions.Push)
		expect(pushTable.routeName).toEqual("routeName")
		expect(pushTable.params).toEqual("params")
		expect(pushTable.action).toEqual("action")
	end)

	it("should return a reset action for reset()", function()
		local resetTable = StackActions.reset({
			index = "index",
			actions = "actions",
			key = "key",
		})

		expect(resetTable.type).toBe(StackActions.Reset)
		expect(resetTable.index).toEqual("index")
		expect(resetTable.key).toEqual("key")
	end)

	it("should return a replace action for replace()", function()
		local replaceTable = StackActions.replace({
			key = "key",
			newKey = "newKey",
			routeName = "routeName",
			params = "params",
			action = "action",
			immediate = "immediate",
		})

		expect(replaceTable.type).toBe(StackActions.Replace)
		expect(replaceTable.key).toEqual("key")
		expect(replaceTable.newKey).toEqual("newKey")
		expect(replaceTable.routeName).toEqual("routeName")
		expect(replaceTable.params).toEqual("params")
		expect(replaceTable.action).toEqual("action")
		expect(replaceTable.immediate).toEqual("immediate")
	end)

	it("should return a complete transition action with matching data for call to completeTransition()", function()
		local completeTransitionTable = StackActions.completeTransition({
			key = "key",
			toChildKey = "toChildKey",
		})

		expect(completeTransitionTable.type).toBe(StackActions.CompleteTransition)
		expect(completeTransitionTable.key).toEqual("key")
		expect(completeTransitionTable.toChildKey).toEqual("toChildKey")
	end)
end)
