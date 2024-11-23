local React = require("@pkg/@jsdotlua/react")
local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local NavigationActions = require("../NavigationActions")
local createAppContainerExports = require("../createAppContainer")
local createAppContainer = createAppContainerExports.createAppContainer
local _TESTING_ONLY_reset_container_count = createAppContainerExports._TESTING_ONLY_reset_container_count
local createSwitchNavigator = require("../navigators/createSwitchNavigator")

beforeEach(function()
	_TESTING_ONLY_reset_container_count()
end)

it("should be a function", function()
	expect(createAppContainer).toEqual(expect.any("function"))
end)

it("should return a valid component when mounting a switch navigator", function()
	local TestNavigator = createSwitchNavigator({
		{ Foo = function() end },
	})

	local TestApp = createAppContainer(TestNavigator)
	local element = React.createElement(TestApp)

	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	ReactRoblox.act(function()
		root:render(element)
	end)
	ReactRoblox.act(function()
		root:unmount()
	end)
end)

it("should throw when navigator has both navigation and container props", function()
	local TestAppComponent = React.Component:extend("TestAppComponent")
	TestAppComponent.router = {}
	function TestAppComponent:render() end

	local element = React.createElement(createAppContainer(TestAppComponent), {
		navigation = {},
		somePropThatShouldNotBeHere = true,
	})

	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	expect(function()
		ReactRoblox.act(function()
			root:render(element)
		end)
	end).toThrow(
		"This navigator has both navigation and container props, " .. "so it is unclear if it should own its own state"
	)
end)

it("should throw when not passed a table for AppComponent", function()
	local TestAppComponent = 5

	expect(function()
		createAppContainer(TestAppComponent)
	end).toThrow("AppComponent must be a navigator or a stateful Roact component with a 'router' field")
end)

it("should throw when passed a stateful component without router field", function()
	local TestAppComponent = React.Component:extend("TestAppComponent")

	expect(function()
		createAppContainer(TestAppComponent)
	end).toThrow("AppComponent must be a navigator or a stateful Roact component with a 'router' field")
end)

it("should accept actions from externalDispatchConnector", function()
	local TestNavigator = createSwitchNavigator({
		{ Foo = function() end },
	})

	local registeredCallback = nil
	local externalDispatchConnector = function(rnCallback)
		registeredCallback = rnCallback
		return function()
			registeredCallback = nil
		end
	end

	local element = React.createElement(createAppContainer(TestNavigator), {
		externalDispatchConnector = externalDispatchConnector,
	})

	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	ReactRoblox.act(function()
		root:render(element)
	end)
	expect(registeredCallback).toEqual(expect.any("function"))

	-- Make sure it processes action
	local result = registeredCallback(NavigationActions.navigate({
		routeName = "Foo",
	}))
	expect(result).toEqual(true)

	local failResult = registeredCallback(NavigationActions.navigate({
		routeName = "Bar", -- should fail because not a valid route
	}))
	expect(failResult).toEqual(false)

	ReactRoblox.act(function()
		root:unmount()
	end)
	expect(registeredCallback).toEqual(nil)
end)

it("should correctly pass screenProps to pages", function()
	local passedScreenProps = nil
	local extractedValue1 = nil
	local extractedMissingValue1 = nil
	local extractedMissingValue2 = nil

	local testScreenProps = {
		MyKey1 = "MyValue1",
	}

	local TestNavigator = createSwitchNavigator({
		{
			Foo = function(props)
				-- doing this in render is an abuse, but it's just a test
				passedScreenProps = props.navigation.getScreenProps()
				extractedValue1 = props.navigation.getScreenProps("MyKey1")
				extractedMissingValue1 = props.navigation.getScreenProps("MyMissingKey", 5)
				extractedMissingValue2 = props.navigation.getScreenProps("MyMissingKey")
			end,
		},
	})

	local TestApp = createAppContainer(TestNavigator)
	local element = React.createElement(TestApp, {
		screenProps = testScreenProps,
	})
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	ReactRoblox.act(function()
		root:render(element)
	end)

	expect(passedScreenProps).toEqual(testScreenProps)
	expect(extractedValue1).toEqual("MyValue1")
	expect(extractedMissingValue1).toEqual(5)
	expect(extractedMissingValue2).toEqual(nil)

	ReactRoblox.act(function()
		root:unmount()
	end)
end)

