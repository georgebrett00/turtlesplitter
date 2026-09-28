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
local CLAIM_RETRIES=3
local CLAIM_BYPASS=20
-- Per-bay bypass side/extra spacing. Adjacent mining lanes are only 2 blocks
-- apart, so all four miners must NOT choose the same detour corridor.
local CLAIM_SIDE={ "west","east","west","east" }
local CLAIM_EXTRA={ 0,4,8,12 }

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
  n=="minecraft:iron_ingot" or n=="minecraft:gold_ingot" or
  n=="minecraft:deepslate_coal_ore" or
  n=="minecraft:deepslate_iron_ore" or
  n=="minecraft:copper_ore" or n=="minecraft:deepslate_copper_ore" or
  n=="minecraft:deepslate_gold_ore" or
  n=="minecraft:deepslate_redstone_ore" or
  n=="minecraft:deepslate_lapis_ore" or
  n=="minecraft:deepslate_diamond_ore" or
  n=="minecraft:deepslate_emerald_ore" or
  n=="minecraft:ancient_debris"
end

local function isOre(n)
 if not n then return false end
 return n=="minecraft:coal_ore" or n=="minecraft:iron_ore" or
  n=="minecraft:gold_ore" or n=="minecraft:diamond_ore" or
  n=="minecraft:redstone_ore" or n=="minecraft:lapis_ore" or
  n=="minecraft:emerald_ore" or
  n=="minecraft:deepslate_coal_ore" or
  n=="minecraft:deepslate_iron_ore" or
  n=="minecraft:copper_ore" or n=="minecraft:deepslate_copper_ore" or
  n=="minecraft:deepslate_gold_ore" or
  n=="minecraft:deepslate_redstone_ore" or
  n=="minecraft:deepslate_lapis_ore" or
  n=="minecraft:deepslate_diamond_ore" or
  n=="minecraft:deepslate_emerald_ore" or
  n=="minecraft:ancient_debris"
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

local function ensureMoveFuel()
 if fuelLevel()>0 then return true end
 -- Consume onboard coal automatically. A stack sitting in inventory is not
 -- fuel until turtle.refuel() is called.
 if burnCoalTo(200) then return true end
 error("OUT OF FUEL - put coal/charcoal in miner inventory")
end

local function inspectValuable(fn)
 local ok,d=fn()
 return ok and d and isValuable(d.name)
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

-- Try to mine/move one block. A claimed/protected block normally behaves as:
-- detect=true, dig returns false, block remains. We retry briefly so lag is
-- not mistaken for a claim. ComputerCraft machines are never treated as land.
local function tryMineMove()
 ensureMoveFuel()
 local ok,reason=turtle.forward()
 if ok then return true,"moved" end
 if reason and string.find(string.lower(reason),"fuel",1,true) then
  ensureMoveFuel()
  if turtle.forward() then return true,"moved" end
 end
 if not turtle.detect() then return false,"entity" end
 local io,d=turtle.inspect()
 if io and protectedComputer(d) then return false,"machine" end
 for n=1,CLAIM_RETRIES do
  turtle.dig()
  sleep(.25)
  if turtle.forward() then return true,"moved" end
  if not turtle.detect() then return false,"entity" end
 end
 return false,"protected"
end

-- Bypass a protected/claimed region without entering another miner's lane.
-- Bay 1/3 detour WEST, bay 2/4 EAST, with different widths per bay.
-- It searches forward along the outside edge until the original northward
-- corridor becomes mineable again, then returns to the miner's original x lane.
local function bypassClaim()
 local originalFacing=facing
 face(CLAIM_SIDE[BAY])
 local width=CLAIM_BYPASS+CLAIM_EXTRA[BAY]
 print("Claim detected - bypass "..CLAIM_SIDE[BAY].." "..width)

 local sideMoved=0
 for i=1,width do
  local ok,why=tryMineMove()
  if not ok then
   print("Claim bypass side blocked: "..tostring(why))
   face(originalFacing)
   return false
  end
  sideMoved=sideMoved+1
 end

 face("north")
 local forwardMoved=0
 local clearRun=0
 -- Cross at least one full chunk-width plus margin; continue farther if the
 -- claim is larger. 128 is a safety bound against wandering indefinitely.
 for i=1,128 do
  local ok,why=tryMineMove()
  if ok then
   forwardMoved=forwardMoved+1
   clearRun=clearRun+1
   if clearRun>=20 then break end
  elseif why=="protected" then
   clearRun=0
   -- Still alongside claimed land: move another block farther outward.
   face(CLAIM_SIDE[BAY])
   local sok=tryMineMove()
   face("north")
   if not sok then return false end
   sideMoved=sideMoved+1
  elseif why=="entity" or why=="machine" then
   sleep(1)
   i=i-1
  else
   return false
  end
 end
 if clearRun<20 then
  print("Claim bypass too large; returning.")
  return false
 end

 -- Move back toward this miner's own x lane only after clearing the claim.
 local homeSide=CLAIM_SIDE[BAY]=="west" and "east" or "west"
 face(homeSide)
 for i=1,sideMoved do
  local ok,why=tryMineMove()
  if not ok then
   print("Cannot rejoin mining lane: "..tostring(why))
   return false
  end
 end
 face(originalFacing)
 print("Claim bypass complete.")
 return true,forwardMoved
