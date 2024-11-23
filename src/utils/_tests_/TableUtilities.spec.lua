local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe
local TableUtilities = require("../TableUtilities")

describe("DeepEqual", function()
	it("should succeed", function()
		expect(false).toBeDefined()
	end)

	it("should fail with a message when args are not equal", function()
		local success, message = TableUtilities.DeepEqual(1, 2)

		expect(success).toEqual(false)
		expect((message:find("first ~= second"))).toBeDefined()

		success, message = TableUtilities.DeepEqual({
			foo = 1,
		}, {
			foo = 2,
		})

		expect(success).toEqual(false)
		expect((message:find("first%[foo%] ~= second%[foo%]"))).toBeDefined()
	end)

	it("should compare non-table values using standard '==' equality", function()
		expect(TableUtilities.DeepEqual(1, 1)).toEqual(true)
		expect(TableUtilities.DeepEqual("hello", "hello")).toEqual(true)
		expect(TableUtilities.DeepEqual(nil, nil)).toEqual(true)

		local someFunction = function() end
		local theSameFunction = someFunction

		expect(TableUtilities.DeepEqual(someFunction, theSameFunction)).toEqual(true)

		local A = {
			foo = someFunction,
		}
		local B = {
			foo = theSameFunction,
		}

		expect(TableUtilities.DeepEqual(A, B)).toEqual(true)
	end)

	it("should fail when types differ", function()
		local success, message = TableUtilities.DeepEqual(1, "1")

		expect(success).toEqual(false)

		assert(
			message:find("first is of type number, but second is of type string"),
			"cannot find substring in: " .. message
		)
	end)

	it("should compare (and report about) nested tables", function()
		local A = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 2,
			},
		}
		local B = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 2,
			},
		}

		expect(TableUtilities.DeepEqual(A, B)).toEqual(true)

		local C = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 3,
			},
		}

		local success, message = TableUtilities.DeepEqual(A, C)

		expect(success).toEqual(false)
		assert(
			message:find("first%[nested%]%[bar%] ~= second%[nested%]%[bar%]"),
			"cannot find substring in: " .. message
		)
	end)

	it("should be commutative", function()
		local equalArgsA = {
			foo = "bar",
			hello = "world",
		}
		local equalArgsB = {
			foo = "bar",
			hello = "world",
		}

		expect(TableUtilities.DeepEqual(equalArgsA, equalArgsB)).toEqual(true)
		expect(TableUtilities.DeepEqual(equalArgsB, equalArgsA)).toEqual(true)

		local nonEqualArgs = {
			foo = "bar",
		}

		local successA = TableUtilities.DeepEqual(equalArgsA, nonEqualArgs)
		local successB = TableUtilities.DeepEqual(nonEqualArgs, equalArgsA)

		expect(successA).toEqual(false)
		expect(successB).toEqual(false)
	end)

	it("should give the appropriate message if the second table has extra fields", function()
		local success, message = TableUtilities.DeepEqual({}, { foo = 1 })

		expect(success).toEqual(false)
		expect(message).toEqual("first[foo] is of type nil, but second[foo] is of type number")
	end)
end)
