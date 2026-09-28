-- miner.lua - multi-turtle self-sufficient hub miner
-- Old CraftOS / Lua 5.1 friendly.
--
-- FIRST RUN: place turtle on one of the four bay markers, facing NORTH.
-- Select bay 1-4 once. Choice is saved in "miner.cfg".
--
-- All miners share the hub mining gate, but outside the hub they fan out
-- into separate lanes before descending. Hub traffic waits for turtles.

local hub=require("hub")

local CFG_FILE="miner.cfg"
local LEG=32
local FUEL_RESERVE=180
local RETURN_MARGIN=100
local MAX_BRANCHES=8
local APPROACH=8
local TARGET_DEPTH=12

-- Separate mining lanes. Negative = west, positive = east.
-- Spacing keeps 32-block branches from starting on the same staircase.
local LANE_OFFSET={-54,-18,18,54}

local function loadBay()
 if fs.exists(CFG_FILE) then
  local f=fs.open(CFG_FILE,"r")
  local n=tonumber(f.readLine())
  f.close()
  if n and n>=1 and n<=4 then return n end
 end
 term.clear();term.setCursorPos(1,1)
 print("HUB MINER SETUP")
 print("---------------")
 print("Place me on my bay")
 print("facing NORTH.")
 print("")
 print("Bay 1 = x1")
 print("Bay 2 = x3")
 print("Bay 3 = x5")
 print("Bay 4 = x7")
 print("")
 write("Select bay 1-4: ")
 local n=tonumber(read())
 if not n or n<1 or n>4 then error("Bay must be 1, 2, 3 or 4") end
 local f=fs.open(CFG_FILE,"w");f.writeLine(tostring(n));f.close()
 return n
end

local BAY=loadBay()
local ROLE="miner"..tostring(BAY)
local OFFSET=LANE_OFFSET[BAY]
hub.setRole(ROLE)

local facing="north"
local right={north="east",east="south",south="west",west="north"}
local left ={north="west",west="south",south="east",east="north"}

local function tr() turtle.turnRight();facing=right[facing] end
local function tl() turtle.turnLeft();facing=left[facing] end
local function face(d)
 if facing==d then return end
 if right[facing]==d then tr()
 elseif left[facing]==d then tl()
 else tr();tr() end
end

local function fuelLevel()
 local n=turtle.getFuelLevel()
 if n=="unlimited" then return 999999 end
 return n
end

local function isCoal(n)
 return n=="minecraft:coal" or n=="minecraft:charcoal"
end

local function isValuable(n)
 return isCoal(n) or n=="minecraft:coal_ore" or
  n=="minecraft:iron_ore" or n=="minecraft:gold_ore" or
  n=="minecraft:diamond" or n=="minecraft:diamond_ore" or
  n=="minecraft:redstone" or n=="minecraft:redstone_ore" or
  n=="minecraft:lapis" or n=="minecraft:lapis_ore" or
  n=="minecraft:emerald" or n=="minecraft:emerald_ore" or
  n=="minecraft:iron_ingot" or n=="minecraft:gold_ingot"
end

local function isWaste(n)
 return n=="minecraft:cobblestone" or n=="minecraft:stone" or
  n=="minecraft:dirt" or n=="minecraft:grass" or
  n=="minecraft:gravel" or n=="minecraft:sand" or
  n=="minecraft:sandstone" or n=="minecraft:netherrack" or
  n=="minecraft:flint"
end

local function cleanInventory()
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isWaste(d.name) then turtle.select(s);turtle.drop() end
 end
end

local function emptySlots()
 local n=0
 for s=1,16 do if turtle.getItemCount(s)==0 then n=n+1 end end
 return n
end

local function burnCoalTo(target)
 if fuelLevel()>=target then return true end
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isCoal(d.name) then
   turtle.select(s)
   while turtle.getItemCount(s)>0 and fuelLevel()<target do
    if not turtle.refuel(1) then break end
   end
  end
 end
 return fuelLevel()>=target
end

local function inspectValuable(fn)
 local ok,d=fn()
 return ok and d and isValuable(d.name)
end

local function collectSides()
 if inspectValuable(turtle.inspectUp) then turtle.digUp() end
 if inspectValuable(turtle.inspectDown) then turtle.digDown() end
 tr()
 if inspectValuable(turtle.inspect) then turtle.dig() end
 tr();tr()
 if inspectValuable(turtle.inspect) then turtle.dig() end
 tr()
end

local function waitOrDigForward()
 -- OUTSIDE HUB ONLY. A block may be mined. If movement is blocked by an
 -- entity/turtle, wait rather than attack it.
 while true do
  if turtle.forward() then return true end
  if turtle.detect() then
   if not turtle.dig() then sleep(.5) end
  else
   print("Mine traffic: waiting...")
   sleep(.5)
  end
 end
end

local function forwardDig()
 if not waitOrDigForward() then return false end
 collectSides();cleanInventory()
 return true
end

local function backWait()
 while not turtle.back() do
  print("Mine traffic: waiting...")
  sleep(.5)
 end
