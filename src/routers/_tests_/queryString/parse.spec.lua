-- upstream: https://github.com/sindresorhus/query-string/blob/v6.11.1/test/parse.js

local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local LuauPolyfill = require("@pkg/@jsdotlua/luau-polyfill")
local Array = LuauPolyfill.Array

local queryString = require("../../queryString")

it("query strings starting with a `?`", function()
	expect(queryString.parse("?foo=bar")).toEqual({ foo = "bar" })
end)

it("query strings starting with a `#`", function()
	expect(queryString.parse("#foo=bar")).toEqual({ foo = "bar" })
end)

it("query strings starting with a `&`", function()
	expect(queryString.parse("&foo=bar&foo=baz")).toEqual({
		foo = { "bar", "baz" },
	})
end)

it("parse a query string", function()
	expect(queryString.parse("foo=bar")).toEqual({ foo = "bar" })
end)

it("parse multiple query string", function()
	expect(queryString.parse("foo=bar&key=val")).toEqual({
		foo = "bar",
		key = "val",
	})
end)

it.skip("parse multiple query string retain order when not sorted", function()
	local expectedKeys = { "b", "a", "c" }
	local parsed = queryString.parse("b=foo&a=bar&c=yay", { sort = false })

	local index = 1
	for key in pairs(parsed) do
		expect(key).toEqual(expectedKeys[index])
		index += 1
	end
end)

it.skip("parse multiple query string sorted keys", function()
	local fixture = { "a", "b", "c" }
	local parsed = queryString.parse("a=foo&c=bar&b=yay")

	local index = 1
	for key in pairs(parsed) do
		expect(key).toEqual(fixture[index])
		index += 1
	end
end)

it.skip("should sort parsed keys in given order", function()
	local fixture = { "c", "a", "b" }
	local function sort(key1, key2)
		return Array.indexOf(fixture, key1) - Array.indexOf(fixture, key2)
	end
	local parsed = queryString.parse("a=foo&b=bar&c=yay", { sort = sort })

	local index = 1
	for key in pairs(parsed) do
		expect(key).toEqual(fixture[index])
		index += 1
	end
end)

it.skip("parse query string without a value", function()
	expect(queryString.parse("foo"), { foo = nil })
	expect(queryString.parse("foo&key"), { foo = nil, key = nil })
	expect(queryString.parse("foo=bar&key"), { foo = "bar", key = nil })
	expect(queryString.parse("a&a"), { a = { nil, nil } })
	expect(queryString.parse("a=&a"), { a = { "", nil } })
end)

it("return empty object if no qss can be found", function()
	expect(queryString.parse("?")).toEqual({})
	expect(queryString.parse("&")).toEqual({})
	expect(queryString.parse("#")).toEqual({})
	expect(queryString.parse(" ")).toEqual({})
end)

it("handle `+` correctly", function()
	expect(queryString.parse("foo+faz=bar+baz++")).toEqual({ ["foo faz"] = "bar baz  " })
end)

it("parses numbers with exponential notation as string", function()
	expect(queryString.parse("192e11=bar")).toEqual({ ["192e11"] = "bar" })
	expect(queryString.parse("bar=192e11")).toEqual({ bar = "192e11" })
end)

it("handle `+` correctly when not decoding", function()
	expect(queryString.parse("foo+faz=bar+baz++", { decode = false })).toEqual({
		["foo+faz"] = "bar+baz++",
	})
end)

it("handle multiple of the same key", function()
	expect(queryString.parse("foo=bar&foo=baz")).toEqual({
		foo = { "bar", "baz" },
	})
end)

it("handle multiple values and preserve appearence order", function()
	expect(queryString.parse("a=value&a=")).toEqual({ a = { "value", "" } })
	expect(queryString.parse("a=&a=value")).toEqual({ a = { "", "value" } })
end)

it("handle multiple values and preserve appearance order with brackets", function()
	expect(queryString.parse("a[]=value&a[]=", {
		arrayFormat = "bracket",
	})).toEqual({ a = { "value", "" } })
	expect(queryString.parse("a[]=&a[]=value", {
		arrayFormat = "bracket",
	})).toEqual({ a = { "", "value" } })
end)

it("handle multiple values and preserve appearance order with indexes", function()
	expect(queryString.parse("a[0]=value&a[1]=", {
		arrayFormat = "index",
	})).toEqual({ a = { "value", "" } })
	expect(queryString.parse("a[1]=&a[0]=value", {
		arrayFormat = "index",
	})).toEqual({ a = { "value", "" } })
end)

