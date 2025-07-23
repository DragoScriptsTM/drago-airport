Config = {}

Config.Airports = {
    ["lsia"] = {
        label = "Los Santos International",
        coords = vector3(-1037.5, -2737.6, 20.2), -- place for ped + menu
        exitCoords = vector3(-1034.01, -2732.61, 20.17), -- place where u spawn when u took a flight
        ped = {
            model = "s_m_m_pilot_01",
            heading = 58.0
        },
        flights = {
            { label = "Sandy Shores Airfield", to = "sandy", price = 250 },
            { label = "Paleto Bay Airstrip", to = "paleto", price = 500 },
        }
    },
    ["sandy"] = {
        label = "Sandy Shores Airfield",
        coords = vector3(1764.57, 3295.55, 41.17),
        exitCoords = vector3(1770.0, 3300.0, 41.17),
        ped = {
            model = "s_m_m_pilot_01",
            heading = 120.0
        },
        flights = {
            { label = "Los Santos International", to = "lsia", price = 250 },
            { label = "Paleto Bay Airstrip", to = "paleto", price = 300 },
        }
    },
    ["paleto"] = {
        label = "Paleto Bay Airport",
        coords = vector3(-143.65, 6194.4, 31.22),
        exitCoords = vector3(-157.99, 6194.62, 31.39),
        ped = {
            model = "s_m_m_pilot_01",
            heading = 54.99
        },
        flights = {
            { label = "Los Santos International", to = "lsia", price = 500 },
            { label = "Sandy Shores Airfield", to = "sandy", price = 300 },
        }
    },
}

Config.IllegalItems = {     --add items if u want more illegal items, make sure to update server.lua as well
    "weedplant_packedweed",
    "cokebaggy",
    "coke_brick",
    "kq_wild_cannabis",
    "cokeleaf",
}

Config.FlightTime = 5000 -- Time in ms for flight duration
