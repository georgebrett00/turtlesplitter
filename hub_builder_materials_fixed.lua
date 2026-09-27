-- hub_builder.lua
-- ComputerCraft / old CraftOS friendly
--
-- Builds a clearly marked 10x10 Turtle Hub FLOOR and marker layout.
-- It deliberately does NOT place chests or working turtles: chest orientation
-- and turtle facing are much safer to do after the floor is labelled.
--
-- START:
-- 1. Make a chest with cobblestone (or another floor block) behind the turtle.
-- 2. Put this turtle on the SOUTH-WEST corner of the desired 10x10 hub.
-- 3. Face NORTH, into the area to be built.
-- 4. Put marker blocks in inventory as described below.
--
-- Slots:
-- 1-8  : floor blocks (cobble recommended)
-- 9    : replicator-bay marker
-- 10   : wood-turtle marker
-- 11   : birth-station marker
-- 12   : storage/service marker
-- 13   : mining-gate marker
-- 14   : wood-gate marker
-- 15   : reed-gate marker
-- 16   : spare fuel
--
-- The program replaces/places the floor block UNDER the turtle. It will NOT
-- dig blocks in front while travelling. Start on a clear, flat 10x10 site.

local W=10
local D=10

local x,z=0,9       -- southwest corner in hub coordinates
local facing="north"

local right={north="east",east="south",south="west",west="north"}
local left ={north="west",west="south",south="east",east="north"}

local marks = {
  ["1,1"]=9, ["3,1"]=9, ["5,1"]=9, ["7,1"]=9, -- replicator bays
  ["9,3"]=10,                                   -- wood turtle
  ["2,2"]=11,                                   -- birth station

  -- storage SERVICE squares
  ["1,7"]=12, ["3,7"]=12, ["5,7"]=12, ["7,7"]=12,
  ["1,5"]=12, ["3,5"]=12,

  -- gates
  ["4,0"]=13, ["8,0"]=14, ["9,4"]=15,
}

local function turnRight()
  turtle.turnRight(); facing=right[facing]
end
local function turnLeft()
  turtle.turnLeft(); facing=left[facing]
end
local function face(dir)
  if facing==dir then return end
  if right[facing]==dir then turnRight(); return end
  if left[facing]==dir then turnLeft(); return end
  turnRight(); turnRight()
end

local function refuel()
  if turtle.getFuelLevel()=="unlimited" then return true end
  if turtle.getFuelLevel()>50 then return true end
  turtle.select(16)
  if turtle.refuel(1) then return true end
  for s=1,8 do
    turtle.select(s)
    if turtle.refuel(1) then return true end
  end
  return turtle.getFuelLevel()>0
end

local function selectFloor()
  for s=1,8 do
    if turtle.getItemCount(s)>0 then turtle.select(s); return true end
  end
  return false
end

local function floorHere()
  local key=tostring(x)..","..tostring(z)
  local slot=marks[key]
  if slot and turtle.getItemCount(slot)>0 then
    turtle.select(slot)
  else
    if not selectFloor() then
      error("Out of floor blocks in slots 1-8 at "..key)
    end
  end

  -- Replace only the block directly below. This is the intentional build area.
  if turtle.detectDown() then turtle.digDown() end
  if not turtle.placeDown() then
    error("Could not place floor/marker at "..key)
  end
end

local function forward()
  refuel()
  if turtle.detect() then
    error("Path blocked. Clear the 10x10 area; builder refuses to dig forward.")
  end
  if not turtle.forward() then error("Could not move forward") end
  if facing=="north" then z=z-1
  elseif facing=="south" then z=z+1
  elseif facing=="east" then x=x+1
  else x=x-1 end
end

print("TURTLE HUB BUILDER")
print("Build: 10x10")
print("")
print("REQUIRED MATERIALS")
print("------------------")
print("Floor blocks: 84")
print("  Put these in slots 1-8")
print("")
print("Marker blocks: 16 total")
print("  Slot 9 :  4 matching blocks - replicator bays")
print("  Slot 10:  1 block - wood turtle bay")
print("  Slot 11:  1 block - child birth station")
print("  Slot 12:  6 matching blocks - storage service points")
print("  Slot 13:  1 block - mining gate")
print("  Slot 14:  1 block - wood gate")
print("  Slot 15:  1 block - reed gate")
print("")
print("Fuel:")
print("  Slot 16: coal/charcoal (at least 2 recommended)")
print("")
print("TOTAL FLOOR AREA: 100 blocks")
print("  84 normal floor + 16 marker blocks")
print("")
print("START POSITION")
print("  SOUTH-WEST corner of the 10x10 area")
print("  Turtle must face NORTH into the hub.")
print("")
print("WARNING: the 10x10 travel area must be clear.")
print("The builder replaces floor blocks below it but")
print("will NOT dig obstacles in front of itself.")
print("")
write("Type BUILD when inventory is ready: ")
if read()~="BUILD" then print("Cancelled."); return end

-- Serpentine pass. Start SW (0,9), finish opposite end.
for row=1,D do
  for col=1,W do
    floorHere()
    if col<W then forward() end
  end
  if row<D then
    if facing=="north" then
      turnRight(); forward(); turnRight()
    else
      turnLeft(); forward(); turnLeft()
    end
  end
end

print("")
print("HUB FLOOR COMPLETE")
print("Marker legend:")
print(" slot 9  = replicator bays")
print(" slot 10 = wood turtle bay")
print(" slot 11 = child birth station")
print(" slot 12 = chest SERVICE squares")
print(" slot 13 = mining gate")
print(" slot 14 = wood gate")
print(" slot 15 = reed gate")
print("")
print("Place chests/turtles only after identifying these markers.")
