-- reeds.lua - permanent hub sugar-cane/reed farmer
-- Old ComputerCraft / CraftOS friendly.
--
-- START: reed turtle bay at (9,6), facing EAST.
-- Farm is SOUTH of tree zone of the hub, deliberately away from:
--   * miners, which leave NORTH
--   * wood farm, which leaves EAST from (9,3) then works farther NORTH
--
-- First run:
--   1. turtle digs the farm channels
--   2. user fills the water trench with SOURCE water
--   3. user returns to turtle and types WATER
--   4. turtle plants minecraft:reeds on BOTH banks
-- Thereafter it sleeps 300 seconds between harvest checks.

local hub=require("hub")
hub.setRole("reeds")

local STATE="reeds.cfg"
local WAIT=300
local ROWS=7
local EXIT_EAST=1
local SOUTH_CLEAR=5

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

local function refuelIfNeeded(minFuel)
 minFuel=minFuel or 100
 local level=turtle.getFuelLevel()
 if level=="unlimited" or level>=minFuel then return true end

 local old=turtle.getSelectedSlot()

 -- Prefer coal/charcoal, but allow any item this old CraftOS recognises
 -- as fuel. Test with refuel(0) so non-fuel items are not consumed.
 for slot=1,16 do
  if turtle.getItemCount(slot)>0 then
   turtle.select(slot)
   if turtle.refuel(0) then
    while turtle.getItemCount(slot)>0 do
     level=turtle.getFuelLevel()
     if level=="unlimited" or level>=minFuel then break end
     if not turtle.refuel(1) then break end
    end
    level=turtle.getFuelLevel()
    if level=="unlimited" or level>=minFuel then
     turtle.select(old)
     return true
    end
   end
  end
 end

 turtle.select(old)
 level=turtle.getFuelLevel()
 return level=="unlimited" or level>0
end

local function waitForward()
 local waits=0
 while true do
  if not refuelIfNeeded(100) then
   error("OUT OF FUEL - put coal in turtle inventory")
  end

  local ok,reason=turtle.forward()
  if ok then return end

  -- CraftOS returns a useful reason such as "Out of fuel". Do not disguise
  -- that as an entity collision.
  if reason and string.find(string.lower(reason),"fuel",1,true) then
   if not refuelIfNeeded(100) then
    error("OUT OF FUEL - put coal in turtle inventory")
   end
  elseif turtle.detect() then
   local seen,d=turtle.inspect()
   local name=seen and d and d.name or ""
   -- Never attack another ComputerCraft machine.
   if string.find(name,"computercraft:turtle",1,true) or
      string.find(name,"computercraft:computer",1,true) then
    print("Turtle/computer ahead; waiting...")
    sleep(1)
   else
    if not turtle.dig() then sleep(.5) end
   end
  else
   waits=waits+1
   if waits==1 or waits%10==0 then
    print("Entity in reed path; waiting...")
   end
   sleep(.5)
  end
 end
end

local function safeForward(where)
 if not refuelIfNeeded(100) then
  error("OUT OF FUEL - put coal in turtle inventory")
 end
 local ok,reason=turtle.forward()
 if ok then return true end
 if reason and string.find(string.lower(reason),"fuel",1,true) then
  if refuelIfNeeded(100) then
   ok,reason=turtle.forward()
   if ok then return true end
  end
  error("OUT OF FUEL - put coal in turtle inventory")
 end
 error((where or "Forward movement blocked")..
       (reason and (": "..tostring(reason)) or ""))
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
 -- Actual reed bay/gate is (9,6), facing EAST.
 -- Step only ONE block east, then immediately head SOUTH.
 facing="east"
 move(EXIT_EAST)
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
local function gotoBuildStart()
 leaveHub()                 -- x10,z6, just outside hub/tree boundary
 face("south")
 move(SOUTH_CLEAR)          -- x10,z11: safely SOUTH of tree farm
end

local function returnHubFromFarm()
 face("north");move(SOUTH_CLEAR)
 face("west");move(EXIT_EAST)
 hub.setPosition(9,0,6,"west")
end

-- Permanent two-bank navigation.
-- Once WEST-bank reeds exist, the old access path is itself occupied by reeds.
-- Enter/leave the water trench through its NORTH end instead.
local function gotoFarmCap()
 leaveHub()                 -- x10,z6
 face("south")
 move(SOUTH_CLEAR-1)        -- x10,z10, NW of first water cell
end

local function enterWater()
 -- cap -> north end of trench -> first water row
 face("east");waitForward()
 face("south");waitForward()
