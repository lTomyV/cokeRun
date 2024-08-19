Config = {}

Config.spawnPlaneAutomatically = true
-- true = the plane will spawn automatically when the player pays to get the plane
-- false = the plane will not spawn automatically, the player will have to go to the spawn location and press E to spawn the plane

Config.messages = {
    getKeyText = "~r~[~s~E~r~]~s~ Get a key for $",
    planeKeyNeeded = "You need a plane key",
    missionAlreadyInProgress = "Theres some one else doing the mission, try again later",
    getPlaneText = "~r~[~s~E~r~]~s~ Get a sea plane for $",
    notEnoughMoney = "You dont have enough dirty money",
    getPlane = "~r~[~s~E~r~]~s~ Get the sea plane",
    coordsNotOnWater = "The prop could not be spawned because the coords are not on water",
    collectBrick = "~r~[~s~E~r~]~s~ Get the drugs",
    collectingDrugs = "Collecting drugs...",

    returnPlane = "Return the plane to the airfield, its marked on your minimap",
    returnPlaneInteraction = "Press ~r~[~s~E~r~]~s~ to return the plane",
    
    packing = "Packing drugs...",
    packedSuccessfully = "You packed the drugs successfully",
    noEnoughBags = "You dont have enough plastic bags",

    runOutOfTime = "You ran out of time, mission failed",

    cantSpawnPlane = "The plane spawn position is blocked...",
}

Config.cokeBrickProp = 'imp_prop_impexp_boxcoke_01'
Config.cokeBrickAmount = {min = 1, max = 3}

Config.returnPlanePay = 2500 -- THIS IS HOW MUCH YOU GET WHEN RETURNING THE PLANE

Config.missionTime = 10.5 -- MINUTES

Config.items = {
    planeKey = "bread",
    brick = "coke_brick",
    bag = "plastic_bag",
    baggy = "coke_baggy",
    bagAmount = 30, -- THIS IS HOW MANY bag you need to convert a brick, and how many bags you get from a brick
    packingSeconds = 25, -- THIS IS HOW MANY SECONDS IT TAKES TO PACK A BRICK
}

Config.buyKey = {
    {
        npcCoords = {x = -697.331848, y = -856.905518, z = 23.668823, h = 68.031494},
        spawnPlaneCoords = {x = 1732.457153, y = 3311.868164, z = 42.018311, h = 192.755920},
        model = "cs_hunter",
        price = 10000,
    },
}

Config.rentPlane = {
    {
        npcCoords = {x = 1588.615356, y = 3586.193359, z = 35.379517, h = 136.062988},
        spawnPlaneCoords = {x = 1732.457153, y = 3311.868164, z = 42.018311, h = 192.755920},
        model = "cs_patricia",
        price = 5000,
    },
}

Config.returnPlaneCoords = vector3(2132.637451, 4783.569336, 41.765625)

Config.cokeBrickSpawnLocations = {
    vector3(3621.441650, 1828.997803, 0.618286),
    vector3(-411.098907, -4112.254883, -0.881348),
    vector3(-2375.393311, 6560.927246, -0.797119)
    -- add as many as you want
}