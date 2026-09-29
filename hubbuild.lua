-- hubbuild.lua v2 - 15x10 hub + permanent Genesis workshop
-- Old CraftOS / Lua 5.1 friendly.
--
-- COORDINATES:
-- Original hub remains x=0..9, z=0..9.
-- Genesis extension is x=-5..-1, z=0..9.
--
-- START: turtle at ORIGINAL south-west corner (0,0,9), facing NORTH.
-- The block directly below the turtle is coordinate (0,0,9).
--
-- IMPORTANT:
-- This builder creates the floor, shared storage, MISC chest and Genesis
-- workshop infrastructure. It never digs forward through obstacles.

local MINX,MAXX=-5,9
local MINZ,MAXZ=0,9
local x,z=0,9
local facing="north"
local right={north="east",east="south",south="west",west="north"}
local left ={north="west",west="south",south="east",east="north"}

-- Marker slots. Existing hub coordinates are unchanged.
local marks={
 ["1,1"]=9,["3,1"]=9,["5,1"]=9,["7,1"]=9, -- miner bays
 ["9,3"]=10,                                  -- wood bay
 ["9,6"]=10,                                  -- reeds bay
 ["2,2"]=11,                                  -- birth station
 ["1,7"]=12,["5,7"]=12,["1,5"]=12,["5,5"]=12,["8,7"]=12, -- services
 ["4,0"]=13,["8,0"]=14,                       -- mine/wood gates
 ["-2,5"]=15,                                 -- Genesis workshop station
}

local function page(title,lines)
 term.clear(); term.setCursorPos(1,1)
 print(title); print("------------------")
 for i=1,#lines do print(lines[i]) end
 print(""); print("Press ENTER...")
 read()
end

