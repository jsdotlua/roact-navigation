return function()
	local expect = require("@pkg/@jsdotlua/jest-globals").expect
	local React = require("@pkg/@jsdotlua/react")
	local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")

	local createSwitchNavigator = require("../createSwitchNavigator")
	local getChildNavigation = require("../../getChildNavigation")

	it("should return a mountable Roact component", function()
		local navigator = createSwitchNavigator({
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
end
