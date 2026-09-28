-- wood.lua - autonomous 3x3 tree farm worker
-- Old CraftOS / Lua 5.1 compatible.
-- START: wood bay (9,3), facing EAST/out of the hub.

local hub=require("hub")
hub.setRole("wood")

local WAIT=300
local trees={
 {6,-3},{9,-3},{12,-3},
 {6, 0},{9, 0},{12, 0},
 {6, 3},{9, 3},{12, 3},
}

-- Outside-farm coordinates are relative to the wood bay.
-- (0,0)=wood bay; +X=east/outside; +Z=south.
local x,z,facing=0,0,"east"
local right={north="east",east="south",south="west",west="north"}
local left ={north="west",west="south",south="east",east="north"}
local step={north={0,-1},east={1,0},south={0,1},west={-1,0}}

local function isSapling(n)
 return n=="minecraft:sapling" or n=="minecraft:oak_sapling" or
        n=="minecraft:spruce_sapling" or n=="minecraft:birch_sapling" or
        n=="minecraft:jungle_sapling"
end
local function isLog(n)
 return n=="minecraft:log" or n=="minecraft:log2" or
        n=="minecraft:oak_log" or n=="minecraft:spruce_log" or
        n=="minecraft:birch_log" or n=="minecraft:jungle_log"
end
local function isLeaves(n)
 return n=="minecraft:leaves" or n=="minecraft:leaves2" or
        n=="minecraft:oak_leaves" or n=="minecraft:spruce_leaves" or
        n=="minecraft:birch_leaves" or n=="minecraft:jungle_leaves"
end
local function isDirt(n) return n=="minecraft:dirt" or n=="minecraft:grass" end

local function countWhere(test)
 local n=0
 for s=1,16 do local d=turtle.getItemDetail(s); if d and test(d.name) then n=n+d.count end end
 return n
end
local function selectWhere(test)
 for s=1,16 do local d=turtle.getItemDetail(s); if d and test(d.name) then turtle.select(s);return true end end
 return false
end

local function waitFor(test,need,title,item)
 while countWhere(test)<need do
  term.clear();term.setCursorPos(1,1)
  print("===================")
  print(title)
  print("===================")
  print("")
  print("Need "..need.." total.")
  print("Have "..countWhere(test)..".")
  print("")
  print("Add "..item.." to")
  print("my inventory.")
  print("")
  print("Waiting...")
  sleep(1)
 end
end

local function tr() turtle.turnRight();facing=right[facing] end
local function tl() turtle.turnLeft();facing=left[facing] end
local function face(d)
 if facing==d then return end
 if right[facing]==d then tr() elseif left[facing]==d then tl() else tr();tr() end
end
local function treeCell(tx,tz)
 for i=1,#trees do if trees[i][1]==tx and trees[i][2]==tz then return true end end
 return false
end
local function fw()
 local d=step[facing];local nx,nz=x+d[1],z+d[2]
 -- x=0 is the hub edge and may only be used at the actual wood bay (0,0).
 if nx<0 or nx>13 or nz< -3 or nz>3 or (nx==0 and nz~=0) or treeCell(nx,nz) then return false end
 if turtle.forward() then x=nx;z=nz;return true end
 return false
end

