local NavigationContext = require("./views/NavigationContext")
local LuauPolyfill = require("@pkg/@jsdotlua/luau-polyfill")
local Object = LuauPolyfill.Object

return {
	-- Navigation container construction
	createAppContainer = require("./createAppContainer").createAppContainer,
	getNavigation = require("./getNavigation"),

	-- Context Access
	Context = NavigationContext,
	Provider = NavigationContext.Provider,
	Consumer = NavigationContext.Consumer,

	withNavigation = require("./views/withNavigation"),
	withNavigationFocus = require("./views/withNavigationFocus"),
	useNavigation = require("./views/useNavigation"),

	-- Navigators
	createRobloxStackNavigator = require("./navigators/createRobloxStackNavigator"),
	createRobloxSwitchNavigator = require("./navigators/createRobloxSwitchNavigator"),
	createSwitchNavigator = require("./navigators/createSwitchNavigator"),
	createNavigator = require("./navigators/createNavigator"),

	-- Routers
	StackRouter = require("./routers/StackRouter"),
	SwitchRouter = require("./routers/SwitchRouter"),
	TabRouter = require("./routers/TabRouter"),
	DontMatchEmptyPath = require("./routers/NullPathSymbol.roblox.lua"),

	-- Navigation Actions
	Actions = require("./NavigationActions"),
	StackActions = require("./routers/StackActions"),
	SwitchActions = require("./routers/SwitchActions"),
	BackBehavior = require("./BackBehavior"),

	-- Navigation Events
	Events = require("./Events"),
	NavigationEvents = require("./views/NavigationEvents"),

	-- Util Types
	None = Object.None,

	-- Additional Types
	StackPresentationStyle = require("./views/RobloxStackView/StackPresentationStyle"),
	StackViewTransitionConfigs = require("./views/RobloxStackView/StackViewTransitionConfigs"),

	-- Screen Views
	SceneView = require("./views/SceneView"),
	RobloxSwitchView = require("./views/RobloxSwitchView"),
	RobloxStackView = require("./views/RobloxStackView/StackView"),

	-- Utilities
	createConfigGetter = require("./routers/createConfigGetter"),
	getScreenForRouteName = require("./routers/getScreenForRouteName"),
	validateRouteConfigMap = require("./routers/validateRouteConfigMap"),
	getActiveChildNavigationOptions = require("./utils/getActiveChildNavigationOptions"),
}