it("query strings params including embedded `=`", function()
	expect(queryString.parse("?param=https%3A%2F%2Fsomeurl%3Fid%3D2837")).toEqual({
		param = "https://someurl?id=2837",
	})
end)

it("object properties", function()
	-- t.falsy(queryString.parse().prototype)
	expect(queryString.parse("hasOwnProperty=foo")).toEqual({
		hasOwnProperty = "foo",
	})
end)

it("query strings having indexed arrays", function()
	expect(queryString.parse("foo[0]=bar&foo[1]=baz")).toEqual({
		["foo[0]"] = "bar",
		["foo[1]"] = "baz",
	})
end)

it("query strings having brackets arrays", function()
	expect(queryString.parse("foo[]=bar&foo[]=baz")).toEqual({
		["foo[]"] = { "bar", "baz" },
	})
end)

it("query strings having indexed arrays keeping index order", function()
	expect(queryString.parse("foo[1]=bar&foo[0]=baz")).toEqual({
		["foo[1]"] = "bar",
		["foo[0]"] = "baz",
	})
end)

it("query string having a single bracketed value and format option as `bracket`", function()
	expect(queryString.parse("foo[]=bar", {
		arrayFormat = "bracket",
	})).toEqual({
		foo = { "bar" },
	})
end)

it("query string not having a bracketed value and format option as `bracket`", function()
	expect(queryString.parse("foo=bar", {
		arrayFormat = "bracket",
	})).toEqual({
		foo = "bar",
	})
end)

it("query string having a bracketed value and a single value and format option as `bracket`", function()
	expect(queryString.parse("foo=bar&baz[]=bar", {
		arrayFormat = "bracket",
	})).toEqual({
		foo = "bar",
		baz = { "bar" },
	})
end)

it("query strings having brackets arrays and format option as `bracket`", function()
	expect(queryString.parse("foo[]=bar&foo[]=baz", {
		arrayFormat = "bracket",
	})).toEqual({
		foo = {
			"bar",
			"baz",
		},
	})
end)

it("query strings having comma separated arrays and format option as `comma`", function()
	expect(queryString.parse("foo=bar,baz", {
		arrayFormat = "comma",
	})).toEqual({
		foo = {
			"bar",
			"baz",
		},
	})
end)

it("query strings having pipe separated arrays and format option as `separator`", function()
	expect(queryString.parse("foo=bar|baz", {
		arrayFormat = "separator",
		arrayFormatSeparator = "|",
	})).toEqual({
		foo = {
			"bar",
			"baz",
		},
	})
end)

it.skip("query strings having brackets arrays with null and format option as `bracket`", function()
	expect(queryString.parse("bar[]&foo[]=a&foo[]&foo[]=", {
		arrayFormat = "bracket",
	})).toEqual({
		foo = {
			"a",
			nil,
			"",
		},
		bar = { nil },
	})
end)

it("query strings having comma separated arrays with null and format option as `comma`", function()
	expect(queryString.parse("bar&foo=a,", {
		arrayFormat = "comma",
	})).toEqual({
		foo = { "a", "" },
		bar = nil,
	})
end)

it("query strings having indexed arrays and format option as `index`", function()
	expect(queryString.parse("foo[0]=bar&foo[1]=baz", {
		arrayFormat = "index",
	})).toEqual({ foo = { "bar", "baz" } })
end)

it("query strings having = within parameters (i.e. GraphQL IDs)", function()
	expect(queryString.parse("foo=bar=&foo=ba=z=")).toEqual({
		foo = { "bar=", "ba=z=" },
	})
end)

