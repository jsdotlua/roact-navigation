local setupReactStory = require("../setupReactStory")
local React = require("@pkg/@jsdotlua/react")
local RoactNavigation = require("../../src")
local LuauPolyfill = require("@pkg/@jsdotlua/luau-polyfill")
local Object = LuauPolyfill.Object

--[[
	This story demonstrates how to control whether or not stack navigator screens
	allow pass-through of taps using the "absorbInput" navigationOption. When left at
	the default (true), the stack navigator will prevent any clicks/touches from
	falling through to underlying pages.

	If you have a specific UI need, like layering partial pages where you need
	the main UI to function as well, you can set navigationOptions.absorbInput
	to false.

	Keep in mind that navigationOptions are screen-specific, so if you need to
	layer a page that does block input above everything else, you can do that too!

	AppContainer
		StackNavigator(Overlay)
			MainContent
			OverlayDialog
]]
return function(target, navigatorOptions)
	navigatorOptions = navigatorOptions or {}

	local function MainContent(props)
		local navigation = props.navigation

		return React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 0),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Main App Content",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			showOverlayButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Show the Overlay",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("OverlayDialog")
				end,
			}),
			goBackPassThroughButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 1, -40),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go to Main (pass-through)",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("MainContent")
				end,
			}),
		})
	end

	local function OverlayDialog(props)
		local navigation = props.navigation
		local dialogCount = navigation.getParam("dialogCount", 0)

		return React.createElement("Frame", {
			Size = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, {
			dialog = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Size = UDim2.new(0.5, 0, 0.5, 0),
				Text = "Overlay Dialog " .. tostring(dialogCount),
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
			}, {
				pushAnotherOverlayButton = React.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 0),
					Size = UDim2.new(0, 160, 0, 30),
					Text = "Push Another",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[React.Event.Activated] = function()
						navigation.push("OverlayDialog", {
							dialogCount = dialogCount + 1,
						})
					end,
				}),
			}),
		})
	end

	local config = Object.assign({
		mode = RoactNavigation.StackPresentationStyle.Overlay, -- use Overlay mode instead of Modal!
	}, navigatorOptions)
	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ MainContent = MainContent },
		{
			OverlayDialog = {
				screen = OverlayDialog,
				navigationOptions = {
					overlayEnabled = true,
					overlayTransparency = 1,
					absorbInput = false,
				},
			},
		},
	}, config)
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
