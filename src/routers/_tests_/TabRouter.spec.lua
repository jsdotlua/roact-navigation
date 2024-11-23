-- upstream https://github.com/react-navigation/react-navigation/blob/72e8160537954af40f1b070aa91ef45fc02bba69/packages/core/src/routers/__tests__/TabRouter.test.js

local React = require("@pkg/@jsdotlua/react")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

local BackBehavior = require("../../BackBehavior")
local NavigationActions = require("../../NavigationActions")
local TabRouter = require("../TabRouter")

local BareLeafRouteConfig = {
	screen = function()
		return React.createElement("Frame")
	end,
}

local INIT_ACTION = { type = NavigationActions.Init }

describe("TabRouter", function()
	it("Handles basic tab logic", function()
		local function ScreenA()
			return React.createElement("Frame")
		end
		local function ScreenB()
			return React.createElement("Frame")
		end
		local router = TabRouter({
			{ Foo = { screen = ScreenA } },
			{ Bar = { screen = ScreenB } },
		})
		local state = router.getStateForAction({
			type = NavigationActions.Init,
		})
		local expectedState = {
			index = 1,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{ key = "Bar", routeName = "Bar" },
			},
		}

		expect(state).toEqual(expectedState)

		local state2 = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "Bar",
		}, state)
		local expectedState2 = {
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{ key = "Bar", routeName = "Bar" },
			},
		}

		expect(state2).toEqual(expectedState2)
		expect(router.getComponentForState(expectedState)).toBe(ScreenA)
		expect(router.getComponentForState(expectedState2)).toBe(ScreenB)

		local state3 = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "Bar",
		}, state2)

		expect(state3).toEqual(nil)
	end)

	it("Handles getScreen", function()
		local function ScreenA()
			return React.createElement("Frame")
		end
		local function ScreenB()
			return React.createElement("Frame")
		end
		local router = TabRouter({
			{ Foo = {
				getScreen = function()
					return ScreenA
				end,
			} },
			{ Bar = {
				getScreen = function()
					return ScreenB
				end,
			} },
		})
		local state = router.getStateForAction({
			type = NavigationActions.Init,
		})
		local expectedState = {
			index = 1,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{ key = "Bar", routeName = "Bar" },
			},
		}

		expect(state).toEqual(expectedState)

		local state2 = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "Bar",
		}, state)
		local expectedState2 = {
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{ key = "Bar", routeName = "Bar" },
			},
		}

		expect(state2).toEqual(expectedState2)
		expect(router.getComponentForState(expectedState)).toBe(ScreenA)
		expect(router.getComponentForState(expectedState2)).toBe(ScreenB)

		local state3 = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "Bar",
		}, state2)

		expect(state3).toEqual(nil)
	end)

	it("Can set the initial tab", function()
		local router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Bar = BareLeafRouteConfig },
		}, {
			initialRouteName = "Bar",
		})
		local state = router.getStateForAction({ type = NavigationActions.Init })

		expect(state).toEqual({
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{ key = "Bar", routeName = "Bar" },
			},
		})
	end)

	it("Can set the initial params", function()
		local router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Bar = BareLeafRouteConfig },
		}, {
			initialRouteName = "Bar",
			initialRouteParams = { name = "Qux" },
		})
		local state = router.getStateForAction({ type = NavigationActions.Init })

		expect(state).toEqual({
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{ key = "Bar", routeName = "Bar", params = { name = "Qux" } },
			},
		})
	end)

	it("Handles the SetParams action", function()
		local router = TabRouter({
			{
				Foo = {
					screen = function()
						return React.createElement("Frame")
					end,
				},
			},
			{
				Bar = {
					screen = function()
						return React.createElement("Frame")
					end,
				},
			},
		})
		local state2 = router.getStateForAction({
			type = NavigationActions.SetParams,
			params = { name = "Qux" },
			key = "Foo",
		})

		expect(state2 and state2.routes[1].params).toEqual({
			name = "Qux",
		})
	end)

	it("Handles the SetParams action for inactive routes", function()
		local router = TabRouter({
			{
				Foo = {
					screen = function()
						return React.createElement("Frame")
					end,
				},
			},
			{
				Bar = {
					screen = function()
						return React.createElement("Frame")
					end,
				},
			},
		}, {
			initialRouteName = "Bar",
		})
		local initialState = {
			index = 2,
			routes = {
				{
					key = "RouteA",
					routeName = "Foo",
					params = { name = "InitialParam", other = "Unchanged" },
				},
				{ key = "RouteB", routeName = "Bar", params = {} },
			},
		}
		local state = router.getStateForAction({
			type = NavigationActions.SetParams,
			params = { name = "NewParam" },
			key = "RouteA",
		}, initialState)

		expect(state.index).toEqual(2)
		expect(state.routes[1].params).toEqual({
			name = "NewParam",
			other = "Unchanged",
		})
	end)

	it("getStateForAction returns null when navigating to same tab", function()
		local router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Bar = BareLeafRouteConfig },
		}, {
			initialRouteName = "Bar",
		})
		local state = router.getStateForAction({
			type = NavigationActions.Init,
		})
		local state2 = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "Bar",
		}, state)

		expect(state2).toEqual(nil)
	end)

	it("getStateForAction returns initial navigate", function()
		local router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Bar = BareLeafRouteConfig },
		})
		local state = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "Foo",
		})

		expect(state and state.index).toEqual(1)
	end)

	it("Handles nested tabs and nested actions", function()
		local ChildTabNavigator = React.Component:extend("ChildTabNavigator")

		function ChildTabNavigator:render()
			return React.createElement("Frame")
		end

		ChildTabNavigator.router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Bar = BareLeafRouteConfig },
		})

		local router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Baz = { screen = ChildTabNavigator } },
			{ Boo = BareLeafRouteConfig },
		})
		local action = router.getActionForPathAndParams("Baz/Bar", { foo = "42" })
		local navAction = {
			type = NavigationActions.Navigate,
			routeName = "Baz",
			params = { foo = "42" },
			action = {
				type = NavigationActions.Navigate,
				routeName = "Bar",
				params = { foo = "42" },
			},
		}

		expect(action).toEqual(navAction)

		local state = router.getStateForAction(navAction)

		expect(state).toEqual({
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{
					index = 2,
					key = "Baz",
					routeName = "Baz",
					params = { foo = "42" },
					routes = {
						{ key = "Foo", routeName = "Foo" },
						{
							key = "Bar",
							routeName = "Bar",
							params = { foo = "42" },
						},
					},
				},
				{ key = "Boo", routeName = "Boo" },
			},
		})
	end)

	it("Handles passing params to nested tabs", function()
		local ChildTabNavigator = React.Component:extend("ChildTabNavigator")

		function ChildTabNavigator:render()
			return React.createElement("Frame")
		end

		ChildTabNavigator.router = TabRouter({
			{ Boo = BareLeafRouteConfig },
			{ Bar = BareLeafRouteConfig },
		})

		local router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Baz = { screen = ChildTabNavigator } },
		})
		local navAction = {
			type = NavigationActions.Navigate,
			routeName = "Baz",
		}
		local state = router.getStateForAction(navAction)

		expect(state).toEqual({
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{
					index = 1,
					key = "Baz",
					routeName = "Baz",
					routes = {
						{ key = "Boo", routeName = "Boo" },
						{ key = "Bar", routeName = "Bar" },
					},
				},
			},
		})

		-- Ensure that navigating back and forth doesn't overwrite
		state = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "Bar" }, state)
		state = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "Boo" }, state)

		expect(state and state.routes[2]).toEqual({
			index = 1,
			key = "Baz",
			routeName = "Baz",
			routes = {
				{ key = "Boo", routeName = "Boo" },
				{ key = "Bar", routeName = "Bar" },
			},
		})
	end)

	it("Handles initial deep linking into nested tabs", function()
		local ChildTabNavigator = React.Component:extend("ChildTabNavigator")

		function ChildTabNavigator:render()
			return React.createElement("Frame")
		end

		ChildTabNavigator.router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Bar = BareLeafRouteConfig },
		})

		local router = TabRouter({
			{ Foo = BareLeafRouteConfig },
			{ Baz = { screen = ChildTabNavigator } },
			{ Boo = BareLeafRouteConfig },
		})
		local state = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "Bar",
		})

		expect(state).toEqual({
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{
					index = 2,
					key = "Baz",
					routeName = "Baz",
					routes = {
						{ key = "Foo", routeName = "Foo" },
						{ key = "Bar", routeName = "Bar" },
					},
				},
				{ key = "Boo", routeName = "Boo" },
			},
		})

		local state2 = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "Foo" }, state)
		expect(state2).toEqual({
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{
					index = 1,
					key = "Baz",
					routeName = "Baz",
					routes = {
						{ key = "Foo", routeName = "Foo" },
						{ key = "Bar", routeName = "Bar" },
					},
				},
				{ key = "Boo", routeName = "Boo" },
			},
		})

		local state3 = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "Foo" }, state2)
		expect(state3).toEqual(nil)
	end)

	it("Handles linking across of deeply nested tabs", function()
		local ChildNavigator0 = React.Component:extend("ChildNavigator0")
		function ChildNavigator0:render()
			return React.createElement("Frame")
		end

		ChildNavigator0.router = TabRouter({
			{ Boo = BareLeafRouteConfig },
			{ Baz = BareLeafRouteConfig },
		})

		local ChildNavigator1 = React.Component:extend("ChildNavigator1")
		function ChildNavigator1:render()
			return React.createElement("Frame")
		end

		ChildNavigator1.router = TabRouter({
			{ Zoo = BareLeafRouteConfig },
			{ Zap = BareLeafRouteConfig },
		})

		local MidNavigator = React.Component:extend("MidNavigator")
		function MidNavigator:render()
			return React.createElement("Frame")
		end

		MidNavigator.router = TabRouter({
			{ Fee = { screen = ChildNavigator0 } },
			{ Bar = { screen = ChildNavigator1 } },
		})

		local router = TabRouter({
			{ Foo = { screen = MidNavigator } },
			{ Gah = BareLeafRouteConfig },
		})
		local state = router.getStateForAction(INIT_ACTION)

		expect(state).toEqual({
			index = 1,
			routes = {
				{
					index = 1,
					key = "Foo",
					routeName = "Foo",
					routes = {
						{
							index = 1,
							key = "Fee",
							routeName = "Fee",
							routes = {
								{ key = "Boo", routeName = "Boo" },
								{ key = "Baz", routeName = "Baz" },
							},
						},
						{
							index = 1,
							key = "Bar",
							routeName = "Bar",
							routes = {
								{ key = "Zoo", routeName = "Zoo" },
								{ key = "Zap", routeName = "Zap" },
							},
						},
					},
				},
				{ key = "Gah", routeName = "Gah" },
			},
		})

		local state2 = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "Zap" }, state)

		expect(state2).toEqual({
			index = 1,
			routes = {
				{
					index = 2,
					key = "Foo",
					routeName = "Foo",
					routes = {
						{
							index = 1,
							key = "Fee",
							routeName = "Fee",
							routes = {
								{ key = "Boo", routeName = "Boo" },
								{ key = "Baz", routeName = "Baz" },
							},
						},
						{
							index = 2,
							key = "Bar",
							routeName = "Bar",
							routes = {
								{ key = "Zoo", routeName = "Zoo" },
								{ key = "Zap", routeName = "Zap" },
							},
						},
					},
				},
				{ key = "Gah", routeName = "Gah" },
			},
		})

		local state3 = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "Zap" }, state2)

		expect(state3).toEqual(nil)

		local state4 = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "Foo",
			action = {
				type = NavigationActions.Navigate,
				routeName = "Bar",
				action = { type = NavigationActions.Navigate, routeName = "Zap" },
			},
		})

		expect(state4).toEqual({
			index = 1,
			routes = {
				{
					index = 2,
					key = "Foo",
					routeName = "Foo",
					routes = {
						{
							index = 1,
							key = "Fee",
							routeName = "Fee",
							routes = {
								{ key = "Boo", routeName = "Boo" },
								{ key = "Baz", routeName = "Baz" },
							},
						},
						{
							index = 2,
							key = "Bar",
							routeName = "Bar",
							routes = {
								{ key = "Zoo", routeName = "Zoo" },
								{ key = "Zap", routeName = "Zap" },
							},
						},
					},
				},
				{ key = "Gah", routeName = "Gah" },
			},
		})
	end)

	it("Handles path configuration", function()
		local function ScreenA()
			return React.createElement("Frame")
		end
		local function ScreenB()
			return React.createElement("Frame")
		end
		local router = TabRouter({
			{ Foo = { path = "f", screen = ScreenA } },
			{ Bar = { path = "b/:great", screen = ScreenB } },
		})
		local params = { foo = "42" }
		local action = router.getActionForPathAndParams("b/anything", params)
		local expectedAction = {
			params = {
				foo = "42",
				great = "anything",
			},
			routeName = "Bar",
			type = NavigationActions.Navigate,
		}

		expect(action).toEqual(expectedAction)

		local state = router.getStateForAction({ type = NavigationActions.Init })
		local expectedState = {
			index = 1,
			routes = {
				{ key = "Foo", routeName = "Foo" },
				{ key = "Bar", routeName = "Bar" },
			},
		}

		expect(state).toEqual(expectedState)

		local state2 = router.getStateForAction(expectedAction, state)
		local expectedState2 = {
			index = 2,
			routes = {
				{ key = "Foo", routeName = "Foo", params = nil },
				{
					key = "Bar",
					routeName = "Bar",
					params = { foo = "42", great = "anything" },
				},
			},
		}

		expect(state2).toEqual(expectedState2)
		expect(router.getComponentForState(expectedState)).toBe(ScreenA)
		expect(router.getComponentForState(expectedState2)).toBe(ScreenB)
		expect(router.getPathAndParamsForState(expectedState).path).toEqual("f")
		expect(router.getPathAndParamsForState(expectedState2).path).toEqual("b/anything")
	end)

	it("Handles default configuration", function()
		local function ScreenA()
			return React.createElement("Frame")
		end
		local function ScreenB()
			return React.createElement("Frame")
		end
		local router = TabRouter({
			{ Foo = { path = "", screen = ScreenA } },
			{ Bar = { path = "b", screen = ScreenB } },
		})
		local action = router.getActionForPathAndParams("", { foo = "42" })

		expect(action).toEqual({
			params = { foo = "42" },
			routeName = "Foo",
			type = NavigationActions.Navigate,
		})
	end)

	it("Gets deep path", function()
		local ScreenA = React.Component:extend("ScreenA")
		function ScreenA:render()
			return React.createElement("Frame")
		end
		local function ScreenB()
			return React.createElement("Frame")
		end

		ScreenA.router = TabRouter({
			{ Baz = { screen = ScreenB } },
			{ Boo = { screen = ScreenB } },
		})

		local router = TabRouter({
			{ Foo = { path = "f", screen = ScreenA } },
			{ Bar = { screen = ScreenB } },
		})
		local state = {
			index = 1,
			routes = {
				{
					index = 2,
					key = "Foo",
					routeName = "Foo",
					routes = {
						{ key = "Boo", routeName = "Boo" },
						{ key = "Baz", routeName = "Baz" },
					},
				},
				{ key = "Bar", routeName = "Bar" },
			},
		}
		local path = router.getPathAndParamsForState(state).path

		expect(path).toEqual("f/Baz")
	end)

	it("Can navigate to other tab (no router) with params", function()
		local function ScreenA()
			return React.createElement("Frame")
		end
		local function ScreenB()
			return React.createElement("Frame")
		end
		local router = TabRouter({
			{ a = { screen = ScreenA } },
			{ b = { screen = ScreenB } },
		})
		local state0 = router.getStateForAction(INIT_ACTION)

		expect(state0).toEqual({
			index = 1,
			routes = {
				{ key = "a", routeName = "a" },
				{ key = "b", routeName = "b" },
			},
		})

		local params = { key = "value" }
		local state1 = router.getStateForAction({
			type = NavigationActions.Navigate,
			routeName = "b",
			params = params,
		}, state0)

		expect(state1).toEqual({
			index = 2,
			routes = {
				{ key = "a", routeName = "a" },
				{ key = "b", routeName = "b", params = params },
			},
		})
	end)

	it("Back actions are not propagated to inactive children", function()
		local function ScreenA()
			return React.createElement("Frame")
		end
		local function ScreenB()
			return React.createElement("Frame")
		end
		local function ScreenC()
			return React.createElement("Frame")
		end
		local InnerNavigator = React.Component:extend("InnerNavigator")
		function InnerNavigator:render()
			return React.createElement("Frame")
		end

		InnerNavigator.router = TabRouter({
			{ a = { screen = ScreenA } },
			{ b = { screen = ScreenB } },
		})

		local router = TabRouter({
			{ inner = { screen = InnerNavigator } },
			{ c = { screen = ScreenC } },
		}, {
			backBehavior = BackBehavior.None,
		})
		local state0 = router.getStateForAction(INIT_ACTION)
		local state1 = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "b" }, state0)
		local state2 = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "c" }, state1)
		local state3 = router.getStateForAction({ type = NavigationActions.Back }, state2)

		expect(state3).toEqual(state2)
	end)

	it("Back behavior initialRoute works", function()
		local function ScreenA()
			return React.createElement("Frame")
		end
		local function ScreenB()
			return React.createElement("Frame")
		end
		local router = TabRouter({
			{ a = { screen = ScreenA } },
			{ b = { screen = ScreenB } },
		})
		local state0 = router.getStateForAction(INIT_ACTION)
		local state1 = router.getStateForAction({ type = NavigationActions.Navigate, routeName = "b" }, state0)
		local state2 = router.getStateForAction({ type = NavigationActions.Back }, state1)

		expect(state2).toEqual(state0)
	end)

	it("Inner actions are only unpacked if the current tab matches", function()
		local PlainScreen = function()
			return React.createElement("Frame")
		end
		local ScreenA = React.Component:extend("ScreenA")
		function ScreenA:render()
			return React.createElement("Frame")
		end
		local ScreenB = React.Component:extend("ScreenB")
		function ScreenB:render()
			return React.createElement("Frame")
		end

		ScreenB.router = TabRouter({
			{ Baz = { screen = PlainScreen } },
			{ Zoo = { screen = PlainScreen } },
		})
		ScreenA.router = TabRouter({
			{ Bar = { screen = PlainScreen } },
			{ Boo = { screen = ScreenB } },
		})
		local router = TabRouter({
			{ Foo = { screen = ScreenA } },
		})

		local screenApreState = {
			index = 1,
			key = "Foo",
			routeName = "Foo",
			routes = {
				{ key = "Bar", routeName = "Bar" },
			},
		}
		local preState = {
			index = 1,
			routes = { screenApreState },
		}

		local function comparable(state)
			local result = {}

			if type(state.routeName) == "string" then
				result.routeName = state.routeName
			end
			if type(state.routes) == "table" then
				result.routes = {}
				for i = 1, #state.routes do
					result.routes[i] = comparable(state.routes[i])
				end
			end

			return result
		end

		local action = NavigationActions.navigate({
			routeName = "Boo",
			action = NavigationActions.navigate({ routeName = "Zoo" }),
		})
		local expectedState = ScreenA.router.getStateForAction(action, screenApreState)
		local state = router.getStateForAction(action, preState)
		local innerState = state and state.routes[1] or state

		expect(innerState.routes[2].index).toEqual(2)
		expect(expectedState and comparable(expectedState)).toEqual(innerState and comparable(innerState))

		local noMatchAction = NavigationActions.navigate({
			routeName = "Qux",
			action = NavigationActions.navigate({ routeName = "Zoo" }),
		})
		local expectedState2 = ScreenA.router.getStateForAction(noMatchAction, screenApreState)
		local state2 = router.getStateForAction(noMatchAction, preState)
		local innerState2 = state2 and state2.routes[1] or state2

		expect(innerState2.routes[2].index).toEqual(1)
		expect(expectedState2 and comparable(expectedState2)).toEqual(innerState2 and comparable(innerState2))
	end)
end)