end

local function leaveWaterAndReturnHub()
 -- Called from row 1 water cell after returning NORTH through the trench.
 face("north");waitForward() -- north cap
 face("west");waitForward()  -- x10,z10
 face("north");move(SOUTH_CLEAR-1)
 face("west");move(EXIT_EAST)
 hub.setPosition(9,0,6,"west")
end

local function digTemplate()
 print("BUILDING REED FARM")
 print("------------------")
 print("Farm is SOUTH of tree zone")
 print("of hub, clear of trees")
 print("and north-side miners.")
 print("")

 gotoBuildStart()

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
 print("Farm is SOUTH of tree zone.")
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

local function plantSide(side,row)
 face(side)
 local ok,d=turtle.inspect()
 if ok then
  if d and d.name=="minecraft:reeds" then return end
  error("Planting space blocked at row "..row.." "..side..": "..
        tostring(d and d.name))
 end
 if not findItem("minecraft:reeds") then error("Out of reeds") end
 if not turtle.place() then
  error("Cannot plant "..side.." reed at row "..row..
        ". Check dirt/sand beside the water.")
 end
end

local function verifyAndPlant()
 if countItem("minecraft:reeds")<(ROWS*2) then
  error("Need "..(ROWS*2).." minecraft:reeds in turtle inventory")
 end

 gotoFarmCap()
 enterWater()

 for row=1,ROWS do
  local ok,d=turtle.inspectDown()
  if not (ok and d and (d.name=="minecraft:water" or d.name=="minecraft:flowing_water")) then
   error("Water missing at farm row "..row)
  end

  plantSide("west",row)
  plantSide("east",row)

  if row<ROWS then
   -- Do NOT travel along the water-level corridor. On this old CC build
   -- forward movement there can fail even though detect() sees no block.
   -- Fly one block above it, advance to the next row, then descend.
   if not turtle.up() then error("Cannot rise after planting row "..row) end
   face("south")
   safeForward("Upper farm lane blocked after row "..row)
   if not turtle.down() then error("Cannot descend onto water row "..(row+1)) end
  end
 end

 -- Return using the clear upper lane, not the water-level lane.
 if not turtle.up() then error("Cannot rise for farm return") end
 face("north")
 for i=1,ROWS-1 do
  safeForward("Upper return lane blocked")
 end
 if not turtle.down() then error("Cannot descend at first water row") end
 leaveWaterAndReturnHub()

 saveReady()
 print("Reed farm planted: "..(ROWS*2).." plants.")
end

local function harvest()
 gotoFarmCap()
 local gotBefore=countItem("minecraft:reeds")
 enterWater()

 -- Rise once and stay in the clear lane ABOVE the water corridor for the
 -- whole harvest. At this height the second reed segments are beside us.
 if not turtle.up() then error("Cannot rise into harvest lane") end

 for row=1,ROWS do
  face("west")
  local w,wd=turtle.inspect()
  if w and wd and wd.name=="minecraft:reeds" then turtle.dig() end

  face("east")
  local e,ed=turtle.inspect()
  if e and ed and ed.name=="minecraft:reeds" then turtle.dig() end

  face("south")
  if row<ROWS then
   safeForward("Upper harvest lane blocked after row "..row)
  end
 end

 -- Return NORTH at the same safe height.
 face("north")
 for i=1,ROWS-1 do
  safeForward("Upper harvest return lane blocked")
 end
 if not turtle.down() then error("Cannot descend at first water row") end
 leaveWaterAndReturnHub()

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
 local keep=ROWS*2
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and d.name=="minecraft:reeds" then
   local drop=d.count
   if keep>0 then local k=math.min(keep,drop);keep=keep-k;drop=drop-k end
   if drop>0 then turtle.select(s);turtle.drop(drop) end
  end
 end
end

print("HUB REED FARMER v15")
print("minecraft:reeds")
print("14 plants / both water banks")
print("Check interval: 5 min")
if not refuelIfNeeded(200) then
 error("OUT OF FUEL - put coal in turtle inventory")
end
print("Fuel: "..tostring(turtle.getFuelLevel()))

if not hub.fuelAtHub(220) then error("Need fuel") end

if not ready() then
 digTemplate()
 verifyAndPlant()
end

while true do
 if not hub.home() then error("Cannot reach reed bay") end
 if not hub.fuelAtHub(220) then error("Need fuel") end
 print("Sleeping 5 minutes...")
 sleep(WAIT)
 harvest()
 depositReeds()
 if not hub.home() then error("Cannot return to reed bay") end
end
