local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local KeyGenerator = require("../KeyGenerator")

it("should generate a new string key when called", function()
	KeyGenerator._TESTING_ONLY_normalize_keys()

	expect(KeyGenerator.generateKey()).toEqual("id-0")
	expect(KeyGenerator.generateKey()).toEqual("id-1")
end)

it("should generate unique string keys without being normalized", function()
	expect(KeyGenerator.generateKey()).never.toEqual(KeyGenerator.generateKey())
end)
