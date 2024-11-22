local createNavigator = require("./createNavigator")
local StackRouter = require("../routers/StackRouter")
local StackView = require("../views/RobloxStackView/StackView")

return function(routeArray, stackConfig)
	local router = StackRouter(routeArray, stackConfig)

	return createNavigator(StackView, router, stackConfig or {})
end
