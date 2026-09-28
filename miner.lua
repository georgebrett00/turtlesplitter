-- miner.lua - multi-turtle self-sufficient hub miner
-- Old CraftOS / Lua 5.1 friendly.
--
-- FIRST RUN: place turtle on one of the four bay markers, facing NORTH.
-- Select bay 1-4 once. Choice is saved in "miner.cfg".
--
-- Each miner exits directly NORTH from its own bay on x=1,3,5,7.
-- There is NO shared mining gate and NO surface fan-out.
-- Each miner returns SOUTH through the same private entrance.
-- SAFETY: never digs ComputerCraft turtles/computers.
-- Dedicated private vertical shaft per miner; no cross-lane branches.
-- Persistent north-going frontier saved in miner.progress.

local hub=require("hub")

local CFG_FILE="miner.cfg"
local PROGRESS_FILE="miner.progress"
local LEG=48
local FUEL_RESERVE=180
local RETURN_MARGIN=100
local MAX_BRANCHES=1
local APPROACH=4
local TARGET_DEPTH=57

-- Separate mining lanes. Negative = west, positive = east.
-- Spacing keeps 32-block branches from starting on the same staircase.

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

local function loadProgress()
 if fs.exists(PROGRESS_FILE) then
  local f=fs.open(PROGRESS_FILE,"r")
  local n=tonumber(f.readLine())
  f.close()
  if n and n>=0 then return n end
 end
 return 0
end

local function saveProgress(n)
 local f=fs.open(PROGRESS_FILE,"w")
 f.writeLine(tostring(n))
 f.close()
end

local BAY=loadBay()
local ROLE="miner"..tostring(BAY)
hub.setRole(ROLE)
local FRONTIER=loadProgress()

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

local function protectedComputer(d)
 if not d or not d.name then return false end
 return string.find(d.name,"computercraft:turtle",1,true)~=nil or
        string.find(d.name,"computercraft:computer",1,true)~=nil
end

local function safeDigFront()
 local ok,d=turtle.inspect()
 if ok and protectedComputer(d) then
  print("MINER SAFETY: turtle/computer ahead - waiting")
  return false
 end
 return turtle.dig()
end

local function safeDigDown()
 local ok,d=turtle.inspectDown()
 if ok and protectedComputer(d) then
  print("MINER SAFETY: turtle/computer below - waiting")
  return false
 end
 return turtle.digDown()
end

local function safeDigUp()
 local ok,d=turtle.inspectUp()
 if ok and protectedComputer(d) then
  print("MINER SAFETY: turtle/computer above - waiting")
  return false
 end
 return turtle.digUp()
end

local function waitOrDigForward()
 -- OUTSIDE HUB ONLY. A block may be mined. If movement is blocked by an
 -- entity/turtle, wait rather than attack it.
 while true do
  if turtle.forward() then return true end
  if turtle.detect() then
   if not safeDigFront() then sleep(.5) end
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
  if not safeDigDown() then return false end
 end
 while not turtle.down() do
  if turtle.detectDown() then safeDigDown();sleep(.5) else sleep(.5) end
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
  if turtle.detectUp() then safeDigUp();sleep(.5) else sleep(.5) end
 end
end

local function descendShaft(n)
 local moved=0
 for i=1,n do
  while not turtle.down() do
   if turtle.detectDown() then
    if not safeDigDown() then
     -- Another turtle/computer must never be destroyed.
     sleep(1)
    end
   else
    print("Shaft occupied; waiting...")
    sleep(1)
   end
  end
  moved=moved+1
  cleanInventory()
 end
 return moved
end

local function ascendShaft(n)
 for i=1,n do
  while not turtle.up() do
   if turtle.detectUp() then
    if not safeDigUp() then sleep(1) end
   else
    print("Shaft occupied; waiting...")
    sleep(1)
   end
  end
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
 -- Each miner owns the NORTH exit directly in front of its own bay.
 -- Bay coordinates are x=1,3,5,7 at z=1. Move to z=0 inside the hub,
 -- then one more step NORTH leaves the hub on that same x lane.
 local b=hub.config.BAYS[ROLE]
 local exit={x=b.x,y=0,z=0,facing="north"}
 if not hub.gotoPos(exit) then error("Cannot reach private mining exit") end
 facing="north"
 waitOrDigForward()
end

local function enterHub()
 -- We are immediately NORTH of this miner's private x lane, facing SOUTH.
 local b=hub.config.BAYS[ROLE]
 while not turtle.forward() do
  -- Never dig toward the hub. If another turtle is temporarily on our
  -- private entrance square, wait for it to clear.
  if turtle.detect() then
   print("Private miner entrance blocked. Waiting...")
  else
   print("Waiting to enter hub...")
  end
  sleep(.5)
 end
 hub.setPosition(b.x,0,0,"south")
end

print("HUB MINER "..BAY)
print("Private lane x="..tostring(hub.config.BAYS[ROLE].x))
print("Vertical shaft + persistent frontier")
print("Self-fuel + communal coal")
print("Valuables -> ORES")
print("Frontier: "..tostring(FRONTIER))

while true do
 if not hub.home() then error("Cannot reach miner bay") end
 if not hub.ensureFuel(FUEL_RESERVE) then error("Need startup fuel") end
 if not hub.home() then error("Cannot return to miner bay") end

 leaveHub()

 -- Move a few blocks NORTH so the shaft is outside the hub.
 -- Each miner remains on its own x coordinate (1,3,5,7).
 facing="north"
 local approachMoved=straightDig(APPROACH)
 print("Miner "..BAY.." shaft reached. Descending...")

 -- Genesis-style concept: a dedicated vertical shaft down to deep mining
 -- level. TARGET_DEPTH is a relative 57-block descent from the surface hub.
 -- The Genesis source targets diamond/redstone around -57 after calibration;
 -- this dedicated hub miner cannot know absolute Y on old CraftOS, so it uses
 -- a fixed private shaft depth instead.
 local depth=descendShaft(TARGET_DEPTH)

 -- Persistent frontier: every completed trip advances farther NORTH.
 -- This prevents repeatedly mining the same tunnel.
 face("north")
 local outbound=FRONTIER
 if outbound>0 then
  print("Returning to frontier: "..outbound)
  straightDig(outbound)
 end

 local mined=mineBranch(LEG)
 if mined>0 then
  FRONTIER=FRONTIER+mined
  saveProgress(FRONTIER)
 end

 -- mineBranch returns us to the old frontier. Return to shaft.
 face("south")
 for i=1,outbound do waitOrDigForward() end

 -- Climb the same private vertical shaft.
 ascendShaft(depth)

 -- Return SOUTH to this miner's private hub entrance.
 face("south")
 for i=1,approachMoved do waitOrDigForward() end

 enterHub()
 deposit()
 if not hub.home() then error("Cannot return to miner bay") end

 print("Miner "..BAY.." trip complete.")
 print("Fuel: "..tostring(turtle.getFuelLevel()))
 sleep(5)
end