end
local VEIN_MAX=64

-- TurtleSplitter-style vein miner:
-- when the straight tunnel exposes ore, temporarily leave the tunnel,
-- recursively follow the connected ore vein, then retrace every movement
-- exactly back to the tunnel square and restore the original facing.
local function mineVeinFrom(direction)
 local mined=0

 local function inspectDir(dir)
  if dir=="front" then return turtle.inspect()
  elseif dir=="up" then return turtle.inspectUp()
  else return turtle.inspectDown() end
 end
 local function digDir(dir)
  if dir=="front" then return safeDigFront()
  elseif dir=="up" then return safeDigUp()
  else return safeDigDown() end
 end
 local function moveDir(dir)
  ensureMoveFuel()
  if dir=="front" then return turtle.forward()
  elseif dir=="up" then return turtle.up()
  else return turtle.down() end
 end
 local function undoMove(dir)
  ensureMoveFuel()
  if dir=="front" then
   tr();tr()
   while not turtle.forward() do sleep(.25) end
   tr();tr()
  elseif dir=="up" then
   while not turtle.down() do sleep(.25) end
  else
   while not turtle.up() do sleep(.25) end
  end
 end

 local function chase(dir)
  if mined>=VEIN_MAX or emptySlots()<2 then return end
  -- Keep a generous reserve while wandering away from the main tunnel.
  if not hub.fuelCheck(RETURN_MARGIN+180+mined*2) then return end

  local ok,d=inspectDir(dir)
  if not (ok and d and isOre(d.name)) then return end
  if not digDir(dir) then return end
  if not moveDir(dir) then return end
  mined=mined+1
  cleanInventory()

  -- Search all six neighbours. "Back" is already-open rock/tunnel, so
  -- connected ore is found through front/up/down and both turned sides.
  chase("up")
  chase("down")
  chase("front")
  tr(); chase("front"); tr();tr(); chase("front"); tr()

  undoMove(dir)
 end

 if direction=="up" then
  chase("up")
 elseif direction=="down" then
  chase("down")
 elseif direction=="left" then
  tl();chase("front");tr()
 elseif direction=="right" then
  tr();chase("front");tl()
 elseif direction=="front" then
  chase("front")
 end
 return mined
end

local function collectVeins()
 local total=0
 total=total+mineVeinFrom("up")
 total=total+mineVeinFrom("down")
 total=total+mineVeinFrom("left")
 total=total+mineVeinFrom("right")
 return total
end

local function waitOrDigForward(allowBypass)
 -- OUTSIDE HUB ONLY.
 -- If a normal block cannot be dug after several attempts, assume server
 -- protection/claimed land rather than waiting forever.
 while true do
  local ok,why=tryMineMove()
  if ok then return true,0 end
  if why=="protected" then
   if allowBypass then
    return bypassClaim()
   end
   print("Protected/claimed block encountered.")
   return false,0
  elseif why=="machine" then
   print("MINER SAFETY: turtle/computer ahead - waiting")
   sleep(.5)
  else
   print("Mine traffic: waiting...")
   sleep(.5)
  end
 end
end

local function forwardDig()
 if not waitOrDigForward(false) then return false end
 collectVeins()
 cleanInventory()
 return true
end

local function backWait()
 while true do
  ensureMoveFuel()
  local ok,reason=turtle.back()
  if ok then return end
  if reason and string.find(string.lower(reason),"fuel",1,true) then
   ensureMoveFuel()
  else
   print("Mine traffic: waiting...")
   sleep(.5)
  end
 end
end

local function backSteps(n)
 for i=1,n do backWait() end
end

