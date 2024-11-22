local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")

return function(predicate, timeout)
	timeout = timeout or 1
	local waitedTime = 0
	while waitedTime < timeout and not predicate() do
		ReactRoblox.act(function()
			waitedTime = waitedTime + task.wait()
		end)
	end
end