page("HUB BUILD 1/6",{
 "FULL HUB: 15 x 10",
 "x=-5 through x=9.",
 "",
 "START at ORIGINAL",
 "SW corner (0,9),",
 "facing NORTH.",
 "",
 "Old coordinates stay",
 "exactly unchanged."
})
page("HUB BUILD 2/6",{
 "FLOOR MATERIAL:",
 "normal blocks slots",
 "2 through 8.",
 "",
 "Slot 1 MUST start",
 "EMPTY.",
 "",
 "Fuel: slot 16."
})
page("HUB BUILD 3/6",{
 "MARKERS:",
 "9  = miner bays",
 "10 = wood/reed bays",
 "11 = birth station",
 "12 = storage service",
 "13 = mining gate",
 "14 = wood gate",
 "15 = Genesis station"
})
page("HUB BUILD 4/6",{
 "AFTER FLOOR:",
 "load 10 CHESTS",
 "into slot 1.",
 "",
 "8 = four double banks",
 "1 = REEDS/MISC",
 "1 = Genesis proxy.",
 "",
 "Genesis lower chest",
 "is placed separately."
})
page("HUB BUILD 5/6",{
 "WORKSHOP:",
 "Genesis (-2,0,5)",
 "faces NORTH.",
 "",
 "Proxy (-2,0,4)",
 "Storage (-2,-1,5)",
 "",
 "3 furnaces at y=1:",
 "x=-3,z=5..7"
})
page("HUB BUILD 6/6",{
 "Builder never digs",
 "forward obstacles.",
 "",
 "Floor replacement DOES",
 "dig blocks directly",
 "below the builder.",
 "",
 "Clear the whole 15x10",
 "area before starting."
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
 local n=turtle.getFuelLevel()
 if n=="unlimited" or n>60 then return true end
 turtle.select(16)
 if turtle.refuel(1) then return true end
 return turtle.getFuelLevel()>0
end
local function floorSlot()
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
 if turtle.detect() then error("Path blocked at "..x..","..z.."; refusing to dig") end
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
print("READY: 15x10 FLOOR")
print("------------------")
print("Start: (0,9)")
print("Face NORTH.")
print("Slot 1 empty.")
print("Floor: slots 2-8.")
print("Fuel: slot 16.")
print("")
if turtle.getItemCount(1)>0 then print("ERROR: empty slot 1."); return end
print("Type BUILD to start.")
if read()~="BUILD" then print("Cancelled"); return end

-- First move from original SW to new extension SW (-5,9).
face("west")
for i=1,5 do fw() end
face("north")

-- 15x10 serpentine pass, beginning (-5,9).
for row=1,10 do
 for col=1,15 do
  floorHere()
  if col<15 then fw() end
 end
 if row<10 then
  if facing=="east" then tr(); fw(); tr()
  else tl(); fw(); tl() end
 end
end

-- Return above original SW for staged infrastructure build.
gotoPos(0,9); face("north")

term.clear(); term.setCursorPos(1,1)
print("FLOOR COMPLETE")
print("------------------")
print("Load 10 CHESTS")
print("into SLOT 1.")
print("")
print("Then press ENTER.")
read()

local function selectChest()
 local d=turtle.getItemDetail(1)
 if d and d.name=="minecraft:chest" then turtle.select(1); return true end
 return false
end

if not turtle.up() then error("Cannot rise for chest stage") end

local function chestDownAt(tx,tz)
 gotoPos(tx,tz)
 if turtle.detectDown() then error("Chest square occupied at "..tx..","..tz) end
 if not selectChest() then error("Out of chests in slot 1") end
 if not turtle.placeDown() then error("Could not place chest at "..tx..","..tz) end
end

-- Existing shared storage.
chestDownAt(0,8); chestDownAt(1,8) -- WOOD
chestDownAt(4,8); chestDownAt(5,8) -- FUEL
chestDownAt(0,6); chestDownAt(1,6) -- STONE
chestDownAt(4,6); chestDownAt(5,6) -- ORES
chestDownAt(8,8)                    -- REEDS/MISC
chestDownAt(-2,4)                   -- Genesis proxy chest

-- Return and land temporarily.
gotoPos(0,9)
if not turtle.down() then error("Could not land") end

term.clear(); term.setCursorPos(1,1)
print("CHESTS COMPLETE")
print("------------------")
print("Now put:")
print("1 CHEST in slot 1")
print("3 FURNACES in slot 2")
print("")
print("These build Genesis")
print("storage + smeltery.")
print("")
print("Press ENTER.")
read()

-- Genesis persistent storage chest is BELOW the workshop floor.
-- Stand on (-2,5), remove only the workshop marker/floor block, descend one,
-- place chest down, then rise. This intentionally creates the recessed chest.
gotoPos(-2,5); face("north")
if turtle.detectDown() then
 if not turtle.digDown() then error("Cannot open Genesis storage recess") end
end
if not turtle.down() then error("Cannot descend into Genesis storage recess") end
-- Now at y=-1; chest belongs at y=-1, so place it DOWN would be y=-2.
-- Instead place chest in front is wrong. We therefore return to y=0 and place
-- chest DOWN into the y=-1 recess.
if not turtle.up() then error("Cannot rise from Genesis recess") end
if not selectChest() then error("Need 1 Genesis storage chest in slot 1") end
if not turtle.placeDown() then error("Cannot place Genesis storage chest") end

-- Build furnaces from y=0 by navigating under each coordinate and placing up.
local function selectFurnace()
 for s=2,15 do
  local d=turtle.getItemDetail(s)
  if d and d.name=="minecraft:furnace" then turtle.select(s); return true end
 end
 return false
end
local function furnaceUpAt(tx,tz)
 gotoPos(tx,tz)
 if turtle.detectUp() then error("Furnace position occupied at "..tx..","..tz) end
 if not selectFurnace() then error("Out of furnaces") end
 if not turtle.placeUp() then error("Could not place furnace at "..tx..",1,"..tz) end
end
furnaceUpAt(-3,5)
furnaceUpAt(-3,6)
furnaceUpAt(-3,7)

gotoPos(0,9); face("north")
term.clear(); term.setCursorPos(1,1)
print("HUB BUILD COMPLETE")
print("------------------")
print("15x10 protected hub.")
print("Existing coordinates")
print("unchanged.")
print("")
print("Genesis workshop:")
print("station (-2,0,5)")
print("proxy   (-2,0,4)")
print("storage (-2,-1,5)")
print("furnaces x=-3")
print("z=5,6,7 at y=1")
print("")
print("Run workshop.lua")
print("before Genesis.")
