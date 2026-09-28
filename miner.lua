-- miner.lua - self-sufficient hub miner
-- Old CraftOS / Lua 5.1 compatible.
-- START: miner1 bay from hubcfg.lua.
--
-- Behaviour:
-- * uses the hub only for safe travel to/from the mining gate
-- * mines its own coal and burns only what it needs
-- * reserves some coal for itself and deposits surplus in communal FUEL
-- * deposits ores/gems/redstone/lapis in ORES
-- * discards common waste (cobble, dirt, gravel, etc.)
-- * returns before fuel/inventory become unsafe
--
-- Mining pattern: repeated 32-block branch tunnels from a descending staircase.

local hub=require("hub")
hub.setRole("miner1")

local LEG=32
local FUEL_RESERVE=160
local RETURN_MARGIN=80
local MAX_BRANCHES=8

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
 return n=="minecraft:coal" or n=="minecraft:charcoal" or
        n=="minecraft:coal_ore" or
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
  if d and isWaste(d.name) then
   turtle.select(s)
   turtle.drop()
  end
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

local function inspectValuable(inspectFn)
 local ok,d=inspectFn()
 return ok and d and isValuable(d.name)
end

local function collectSides()
 -- Collect exposed valuables without wandering away from the known tunnel.
 if inspectValuable(turtle.inspectUp) then turtle.digUp() end
 if inspectValuable(turtle.inspectDown) then turtle.digDown() end

 tr()
 if inspectValuable(turtle.inspect) then turtle.dig() end
 tr();tr()
 if inspectValuable(turtle.inspect) then turtle.dig() end
 tr()
end

local function forwardDig()
 while turtle.detect() do
  if not turtle.dig() then sleep(.5) end
 end
 if not turtle.forward() then return false end
 collectSides()
 cleanInventory()
 return true
end

local function backSteps(n)
 for i=1,n do
  while not turtle.back() do sleep(.5) end
 end
end

local function mineBranch(length)
 local moved=0
 collectSides()
 for i=1,length do
  -- Leave enough fuel to retrace this branch plus a generous hub margin.
  if fuelLevel() < (moved + RETURN_MARGIN) then
   burnCoalTo(moved + RETURN_MARGIN + 80)
  end
  if fuelLevel() < (moved + RETURN_MARGIN) then break end
  if not forwardDig() then break end
  moved=moved+1
  if emptySlots()<3 then break end
 end

 backSteps(moved)
 cleanInventory()
 return moved
end

local function descendOne()
 -- One-block descending staircase step, then return path is simply up+back.
 if turtle.detectDown() then
  if not turtle.digDown() then return false end
 end
 if not turtle.down() then return false end
 if not forwardDig() then
  turtle.up()
  return false
 end
 return true
end

local function ascendOne()
 turtle.turnLeft();turtle.turnLeft()
 while not turtle.back() do sleep(.5) end
 while not turtle.up() do sleep(.5) end
 turtle.turnLeft();turtle.turnLeft()
end

local function deposit()
 cleanInventory()

 -- Coal/charcoal: keep enough carried fuel for the next trip, put surplus
 -- into the communal FUEL chest.
 if not hub.gotoPos(hub.config.STORAGE.fuel) then error("Cannot reach FUEL chest") end

 local keepCoal=2
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isCoal(d.name) then
   local drop=d.count
   if keepCoal>0 then
    local k=math.min(keepCoal,drop)
    keepCoal=keepCoal-k
    drop=drop-k
   end
   if drop>0 then
    turtle.select(s)
    turtle.drop(drop)
   end
  elseif d and d.name=="minecraft:coal_ore" then
   turtle.select(s);turtle.drop()
  end
 end

 -- Everything else valuable goes to ORES.
 if not hub.gotoPos(hub.config.STORAGE.ores) then error("Cannot reach ORES chest") end
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isValuable(d.name) and not isCoal(d.name) and d.name~="minecraft:coal_ore" then
   turtle.select(s);turtle.drop()
  end
 end
end

local function leaveHub()
 -- Hub navigation owns orientation until the mining gate.
 if not hub.gotoPos(hub.config.GATES.mining) then error("Cannot reach mining gate") end
 -- Gate is configured facing NORTH/outward.
 facing="north"
 -- We are standing ON the mining gate and facing outward. The block
 -- directly ahead is outside the protected hub, so it is safe to clear.
 -- This handles tall grass as well as ordinary terrain at the entrance.
 while turtle.detect() do
  if not turtle.dig() then
   sleep(.5)
  end
 end
 if not turtle.forward() then error("Cannot leave mining gate") end
end

local function enterHub()
 -- Caller is immediately north/outside of gate and facing SOUTH.
 if not turtle.forward() then error("Cannot re-enter mining gate") end
 hub.setPosition(4,0,0,"south")
end

print("HUB MINER")
print("Self-fuel + communal coal")
print("Valuables -> ORES")

while true do
 -- Begin every trip from a known hub state.
 if not hub.home() then error("Cannot reach miner bay") end
 if not hub.ensureFuel(FUEL_RESERVE) then error("Need startup fuel") end
 if not hub.home() then error("Cannot return to miner bay") end

 leaveHub()

 -- Outside the hub: move straight away first, then descend BEFORE
 -- doing any sideways branch mining. This keeps surface digging away from hub.
 local approach=8
 local approachMoved=0
 -- Surface approach: go STRAIGHT north. Do not scan the sides here,
 -- because collectSides() visibly rotates the turtle on every step.
 for i=1,approach do
  while turtle.detect() do
   if not turtle.dig() then sleep(.5) end
  end
  if not turtle.forward() then break end
  approachMoved=approachMoved+1
  cleanInventory()
 end
 print("Surface approach complete. Descending...")

 -- Descend a staircase to mining depth. Each step moves one block NORTH
 -- and one block DOWN. We later reverse these exact steps.
 local targetDepth=12
 local depth=0
 for i=1,targetDepth do
  if fuelLevel() < RETURN_MARGIN + (depth*2) + approachMoved + 40 then
   burnCoalTo(RETURN_MARGIN + (depth*2) + approachMoved + 120)
  end
  if fuelLevel() < RETURN_MARGIN + (depth*2) + approachMoved + 40 then break end
  if not descendOne() then break end
  depth=depth+1
 end

 -- Only branch mine once we are underground.
 local branches=0
 while branches<MAX_BRANCHES do
  tl()
  mineBranch(LEG)
  face("north")

  tr()
  mineBranch(LEG)
  face("north")

  branches=branches+1
  if fuelLevel()<RETURN_MARGIN+(depth*2)+approachMoved+30 or emptySlots()<3 then break end

  -- Go one level deeper between branch pairs.
  if not descendOne() then break end
  depth=depth+1
 end

 -- Retrace the staircase exactly back to the surface approach tunnel.
 for i=1,depth do ascendOne() end

 -- Retrace the straight approach back to the square outside the mining gate.
 face("south")
 backSteps(approachMoved)
 face("south")

 -- We are outside the north gate. Face south toward hub and hand control back.
 face("south")
 enterHub()

 deposit()
 if not hub.home() then error("Cannot return to miner bay") end

 print("Mining trip complete.")
 print("Fuel: "..tostring(turtle.getFuelLevel()))
 sleep(5)
end
