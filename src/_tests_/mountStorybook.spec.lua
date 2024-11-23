local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local it = JestGlobals.it
local expect = JestGlobals.expect

for _, storyModule in ipairs(ReplicatedStorage.RoactNavigationStorybook:GetDescendants()) do
	local storyName = storyModule.Name:match("(.+)%.story$")
	if storyName then
		it(("mounts %s"):format(storyName), function()
			local storyBuilder = require(storyModule)
			local parent = Instance.new("Folder")

			expect(function()
				local cleanUp = storyBuilder(parent)
				cleanUp()
			end).never.toThrow()
		end)
	end
end
