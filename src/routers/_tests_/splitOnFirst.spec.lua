-- upstream: https://github.com/sindresorhus/split-on-first/blob/v1.1.0/test.js

local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

local splitOnFirst = require("../splitOnFirst")

it("main", function()
	expect(splitOnFirst("a-b-c", "-")).toEqual({ "a", "b-c" })
	expect(splitOnFirst("key:value:value2", ":")).toEqual({ "key", "value:value2" })
	expect(splitOnFirst("a---b---c", "---")).toEqual({ "a", "b---c" })
	expect(splitOnFirst("a-b-c", "+")).toEqual({ "a-b-c" })
	expect(splitOnFirst("abc", "")).toEqual({ "abc" })
end)
