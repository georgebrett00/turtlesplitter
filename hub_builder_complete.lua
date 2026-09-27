-- hub_builder_complete.lua
-- Combined 10x10 hub floor + storage builder
-- Old CraftOS / Lua 5.1 friendly.
--
-- START: turtle on SOUTH-WEST corner, facing NORTH into a clear 10x10 area.
-- It builds/marks the floor first, then places the storage chests.
-- Actual working turtles are NOT required as building materials.

local W,D=10,10
local x,z=0,9
local facing="north"
local right={north="east",east="south",south="west",west="north"}
local left ={north="west",west="south",south="east",east="north"}

-- Floor markers. Storage markers are service squares where turtles stand.
local marks={
 ["1,1"]=9,["3,1"]=9,["5,1"]=9,["7,1"]=9, -- replicator bays
 ["9,3"]=10,                                  -- wood turtle bay
 ["2,2"]=11,                                  -- birth station
 ["1,7"]=12,["3,7"]=12,["5,7"]=12,["7,7"]=12,
 ["1,5"]=12,["3,5"]=12,                       -- storage service squares
 ["4,0"]=13,["8,0"]=14,["9,4"]=15             -- gates
}

local function page(title,lines)
 term.clear(); term.setCursorPos(1,1)
 print(title); print("------------------")
 for i=1,#lines do print(lines[i]) end
 print(""); print("Press ENTER...")
 read()
end

page("HUB BUILD 1/5",{
 "FLOOR:",
 "84 normal blocks",
 "in slots 1-8.",
 "",
 "MARKERS ONLY:",
 "Slot 9: 4 Rep bays",
 "Slot 10: 1 Wood bay"
})
page("HUB BUILD 2/5",{
 "MARKER BLOCKS:",
 "Slot 11: 1 Birth",
 "Slot 12: 6 Storage",
 "Slot 13: 1 Mine gate",
 "Slot 14: 1 Wood gate",
 "Slot 15: 1 Reed gate"
})
page("HUB BUILD 3/5",{
 "NO TURTLES NEEDED.",
 "",
 "After floor pass,",
 "builder pauses so",
 "you can load chests.",
 "",
 "Fuel: slot 16 now."
})
page("HUB BUILD 4/5",{
 "CHESTS NEEDED:",
 "8 chests total.",
 "",
 "This makes:",
 "WOOD   double",
 "FUEL   double",
 "ORES   double",
 "STONE  double",
 "",
 "REEDS/MISC single"
})
page("HUB BUILD 5/5",{
 "START:",
 "South-west corner.",
 "Face NORTH.",
 "",
 "Clear whole 10x10.",
 "Builder never digs",
 "forward obstacles."
})

local function tr() turtle.turnRight(); facing=right[facing] end
local function tl() turtle.turnLeft(); facing=left[facing] end
local function face(d)
 if facing==d then return end
 if right[facing]==d then tr(); return end
 if left[facing]==d then tl(); return end
 tr(); tr()
end
local function fuel()
 if turtle.getFuelLevel()=="unlimited" or turtle.getFuelLevel()>40 then return true end
 turtle.select(16)
 if turtle.refuel(1) then return true end
 return turtle.getFuelLevel()>0
end
local function floorSlot()
 for s=1,8 do if turtle.getItemCount(s)>0 then turtle.select(s); return true end end
 return false
end
local function floorHere()
 local s=marks[tostring(x)..","..tostring(z)]
 if s and turtle.getItemCount(s)>0 then turtle.select(s)
 elseif not floorSlot() then error("Out of floor blocks") end
 if turtle.detectDown() then turtle.digDown() end
 if not turtle.placeDown() then error("Cannot place floor at "..x..","..z) end
end
local function fw()
 fuel()
 if turtle.detect() then error("Path blocked; refusing to dig") end
 if not turtle.forward() then error("Movement blocked") end
 if facing=="north" then z=z-1 elseif facing=="south" then z=z+1
 elseif facing=="east" then x=x+1 else x=x-1 end
end
local function gotoPos(tx,tz)
 if x<tx then face("east"); for i=1,tx-x do fw() end end
 if x>tx then face("west"); for i=1,x-tx do fw() end end
 if z<tz then face("south"); for i=1,tz-z do fw() end end
 if z>tz then face("north"); for i=1,z-tz do fw() end end
end

term.clear(); term.setCursorPos(1,1)
print("READY: FLOOR")
print("Type BUILD to start.")
if read()~="BUILD" then print("Cancelled"); return end

-- serpentine floor pass
for row=1,D do
 for col=1,W do
  floorHere()
  if col<W then fw() end
 end
 if row<D then
  if facing=="north" then tr(); fw(); tr() else tl(); fw(); tl() end
 end
end

-- Return to SW corner before storage stage.
gotoPos(0,9); face("north")

term.clear(); term.setCursorPos(1,1)
print("FLOOR COMPLETE")
print("------------------")
print("Now load 8 CHESTS")
print("into any inventory")
print("slots 1-15.")
print("")
print("Keep fuel available.")
print("")
print("Press ENTER when")
print("ready.")
read()

local function selectChest()
 for s=1,15 do
  local d=turtle.getItemDetail(s)
  if d and d.name=="minecraft:chest" then turtle.select(s); return true end
 end
 return false
end

-- Place a chest in front from a service square.  For a double chest, place
-- first half, step sideways to adjacent service square, and place second half
-- facing the same direction. These banks are deliberately spaced apart.
local function singleAt(sx,sz,dir)
 gotoPos(sx,sz); face(dir)
 if not selectChest() then error("Out of chests") end
 if turtle.detect() then error("Chest position blocked") end
 if not turtle.place() then error("Could not place chest") end
end

local function doubleNorth(sx,sz)
 -- chest halves north of (sx,sz) and (sx+1,sz)
 singleAt(sx,sz,"north")
 gotoPos(sx+1,sz); face("north")
 if not selectChest() then error("Out of chests") end
 if turtle.detect() then error("Second chest position blocked") end
 if not turtle.place() then error("Could not place second chest") end
end

-- IMPORTANT: Four doubles need 8 chests by themselves. Reeds/Misc therefore
-- remain marker/service stations for now; they can be added after another
-- two chests are supplied. To keep startup material count truthful, build
-- the four high-capacity banks automatically.
doubleNorth(0,8) -- WOOD, service approach near (1,7)
doubleNorth(4,8) -- FUEL
doubleNorth(0,6) -- STONE
doubleNorth(4,6) -- ORES

gotoPos(0,9); face("north")
term.clear(); term.setCursorPos(1,1)
print("HUB BUILD COMPLETE")
print("------------------")
print("Built 4 double banks:")
print("WOOD, FUEL,")
print("STONE, ORES.")
print("")
print("REEDS and MISC")
print("markers remain for")
print("later single chests.")
print("")
print("Builder is back at")
print("south-west corner.")
