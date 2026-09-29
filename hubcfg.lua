-- hubcfg.lua v6 - 10x10 hub + protected nursery
-- Coordinate origin and markers match hubbuild.lua.
local C={}

C.HUB={minX=0,maxX=9,minY=0,maxY=9,minZ=0,maxZ=9}

C.BAYS={
 genesis={x=2,y=0,z=1,facing="north"},
 miner1 ={x=1,y=0,z=1,facing="north"},
 miner2 ={x=3,y=0,z=1,facing="north"},
 miner3 ={x=5,y=0,z=1,facing="north"},
 miner4 ={x=7,y=0,z=1,facing="north"},

 -- Wood bay is on the EAST edge of the hub and faces OUTWARD.
 wood   ={x=9,y=0,z=3,facing="east"},

 reeds  ={x=9,y=0,z=6,facing="east"},
}

C.REPLICATOR_BAYS={
 {id=1,x=1,y=0,z=1,facing="north"},
 {id=2,x=3,y=0,z=1,facing="north"},
 {id=3,x=5,y=0,z=1,facing="north"},
 {id=4,x=7,y=0,z=1,facing="north"},
}

C.BIRTH_STATION={x=2,y=0,z=2,facing="north"}
C.BIRTH_DRIVE={x=1,y=0,z=2,facing="east"}
C.NURSERY={
 {id=1,x=1,y=0,z=3,facing="north"},
 {id=2,x=3,y=0,z=3,facing="north"},
 {id=3,x=5,y=0,z=3,facing="north"},
 {id=4,x=7,y=0,z=3,facing="north"},
}

C.CHEST_BLOCKS={
 ["0,8"]=true,["1,8"]=true, -- WOOD
 ["4,8"]=true,["5,8"]=true, -- FUEL
 ["0,6"]=true,["1,6"]=true, -- STONE
 ["4,6"]=true,["5,6"]=true, -- ORES
 ["8,8"]=true,                 -- REEDS/MISC
}

C.STORAGE={
 wood ={x=1,y=0,z=7,facing="south"},
 fuel ={x=5,y=0,z=7,facing="south"},
 stone={x=1,y=0,z=5,facing="south"},
 ores ={x=5,y=0,z=5,facing="south"},
 misc ={x=8,y=0,z=7,facing="south"},
}

C.GATES={
 mining={x=4,y=0,z=0,facing="north"},
 wood  ={x=8,y=0,z=0,facing="north"},
 reeds ={x=9,y=0,z=6,facing="east"},
}

C.ITEM_BANK={
 ["minecraft:reeds"]="misc",
 ["minecraft:paper"]="misc",
 ["minecraft:dirt"]="misc",
 ["minecraft:log"]="wood",
 ["minecraft:log2"]="wood",
 ["minecraft:planks"]="wood",

 ["minecraft:coal"]="fuel",
 ["minecraft:charcoal"]="fuel",
 ["minecraft:coal_ore"]="fuel",

 ["minecraft:iron_ore"]="ores",
 ["minecraft:gold_ore"]="ores",
 ["minecraft:diamond"]="ores",
 ["minecraft:diamond_ore"]="ores",
 ["minecraft:redstone"]="ores",
 ["minecraft:redstone_ore"]="ores",
 ["minecraft:lapis"]="ores",
 ["minecraft:lapis_ore"]="ores",
 ["minecraft:emerald"]="ores",
 ["minecraft:emerald_ore"]="ores",
 ["minecraft:iron_ingot"]="ores",
 ["minecraft:gold_ingot"]="ores",

 ["minecraft:cobblestone"]="stone",
 ["minecraft:stone"]="stone",
}

return C
