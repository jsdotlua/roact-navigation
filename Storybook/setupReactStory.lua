local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")

local function act(callback)
	callback()
end

if _G.__ROACT_17_MOCK_SCHEDULER__ then
	act = ReactRoblox.act
end

local function setupReactStory(target, element)
	local root = ReactRoblox.createRoot(target)

	act(function()
		root:render(element)
	end)

	local function cleanup()
		act(function()
			root:unmount()
		end)
	end

	return cleanup
end

return setupReactStory
