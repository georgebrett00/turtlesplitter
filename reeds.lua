-- reeds.lua - permanent hub sugar-cane/reed farmer
-- Old ComputerCraft / CraftOS friendly.
--
-- START: reed turtle bay at (9,4), facing EAST.
-- Farm is SOUTH-EAST of the hub, deliberately away from:
--   * miners, which leave NORTH
--   * wood farm, which leaves EAST from (9,3) then works farther NORTH
--
-- First run:
--   1. turtle digs the farm channels
--   2. user fills the water trench with SOURCE water
--   3. user returns to turtle and types WATER
--   4. turtle plants minecraft:reeds
-- Thereafter it sleeps 300 seconds between harvest checks.

local hub=require("hub")
hub.setRole("reeds")

local STATE="reeds.cfg"
local WAIT=300
local ROWS=7
local START_EAST=2

local facing="east"
local right={north="east",east="south",south="west",west="north"}
local left={north="west",west="south",south="east",east="north"}

local function tr() turtle.turnRight();facing=right[facing] end
local function tl() turtle.turnLeft();facing=left[facing] end
local function face(d)
 if facing==d then return end
 if right[facing]==d then tr()
 elseif left[facing]==d then tl()
 else tr();tr() end
end

local function waitForward()
 while not turtle.forward() do
  if turtle.detect() then
   if not turtle.dig() then sleep(.5) end
  else
   print("Path occupied; waiting...")
   sleep(.5)
  end
 end
end

local function move(n)
 for i=1,n do waitForward() end
end

local function back(n)
 for i=1,n do
  while not turtle.back() do sleep(.5) end
 end
end

local function findItem(name)
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and d.name==name then turtle.select(s);return true end
 end
 return false
end

local function countItem(name)
 local n=0
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and d.name==name then n=n+d.count end
 end
 return n
end

local function leaveHub()
 if not hub.gotoPos(hub.config.GATES.reeds) then error("Cannot reach reed gate") end
 -- Gate is the east-edge square (9,4), facing EAST.
 facing="east"
 move(START_EAST)
end

local function returnHub()
 face("west")
 back(0)
 -- move west through the known farm access corridor
 move(START_EAST)
 -- We are immediately east of the gate after START_EAST moves from farm origin.
 -- One extra west move enters the hub gate only if our local origin was outside.
 -- leaveHub starts ON gate then moves START_EAST, so START_EAST west moves return ON gate.
 hub.setPosition(9,0,4,"west")
end

local function saveReady()
 local f=fs.open(STATE,"w");f.writeLine("ready");f.close()
end

local function ready()
 return fs.exists(STATE)
end

-- Farm geometry:
-- Turtle access path runs SOUTH along x=13 (4 blocks east of hub edge).
-- For each of 7 rows:
--   water is dug one block EAST of path
--   dirt/reed is one further EAST
-- This keeps all farm work around global x=14..15,z=4..10, away from the
-- north-side miner shafts and north-east tree farm.
local function gotoFarmStart()
 leaveHub()                 -- 2 blocks EAST of reed gate
 face("south")
 move(8)                    -- clear the tree farm's z=0..6 working area
end

local function returnHubFromFarm()
 face("north");move(8)
 face("west");move(START_EAST)
 hub.setPosition(9,0,4,"west")
end

local function digTemplate()
 print("BUILDING REED FARM")
 print("------------------")
 print("Farm is SOUTH-EAST")
 print("of hub, clear of trees")
 print("and north-side miners.")
 print("")

 gotoFarmStart()

 -- Access path runs SOUTH. Water is one block EAST of the path;
 -- planting dirt/reeds are one more block EAST.
 for row=1,ROWS do
  face("east");waitForward()
  if turtle.detectDown() then turtle.digDown() end
  face("west");waitForward()
  face("south")
  if row<ROWS then waitForward() end
 end

 face("north")
 for i=1,ROWS-1 do waitForward() end
 returnHubFromFarm()

 term.clear();term.setCursorPos(1,1)
 print("WATER NEEDED")
 print("------------")
 print("Farm is SOUTH-EAST.")
 print("")
 print("Fill all "..ROWS.." holes")
 print("with SOURCE water.")
 print("")
 print("Put DIRT/GRASS one")
 print("block EAST of each")
 print("water hole.")
 print("")
 print("Return and type WATER")
 while string.upper(read())~="WATER" do
  print("Type WATER when ready.")
 end
end

local function verifyAndPlant()
 if countItem("minecraft:reeds")<ROWS then
  error("Need "..ROWS.." minecraft:reeds in turtle inventory")
 end

 gotoFarmStart()
 for row=1,ROWS do
  face("east");waitForward()
  local ok,d=turtle.inspectDown()
  if not (ok and d and (d.name=="minecraft:water" or d.name=="minecraft:flowing_water")) then
   error("Water missing at farm row "..row)
  end

  waitForward()
  local ground,g=turtle.inspectDown()
  if not ground then error("No planting block at row "..row) end

  if not turtle.up() then error("Need clear air above planting row "..row) end
  if not findItem("minecraft:reeds") then error("Out of reeds") end
  if not turtle.placeDown() then error("Cannot plant reed at row "..row) end
  turtle.down()

  face("west");waitForward();waitForward()
  face("south")
  if row<ROWS then waitForward() end
 end

 face("north")
 for i=1,ROWS-1 do waitForward() end
 returnHubFromFarm()
 saveReady()
 print("Reed farm planted.")
end

local function harvest()
 gotoFarmStart()
 local gotBefore=countItem("minecraft:reeds")

 for row=1,ROWS do
  face("east");waitForward();waitForward()

  -- Base reed stays planted. Harvest only growth above it.
  if not turtle.up() then
   if turtle.detectUp() then turtle.digUp() end
   if not turtle.up() then error("Cannot rise at reed row "..row) end
  end
  if turtle.detectUp() then turtle.digUp() end
  turtle.down()

  face("west");waitForward();waitForward()
  face("south")
  if row<ROWS then waitForward() end
 end

 face("north")
 for i=1,ROWS-1 do waitForward() end
 returnHubFromFarm()

 local got=countItem("minecraft:reeds")-gotBefore
 print("Harvest complete. Reeds: +"..tostring(got))
end

local function depositReeds()
 -- Current hub has no dedicated REEDS storage bank, so retain a propagation
 -- reserve and use any configured reeds/misc bank if one is added later.
 local st=hub.config.STORAGE.reeds or hub.config.STORAGE.misc
 if not st then
  print("No REEDS/MISC chest configured; keeping reeds onboard.")
  return
 end
 if not hub.gotoPos(st) then return end
 local keep=ROWS
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and d.name=="minecraft:reeds" then
   local drop=d.count
   if keep>0 then local k=math.min(keep,drop);keep=keep-k;drop=drop-k end
   if drop>0 then turtle.select(s);turtle.drop(drop) end
  end
 end
end

print("HUB REED FARMER")
print("minecraft:reeds")
print("Check interval: 5 min")

if not ready() then
 digTemplate()
 verifyAndPlant()
end

while true do
 if not hub.home() then error("Cannot reach reed bay") end
 print("Sleeping 5 minutes...")
 sleep(WAIT)
 harvest()
 depositReeds()
 if not hub.home() then error("Cannot return to reed bay") end
end
