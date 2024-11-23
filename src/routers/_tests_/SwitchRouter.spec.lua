-- upstream https://github.com/react-navigation/react-navigation/blob/fcd7d83c4c33ad1fa508c8cfe687d2fa259bfc2c/packages/core/src/routers/__tests__/SwitchRouter.test.js

local React = require("@pkg/@jsdotlua/react")
local LuauPolyfill = require("@pkg/@jsdotlua/luau-polyfill")
local Object = LuauPolyfill.Object
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

local StackRouter = require("../StackRouter")
local SwitchRouter = require("../SwitchRouter")
local NavigationActions = require("../../NavigationActions")
local BackBehavior = require("../../BackBehavior")
local getRouterTestHelper = require("./routerTestHelper")

local function getExampleRouter(config)
	config = config or {}

	local function PlainScreen()
		return React.createElement("Frame")
	end
	local StackA = React.Component:extend("StackA")
	function StackA:render()
		return React.createElement("Frame")
	end
	local StackB = React.Component:extend("StackB")
	function StackB:render()
		return React.createElement("Frame")
	end
	local StackC = React.Component:extend("StackC")
	function StackC:render()
		return React.createElement("Frame")
	end

	StackA.router = StackRouter({
		{ A1 = PlainScreen },
		{ A2 = PlainScreen },
	})
	StackB.router = StackRouter({
		{ B1 = PlainScreen },
		{ B2 = PlainScreen },
	})
	StackC.router = StackRouter({
		{ C1 = PlainScreen },
		{ C2 = PlainScreen },
	})

	local router = SwitchRouter({
		{ A = { screen = StackA, path = "" } },
		{ B = { screen = StackB, path = "great/path" } },
		{ C = { screen = StackC, path = "pathC" } },
	}, Object.assign({ initialRouteName = "A" }, config))

	return router
end

