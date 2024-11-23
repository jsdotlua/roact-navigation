local RoactNavigation = require("../..")
local React = require("@pkg/@jsdotlua/react")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach

local StackRouter = require("../StackRouter")
local TabRouter = require("../TabRouter")
local SwitchRouter = require("../SwitchRouter")
local NavigationActions = require("../../NavigationActions")
local StackActions = require("../StackActions")
local KeyGenerator = require("../../utils/KeyGenerator")

local ROUTERS = {
	TabRouter = TabRouter,
	StackRouter = StackRouter,
	SwitchRouter = SwitchRouter,
}

local FooView = React.Component:extend("FooView")
function FooView:render()
	return React.createElement("Frame")
end

local router, initState, initRoute = nil, nil, nil

for routerName, Router in pairs(ROUTERS) do
	describe(("Removing params in %s"):format(routerName), function()
		beforeEach(function()
			KeyGenerator._TESTING_ONLY_normalize_keys()

			router = Router({
				{ Foo = { screen = FooView } },
				{ Bar = { screen = FooView } },
			})
			initState = router.getStateForAction(NavigationActions.init())
			initRoute = initState.routes[initState.index]
		end)

		it("setParams clears individual params using RoactNavigation.None", function()
			local state0 = router.getStateForAction(
				NavigationActions.setParams({ params = { foo = 42 }, key = initRoute.key }),
				initState
			)

			expect(state0.routes[state0.index]).toEqual(expect.objectContaining({ params = { foo = 42 } }))

			local state1 = router.getStateForAction(
				NavigationActions.setParams({ params = { foo = RoactNavigation.None }, key = initRoute.key }),
				state0
			)

			expect(state1.routes[state1.index].params.foo).toBeNil()
		end)

		it("navigate clears individual params using RoactNavigation.None", function()
			local state0 = router.getStateForAction(
				NavigationActions.setParams({ params = { foo = 10, bar = 20 }, key = initRoute.key }),
				initState
			)

			expect(state0.routes[state0.index]).toEqual(expect.objectContaining({ params = { foo = 10, bar = 20 } }))

			local state1 = router.getStateForAction(
				NavigationActions.navigate({ params = { bar = RoactNavigation.None }, routeName = "Foo" }),
				state0
			)

			expect(state1.routes[state1.index]).toEqual(expect.objectContaining({ params = { foo = 10 } }))
		end)

		it("setParams removes entire params with RoactNavigation.None", function()
			local state0 = router.getStateForAction(
				NavigationActions.setParams({ params = { foo = 42 }, key = initRoute.key }),
				initState
			)

			expect(state0.routes[state0.index]).toEqual(expect.objectContaining({ params = { foo = 42 } }))

			local state1 = router.getStateForAction(
				NavigationActions.setParams({ params = RoactNavigation.None, key = initRoute.key }),
				initState
			)

			expect(state1.routes[state1.index].params).toBeNil()
		end)

		it("navigate removes entire params with RoactNavigation.None", function()
			local state0 = router.getStateForAction(
				NavigationActions.setParams({ params = { foo = 10, bar = 20 }, key = initRoute.key }),
				initState
			)

			expect(state0.routes[state0.index]).toEqual(expect.objectContaining({ params = { foo = 10, bar = 20 } }))

			local state1 = router.getStateForAction(
				NavigationActions.navigate({ params = RoactNavigation.None, routeName = "Bar" }),
				state0
			)

			expect(state1.routes[state1.index].params).toBeNil()
		end)
	end)
end

describe("Removing params with StackActions.push", function()
	beforeEach(function()
		KeyGenerator._TESTING_ONLY_normalize_keys()

		router = StackRouter({
			{ Foo = { screen = FooView } },
			{ Bar = { screen = FooView } },
		})
		initState = router.getStateForAction(NavigationActions.init())
		initRoute = initState.routes[initState.index]
	end)

	it("StackActions.push clears individual params with RoactNavigation.None", function()
		local state0 = router.getStateForAction(
			StackActions.push({
				routeName = "Bar",
				params = { foo = 42 },
			}),
			initState
		)

		expect(state0.routes[state0.index]).toEqual(expect.objectContaining({ params = { foo = 42 } }))

		local state1 = router.getStateForAction(
			StackActions.push({
				routeName = "Bar",
				params = { foo = RoactNavigation.None },
			}),
			initState
		)

		expect(state1.routes[state1.index].params.foo).toBeNil()
	end)

	it("StackActions.push clears entire params with RoactNavigation.None", function()
		local state0 = router.getStateForAction(
			StackActions.push({
				routeName = "Bar",
				params = { foo = 42 },
			}),
			initState
		)

		expect(state0.routes[state0.index]).toEqual(expect.objectContaining({ params = { foo = 42 } }))

		local state1 = router.getStateForAction(
			StackActions.push({
				routeName = "Bar",
				params = RoactNavigation.None,
			}),
			state0
		)

		expect(state1.routes[state1.index].params).toBeNil()
	end)
end)