local function straightDig(n,allowBypass)
 local moved=0
 while moved<n do
  local ok,extra=waitOrDigForward(allowBypass)
  if not ok then break end
  moved=moved+1+(extra or 0)
  cleanInventory()
 end
 return moved
end

local function mineBranch(length)
 local moved=0
 collectVeins()
 while moved<length do
  local need=moved+RETURN_MARGIN+180
  if not hub.fuelCheck(need) then break end

  local ok,extra=waitOrDigForward(true)
  if not ok then break end
  moved=moved+1+(extra or 0)
  collectVeins()
  cleanInventory()
  if emptySlots()<3 then break end
 end
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
  while true do
   ensureMoveFuel()
   local ok,reason=turtle.down()
   if ok then break end

   if reason and string.find(string.lower(reason),"fuel",1,true) then
    ensureMoveFuel()
   elseif turtle.detectDown() then
    if not safeDigDown() then
     -- A protected turtle/computer is genuinely below us.
     print("Shaft machine below; waiting...")
     sleep(1)
    end
   else
    -- No block detected. This can be a mob/player/item collision.
    print("Shaft entity below; waiting...")
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
  while true do
   ensureMoveFuel()
   local ok,reason=turtle.up()
   if ok then break end

   if reason and string.find(string.lower(reason),"fuel",1,true) then
    ensureMoveFuel()
   elseif turtle.detectUp() then
    if not safeDigUp() then
     -- A protected turtle/computer is genuinely above us.
     print("Shaft machine above; waiting...")
     sleep(1)
    end
   else
    print("Shaft entity above; waiting...")
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

print("HUB MINER v12 - bay "..BAY)
print("Private lane x="..tostring(hub.config.BAYS[ROLE].x))
print("Vein mining + claimed-land bypass")
print("Self-fuel + communal coal")
print("Valuables -> ORES")
print("Frontier: "..tostring(FRONTIER))

while true do
 if not hub.home() then error("Cannot reach miner bay") end
 local tripStartNeed=TARGET_DEPTH*2+FRONTIER*2+LEG*2+APPROACH*2+RETURN_MARGIN+120
 if not hub.fuelAtHub(tripStartNeed) then error("Need startup fuel") end
 if not hub.home() then error("Cannot return to miner bay") end

 leaveHub()

 -- Move a few blocks NORTH so the shaft is outside the hub.
 -- Each miner remains on its own x coordinate (1,3,5,7).
 facing="north"
 local approachMoved=straightDig(APPROACH,false)
 print("Miner "..BAY.." shaft reached. Descending...")

 -- Genesis-style concept: a dedicated vertical shaft down to deep mining
 -- level. TARGET_DEPTH is a relative 57-block descent from the surface hub.
 -- The Genesis source targets diamond/redstone around -57 after calibration;
 -- this dedicated hub miner cannot know absolute Y on old CraftOS, so it uses
 -- a fixed private shaft depth instead.
 local depth=descendShaft(TARGET_DEPTH)

 -- From here the known return route is depth UP + approach back to hub.
 -- Keep extra margin for mining and hub travel.
 local returnNeed=depth+APPROACH+RETURN_MARGIN+80
 if not hub.fuelCheck(returnNeed+FRONTIER+LEG*2) then
  print("Fuel reserve reached before mining; returning.")
  ascendShaft(depth)
  face("south")
  for i=1,approachMoved do waitOrDigForward() end
  enterHub()
  hub.fuelAtHub(tripStartNeed)
  if not hub.home() then error("Cannot return to miner bay") end
  sleep(5)
 else

 -- Persistent frontier: every completed trip advances farther NORTH.
 -- This prevents repeatedly mining the same tunnel.
 face("north")
 local outbound=FRONTIER
 if outbound>0 then
  print("Returning to frontier: "..outbound)
  straightDig(outbound,true)
 end

 local mined=mineBranch(LEG)
 if mined>0 then
  FRONTIER=FRONTIER+mined
  saveProgress(FRONTIER)
 end

 -- We finish at the NEW frontier. Return south through the tunnel/detour
 -- network. Claimed-land bypasses may mean simple straight retracing is not
 -- possible, so on the return leg the same deterministic bay-specific bypass
 -- rule is used whenever protection is encountered.
 face("south")
 local returned=0
 while returned<FRONTIER do
  local ok,extra=waitOrDigForward(true)
  if not ok then error("Cannot return around claimed land") end
  returned=returned+1+(extra or 0)
 end

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
end