local function route(tx,tz)
 local q={{x,z}};local head=1;local seen={[x..","..z]=true};local prev={}
 local dirs={{0,-1,"north"},{1,0,"east"},{0,1,"south"},{-1,0,"west"}}
 while head<=#q do
  local p=q[head];head=head+1
  if p[1]==tx and p[2]==tz then
   local path={};local k=tx..","..tz
   while prev[k] do table.insert(path,1,prev[k].dir);k=prev[k].from end
   return path
  end
  for i=1,4 do
   local nx,nz=p[1]+dirs[i][1],p[2]+dirs[i][2];local k=nx..","..nz
   if nx>=1 and nx<=13 and nz>=-3 and nz<=3 and not treeCell(nx,nz) and not seen[k] then
    seen[k]=true;prev[k]={from=p[1]..","..p[2],dir=dirs[i][3]};q[#q+1]={nx,nz}
   end
  end
 end
end
local function go(tx,tz,ff)
 local p=route(tx,tz);if not p then return false end
 for i=1,#p do face(p[i]);if not fw() then return false end end
 if ff then face(ff) end
 return true
end

local function leaveHub()
 -- hub.home() owns physical orientation inside the hub and returns this
 -- turtle to the wood bay facing EAST. Reset the separate farm navigator
 -- WITHOUT physically turning the turtle.
 x,z,facing=0,0,"east"

 -- HARD SAFETY BUFFER: four blocks STRAIGHT away from the hub.
 for i=1,4 do
  if not turtle.forward() then error("WOOD exit/buffer blocked") end
 end
 x,z,facing=4,0,"east"
end
local function enterHub()
 if not go(4,0,"west") then error("Cannot return to wood buffer") end
 -- Cross the four-block safety corridor straight back to the wood bay.
 for i=1,4 do
  if not turtle.forward() then error("Cannot return through wood corridor") end
 end
 x,z,facing=0,0,"west"
 -- Explicit handoff back to hub.lua. Physical position is the known
 -- wood bay (9,3), facing WEST.
 hub.setPosition(9,0,3,"west")
end

local function serviceFor(t) return t[1]-1,t[2] end

local function prepareTree(t)
 -- Tree trunks are deliberately >=6 blocks outside the hub.
 -- No ground modification is permitted closer than that.
 if t[1] < 6 then error("SAFETY: tree position too close to hub") end
 local sx,sz=serviceFor(t)
 if not go(sx,sz,"east") then error("Cannot reach tree service square") end
 local ok,d=turtle.inspect()
 if ok and d and (isSapling(d.name) or isLog(d.name)) then return true end
 if ok then
  print("Tree square blocked: "..tostring(d.name))
  return false
 end

 -- Temporarily enter the empty tree square to prepare its ground.
 if not turtle.forward() then return false end
 local ground,gd=turtle.inspectDown()
 if not (ground and gd and isDirt(gd.name)) then
  waitFor(isDirt,1,"   DIRT REQUIRED","dirt")
  if ground and not turtle.digDown() then turtle.back();return false end
  if not selectWhere(isDirt) or not turtle.placeDown() then turtle.back();return false end
 end
 turtle.back()

 waitFor(isSapling,1," SAPLINGS REQUIRED","saplings")
 if not selectWhere(isSapling) or not turtle.place() then return false end
 sleep(.5)
 local planted,pd=turtle.inspect()
 return planted and pd and isSapling(pd.name)
end

local function clearSideLeaves()
 for i=1,4 do
  local ok,d=turtle.inspect();if ok and d and isLeaves(d.name) then turtle.dig() end
  turtle.turnRight()
 end
end

local function harvestTree(t)
 local sx,sz=serviceFor(t)
 if not go(sx,sz,"east") then return false end
 local ok,d=turtle.inspect();if not (ok and d and isLog(d.name)) then return false end
 turtle.dig();if not turtle.forward() then return false end
 local h=0
 while true do
  clearSideLeaves()
  local up,ud=turtle.inspectUp()
  if not (up and ud and (isLog(ud.name) or isLeaves(ud.name))) then break end
  turtle.digUp();if not turtle.up() then break end;h=h+1
 end
 clearSideLeaves()
 for i=1,h do while not turtle.down() do sleep(.5) end end
 for i=1,4 do turtle.suck();turtle.turnRight() end
 turtle.suckUp();turtle.suckDown()
 -- Back from tree cell to its west service square.
 face("west");if not turtle.forward() then return false end
 x,z=sx,sz
 face("east")
 return true
end

local function depositLogs()
 if not hub.gotoPos(hub.config.STORAGE.wood) then error("Cannot reach WOOD chest") end
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and isLog(d.name) then turtle.select(s);if not turtle.drop() then return false end end
 end
 return true
end

print("WOOD WORKER v3 - 3x3")
print("Farm: 9 trees")
print("Check interval: 5 min")
waitFor(isSapling,9," SAPLINGS REQUIRED","saplings")
while true do
 -- HUB PHASE: hub.lua exclusively owns movement/orientation here.
 if not hub.fuelAtHub(260) then error("Need fuel") end
 if not hub.home() then error("Cannot reach wood bay") end

 -- FARM PHASE: hub.home() already left the physical turtle facing EAST.
 -- leaveHub() resets the farm state without turning it.
 leaveHub()

 local harvested=0
 for i=1,#trees do
  if not hub.fuelCheck(100) then
   print("Fuel reserve reached; returning to hub.")
   break
  end
  local sx,sz=serviceFor(trees[i])
  if not go(sx,sz,"east") then error("Farm route blocked") end
  local ok,d=turtle.inspect()
  if ok and d and isLog(d.name) then
   if harvestTree(trees[i]) then harvested=harvested+1 end
  end
  -- Replant missing/harvested position before moving on.
  if not prepareTree(trees[i]) then
   print("Tree "..i.." not ready; will retry.")
  end
 end

 if not go(4,0,"west") then error("Cannot leave farm") end
 enterHub()
 if harvested>0 then depositLogs() end
 hub.home()
 print("Farm cycle complete. Trees cut: "..harvested)
 sleep(WAIT)
end
