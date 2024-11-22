-- upstream: https://github.com/sindresorhus/split-on-first/blob/v1.1.0/test.js
return function()
	local jestExpect = require("@pkg/@jsdotlua/jest-globals").expect

	local splitOnFirst = require("../splitOnFirst")

	it("main", function()
		jestExpect(splitOnFirst("a-b-c", "-")).toEqual({ "a", "b-c" })
		jestExpect(splitOnFirst("key:value:value2", ":")).toEqual({ "key", "value:value2" })
		jestExpect(splitOnFirst("a---b---c", "---")).toEqual({ "a", "b---c" })
		jestExpect(splitOnFirst("a-b-c", "+")).toEqual({ "a-b-c" })
		jestExpect(splitOnFirst("abc", "")).toEqual({ "abc" })
	end)
end
