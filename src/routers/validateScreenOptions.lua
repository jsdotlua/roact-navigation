local invariant = require("../utils/invariant")

return function(screenOptions, route)
	invariant(
		type(screenOptions.title) ~= "function",
		"title cannot be defined as a function in navigation options for screen '%s'",
		route.routeName
	)
end
