local SceneView = require("../SceneView")
local React = require("@pkg/@jsdotlua/react")
local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

it("should mount inner component and pass down required props+context.navigation", function()
	local testComponentNavigationFromProp = nil
	local testComponentScreenProps = nil

	local TestComponent = React.Component:extend("TestComponent")
	function TestComponent:render()
		testComponentNavigationFromProp = self.props.navigation
		testComponentScreenProps = self.props.screenProps
		return nil
	end

	local testScreenProps = {}
	local testNav = {}
	local element = React.createElement(SceneView, {
		screenProps = testScreenProps,
		navigation = testNav,
		component = TestComponent,
	})

	local parent = Instance.new("Folder")
	local root = ReactRoblox.createRoot(parent)
	ReactRoblox.act(function()
		root:render(element)
	end)
	ReactRoblox.act(function()
		root:unmount()
	end)

	expect(testComponentScreenProps).toBe(testScreenProps)
	expect(testComponentNavigationFromProp).toBe(testNav)
end)
