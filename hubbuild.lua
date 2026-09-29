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
 "in slots 2-8.",
 "",
 "KEEP SLOT 1 EMPTY.",
 "It is for chests",
 "after floor stage.",
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
 "load chests.",
 "Turtle rises 1 block",
 "to build storage.",
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
 -- Slot 1 is NEVER a floor-material slot. It is reserved for the chest stage.
 for s=2,8 do
  if turtle.getItemCount(s)>0 then turtle.select(s); return true end
 end
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
print("--------------")
print("Slot 1 MUST be empty.")
print("Floor only slots 2-8.")
print("Fuel in slot 16.")
print("")
if turtle.getItemCount(1)>0 then
 print("ERROR: Empty slot 1")
 print("before building.")
 return
end
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
print("into SLOT 1.")
print("")
print("Slot 1 is chest-only.")
print("Keep fuel in slot 16.")
print("")
print("Press ENTER when")
print("ready.")
read()

local function selectChest()
 local d=turtle.getItemDetail(1)
 if d and d.name=="minecraft:chest" then
  turtle.select(1)
  return true
 end
 return false
end

-- CHEST STAGE
-- Move ONE block upward first.  From this height the turtle can fly over the
-- storage area and place each chest DOWN onto the hub floor.  Chests therefore
-- never block its route.
if not turtle.up() then
  error("Cannot rise above hub for chest construction")
end

local function chestDownAt(tx,tz)
  gotoPos(tx,tz)
  if turtle.detectDown() then
    error("Chest square already occupied at "..tx..","..tz)
  end
  if not selectChest() then
    error("Out of chests in slot 1")
  end
  if not turtle.placeDown() then
    error("Could not place chest at "..tx..","..tz)
  end
end

-- Four double chests.  Each pair is adjacent, but every PAIR has at least
-- one clear block separating it from every other pair.  This works with the
-- older Minecraft rule that forbids chests beside an existing double chest.
--
-- SOUTH storage row:
-- WOOD = (0,8)+(1,8)
-- FUEL = (4,8)+(5,8)
--
-- NORTH storage row:
-- STONE = (0,6)+(1,6)
-- ORES = (4,6)+(5,6)
chestDownAt(0,8); chestDownAt(1,8) -- WOOD
chestDownAt(4,8); chestDownAt(5,8) -- FUEL
chestDownAt(0,6); chestDownAt(1,6) -- STONE
chestDownAt(4,6); chestDownAt(5,6) -- ORES

-- Fly back above the clear southwest corner, then land.
gotoPos(0,9)
if not turtle.down() then
  error("Could not land at southwest corner")
end
face("north")

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
