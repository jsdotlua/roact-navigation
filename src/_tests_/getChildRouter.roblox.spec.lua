local getChildRouter = require("../getChildRouter")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

it("should throw if routeName is not a string", function()
	expect(function()
		getChildRouter({}, 5)
	end).toThrow("router.getComponentForRouteName must be a function if no child routers are specified")
end)

it("should return child router if found", function()
	local childRouter = {}
	local result = getChildRouter({
		childRouters = {
			myRoute = childRouter,
		},
	}, "myRoute")

	expect(result).toBe(childRouter)
end)

it("should look up component router if no child router is found", function()
	local component = { router = {} }

	local result = getChildRouter({
		getComponentForRouteName = function(routeName)
			if routeName == "myRoute" then
				return component
			else
				return nil
			end
		end,
	}, "myRoute")

	expect(result).toBe(component.router)
end)

it("should throw if no child routers are specified and getComponentForRouteName is not a function", function()
	expect(function()
		getChildRouter({
			getComponentForRouteName = 5,
		}, "myRoute")
	end).toThrow("router.getComponentForRouteName must be a function if no child routers are specified")
end)
