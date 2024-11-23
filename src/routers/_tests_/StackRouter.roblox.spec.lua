local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe

local StackRouter = require("../StackRouter")
local StackActions = require("../StackActions")
local NavigationActions = require("../../NavigationActions")

it("should be a function", function()
	expect(StackRouter).toEqual(expect.any("function"))
end)

it("should throw when passed a non-table", function()
	expect(function()
		StackRouter(5)
	end).toThrow("routeConfigs must be an array table")
end)

it("should throw if initialRouteName is not found in routes table", function()
	expect(function()
		StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		}, {
			initialRouteName = "MyRoute",
		})
	end).toThrow("Invalid initialRouteName 'MyRoute'. Must be one of [Foo,Bar,]")
end)

it("should expose childRouters as a member", function()
	local router = StackRouter({
		{
			Foo = {
				screen = {
					render = function() end,
					router = "A",
				},
			},
		},
		{
			Bar = {
				screen = {
					render = function() end,
					router = "B",
				},
			},
		},
	})

	expect(router.childRouters.Foo).toEqual("A")
	expect(router.childRouters.Bar).toEqual("B")
end)

it("should not expose childRouters list members if they are CHILD_IS_SCREEN", function()
	local router = StackRouter({
		{
			Foo = {
				screen = {
					render = function() end,
					router = "A",
				},
			},
		},
		{
			Bar = {
				screen = {
					render = function() end,
				},
			},
		},
	})

	expect(router.childRouters.Foo).toEqual("A")

	expect(router._CHILD_IS_SCREEN).never.toEqual(nil)
	for _, childRouter in pairs(router.childRouters) do
		expect(childRouter).never.toBe(router._CHILD_IS_SCREEN)
	end
end)

describe("getScreenOptions tests", function()
	it("should correctly configure default screen options", function()
		local router = StackRouter({
			{
				Foo = {
					screen = {
						render = function() end,
					},
				},
			},
		}, {
			defaultNavigationOptions = {
				title = "FooTitle",
			},
		})

		local screenOptions = router.getScreenOptions({
			state = {
				routeName = "Foo",
			},
		})

		expect(screenOptions.title).toEqual("FooTitle")
	end)

	it("should correctly configure route-specified screen options", function()
		local router = StackRouter({
			{
				Foo = {
					screen = {
						render = function() end,
					},
					navigationOptions = { title = "RouteFooTitle" },
				},
			},
		}, {
			defaultNavigationOptions = {
				title = "FooTitle",
			},
		})

		local screenOptions = router.getScreenOptions({
			state = {
				routeName = "Foo",
			},
		})

		expect(screenOptions.title).toEqual("RouteFooTitle")
	end)

	it("should correctly configure component-specified screen options", function()
		local router = StackRouter({
			{
				Foo = {
					screen = {
						render = function() end,
						navigationOptions = { title = "ComponentFooTitle" },
					},
				},
			},
		}, {
			defaultNavigationOptions = {
				title = "FooTitle",
			},
		})

		local screenOptions = router.getScreenOptions({
			state = {
				routeName = "Foo",
			},
		})

		expect(screenOptions.title).toEqual("ComponentFooTitle")
	end)
end)