it("query strings having ordered index arrays and format option as `index`", function()
	expect(queryString.parse("foo[1]=bar&foo[0]=baz&foo[3]=one&foo[2]=two", {
		arrayFormat = "index",
	})).toEqual({ foo = { "baz", "bar", "two", "one" } })
	expect(queryString.parse("foo[0]=bar&foo[1]=baz&foo[2]=one&foo[3]=two", {
		arrayFormat = "index",
	})).toEqual({ foo = { "bar", "baz", "one", "two" } })
	expect(queryString.parse("foo[3]=three&foo[2]=two&foo[1]=one&foo[0]=zero", {
		arrayFormat = "index",
	})).toEqual({ foo = { "zero", "one", "two", "three" } })
	expect(queryString.parse("foo[3]=three&foo[2]=two&foo[1]=one&foo[0]=zero&bat=buz", {
		arrayFormat = "index",
	})).toEqual({
		foo = { "zero", "one", "two", "three" },
		bat = "buz",
	})
	expect(queryString.parse("foo[1]=bar&foo[0]=baz", {
		arrayFormat = "index",
	})).toEqual({ foo = { "baz", "bar" } })
	expect(queryString.parse("foo[102]=three&foo[2]=two&foo[1]=one&foo[0]=zero&bat=buz", {
		arrayFormat = "index",
	})).toEqual({
		bat = "buz",
		foo = { "zero", "one", "two", "three" },
	})
	expect(queryString.parse("foo[102]=three&foo[2]=two&foo[100]=one&foo[0]=zero&bat=buz", {
		arrayFormat = "index",
	})).toEqual({
		bat = "buz",
		foo = { "zero", "two", "one", "three" },
	})
end)

it.skip("circuit parse -> stringify", function()
	local original = "foo[3]=foo&foo[2]&foo[1]=one&foo[0]=&bat=buz"
	local sortedOriginal = "bat=buz&foo[0]=&foo[1]=one&foo[2]&foo[3]=foo"
	local expected = {
		bat = "buz",
		foo = { "", "one", nil, "foo" },
	}
	local options = { arrayFormat = "index" }

	expect(queryString.parse(original, options)).toEqual(expected)
	expect(queryString.stringify(expected, options)).toEqual(sortedOriginal)
end)

it.skip("circuit original -> parse -> stringify -> sorted original", function()
	local original = "foo[21474836471]=foo&foo[21474836470]&foo[1]=one&foo[0]=&bat=buz"
	local sortedOriginal = "bat=buz&foo[0]=&foo[1]=one&foo[2]&foo[3]=foo"
	local options = { arrayFormat = "index" }

	expect(queryString.stringify(queryString.parse(original, options), options)).toEqual(sortedOriginal)
end)

it.skip("decode keys and values", function()
	expect(queryString.parse("st%C3%A5le=foo")).toEqual({ ["ståle"] = "foo" })
	expect(queryString.parse("foo=%7B%ab%%7C%de%%7D+%%7Bst%C3%A5le%7D%")).toEqual({
		foo = "{%ab%|%de%} %{ståle}%",
	})
end)

it("disable decoding of keys and values", function()
	expect(queryString.parse("tags=postal%20office,burger%2C%20fries%20and%20coke", { decode = false })).toEqual({
		tags = "postal%20office,burger%2C%20fries%20and%20coke",
	})
end)

it("number value returns as string by default", function()
	expect(queryString.parse("foo=1")).toEqual({ foo = "1" })
end)

it("number value returns as number if option is set", function()
	expect(queryString.parse("foo=1", { parseNumbers = true })).toEqual({ foo = 1 })
	expect(queryString.parse("foo=12.3&bar=123e-1", { parseNumbers = true })).toEqual({
		foo = 12.3,
		bar = 12.3,
	})
	expect(queryString.parse("foo=0x11&bar=12.00", { parseNumbers = true })).toEqual({
		foo = 17,
		bar = 12,
	})
end)

it("NaN value returns as string if option is set", function()
	expect(queryString.parse("foo=null", { parseNumbers = true })).toEqual({
		foo = "null",
	})
	expect(queryString.parse("foo=undefined", { parseNumbers = true })).toEqual({
		foo = "undefined",
	})
	expect(queryString.parse("foo=100a&bar=100", { parseNumbers = true })).toEqual({
		foo = "100a",
		bar = 100,
	})
	expect(queryString.parse("foo=   &bar=", { parseNumbers = true })).toEqual({
		foo = "   ",
		bar = "",
	})
end)

it("parseNumbers works with arrayFormat", function()
	expect(queryString.parse("foo[]=1&foo[]=2&foo[]=3&bar=1", {
		parseNumbers = true,
		arrayFormat = "bracket",
	})).toEqual({
		foo = { 1, 2, 3 },
		bar = 1,
	})
	expect(queryString.parse("foo=1,2,a", {
		parseNumbers = true,
		arrayFormat = "comma",
	})).toEqual({
		foo = {
			1,
			2,
			"a",
		},
	})
	expect(queryString.parse("foo=1|2|a", {
		parseNumbers = true,
		arrayFormat = "separator",
		arrayFormatSeparator = "|",
	})).toEqual({
		foo = {
			1,
			2,
			"a",
		},
	})
	expect(queryString.parse("foo[0]=1&foo[1]=2&foo[2]", {
		parseNumbers = true,
		arrayFormat = "index",
	})).toEqual({
		foo = { 1, 2, nil },
	})
	expect(queryString.parse("foo=1&foo=2&foo=3", { parseNumbers = true })).toEqual({
		foo = { 1, 2, 3 },
	})
end)