describe("with deep linking", function()
	local function getLinkingProtocolMock(initialURL)
		local linkingProtocolMock = {}

		function linkingProtocolMock:listenForLuaURLs(callback, sticky)
			self.callback = callback
			self.sticky = sticky
		end

		function linkingProtocolMock:getLastLuaURL()
			return initialURL
		end

		function linkingProtocolMock:stopListeningForLuaURLs()
			self.callback = nil
		end

		return linkingProtocolMock
	end

	local function findFirstDescendantOfClass(parent, className)
		for _, descendant in ipairs(parent:GetDescendants()) do
			if descendant:IsA(className) then
				return descendant
			end
		end
		return nil
	end

	-- use a class that we will never find within the instance hierarchy created
	-- by Roact Navigation. That way if the swith navigation implementation changes,
	-- we won't have to modify the test
	local UNIQUE_CLASS_NAME = "HopperBin"

	it("connects and disconnects from `listenForLuaURLs`", function()
		local function Screen(_props)
			return nil
		end
		local testNavigator = createSwitchNavigator({
			{ Foo = { screen = Screen, path = "foo" } },
			{ Bar = { screen = Screen, path = "bar" } },
		})

		local protocolMock = getLinkingProtocolMock("foo")
		local app = createAppContainer(testNavigator, protocolMock)

		local element = React.createElement(app)
		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(element)
		end)

		expect(protocolMock.callback).never.toEqual(nil)
		expect(protocolMock.sticky).toEqual(false)

		ReactRoblox.act(function()
			root:unmount()
		end)

		expect(protocolMock.callback).toEqual(nil)
	end)

	it("uses the last URL to set the initial navigation state", function()
		local fooElementClass = "TextLabel"
		local barElementClass = "Frame"
		local function FooScreen(_props)
			return React.createElement(UNIQUE_CLASS_NAME, {}, {
				Foo = React.createElement(fooElementClass),
			})
		end
		local function BarScreen(_props)
			return React.createElement(UNIQUE_CLASS_NAME, {}, {
				Bar = React.createElement(barElementClass),
			})
		end

		for url, expectedClass in pairs({
			foo = { fooElementClass, barElementClass },
			bar = { barElementClass, fooElementClass },
		}) do
			local testNavigator = createSwitchNavigator({
				{ Foo = { screen = FooScreen, path = "foo" } },
				{ Bar = { screen = BarScreen, path = "bar" } },
			})

			local protocolMock = getLinkingProtocolMock(url)
			local app = createAppContainer(testNavigator, protocolMock)

			local element = React.createElement(app)
			local parent = Instance.new("Folder")
			local root = ReactRoblox.createRoot(parent)
			ReactRoblox.act(function()
				root:render(element)
			end)

			local screen = findFirstDescendantOfClass(parent, UNIQUE_CLASS_NAME)
			expect(screen).toBeDefined()
			expect(screen:FindFirstChildOfClass(expectedClass[1])).toBeDefined()
			expect(screen:FindFirstChildOfClass(expectedClass[2])).toBeUndefined()

			ReactRoblox.act(function()
				root:unmount()
			end)
		end
	end)

	it("can get the params from the initial URL", function()
		local fooElementClass = "TextLabel"
		local barElementClass = "Frame"
		local function FooScreen(_props)
			return React.createElement(UNIQUE_CLASS_NAME, {}, {
				Foo = React.createElement(fooElementClass),
			})
		end
		local function BarScreen(props)
			local navigation = props.navigation
			local name = navigation.getParam("name")
			return React.createElement(UNIQUE_CLASS_NAME, {}, {
				[name] = React.createElement(barElementClass, {
					Name = name,
				}),
			})
		end

		local testNavigator = createSwitchNavigator({
			{ Foo = { screen = FooScreen, path = "foo" } },
			{ Bar = { screen = BarScreen, path = "bar/:name" } },
		})

		local expectName = "orange"
		local protocolMock = getLinkingProtocolMock("bar/" .. expectName)
		local app = createAppContainer(testNavigator, protocolMock)

		local element = React.createElement(app)
		local parent = Instance.new("Folder")
		local root = ReactRoblox.createRoot(parent)
		ReactRoblox.act(function()
			root:render(element)
		end)

		local screen = findFirstDescendantOfClass(parent, UNIQUE_CLASS_NAME)
		expect(screen).toBeDefined()
		local barInstance = screen:FindFirstChildOfClass(barElementClass)
		expect(barInstance).toBeDefined()
		expect(barInstance.Name).toEqual(expectName)
		expect(screen:FindFirstChildOfClass(fooElementClass)).toBeUndefined()

		ReactRoblox.act(function()
			root:unmount()
		end)
	end)

	it("updates the navigation state when the URL updates", function()
		local fooElementClass = "TextLabel"
		local barElementClass = "Frame"
		local function FooScreen(_props)
			return React.createElement(UNIQUE_CLASS_NAME, {}, {
				Foo = React.createElement(fooElementClass),
			})
		end
		local function BarScreen(_props)
			return React.createElement(UNIQUE_CLASS_NAME, {}, {
				Bar = React.createElement(barElementClass),
			})
		end

		local testNavigator = createSwitchNavigator({
			{ Foo = { screen = FooScreen, path = "foo" } },
			{ Bar = { screen = BarScreen, path = "bar" } },
		})

		local protocolMock = getLinkingProtocolMock("foo")
		local app = createAppContainer(testNavigator, protocolMock)

		local element = React.createElement(app)
		local parent = Instance.new("Folder")
		local root = ReactRoblox.createRoot(parent)
		ReactRoblox.act(function()
			root:render(element)
		end)

		local screen = findFirstDescendantOfClass(parent, UNIQUE_CLASS_NAME)
		expect(screen).toBeDefined()
		expect(screen:FindFirstChildOfClass(fooElementClass)).toBeDefined()
		expect(screen:FindFirstChildOfClass(barElementClass)).toBeUndefined()

		ReactRoblox.act(function()
			protocolMock.callback("bar")
		end)

		screen = findFirstDescendantOfClass(parent, UNIQUE_CLASS_NAME)
		expect(screen).toBeDefined()
		expect(screen:FindFirstChildOfClass(barElementClass)).toBeDefined()
		expect(screen:FindFirstChildOfClass(fooElementClass)).toBeUndefined()

		ReactRoblox.act(function()
			root:unmount()
		end)
	end)
end)
