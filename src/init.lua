-- Generator information:
-- Human name: Roact Navigation
-- Variable name: RoactNavigation
-- Repo name: roact-navigation

return {
	-- Navigation container construction
	createAppContainer = require(script.createAppContainer),
	getNavigation = require(script.getNavigation),

	-- Context Access
	NavigationContext = require(script.views.AppNavigationContext),
	NavigationProvider = require(script.views.AppNavigationContext).Provider,
	NavigationConsumer = require(script.views.AppNavigationContext).Consumer,
	connect = require(script.views.AppNavigationContext).connect,

	withNavigation = require(script.views.withNavigation),
	-- TODO: withNavigationFocus = require(script.views.withNavigationFocus),

	-- Navigators
	createTopBarStackNavigator = require(script.navigators.createTopBarStackNavigator),
	createBottomTabNavigator = require(script.navigators.createBottomTabNavigator),
	createSwitchNavigator = require(script.navigators.createSwitchNavigator),
	createNavigator = require(script.navigators.createNavigator),

	-- Routers
	StackRouter = require(script.routers.StackRouter),
	SwitchRouter = require(script.routers.SwitchRouter),
	TabRouter = require(script.routers.TabRouter),

	-- Navigation Actions
	Actions = require(script.NavigationActions),
	StackActions = require(script.StackActions),

	-- Navigation Events
	Events = require(script.NavigationEvents),
	EventsAdapter = require(script.views.NavigationEventsAdapter),

	-- Views
	SceneView = require(script.views.SceneView),
	SwitchView = require(script.views.SwitchView),

	-- Utilities
	createConfigGetter = require(script.routers.createConfigGetter),
	getScreenForRouteName = require(script.routers.getScreenForRouteName),
	validateRouteConfigMap = require(script.routers.validateRouteConfigMap),
	getActiveChildNavigationOptions = require(script.utils.getActiveChildNavigationOptions),
}