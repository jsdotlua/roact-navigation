return function()
	local Otter = require("@pkg/@jsdotlua/otter")
	local React = require("@pkg/@jsdotlua/react")
	local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")
	local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
	local expect = JestGlobals.expect
	local StackViewCard = require("../StackViewCard")

	it("should mount its renderProp and pass it scene", function()
		local didRender = false
		local testScene = {
			isActive = true,
			index = 1,
		}

		local renderedScene = nil
		local element = React.createElement(StackViewCard, {
			renderScene = function(theScene)
				renderedScene = theScene
				return React.createElement(function()
					didRender = true -- verifies component is attached to tree
				end)
			end,
			scene = testScene,
			position = Otter.createSingleMotor(1),
			navigation = {
				state = {
					index = 1,
				},
			},
		})

		local parent = Instance.new("Folder")
		local root = ReactRoblox.createRoot(parent)
		ReactRoblox.act(function()
			root:render(element)
		end)
		ReactRoblox.act(function()
			root:unmount()
		end)

		expect(renderedScene).toBe(testScene)
		expect(didRender).toBe(true)
	end)
end
