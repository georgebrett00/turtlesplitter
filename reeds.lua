-- reeds.lua - permanent hub sugar-cane/reed farmer
-- Old ComputerCraft / CraftOS friendly.
--
-- START: reed turtle bay at (9,4), facing EAST.
-- Farm is built outside the EAST side of the hub, deliberately away from:
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
local START_EAST=4

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
 leaveHub()
 face("south")
end

local function digTemplate()
 print("BUILDING REED FARM")
 print("------------------")
 print("Digging "..ROWS.." water cells.")
 print("Farm is east/south of hub.")
 print("")

 gotoFarmStart()

 for row=1,ROWS do
  -- stand on access path; water trench is immediately EAST
  face("east")
  if turtle.detectDown() then
   -- access path itself is left intact
  end
  -- move into water-cell position, dig floor down one block, return
  waitForward()
  if turtle.detectDown() then turtle.digDown() end
  face("west");waitForward()
  face("south")
  if row<ROWS then waitForward() end
 end

 -- Return to farm start, then hub.
 face("north")
 for i=1,ROWS-1 do waitForward() end
 face("west")
 move(START_EAST)
 hub.setPosition(9,0,4,"west")

 term.clear();term.setCursorPos(1,1)
 print("WATER NEEDED")
 print("------------")
 print("I dug "..ROWS.." water holes")
 print("east/south of the hub.")
 print("")
 print("Fill EVERY hole with")
 print("source water.")
 print("")
 print("Also make sure the block")
 print("immediately EAST of each")
 print("water hole is DIRT/GRASS.")
 print("")
 print("Return here and type:")
 print("WATER")
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
  -- access path -> water cell
  face("east");waitForward()

  local ok,d=turtle.inspectDown()
  if not (ok and d and (d.name=="minecraft:water" or d.name=="minecraft:flowing_water")) then
   error("Water missing at farm row "..row)
  end

  -- Cross water cell to planting block, then rise one block and plant down.
  waitForward()
  local ground,g=turtle.inspectDown()
  if not ground then error("No planting block at row "..row) end

  if not turtle.up() then error("Need clear air above planting row "..row) end
  if not findItem("minecraft:reeds") then error("Out of reeds") end
  if not turtle.placeDown() then error("Cannot plant reed at row "..row) end
  turtle.down()

  -- back across water to access path
  face("west");waitForward();waitForward()
  face("south")
  if row<ROWS then waitForward() end
 end

 -- back to farm start and hub
 face("north")
 for i=1,ROWS-1 do waitForward() end
 face("west");move(START_EAST)
 hub.setPosition(9,0,4,"west")
 saveReady()
 print("Reed farm planted.")
end

local function harvest()
 gotoFarmStart()
 local gotBefore=countItem("minecraft:reeds")

 for row=1,ROWS do
  -- Move over water then over base reed at ground level.
  face("east");waitForward();waitForward()

  -- Rise to one block above the permanent base. Only harvest blocks above it.
  if not turtle.up() then
   -- A grown reed may occupy the space above; harvest it first.
   if turtle.detectUp() then turtle.digUp() end
   if not turtle.up() then error("Cannot rise at reed row "..row) end
  end

  -- At y+1, break upper growth below/above as appropriate but NEVER base at y0.
  if turtle.detectUp() then turtle.digUp() end

  -- Step back down; collect drops by moving around the plant cell.
  turtle.down()
  face("west");waitForward();waitForward()
  face("south")
  if row<ROWS then waitForward() end
 end

 face("north")
 for i=1,ROWS-1 do waitForward() end
 face("west");move(START_EAST)
 hub.setPosition(9,0,4,"west")

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
