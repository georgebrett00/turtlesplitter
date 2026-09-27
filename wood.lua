-- wood.lua - autonomous hub wood worker
-- Old CraftOS / Lua 5.1 compatible.
--
-- Physical farm:
--   The tree is planted ONE block directly outside the WOOD gate.
--   Keep that outside square clear with ordinary dirt/grass underneath it.
--
-- Startup:
--   New worker waits for fuel via hub.lua.
--   If it has no saplings, it waits for the player to insert some.
--   It permanently keeps a sapling reserve and deposits logs at the hub.

local hub=require("hub")
hub.setRole("wood")
local gate=hub.config.GATES.wood

local SAPLING_RESERVE=4
local CYCLE_WAIT=15

local function isSapling(name)
 return name=="minecraft:sapling" or
        name=="minecraft:oak_sapling" or
        name=="minecraft:spruce_sapling" or
        name=="minecraft:birch_sapling" or
        name=="minecraft:jungle_sapling"
end

local function isLog(name)
 return name=="minecraft:log" or
        name=="minecraft:oak_log" or
        name=="minecraft:spruce_log" or
        name=="minecraft:birch_log" or
        name=="minecraft:jungle_log"
end

local function isLeaves(name)
 return name=="minecraft:leaves" or
        name=="minecraft:leaves2" or
        name=="minecraft:oak_leaves" or
        name=="minecraft:spruce_leaves" or
        name=="minecraft:birch_leaves" or
        name=="minecraft:jungle_leaves"
end

local function countSaplings()
 local n=0
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isSapling(d.name) then n=n+d.count end
 end
 return n
end

local function selectSapling()
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isSapling(d.name) then turtle.select(s); return true end
 end
 return false
end

local function isDirt(name)
 return name=="minecraft:dirt" or name=="minecraft:grass"
end

local function countDirt()
 local n=0
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isDirt(d.name) then n=n+d.count end
 end
 return n
end

local function selectDirt()
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isDirt(d.name) then turtle.select(s); return true end
 end
 return false
end

local function waitForDirt()
 if countDirt()>0 then return end
 term.clear(); term.setCursorPos(1,1)
 print("===================")
 print("   DIRT REQUIRED")
 print("===================")
 print("")
 print("Add at least 1 dirt")
 print("to my inventory.")
 print("")
 print("This creates the")
 print("tree planting square.")
 print("")
 print("Waiting...")
 while countDirt()==0 do sleep(1) end
 print("")
 print("Dirt detected!")
 sleep(1)
end

local function waitForSaplings()
 if countSaplings()>0 then return end
 term.clear(); term.setCursorPos(1,1)
 print("===================")
 print(" SAPLINGS REQUIRED")
 print("===================")
 print("")
 print("Add saplings to my")
 print("inventory.")
 print("")
 print("4+ recommended.")
 print("")
 print("Waiting...")
 while countSaplings()==0 do sleep(1) end
 print("")
 print("Saplings detected!")
 sleep(1)
end

-- hub.depositAll() cannot express "keep all saplings", because saplings are
-- not yet a configured storage bank. Deposit only logs here.
local function depositLogs()
 if not hub.gotoPos(hub.config.STORAGE.wood) then
  error("Could not reach WOOD chest")
 end
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isLog(d.name) then
   turtle.select(s)
   if not turtle.drop() then
    print("WOOD chest full?")
    return false
   end
  end
 end
 return true
end

-- While climbing the trunk, clear nearby leaves. Leaf blocks broken by the
-- turtle can yield replacement saplings directly into inventory.
local function clearSideLeaves()
 for i=1,4 do
  local ok,d=turtle.inspect()
  if ok and d and isLeaves(d.name) then turtle.dig() end
  turtle.turnRight()
 end
end

local function harvestTree()
 -- We are at the WOOD gate facing outward/north; trunk is directly ahead.
 local ok,d=turtle.inspect()
 if not (ok and d and isLog(d.name)) then return false end

 turtle.dig()
 if not turtle.forward() then return false end

 local height=0
 while true do
  clearSideLeaves()
  local up,ud=turtle.inspectUp()
  if not (up and ud and (isLog(ud.name) or isLeaves(ud.name))) then break end
  turtle.digUp()
  if not turtle.up() then break end
  height=height+1
 end

 clearSideLeaves()

 -- Return to ground/tree square.
 for i=1,height do
  while not turtle.down() do sleep(0.5) end
 end

 -- Collect nearby dropped items without wandering away from the farm.
 for i=1,4 do
  turtle.suck()
  turtle.turnRight()
 end
 turtle.suckUp()
 turtle.suckDown()

 -- Back onto the gate square and restore outward-facing orientation.
 turtle.turnRight(); turtle.turnRight()
 if not turtle.forward() then
  error("Cannot return from tree square to WOOD gate")
 end
 turtle.turnRight(); turtle.turnRight()

 return true
end

local function preparePlantingGround()
 -- Turtle is standing on the WOOD gate, facing outward.
 -- Move temporarily onto the planting square so we can inspect its foundation.
 if turtle.detect() then
  local ok,d=turtle.inspect()
  if ok and d and (isSapling(d.name) or isLog(d.name)) then
   -- Existing farm already occupies the planting square; its ground was
   -- prepared previously.
   return true
  end
  print("WOOD FARM BLOCKED")
  return false
 end

 if not turtle.forward() then return false end

 local ok,d=turtle.inspectDown()
 if ok and d and isDirt(d.name) then
  turtle.back()
  return true
 end

 -- Unknown/non-soil surface: require dirt before altering anything.
 waitForDirt()

 if ok then
  if not turtle.digDown() then
   print("Cannot prepare farm ground.")
   turtle.back()
   return false
  end
 end

 if not selectDirt() or not turtle.placeDown() then
  print("Could not place dirt.")
  turtle.back()
  return false
 end

 print("Tree farm dirt prepared.")
 turtle.back()
 return true
end

local function plantIfEmpty()
 local ok,d=turtle.inspect()
 if ok then
  -- Existing sapling: leave it alone. Existing log: harvest next.
  if isSapling(d.name) or isLog(d.name) then return true end
  print("WOOD FARM BLOCKED")
  print("Clear block outside gate:")
  print(d.name)
  return false
 end

 if not selectSapling() then return false end
 if turtle.place() then
  print("Planted sapling.")
  return true
 end

 print("Could not plant.")
 print("Need dirt/grass directly")
 print("under square outside gate.")
 return false
end

print("WOOD WORKER")
print("Autonomous tree farm")
waitForSaplings()

while true do
 if not hub.ensureFuel(80) then error("Need fuel") end
 if not hub.gotoPos(gate) then error("Could not reach WOOD gate") end
 hub.face("north")

 local ok,d=turtle.inspect()
 if ok and d and isLog(d.name) then
  print("Tree grown - harvesting.")
  if harvestTree() then
   -- hub's logical position deliberately remained the gate while the turtle
   -- temporarily worked outside it; physically it is back on the gate now.
   sleep(2)
   plantIfEmpty()
   depositLogs()
   hub.home()
   print("Wood deposited.")
  end
 elseif ok and d and isSapling(d.name) then
  print("Sapling growing...")
  hub.home()
 else
  waitForSaplings()
  if preparePlantingGround() then plantIfEmpty() end
  hub.home()
 end

 sleep(CYCLE_WAIT)
end
