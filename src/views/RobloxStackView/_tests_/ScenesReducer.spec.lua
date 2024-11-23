local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local it = JestGlobals.it

local ScenesReducer = require("../ScenesReducer")

local initialRouteKey = "id-1"
local initialRouteName = "First Route"
local initialRoute = {
	routeName = initialRouteName,
	key = initialRouteKey,
}

local initialState = {
	index = 1,
	key = "StackRouterRoot",
	isTransitioning = false,
	routes = {
		initialRoute,
	},
}

local initialDescriptors = {
	[initialRouteKey] = {
		key = initialRouteKey,
		navigation = {
			state = initialRoute,
		},
		state = initialRoute,
	},
}

it("should generate valid initial scene", function()
	local scenes = ScenesReducer({}, initialState, nil, initialDescriptors)
	expect(scenes).toEqual({
		expect.objectContaining({
			route = initialRoute,
			index = 1,
			isActive = true,
			isStale = false,
		}),
	})
end)

it("should update descriptor", function()
	local scenes = ScenesReducer({}, initialState, nil, initialDescriptors)
	local dummyDescriptor = { key = "this is a dummy descriptor" }
	scenes[1].descriptor = dummyDescriptor
	local updatedScenes = ScenesReducer(scenes, initialState, initialState, initialDescriptors)
	expect(updatedScenes).toEqual({
		expect.objectContaining({
			descriptor = initialDescriptors[initialRouteKey],
			route = initialRoute,
			index = 1,
			isActive = true,
			isStale = false,
		}),
	})
end)

it("should bail out early", function()
	local initialScenes = ScenesReducer({}, initialState, nil, initialDescriptors)
	local scenes = ScenesReducer(initialScenes, nil, nil, nil)
	expect(scenes).toBe(initialScenes)
	scenes = ScenesReducer(initialScenes, initialState, initialState, initialDescriptors)
	expect(scenes).toBe(initialScenes)
end)

local secondRouteKey = "id-2"
local secondRouteName = "Second Route"
local secondRoute = {
	key = secondRouteKey,
	routeName = secondRouteName,
}

local secondState = {
	index = 2,
	key = "StackRouterRoot",
	isTransitioning = true,
	routes = {
		initialRoute,
		secondRoute,
	},
}

local secondDescriptors = {
	[initialRouteKey] = initialDescriptors[initialRouteKey],
	[secondRouteKey] = {
		key = secondRouteKey,
		navigation = {
			state = secondRoute,
		},
		state = secondRoute,
	},
}

it("should add second scene", function()
	local initialScenes = ScenesReducer({}, initialState, nil, initialDescriptors)
	local scenes = ScenesReducer(initialScenes, secondState, initialState, secondDescriptors)
	expect(scenes).never.toBe(initialScenes)
	expect(#scenes).toBe(2)

	expect(scenes).toEqual({
		expect.objectContaining({
			route = initialRoute,
			index = 1,
			isActive = false,
			isStale = false,
		}),
		expect.objectContaining({
			route = secondRoute,
			index = 2,
			isActive = true,
			isStale = false,
		}),
	})
end)

local thirdRouteKey = "id-3"
local thirdRouteName = "Third Route"
local thirdRoute = {
	key = thirdRouteKey,
	routeName = thirdRouteName,
}

local thirdState = {
	index = 3,
	key = "StackRouterRoot",
	isTransitioning = true,
	routes = {
		initialRoute,
		secondRoute,
		thirdRoute,
	},
}

local thirdDescriptors = {
	[initialRouteKey] = initialDescriptors[initialRouteKey],
	[secondRouteKey] = secondDescriptors[secondRouteKey],
	[thirdRouteKey] = {
		key = thirdRouteKey,
		navigation = {
			state = thirdRoute,
		},
		state = thirdRoute,
	},
}

it("should add third scene", function()
	local initialScenes = ScenesReducer({}, initialState, nil, initialDescriptors)
	local secondScenes = ScenesReducer(initialScenes, secondState, initialState, secondDescriptors)

	local scenes = ScenesReducer(secondScenes, thirdState, secondState, thirdDescriptors)

	expect(scenes).toEqual({
		expect.objectContaining({
			route = initialRoute,
			index = 1,
			isActive = false,
			isStale = false,
		}),
		expect.objectContaining({
			route = secondRoute,
			index = 2,
			isActive = false,
			isStale = false,
		}),
		expect.objectContaining({
			route = thirdRoute,
			index = 3,
			isActive = true,
			isStale = false,
		}),
	})
end)

it("should mark removed scenes as stale", function()
	local initialScenes = ScenesReducer({}, initialState, nil, initialDescriptors)
	local secondScenes = ScenesReducer(initialScenes, secondState, initialState, secondDescriptors)
	local thirdScenes = ScenesReducer(secondScenes, thirdState, secondState, thirdDescriptors)

	local scenes = ScenesReducer(thirdScenes, initialState, thirdState, initialDescriptors)

	expect(scenes).toEqual({
		expect.objectContaining({
			route = initialRoute,
			index = 1,
			isActive = true,
			isStale = false,
		}),
		expect.objectContaining({
			route = secondRoute,
			index = 2,
			isActive = false,
			isStale = true,
		}),
		expect.objectContaining({
			route = thirdRoute,
			index = 3,
			isActive = false,
			isStale = true,
		}),
	})
end)

local secondScreenReplacementKey = "id-22"
local secondScreenReplacementName = "Second Route Replacement"
local secondScreenReplacementRoute = {
	key = secondScreenReplacementKey,
	routeName = secondScreenReplacementName,
}

local replacedSecondSceneState = {
	index = 3,
	key = "StackRouterRoot",
	isTransitioning = true,
	routes = {
		initialRoute,
		secondScreenReplacementRoute,
		thirdRoute,
	},
}

local replacedSceneDescriptors = {
	[initialRouteKey] = initialDescriptors[initialRouteKey],
	[secondRouteKey] = {
		key = secondScreenReplacementKey,
		navigation = {
			state = secondScreenReplacementRoute,
		},
		state = secondScreenReplacementRoute,
	},
	[thirdRouteKey] = thirdDescriptors[thirdRouteKey],
}

it("should mark replaced scene as stale", function()
	local initialScenes = ScenesReducer({}, initialState, nil, initialDescriptors)
	local secondScenes = ScenesReducer(initialScenes, secondState, initialState, secondDescriptors)
	local thirdScenes = ScenesReducer(secondScenes, thirdState, secondState, thirdDescriptors)

	local scenes = ScenesReducer(thirdScenes, replacedSecondSceneState, thirdState, replacedSceneDescriptors)
	expect(#scenes).toEqual(4) -- replaced scene is marked stale, it is not removed

	expect(scenes).toEqual({
		expect.objectContaining({
			route = initialRoute,
			index = 1,
			isActive = false,
			isStale = false,
		}),
		expect.objectContaining({
			route = secondRoute,
			index = 2,
			isActive = false,
			isStale = true,
		}),
		-- because of comparison algorithm in SceneReducer.lua compareScenes
		-- the replacement scene is after the scene it replaced because id-2 < id-22
		expect.objectContaining({
			route = secondScreenReplacementRoute,
			index = 2,
			isActive = false,
			isStale = false,
		}),
		-- index is still 2 because the scene index come from route index in the nextState
		-- this is ok because filterStale in Transitioner.lua will remove the stale scene
		expect.objectContaining({
			route = thirdRoute,
			index = 3,
			isActive = true,
			isStale = false,
		}),
	})
end)
