--[[
	A hook used to consume the RoactNavigation context.
]]
local React = require("@pkg/@jsdotlua/react")
local NavigationContext = require("./NavigationContext")

local function useNavigation()
	return React.useContext(NavigationContext)
end

return useNavigation