describe("getActionCreators tests", function()
	it("should return basic action creators table if none are provided", function()
		local router = StackRouter({
			{
				Foo = { render = function() end },
			},
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")

		local fieldCount = 0
		for _ in pairs(actionCreators) do
			fieldCount = fieldCount + 1
		end

		expect(fieldCount).toEqual(6)
		expect(actionCreators.pop).toEqual(expect.any("function"))
		expect(actionCreators.popToTop).toEqual(expect.any("function"))
		expect(actionCreators.push).toEqual(expect.any("function"))
		expect(actionCreators.replace).toEqual(expect.any("function"))
		expect(actionCreators.reset).toEqual(expect.any("function"))
		expect(actionCreators.dismiss).toEqual(expect.any("function"))
	end)

	it("should call custom action creators function if provided", function()
		local router = StackRouter({
			{
				Foo = { render = function() end },
			},
		}, {
			getCustomActionCreators = function()
				return { a = 1, popToTop = 2 }
			end,
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
		expect(actionCreators.a).toEqual(1)

		-- make sure that we merged the default ones on top!
		expect(actionCreators.pop).toEqual(expect.any("function"))
		expect(actionCreators.popToTop).toEqual(expect.any("function"))
	end)

	it("should build a pop action", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
		expect(actionCreators.pop(1).type).toBe(StackActions.Pop)
	end)

	it("should build a pop to top action", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
		expect(actionCreators.popToTop().type).toBe(StackActions.PopToTop)
	end)

	it("should build a push action", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
		expect(actionCreators.push("Foo").type).toBe(StackActions.Push)
	end)

	it("should build a replace action with a string replaceWith arg", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo", key = "Foo" }, "key")
		expect(actionCreators.replace("Foo").type).toBe(StackActions.Replace)
	end)

	it("should build a replace action with a table replaceWith arg", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
		expect(actionCreators.replace({ routeName = "Foo" }).type).toBe(StackActions.Replace)
	end)

	it("should build a reset action", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
		expect(actionCreators.reset({
			actions = { NavigationActions.navigate({ routeName = "Foo" }) },
		}).type).toBe(StackActions.Reset)
	end)

	it("should build a dismiss action", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
		expect(actionCreators.dismiss().type).toBe(NavigationActions.Back)
	end)
end)

describe("getComponentForState tests", function()
	it("should throw if there is no route matching active index", function()
		local router = StackRouter({
			{ Foo = { screen = function() end } },
		})

		local message = "There is no route defined for index '2'. "
			.. "Make sure that you passed in a navigation state with a "
			.. "valid stack index."
		expect(function()
			router.getComponentForState({
				routes = {
					Foo = { screen = function() end },
				},
				index = 2,
			})
		end).toThrow(message)
	end)

	it("should descend child router for requested route", function()
		local testComponent = function() end
		local childRouter = StackRouter({
			{ Bar = { screen = testComponent } },
		})

		local router = StackRouter({
			{
				Foo = {
					screen = {
						render = function() end,
						router = childRouter,
					},
				},
			},
		})

		local component = router.getComponentForState({
			routes = {
				{
					routeName = "Foo",
					routes = { -- Child router's routes
						{ routeName = "Bar" },
					},
					index = 1,
				},
			},
			index = 1,
		})
		expect(component).toBe(testComponent)
	end)
end)

describe("getComponentForRouteName tests", function()
	it("should return a component that matches the given route name from accessed childRouter", function()
		local testComponent = function() end
		local childRouter = StackRouter({
			{ Bar = testComponent },
		})

		local router = StackRouter({
			{
				Foo = {
					render = function() end,
					router = childRouter,
				},
			},
		})

		local component = router.childRouters.Foo.getComponentForRouteName("Bar")
		expect(component).toBe(testComponent)
	end)
end)

describe("getStateForAction tests", function()
	it("should return initial state for init action", function()
		local router = StackRouter({
			{ Foo = { screen = function() end } },
			{ Bar = { screen = function() end } },
		})

		local state = router.getStateForAction(NavigationActions.init(), nil)
		expect(#state.routes).toEqual(1)
		expect(state.routes[state.index].routeName).toEqual("Foo")
		expect(state.isTransitioning).toEqual(false)
	end)

	it("should adjust initial state index to match initialRouteName's index", function()
		local router = StackRouter({
			{ Foo = { screen = function() end } },
			{ Bar = { screen = function() end } },
		})

		local state = router.getStateForAction(NavigationActions.init(), nil)
		expect(state.routes[state.index].routeName).toEqual("Foo")

		local router2 = StackRouter({
			{ Foo = { screen = function() end } },
			{ Bar = { screen = function() end } },
		}, {
			initialRouteName = "Bar",
		})

		local state2 = router2.getStateForAction(NavigationActions.init(), nil)
		expect(state2.routes[state2.index].routeName).toEqual("Bar")
	end)

	it("should incorporate child router state", function()
		local childRouter = StackRouter({
			{ Bar = { screen = function() end } },
		})

		local router = StackRouter({
			{
				Foo = {
					render = function() end,
					router = childRouter,
				},
			},
			{ City = { screen = function() end } },
		})

		local state = router.getStateForAction(NavigationActions.init(), nil)
		local activeState = state.routes[state.index]
		expect(activeState.routeName).toEqual("Foo") -- parent's tracking uses parent's route name
		expect(activeState.routes[activeState.index].routeName).toEqual("Bar")
	end)

	it("should make historical inactive child router active if it handles action", function()
		local childRouter = StackRouter({
			{ City = function() end },
			{ State = function() end },
		})

		local router = StackRouter({
			{ Foo = function() end },
			{
				Bar = {
					render = function() end,
					router = childRouter,
				},
			},
		})

		local initialState = {
			routes = {
				{ routeName = "Foo", key = "Foo1" },
				{
					routeName = "Bar",
					key = "Bar",
					routes = {
						{ routeName = "City", key = "City" },
					},
					index = 1,
				},
				{ routeName = "Foo", key = "Foo2" },
			},
			index = 3,
		}

		local resultState = router.getStateForAction(NavigationActions.navigate({ routeName = "State" }), initialState)
		expect(resultState.routes[2].index).toEqual(2)
		expect(resultState.routes[2].routes[2].routeName).toEqual("State")
		expect(#resultState.routes[2].routes).toEqual(2)
		expect(resultState.index).toEqual(2)
	end)

	it("should go back to previous stack entry on back action", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
				{
					routeName = "Bar",
					key = "Bar",
				},
			},
			index = 2,
		}

		local resultState = router.getStateForAction(NavigationActions.back(), initialState)
		expect(resultState.index).toEqual(1)
		expect(resultState.routes[1].routeName).toEqual("Foo")
		expect(#resultState.routes).toEqual(1) -- it should delete top entry!
	end)

	it("should not go back if at root of stack", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
			},
			index = 1,
		}

		local resultState = router.getStateForAction(NavigationActions.back(), initialState)
		expect(resultState).toBe(initialState)
	end)

	it("should go back out of child stack if on root of child", function()
		local childRouter = StackRouter({
			{ Bar = { screen = function() end } },
			{ City = { screen = function() end } },
		})

		local router = StackRouter({
			{
				Foo = {
					render = function() end,
					router = childRouter,
				},
			},
			{ Cat = function() end },
		}, {
			initialRouteName = "Cat",
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Cat",
					key = "Cat",
				},
				{
					routeName = "Foo",
					key = "Foo",
					routes = {
						{
							routeName = "Bar",
							key = "Bar",
						},
					},
					index = 1,
				},
			},
			index = 2,
		}

		local resultState = router.getStateForAction(NavigationActions.back(), initialState)
		expect(resultState.index).toEqual(1)
		expect(#resultState.routes).toEqual(1)
		expect(resultState.routes[1].routeName).toEqual("Cat")
	end)

	it("should go back within active child if not on root of child", function()
		local childRouter = StackRouter({
			{ Bar = { screen = function() end } },
			{ City = { screen = function() end } },
		})

		local router = StackRouter({
			{
				Foo = {
					render = function() end,
					router = childRouter,
				},
			},
			{ Cat = function() end },
		}, {
			initialRouteName = "Cat",
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Cat",
					key = "Cat",
				},
				{
					routeName = "Foo",
					key = "Foo",
					routes = {
						{
							routeName = "Bar",
							key = "Bar",
						},
						{
							routeName = "City",
							key = "City",
						},
					},
					index = 2,
				},
			},
			index = 2,
		}

		local resultState = router.getStateForAction(NavigationActions.back(), initialState)
		expect(#resultState.routes).toEqual(2)
		expect(resultState.index).toEqual(2)
		expect(resultState.routes[1].routeName).toEqual("Cat")
		expect(resultState.routes[2].routeName).toEqual("Foo")

		expect(#resultState.routes[2].routes).toEqual(1)
		expect(resultState.routes[2].index).toEqual(1)
		expect(resultState.routes[2].routes[1].routeName).toEqual("Bar")
	end)

	it("should pop to top", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
				{
					routeName = "Bar",
					key = "Bar1",
				},
				{
					routeName = "Bar",
					key = "Bar2",
				},
			},
			index = 3,
		}

		local resultState = router.getStateForAction(StackActions.popToTop(), initialState)
		expect(#resultState.routes).toEqual(1)
		expect(resultState.index).toEqual(1)
		expect(resultState.routes[1].routeName).toEqual("Foo")
	end)

	it("should pop to top through child router", function()
		local childRouter = StackRouter({
			{ Bar = function() end },
			{ City = function() end },
		})

		local router = StackRouter({
			{
				Foo = {
					screen = function() end,
					router = childRouter,
				},
			},
			{ Crazy = function() end },
		}, {
			initialRouteName = "Crazy",
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Crazy",
					key = "Crazy",
				},
				{
					routeName = "Foo",
					key = "Foo",
					routes = {
						{
							routeName = "Bar",
							key = "Bar",
						},
						{
							routeName = "City",
							key = "City",
						},
					},
					index = 2,
				},
			},
			index = 2,
		}

		local resultState = router.getStateForAction(StackActions.popToTop(), initialState)
		expect(#resultState.routes).toEqual(1)
		expect(resultState.index).toEqual(1)
		expect(resultState.routes[1].routeName).toEqual("Crazy")
	end)

	it("should push a new entry on navigate without instance of that screen", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
			},
			index = 1,
		}

		local resultState = router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }), initialState)
		expect(#resultState.routes).toEqual(2)
		expect(resultState.index).toEqual(2)
		expect(resultState.routes[2].routeName).toEqual("Bar")
	end)

	it("should jump to existing entry in stack if one exists already, on navigate", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
			{ City = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
				{
					routeName = "Bar",
					key = "Bar",
				},
				{
					routeName = "City",
					key = "City",
				},
			},
			index = 3,
		}

		local resultState = router.getStateForAction(
			NavigationActions.navigate({
				routeName = "Bar",
				params = { a = 1 },
			}),
			initialState
		)
		expect(#resultState.routes).toEqual(2)
		expect(resultState.index).toEqual(2)
		expect(resultState.routes[2].routeName).toEqual("Bar")
		expect(resultState.routes[2].params.a).toEqual(1)
	end)

	it("should jump to existing entry in stack if one exists already, on navigate, with empty params", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
			{ City = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
				{
					routeName = "Bar",
					key = "Bar",
				},
				{
					routeName = "City",
					key = "City",
				},
			},
			index = 3,
		}

		local resultState = router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }), initialState)
		expect(#resultState.routes).toEqual(2)
		expect(resultState.index).toEqual(2)
		expect(resultState.routes[2].routeName).toEqual("Bar")
		expect(resultState.routes[2].params).toEqual(nil)
	end)

	it("should jump to existing entry in stack with existing params if params is not provided, on navigate", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
			{ City = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
				{
					routeName = "Bar",
					key = "Bar",
					params = { a = 1 },
				},
				{
					routeName = "City",
					key = "City",
				},
			},
			index = 3,
		}

		local resultState = router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }), initialState)
		expect(#resultState.routes).toEqual(2)
		expect(resultState.index).toEqual(2)
		expect(resultState.routes[2].routeName).toEqual("Bar")
		expect(resultState.routes[2].params.a).toEqual(1)
	end)

	it("should jump to existing entry in stack with updated params if params is provided, on navigate", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
			{ City = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
				{
					routeName = "Bar",
					key = "Bar",
					params = { a = 1 },
				},
				{
					routeName = "City",
					key = "City",
				},
			},
			index = 3,
		}

		local resultState = router.getStateForAction(
			NavigationActions.navigate({
				routeName = "Bar",
				params = { a = 2 },
			}),
			initialState
		)
		expect(#resultState.routes).toEqual(2)
		expect(resultState.index).toEqual(2)
		expect(resultState.routes[2].routeName).toEqual("Bar")
		expect(resultState.routes[2].params.a).toEqual(2)
	end)

	it("should stay at current route in stack if navigate with different params", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
			},
			index = 1,
		}

		local resultState = router.getStateForAction(
			NavigationActions.navigate({
				routeName = "Foo",
				params = { a = 1 },
			}),
			initialState
		)
		expect(#resultState.routes).toEqual(1)
		expect(resultState.index).toEqual(1)
		expect(resultState.routes[1].routeName).toEqual("Foo")
		expect(resultState.routes[1].params.a).toEqual(1)
	end)

	it("should stay at current route with existing params if navigate with empty params", function()
		local router = StackRouter({
			{ Foo = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
					params = { a = 1 },
				},
			},
			index = 1,
		}

		local resultState = router.getStateForAction(
			NavigationActions.navigate({
				routeName = "Foo",
				params = {},
			}),
			initialState
		)
		expect(#resultState.routes).toEqual(1)
		expect(resultState.index).toEqual(1)
		expect(resultState.routes[1].routeName).toEqual("Foo")
		expect(resultState.routes[1].params.a).toEqual(1)
	end)

	it("should always push new entry on push action even with pre-existing instance of that screen", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
			{ City = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
				{
					routeName = "Bar",
					key = "Bar",
				},
				{
					routeName = "City",
					key = "City",
				},
			},
			index = 3,
		}

		local resultState = router.getStateForAction(StackActions.push({ routeName = "Foo" }), initialState)
		expect(#resultState.routes).toEqual(4)
		expect(resultState.index).toEqual(4)
		expect(resultState.routes[4].routeName).toEqual("Foo")
	end)

	it("should navigate to inactive child if route not present elsewhere", function()
		local childRouter = StackRouter({
			{ Bar = { screen = function() end } },
			{ City = { screen = function() end } },
		})

		local router = StackRouter({
			{
				Foo = {
					render = function() end,
					router = childRouter,
				},
			},
			{ Cat = function() end },
		}, {
			initialRouteName = "Cat",
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Cat",
					key = "Cat",
				},
			},
			index = 1,
		}

		local resultState = router.getStateForAction(NavigationActions.navigate({ routeName = "City" }), initialState)
		expect(#resultState.routes).toEqual(2)
		expect(resultState.index).toEqual(2)
		expect(resultState.routes[2].routeName).toEqual("Foo")

		expect(#resultState.routes[2].routes).toEqual(2)
		expect(resultState.routes[2].index).toEqual(2)
		expect(resultState.routes[2].routes[2].routeName).toEqual("City")
	end)

	it("should set params on route for setParams action", function()
		local router = StackRouter({
			{ Foo = { render = function() end } },
			{ Bar = { render = function() end } },
		}, {
			initialRouteKey = "FooKey",
		})

		local newState = router.getStateForAction(NavigationActions.setParams({
			key = "FooKey",
			params = { a = 1 },
		}))

		expect(newState.routes[newState.index].params.a).toEqual(1)
	end)

	it("should combine params from action and route config", function()
		local router = StackRouter({
			{ Foo = { render = function() end } },
			{
				Bar = {
					screen = function() end,
					params = { a = 1 },
				},
			},
		})

		local state = router.getStateForAction(NavigationActions.init())
		local newState =
			router.getStateForAction(NavigationActions.navigate({ routeName = "Bar", params = { b = 2 } }), state)

		expect(newState.routes[2].params.a).toEqual(1)
		expect(newState.routes[2].params.b).toEqual(2)
	end)

	it("should replace top route if no key is provided", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
			},
			index = 1,
		}

		local newState = router.getStateForAction(
			StackActions.replace({
				routeName = "Bar",
			}),
			initialState
		)

		expect(#newState.routes).toEqual(1)
		expect(newState.index).toEqual(1)
		expect(newState.routes[1].routeName).toEqual("Bar")
	end)

	it("should replace keyed route if provided", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
				{
					routeName = "Bar",
					key = "Bar",
				},
			},
			index = 2,
		}

		local newState = router.getStateForAction(
			StackActions.replace({
				routeName = "Foo",
				key = "Bar",
				newKey = "NewFoo",
			}),
			initialState
		)

		expect(#newState.routes).toEqual(2)
		expect(newState.index).toEqual(2)
		expect(newState.routes[2].routeName).toEqual("Foo")
		expect(newState.routes[2].key).toEqual("NewFoo")
	end)

	it("should reset top-level routes if not given a key", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{ routeName = "Foo", key = "Foo1" },
				{ routeName = "Foo", key = "Foo2" },
			},
			index = 2,
		}

		local resultState = router.getStateForAction(
			StackActions.reset({
				index = 1,
				actions = {
					NavigationActions.navigate({ routeName = "Bar" }),
				},
			}),
			initialState
		)

		-- "actions" array replaces entire state, bypassing initial route config!
		expect(#resultState.routes).toEqual(1)
		expect(resultState.index).toEqual(1)
		expect(resultState.routes[1].routeName).toEqual("Bar")
	end)

	it("should reset keyed route if provided", function()
		local childRouter = StackRouter({
			{ City = function() end },
			{ State = function() end },
		})

		local router = StackRouter({
			{ Foo = function() end },
			{
				Bar = {
					screen = function() end,
					router = childRouter,
				},
			},
		}, {
			initialRouteName = "Bar",
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo1",
				},
				{
					routeName = "Bar",
					key = "Bar",
					routes = {
						{
							routeName = "City",
							key = "City",
						},
					},
					index = 1,
				},
			},
			index = 2,
		}

		local resultState = router.getStateForAction(
			StackActions.reset({
				actions = {
					NavigationActions.navigate({ routeName = "State" }),
				},
				key = "Bar",
			}),
			initialState
		)

		-- "actions" array replaces entire state, bypassing initial route config!
		expect(#resultState.routes).toEqual(2)
		expect(resultState.index).toEqual(2)
		expect(resultState.routes[2].routeName).toEqual("Bar")
		expect(resultState.routes[2].routes[1].routeName).toEqual("City")
	end)

	it("should mark state as transitioning, then clear it on CompleteTransition action", function()
		local router = StackRouter({
			{ Foo = function() end },
			{ Bar = function() end },
		})

		local initialState = {
			key = "root",
			routes = {
				{
					routeName = "Foo",
					key = "Foo",
				},
			},
			index = 1,
		}

		local transitioningState = router.getStateForAction(StackActions.push({ routeName = "Bar" }), initialState)
		expect(transitioningState.isTransitioning).toEqual(true)

		local completedState = router.getStateForAction(
			StackActions.completeTransition({
				toChildKey = transitioningState.routes[2].key, -- Need actual key to identify target
			}),
			transitioningState
		)

		expect(completedState.isTransitioning).toEqual(false)
	end)

	it(
		"should mark root and child states as transitioning, then separately clear them on CompleteTransition",
		function()
			local childRouter = StackRouter({
				{ BarA = function() end },
				{ BarB = function() end },
			})
			local router = StackRouter({
				{ Foo = function() end },
				{
					Bar = {
						screen = {
							render = function() end,
							router = childRouter,
						},
					},
				},
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
				},
				index = 1,
			}

			local transitioningState =
				router.getStateForAction(NavigationActions.navigate({ routeName = "BarB" }), initialState)
			expect(transitioningState).toBeDefined()
			expect(transitioningState.isTransitioning).toEqual(true)
			expect(transitioningState.routes[2].isTransitioning).toEqual(true)
			expect(transitioningState.routes[2].routes[2].routeName).toEqual("BarB")

			local childOnlyCompletedState = router.getStateForAction(
				StackActions.completeTransition({
					toChildKey = transitioningState.routes[2].routes[2].key,
				}),
				transitioningState
			)
			expect(childOnlyCompletedState.isTransitioning).toEqual(true) -- *** parent needs its own completeTransition call ***
			expect(childOnlyCompletedState.routes[2].isTransitioning).toEqual(false)

			local completedState = router.getStateForAction(
				StackActions.completeTransition({
					toChildKey = transitioningState.routes[2].key,
				}),
				childOnlyCompletedState
			)
			expect(completedState.isTransitioning).toEqual(false)
			expect(completedState.routes[2].isTransitioning).toEqual(false)
		end
	)
end)
