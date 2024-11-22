return function()
	local React = require("@pkg/@jsdotlua/react")
	local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")
	local useNavigation = require("../useNavigation")
	local NavigationContext = require("../NavigationContext")

	local jestExpect = require("@pkg/@jsdotlua/jest-globals").expect

	local function defaultMockNavigation()
		return {
			isFocused = function()
				return false
			end,
			addListener = function()
				return {
					remove = function() end,
				}
			end,
			getParam = function()
				return nil
			end,
			navigate = function() end,
			state = {
				routeName = "DummyRoute",
			},
		}
	end

	local function renderWithNavigationProvider(element, navigation: any?)
		navigation = navigation or defaultMockNavigation()
		return React.createElement(NavigationContext.Provider, {
			value = navigation,
		}, {
			Child = element,
		})
	end

	it("it should provide the navigation prop", function()
		local navigation
		local function NavigationHookComponent()
			navigation = useNavigation()
		end

		local element = React.createElement(NavigationHookComponent)
		element = renderWithNavigationProvider(element)

		local container = Instance.new("Frame")
		local root = ReactRoblox.createRoot(container)

		ReactRoblox.act(function()
			root:render(element)
		end)

		jestExpect(navigation).toMatchObject({
			navigate = jestExpect.any("function"),
		})
		root:unmount()
	end)
end
