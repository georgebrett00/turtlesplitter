-- hubtest.lua
-- Put a turtle on replicator bay 1, facing NORTH.
local hub=require("hub")
hub.setPosition(1,0,1,"north")
if not hub.ensureFuel(40) then error("Need fuel") end

local tests={
 {name="WOOD",p=hub.config.STORAGE.wood},
 {name="FUEL",p=hub.config.STORAGE.fuel},
 {name="STONE",p=hub.config.STORAGE.stone},
 {name="ORES",p=hub.config.STORAGE.ores},
}
for i=1,#tests do
 print("Going to "..tests[i].name)
 if not hub.gotoPos(tests[i].p) then error("Route failed") end
 sleep(1)
end
print("Returning to bay 1")
if not hub.gotoPos({x=1,y=0,z=1,facing="north"}) then error("Return failed") end
print("HUB ROUTE TEST PASSED")
