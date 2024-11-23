local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local React = require("@pkg/@jsdotlua/react")
local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")

local expect = JestGlobals.expect
local jest = JestGlobals.jest
local it = JestGlobals.it
local describe = JestGlobals.describe

local createRobloxStackNavigator = require("../createRobloxStackNavigator")
local getChildNavigation = require("../../getChildNavigation")

local Events = require("../../Events")
local NavigationActions = require("../../NavigationActions")
local createAppContainer = require("../../createAppContainer").createAppContainer
local waitUntil = require("../../utils/waitUntil")

it("should return a mountable Roact component", function()
	local navigator = createRobloxStackNavigator({
		{ Foo = function() end },
	})

	local testNavigation = {
		state = {
			routes = {
				{ routeName = "Foo", key = "Foo" },
			},
			index = 1,
		},
		router = navigator.router,
	}

	function testNavigation.getChildNavigation(childKey)
		return getChildNavigation(testNavigation, childKey, function()
			return testNavigation
		end)
	end

	function testNavigation.addListener(_symbol, _callback)
		return {
			remove = function() end,
		}
	end

	local parent = Instance.new("Folder")
	local root = ReactRoblox.createRoot(parent)

	expect(function()
		ReactRoblox.act(function()
			root:render(React.createElement(navigator, {
				navigation = testNavigation,
			}))
		end)
	end).never.toThrow()

	ReactRoblox.act(function()
		root:unmount()
	end)
end)

describe("Focus events", function()
	local function createComponent(focusCallback, blurCallback)
		local TestComponent = React.Component:extend("TestComponent")

		function TestComponent:didMount()
			local navigation = self.props.navigation

			self.focusSub = navigation.addListener(Events.WillFocus, focusCallback)
			self.blurSub = navigation.addListener(Events.WillBlur, blurCallback)
		end

		function TestComponent:willUnmount()
			self.focusSub.remove()
			self.blurSub.remove()
		end

		function TestComponent:render()
			return nil
		end

		return TestComponent
	end

	local function runFocusEventsTests(
		navigator,
		shouldTransitionBack,
		firstFocusCallback,
		firstBlurCallback,
		secondFocusCallback,
		secondBlurCallback
	)
		local dispatch
		local element = React.createElement(navigator, {
			externalDispatchConnector = function(currentDispatch)
				dispatch = currentDispatch
				return function()
					dispatch = nil
				end
			end,
		})

		local parent = Instance.new("Folder")
		local root = ReactRoblox.createRoot(parent)

		ReactRoblox.act(function()
			root:render(element)
		end)

		waitUntil(function()
			return #firstFocusCallback.mock.calls > 0
		end)

		expect(firstFocusCallback).toHaveBeenCalledTimes(1)
		expect(firstBlurCallback).toHaveBeenCalledTimes(0)
		expect(secondFocusCallback).toHaveBeenCalledTimes(0)
		expect(secondBlurCallback).toHaveBeenCalledTimes(0)

		dispatch(NavigationActions.navigate({ routeName = "second" }))

		waitUntil(function()
			return #firstBlurCallback.mock.calls > 0
		end)

		expect(firstFocusCallback).toHaveBeenCalledTimes(1)
		expect(firstBlurCallback).toHaveBeenCalledTimes(1)
		expect(secondFocusCallback).toHaveBeenCalledTimes(1)
		expect(secondBlurCallback).toHaveBeenCalledTimes(0)

		if shouldTransitionBack then
			dispatch(NavigationActions.back())
		else
			dispatch(NavigationActions.back({ immediate = true }))
		end

		waitUntil(function()
			return #secondBlurCallback.mock.calls > 0
		end)

		expect(firstFocusCallback).toHaveBeenCalledTimes(2)
		expect(firstBlurCallback).toHaveBeenCalledTimes(1)
		expect(secondFocusCallback).toHaveBeenCalledTimes(1)
		if shouldTransitionBack then
			expect(secondBlurCallback).toHaveBeenCalledTimes(1)
		else
			expect(secondBlurCallback).toHaveBeenCalledTimes(0)
		end

		ReactRoblox.act(function()
			root:unmount()
		end)
	end

	it("should emit willBlur event when removing a route from the nav state", function()
		local firstFocusCallback, firstFocusCallbackFn = jest.fn()
		local firstBlurCallback, firstBlurCallbackFn = jest.fn()

		local secondFocusCallback, secondFocusCallbackFn = jest.fn()
		local secondBlurCallback, secondBlurCallbackFn = jest.fn()

		local Navigator = createAppContainer(createRobloxStackNavigator({
			{ first = createComponent(firstFocusCallbackFn, firstBlurCallbackFn) },
			{ second = createComponent(secondFocusCallbackFn, secondBlurCallbackFn) },
		}))

		runFocusEventsTests(
			Navigator,
			true, -- with transition
			firstFocusCallback,
			firstBlurCallback,
			secondFocusCallback,
			secondBlurCallback
		)

		firstFocusCallback.mockClear()
		firstBlurCallback.mockClear()
		secondFocusCallback.mockClear()
		secondBlurCallback.mockClear()

		runFocusEventsTests(
			Navigator,
			false, -- without transition
			firstFocusCallback,
			firstBlurCallback,
			secondFocusCallback,
			secondBlurCallback
		)
	end)

	it("should emit willBlur event when removing a route from the nav state for nested navigators", function()
		local firstFocusCallback, firstFocusCallbackFn = jest.fn()
		local firstBlurCallback, firstBlurCallbackFn = jest.fn()

		local secondFocusCallback, secondFocusCallbackFn = jest.fn()
		local secondBlurCallback, secondBlurCallbackFn = jest.fn()

		local Navigator = createAppContainer(createRobloxStackNavigator({
			{ first = createComponent(firstFocusCallbackFn, firstBlurCallbackFn) },
			{
				nested = createRobloxStackNavigator({
					{ second = createComponent(secondFocusCallbackFn, secondBlurCallbackFn) },
				}),
			},
		}))

		runFocusEventsTests(
			Navigator,
			true, -- with transition
			firstFocusCallback,
			firstBlurCallback,
			secondFocusCallback,
			secondBlurCallback
		)

		firstFocusCallback.mockClear()
		firstBlurCallback.mockClear()
		secondFocusCallback.mockClear()
		secondBlurCallback.mockClear()

		runFocusEventsTests(
			Navigator,
			false, -- without transition
			firstFocusCallback,
			firstBlurCallback,
			secondFocusCallback,
			secondBlurCallback
		)
	end)
end)