it("boolean value returns as string by default", function()
	expect(queryString.parse("foo=true")).toEqual({
		foo = "true",
	})
end)

it("boolean value returns as boolean if option is set", function()
	expect(queryString.parse("foo=true", { parseBooleans = true })).toEqual({ foo = true })
	expect(queryString.parse("foo=false&bar=true", { parseBooleans = true })).toEqual({
		foo = false,
		bar = true,
	})
end)

it("parseBooleans works with arrayFormat", function()
	expect(queryString.parse("foo[]=true&foo[]=false&foo[]=true&bar=1", {
		parseBooleans = true,
		arrayFormat = "bracket",
	})).toEqual({
		foo = { true, false, true },
		bar = "1",
	})
	expect(queryString.parse("foo=true,false,a", {
		parseBooleans = true,
		arrayFormat = "comma",
	})).toEqual({
		foo = {
			true,
			false,
			"a",
		},
	})
	expect(queryString.parse("foo[0]=true&foo[1]=false&foo[2]", {
		parseBooleans = true,
		arrayFormat = "index",
	})).toEqual({
		foo = { true, false, nil },
	})
	expect(queryString.parse("foo=true&foo=false&foo=3", { parseBooleans = true })).toEqual({
		foo = {
			true,
			false,
			"3",
		},
	})
end)

it("boolean value returns as boolean and number value as number if both options are set", function()
	expect(queryString.parse("foo=true&bar=1.12", {
		parseNumbers = true,
		parseBooleans = true,
	})).toEqual({
		foo = true,
		bar = 1.12,
	})
	expect(queryString.parse("foo=16.32&bar=false", {
		parseNumbers = true,
		parseBooleans = true,
	})).toEqual({
		foo = 16.32,
		bar = false,
	})
end)

it("parseNumbers and parseBooleans can work with arrayFormat at the same time", function()
	expect(queryString.parse("foo=true&foo=false&bar=1.12&bar=2", {
		parseNumbers = true,
		parseBooleans = true,
	})).toEqual({
		foo = { true, false },
		bar = { 1.12, 2 },
	})
	expect(queryString.parse("foo[]=true&foo[]=false&foo[]=true&bar[]=1&bar[]=2", {
		parseNumbers = true,
		parseBooleans = true,
		arrayFormat = "bracket",
	})).toEqual({
		foo = { true, false, true },
		bar = { 1, 2 },
	})
	expect(queryString.parse("foo=true,false&bar=1,2", {
		parseNumbers = true,
		parseBooleans = true,
		arrayFormat = "comma",
	})).toEqual({
		foo = { true, false },
		bar = { 1, 2 },
	})
	expect(queryString.parse("foo[0]=true&foo[1]=false&bar[0]=1&bar[1]=2", {
		parseNumbers = true,
		parseBooleans = true,
		arrayFormat = "index",
	})).toEqual({
		foo = { true, false },
		bar = { 1, 2 },
	})
end)

it("parse throws TypeError for invalid arrayFormatSeparator", function()
	expect(function()
		return queryString.parse("", {
			arrayFormatSeparator = ",,",
		})
	end).toThrow()
	expect(function()
		return queryString.parse("", { arrayFormatSeparator = {} })
	end).toThrow()
end)

it("query strings having comma encoded and format option as `comma`", function()
	expect(queryString.parse("foo=zero%2Cone,two%2Cthree", {
		arrayFormat = "comma",
	})).toEqual({
		foo = { "zero,one", "two,three" },
	})
end)

it.skip("value should not be decoded twice with `arrayFormat` option set as `separator`", function()
	expect(queryString.parse("foo=2020-01-01T00:00:00%2B03:00", {
		arrayFormat = "separator",
	})).toEqual({ foo = "2020-01-01T00:00:00+03:00" })
end)

it.skip(
	"value separated by encoded comma will not be parsed as array with `arrayFormat` option set to `comma`",
	function()
		expect(queryString.parse("id=1%2C2%2C3", {
			arrayFormat = "comma",
			parseNumbers = true,
		})).toEqual({ id = { 1, 2, 3 } })
	end
)