describe("SwitchRouter", function()
	it("resets the route when unfocusing a tab by default", function()
		local helper = getRouterTestHelper(getExampleRouter())
		local navigateTo = helper.navigateTo
		local getState = helper.getState

		navigateTo("A2")
		expect(getState().routes[1].index).toEqual(2)
		expect(#getState().routes[1].routes).toEqual(2)

		navigateTo("B")
		expect(getState().routes[1].index).toEqual(1)
		expect(#getState().routes[1].routes).toEqual(1)
	end)

	it("does not reset the route on unfocus if resetOnBlur is false", function()
		local helper = getRouterTestHelper(getExampleRouter({ resetOnBlur = false }))
		local navigateTo = helper.navigateTo
		local getState = helper.getState

		navigateTo("A2")
		expect(getState().routes[1].index).toEqual(2)
		expect(#getState().routes[1].routes).toEqual(2)
		navigateTo("B")
		expect(getState().routes[1].index).toEqual(2)
		expect(#getState().routes[1].routes).toEqual(2)
	end)

	it("ignores back by default", function()
		local helper = getRouterTestHelper(getExampleRouter())
		local jumpTo = helper.jumpTo
		local back = helper.back
		local getState = helper.getState

		jumpTo("B")
		expect(getState().index).toEqual(2)

		back()
		expect(getState().index).toEqual(2)
	end)

	it("handles initialRoute backBehavior", function()
		local helper = getRouterTestHelper(getExampleRouter({
			backBehavior = BackBehavior.InitialRoute,
			initialRouteName = "B",
		}))
		local jumpTo = helper.jumpTo
		local back = helper.back
		local getState = helper.getState

		expect(getState().routeKeyHistory).toEqual(nil)
		expect(getState().index).toEqual(2)

		jumpTo("C")
		expect(getState().index).toEqual(3)

		jumpTo("A")
		expect(getState().index).toEqual(1)

		back()
		expect(getState().index).toEqual(2)

		back()
		expect(getState().index).toEqual(2)
	end)

	it("handles order backBehavior", function()
		local helper = getRouterTestHelper(getExampleRouter({
			backBehavior = BackBehavior.Order,
		}))
		local navigateTo = helper.navigateTo
		local back = helper.back
		local getState = helper.getState

		expect(getState().routeKeyHistory).toEqual(nil)

		navigateTo("C")
		expect(getState().index).toEqual(3)

		back()
		expect(getState().index).toEqual(2)

		back()
		expect(getState().index).toEqual(1)

		back()
		expect(getState().index).toEqual(1)
	end)

	it("handles history backBehavior", function()
		local helper = getRouterTestHelper(getExampleRouter({
			backBehavior = BackBehavior.History,
		}))
		local navigateTo = helper.navigateTo
		local back = helper.back
		local getState = helper.getState

		expect(getState().routeKeyHistory).toEqual({ "A" })

		navigateTo("B")
		expect(getState().index).toEqual(2)
		expect(getState().routeKeyHistory).toEqual({ "A", "B" })

		navigateTo("A")
		expect(getState().index).toEqual(1)
		expect(getState().routeKeyHistory).toEqual({ "B", "A" })

		navigateTo("C")
		expect(getState().index).toEqual(3)
		expect(getState().routeKeyHistory).toEqual({ "B", "A", "C" })

		navigateTo("A")
		expect(getState().index).toEqual(1)
		expect(getState().routeKeyHistory).toEqual({ "B", "C", "A" })

		back()
		expect(getState().index).toEqual(3)
		expect(getState().routeKeyHistory).toEqual({ "B", "C" })

		back()
		expect(getState().index).toEqual(2)
		expect(getState().routeKeyHistory).toEqual({ "B" })

		back()
		expect(getState().index).toEqual(2)
		expect(getState().routeKeyHistory).toEqual({ "B" })
	end)

	it("handles history backBehavior without popping routeKeyHistory when child handles action", function()
		local helper = getRouterTestHelper(getExampleRouter({
			backBehavior = BackBehavior.History,
		}))
		local navigateTo = helper.navigateTo
		local back = helper.back
		local getState = helper.getState
		local getSubState = helper.getSubState

		expect(getState().routeKeyHistory).toEqual({ "A" })

		navigateTo("B")
		expect(getState().index).toEqual(2)
		expect(getState().routeKeyHistory).toEqual({ "A", "B" })

		navigateTo("B2")
		expect(getState().index).toEqual(2)
		expect(getState().routeKeyHistory).toEqual({ "A", "B" })
		expect(getSubState(2).routeName).toEqual("B2")

		back()
		expect(getState().index).toEqual(2)
		-- "B" should not be popped when the child handles the back action
		expect(getState().routeKeyHistory).toEqual({ "A", "B" })
		expect(getSubState(2).routeName).toEqual("B1")
	end)

	it("handles back and does not apply back action to inactive child", function()
		local helper = getRouterTestHelper(getExampleRouter({
			backBehavior = "initialRoute",
			resetOnBlur = false, -- Don't erase the state of substack B when we switch back to A
		}))
		local navigateTo = helper.navigateTo
		local back = helper.back
		local getSubState = helper.getSubState

		expect(getSubState(1).routeName).toEqual("A")

		navigateTo("B")
		navigateTo("B2")
		expect(getSubState(1).routeName).toEqual("B")
		expect(getSubState(2).routeName).toEqual("B2")

		navigateTo("A")
		expect(getSubState(1).routeName).toEqual("A")

		-- The back action should not switch to B. It should stay on A
		back(nil)
		expect(getSubState(1).routeName).toEqual("A")
	end)

	it("handles pop and does not apply pop action to inactive child", function()
		local helper = getRouterTestHelper(getExampleRouter({
			backBehavior = "initialRoute",
			resetOnBlur = false, -- Don't erase the state of substack B when we switch back to A
		}))
		local navigateTo = helper.navigateTo
		local pop = helper.pop
		local getSubState = helper.getSubState

		expect(getSubState(1).routeName).toEqual("A")

		navigateTo("B")
		navigateTo("B2")
		expect(getSubState(1).routeName).toEqual("B")
		expect(getSubState(2).routeName).toEqual("B2")

		navigateTo("A")
		expect(getSubState(1).routeName).toEqual("A")

		-- The pop action should not switch to B. It should stay on A
		pop()
		expect(getSubState(1).routeName).toEqual("A")
	end)

	it("handles popToTop and does not apply popToTop action to inactive child", function()
		local helper = getRouterTestHelper(getExampleRouter({
			backBehavior = "initialRoute",
			resetOnBlur = false, -- Don't erase the state of substack B when we switch back to A
		}))
		local navigateTo = helper.navigateTo
		local popToTop = helper.popToTop
		local getSubState = helper.getSubState

		expect(getSubState(1).routeName).toEqual("A")

		navigateTo("B")
		navigateTo("B2")
		expect(getSubState(1).routeName).toEqual("B")
		expect(getSubState(2).routeName).toEqual("B2")

		navigateTo("A")
		expect(getSubState(1).routeName).toEqual("A")

		-- The popToTop action should not switch to B. It should stay on A
		popToTop()
		expect(getSubState(1).routeName).toEqual("A")
	end)

	it("handles back and does switch to inactive child with matching key", function()
		local helper = getRouterTestHelper(getExampleRouter({
			backBehavior = "initialRoute",
			resetOnBlur = false, -- Don't erase the state of substack B when we switch back to A
		}))
		local navigateTo = helper.navigateTo
		local back = helper.back
		local getSubState = helper.getSubState

		expect(getSubState(1).routeName).toEqual("A")

		navigateTo("B")
		navigateTo("B2")
		expect(getSubState(1).routeName).toEqual("B")
		expect(getSubState(2).routeName).toEqual("B2")

		local b2Key = getSubState(2).key

		navigateTo("A")
		expect(getSubState(1).routeName).toEqual("A")

		-- The back action should switch to B and go back from B2 to B1
		back(b2Key)
		expect(getSubState(1).routeName).toEqual("B")
		expect(getSubState(2).routeName).toEqual("B1")
	end)

	it("handles nested actions", function()
		local helper = getRouterTestHelper(getExampleRouter())
		local navigateTo = helper.navigateTo
		local getSubState = helper.getSubState

		navigateTo("B", {
			action = {
				type = NavigationActions.Navigate,
				routeName = "B2",
			},
		})
		expect(getSubState(1).routeName).toEqual("B")
		expect(getSubState(2).routeName).toEqual("B2")
	end)

	it("handles nested actions and params simultaneously", function()
		local helper = getRouterTestHelper(getExampleRouter())
		local navigateTo = helper.navigateTo
		local getSubState = helper.getSubState

		local params1 = { foo = "bar" }
		local params2 = { bar = "baz" }

		navigateTo("B", {
			params = params1,
			action = {
				type = NavigationActions.Navigate,
				routeName = "B2",
				params = params2,
			},
		})
		expect(getSubState(1).routeName).toEqual("B")
		expect(getSubState(1).params).toEqual(params1)
		expect(getSubState(2).routeName).toEqual("B2")
		expect(getSubState(2).params).toEqual(params2)
	end)

	it("order of handling navigate action is correct for nested switchrouters", function()
		-- router = switch({ Nested: switch({ Foo, Bar }), Other: switch({ Foo }), Bar })
		-- if we are focused on Other and navigate to Bar, what should happen?

		local function Screen()
			return React.createElement("Frame")
		end
		local NestedSwitch = React.Component:extend("NestedSwitch")
		function NestedSwitch:render()
			return React.createElement("Frame")
		end
		local OtherNestedSwitch = React.Component:extend("OtherNestedSwitch")
		function OtherNestedSwitch:render()
			return React.createElement("Frame")
		end

		local nestedRouter = SwitchRouter({
			{ Foo = Screen },
			{ Bar = Screen },
		})
		local otherNestedRouter = SwitchRouter({
			{ Foo = Screen },
		})

		NestedSwitch.router = nestedRouter
		OtherNestedSwitch.router = otherNestedRouter

		local router = SwitchRouter({
			{ NestedSwitch = NestedSwitch },
			{ OtherNestedSwitch = OtherNestedSwitch },
			{ Bar = Screen },
		}, { initialRouteName = "OtherNestedSwitch" })

		local helper = getRouterTestHelper(router)
		local navigateTo = helper.navigateTo
		local getSubState = helper.getSubState

		expect(getSubState(1).routeName).toEqual("OtherNestedSwitch")

		navigateTo("Bar")
		expect(getSubState(1).routeName).toEqual("Bar")

		navigateTo("NestedSwitch")
		navigateTo("Bar")

		expect(getSubState(1).routeName).toEqual("NestedSwitch")
		expect(getSubState(2).routeName).toEqual("Bar")
	end)

	-- https://github.com/react-navigation/react-navigation.github.io/issues/117#issuecomment-385597628
	it("order of handling navigate action is correct for nested stackrouters", function()
		local function Screen()
			return React.createElement("Frame")
		end
		local MainStack = React.Component:extend("MainStack")
		function MainStack:render()
			return React.createElement("Frame")
		end
		local LoginStack = React.Component:extend("LoginStack")
		function LoginStack:render()
			return React.createElement("Frame")
		end

		MainStack.router = StackRouter({
			{ Home = Screen },
			{ Profile = Screen },
		})
		LoginStack.router = StackRouter({
			{ Form = Screen },
			{ ForgotPassword = Screen },
		})

		local router = SwitchRouter({
			{ Home = Screen },
			{ Login = LoginStack },
			{ Main = MainStack },
		}, { initialRouteName = "Login" })

		local helper = getRouterTestHelper(router)
		local navigateTo = helper.navigateTo
		local getSubState = helper.getSubState

		expect(getSubState(1).routeName).toEqual("Login")

		navigateTo("Home")
		expect(getSubState(1).routeName).toEqual("Home")
	end)

	it("does not error for a nested navigate action in an uninitialized history router", function()
		local helper = getRouterTestHelper(
			getExampleRouter({
				backBehavior = "history",
			}),
			{ skipInitializeState = true }
		)
		local navigateTo = helper.navigateTo
		local getSubState = helper.getSubState

		navigateTo("B", {
			action = NavigationActions.navigate({ routeName = "B2" }),
		})
		expect(getSubState(1).routeName).toEqual("B")
		expect(getSubState(2).routeName).toEqual("B2")
	end)
end)