end

local function backSteps(n)
 for i=1,n do backWait() end
end

local function straightDig(n)
 local moved=0
 for i=1,n do
  if not waitOrDigForward() then break end
  moved=moved+1
  cleanInventory()
 end
 return moved
end

local function mineBranch(length)
 local moved=0
 collectSides()
 for i=1,length do
  if fuelLevel() < moved+RETURN_MARGIN then
   burnCoalTo(moved+RETURN_MARGIN+100)
  end
  if fuelLevel() < moved+RETURN_MARGIN then break end
  if not forwardDig() then break end
  moved=moved+1
  if emptySlots()<3 then break end
 end
 backSteps(moved)
 cleanInventory()
 return moved
end

local function descendOne()
 if turtle.detectDown() then
  if not turtle.digDown() then return false end
 end
 while not turtle.down() do
  if turtle.detectDown() then turtle.digDown() else sleep(.5) end
 end
 if not forwardDig() then
  turtle.up()
  return false
 end
 return true
end

local function ascendOne()
 -- Reverse one staircase step: back SOUTH, then UP, while still facing NORTH.
 backWait()
 while not turtle.up() do
  if turtle.detectUp() then turtle.digUp() else sleep(.5) end
 end
end

local function deposit()
 cleanInventory()

 if not hub.gotoPos(hub.config.STORAGE.fuel) then error("Cannot reach FUEL chest") end
 local keepCoal=2
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isCoal(d.name) then
   local drop=d.count
   if keepCoal>0 then
    local k=math.min(keepCoal,drop);keepCoal=keepCoal-k;drop=drop-k
   end
   if drop>0 then turtle.select(s);turtle.drop(drop) end
  elseif d and d.name=="minecraft:coal_ore" then
   turtle.select(s);turtle.drop()
  end
 end

 if not hub.gotoPos(hub.config.STORAGE.ores) then error("Cannot reach ORES chest") end
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isValuable(d.name) and not isCoal(d.name) and
     d.name~="minecraft:coal_ore" then
   turtle.select(s);turtle.drop()
  end
 end
end

local function leaveHub()
 if not hub.gotoPos(hub.config.GATES.mining) then error("Cannot reach mining gate") end
 facing="north"
 -- Directly ahead is OUTSIDE the hub. Clear terrain, but wait for entities.
 waitOrDigForward()
end

local function enterHub()
 -- Immediately north of gate, facing SOUTH.
 while not turtle.forward() do
  if turtle.detect() then
   error("Mining gate physically blocked - refusing to dig into hub")
  end
  print("Gate occupied. Waiting...")
  sleep(.5)
 end
 hub.setPosition(4,0,0,"south")
end

local function goToLane()
 -- We are APPROACH blocks north of the gate, facing north.
 if OFFSET<0 then face("west") else face("east") end
 local moved=straightDig(math.abs(OFFSET))
 face("north")
 return moved
end

local function returnFromLane(moved)
 -- At lane start, facing north.
 if OFFSET<0 then face("east") else face("west") end
 backSteps(0) -- explicit no-op for old CraftOS
 -- Move toward the central approach using forward movement.
 for i=1,moved do waitOrDigForward() end
 face("south")
end

print("HUB MINER "..BAY)
print("Lane offset: "..OFFSET)
print("Self-fuel + communal coal")
print("Valuables -> ORES")

while true do
 if not hub.home() then error("Cannot reach miner bay") end
 if not hub.ensureFuel(FUEL_RESERVE) then error("Need startup fuel") end
 if not hub.home() then error("Cannot return to miner bay") end

 leaveHub()

 -- Shared exit corridor: straight north, no side scanning.
 facing="north"
 local approachMoved=straightDig(APPROACH)

 -- Fan out to this miner's private surface lane.
 local laneMoved=goToLane()
 print("Miner "..BAY.." lane reached. Descending...")

 local depth=0
 for i=1,TARGET_DEPTH do
  local need=RETURN_MARGIN+(depth*2)+approachMoved+laneMoved+60
  if fuelLevel()<need then burnCoalTo(need+120) end
  if fuelLevel()<need then break end
  if not descendOne() then break end
  depth=depth+1
 end

 local branches=0
 while branches<MAX_BRANCHES do
  tl();mineBranch(LEG);face("north")
  tr();mineBranch(LEG);face("north")
  branches=branches+1
  if fuelLevel()<RETURN_MARGIN+(depth*2)+approachMoved+laneMoved+50 or
     emptySlots()<3 then break end
  if not descendOne() then break end
  depth=depth+1
 end

 for i=1,depth do ascendOne() end

 -- Return from private lane to central approach.
 face("north")
 returnFromLane(laneMoved)

 -- Now at the end of the central approach, facing south.
 for i=1,approachMoved do waitOrDigForward() end

 enterHub()
 deposit()
 if not hub.home() then error("Cannot return to miner bay") end

 print("Miner "..BAY.." trip complete.")
 print("Fuel: "..tostring(turtle.getFuelLevel()))
 sleep(5)
end
