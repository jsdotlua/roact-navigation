local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

local RoactNavigation = require("../..")
local TrackNavigationEvents = require("../TrackNavigationEvents")
local PageNavigationEvent = require("../PageNavigationEvent")

local testPage = "TEST PAGE"
local testPageWillFocus = PageNavigationEvent.new(testPage, RoactNavigation.Events.WillFocus)
local testPageWillBlur = PageNavigationEvent.new(testPage, RoactNavigation.Events.WillBlur)

local trackNavigationEvents = TrackNavigationEvents.new()

it("should implement equalTo function", function()
	expect(trackNavigationEvents:equalTo({})).toBe(true)

	local navigationEvents = trackNavigationEvents:getNavigationEvents()
	table.insert(navigationEvents, testPageWillFocus)
	expect(trackNavigationEvents:equalTo({ testPageWillFocus })).toBe(true)
	expect((trackNavigationEvents:equalTo({}))).toBe(false)

	table.insert(navigationEvents, testPageWillBlur)
	expect(trackNavigationEvents:equalTo({ testPageWillFocus, testPageWillBlur })).toBe(true)

	table.insert(navigationEvents, testPageWillFocus)
	expect((trackNavigationEvents:equalTo({ testPageWillFocus, testPageWillBlur }))).toBe(false)
	expect(trackNavigationEvents:equalTo({ testPageWillFocus, testPageWillBlur, testPageWillFocus })).toBe(true)
end)

it("should be empty after reset", function()
	trackNavigationEvents:resetNavigationEvents()
	local navigationEvents = trackNavigationEvents:getNavigationEvents()
	expect(type(navigationEvents)).toBe("table")
	expect(#navigationEvents).toBe(0)
	expect(trackNavigationEvents:equalTo({})).toBe(true)
end)
