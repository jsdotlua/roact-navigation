-- upstream https://github.com/react-navigation/react-navigation/blob/62da341b672a83786b9c3a80c8a38f929964d7cc/packages/core/src/views/SceneView.js
local React = require("@pkg/@jsdotlua/react")
local NavigationContext = require("./NavigationContext")

local SceneView = React.PureComponent:extend("SceneView")

function SceneView:render()
	local screenProps = self.props.screenProps
	local component = self.props.component
	local navigation = self.props.navigation

	return React.createElement(NavigationContext.Provider, {
		value = navigation,
	}, {
		Scene = React.createElement(component, {
			screenProps = screenProps,
			navigation = navigation,
		}),
	})
end

return SceneView
