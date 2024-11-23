-- upstream https://github.com/react-navigation/react-navigation/blob/1f5000e86bef5e4c8ee6fbeb25e3ca3eb8873ad0/packages/core/src/navigators/createSwitchNavigator.js
local createNavigator = require("./createNavigator")
local SwitchRouter = require("../routers/SwitchRouter")
local SwitchView = require("../views/SwitchView/SwitchView")

return function(routeArray, switchConfig)
	if switchConfig == nil then
		switchConfig = {}
	end
	local router = SwitchRouter(routeArray, switchConfig)

	return createNavigator(SwitchView, router, switchConfig)
end
