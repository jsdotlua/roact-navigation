-- upstream https://github.com/react-navigation/react-navigation/blob/1f5000e86bef5e4c8ee6fbeb25e3ca3eb8873ad0/packages/core/src/views/SwitchView/SwitchView.js

local React = require("@pkg/@jsdotlua/react")
local SceneView = require("../SceneView")

local function SwitchView(props)
	local state = props.navigation.state
	local activeKey = state.routes[state.index].key
	local descriptor = props.descriptors[activeKey]
	local ChildComponent = descriptor.getComponent()

	return React.createElement(SceneView, {
		component = ChildComponent,
		navigation = descriptor.navigation,
		screenProps = props.screenProps,
	})
end

return SwitchView
