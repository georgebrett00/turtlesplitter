-- hub.lua - protected hub navigation with obstacle-aware routing
local cfg=require("hubcfg")
local H={}
H.x,H.y,H.z=0,0,0
H.facing="north"; H.role=nil; H.initialised=false

local right={north="east",east="south",south="west",west="north"}
local left={north="west",west="south",south="east",east="north"}
local step={north={0,-1},south={0,1},east={1,0},west={-1,0}}

function H.inside(x,y,z)
 return x>=cfg.HUB.minX and x<=cfg.HUB.maxX and
        z>=cfg.HUB.minZ and z<=cfg.HUB.maxZ and
        y>=cfg.HUB.minY and y<=cfg.HUB.maxY
end
local function blocked(x,z)
 return cfg.CHEST_BLOCKS[tostring(x)..","..tostring(z)]==true
end
function H.setRole(role)
 local b=cfg.BAYS[role]; if not b then error("Unknown role "..tostring(role)) end
 H.role=role; H.x=b.x; H.y=b.y; H.z=b.z; H.facing=b.facing; H.initialised=true
end
function H.setPosition(x,y,z,f)
 H.x=x;H.y=y;H.z=z;H.facing=f or "north";H.initialised=true
end
function H.turnRight() turtle.turnRight();H.facing=right[H.facing] end
function H.turnLeft() turtle.turnLeft();H.facing=left[H.facing] end
function H.face(f)
 if H.facing==f then return end
 if right[H.facing]==f then H.turnRight()
 elseif left[H.facing]==f then H.turnLeft()
 else H.turnRight();H.turnRight() end
end
local function forwardNoDig()
 local d=step[H.facing]; local nx,nz=H.x+d[1],H.z+d[2]
 if blocked(nx,nz) then return false end
 if turtle.forward() then H.x=nx;H.z=nz;return true end
 if turtle.detect() then
  print("HUB PROTECTION: path blocked; no digging.")
  return false
 end
 print("HUB traffic: waiting...")
 for i=1,20 do
  sleep(.5)
  if turtle.forward() then H.x=nx;H.z=nz;return true end
 end
 return false
end

-- Breadth-first route across the 10x10 floor. Known chest squares are walls.
-- This replaces the old X-then-Z Manhattan movement.
local function route(tx,tz)
 local q={{H.x,H.z}}; local head=1
 local seen={[H.x..","..H.z]=true}; local prev={}
 local dirs={{0,-1,"north"},{1,0,"east"},{0,1,"south"},{-1,0,"west"}}
 while head<=#q do
  local p=q[head];head=head+1
  if p[1]==tx and p[2]==tz then
   local path={};local k=tx..","..tz
   while prev[k] do
    table.insert(path,1,prev[k].dir)
    k=prev[k].from
   end
   return path
  end
  for i=1,4 do
   local nx,nz=p[1]+dirs[i][1],p[2]+dirs[i][2]
   local k=nx..","..nz
   if nx>=0 and nx<=9 and nz>=0 and nz<=9 and
      not blocked(nx,nz) and not seen[k] then
    seen[k]=true
    prev[k]={from=p[1]..","..p[2],dir=dirs[i][3]}
    q[#q+1]={nx,nz}
   end
  end
 end
 return nil
end

function H.gotoPos(p)
 if not H.initialised then error("hub.setRole/setPosition first") end
 if H.y~=p.y then error("Hub floor routing expects y=0") end
 local path=route(p.x,p.z)
 if not path then print("No safe HUB route");return false end
 for i=1,#path do
  H.face(path[i])
  if not forwardNoDig() then return false end
 end
 if p.facing then H.face(p.facing) end
 return true
end
function H.home() return H.gotoPos(cfg.BAYS[H.role]) end
function H.ensureFuel(minimum)
 minimum=minimum or 40

 local function fuelLevel()
  return turtle.getFuelLevel()
 end

 local function tryInventoryFuel()
  for s=1,16 do
   local d=turtle.getItemDetail(s)
   if d and (d.name=="minecraft:coal" or d.name=="minecraft:charcoal") then
    turtle.select(s)
    while turtle.getItemCount(s)>0 do
     if not turtle.refuel(1) then break end
     if fuelLevel()>=minimum then return true end
    end
   end
  end
  return fuelLevel()>0
 end

 local level=fuelLevel()
 if level=="unlimited" then return true end
 if level>=minimum then return true end

 -- Use anything already carried first.
 tryInventoryFuel()
 level=fuelLevel()
 if level>=minimum then return true end

 -- A completely new turtle cannot travel to the fuel chest.
 -- Stay running and wait for the player to insert coal/charcoal.
 if level==0 then
  term.clear()
  term.setCursorPos(1,1)
  print("===================")
  print("   FUEL REQUIRED")
  print("===================")
  print("")
  print("Add coal/charcoal")
  print("to my inventory.")
  print("")
  print("Waiting for fuel...")

  while fuelLevel()==0 do
   tryInventoryFuel()
   if fuelLevel()==0 then sleep(1) end
  end

  print("")
  print("Fuel detected!")
  print("Fuel: "..fuelLevel())
  sleep(1)
 end

 -- Bootstrap fuel now exists. Travel to the central fuel chest and top up.
 local fuel=cfg.STORAGE.fuel
 if not fuel then
  print("HUB: fuel chest not configured")
  return fuelLevel()>=minimum
 end

 if fuelLevel()<minimum then
  print("Going to FUEL chest...")
  if not H.gotoPos(fuel) then
   print("Could not reach FUEL chest.")
   return false
  end

  -- Pull one item at a time. Non-fuel items are returned immediately.
  while fuelLevel()<minimum do
   local slot=nil
   for i=1,16 do
    if turtle.getItemCount(i)==0 then slot=i break end
   end
   if not slot then
    print("No free inventory slot for fuel.")
    return false
   end

   turtle.select(slot)
   if not turtle.suck(1) then
    print("FUEL CHEST EMPTY")
    print("Add coal/charcoal")
    print("to the FUEL chest.")
    return false
   end

   local d=turtle.getItemDetail(slot)
   if d and (d.name=="minecraft:coal" or d.name=="minecraft:charcoal") then
    turtle.refuel(1)
   else
    turtle.drop()
   end
  end
 end

 print("Fuel OK: "..fuelLevel())
 return true
end

local function canon(n)
 if n=="minecraft:oak_log" or n=="minecraft:spruce_log" or
    n=="minecraft:birch_log" or n=="minecraft:jungle_log" then return "minecraft:log" end
 return n
end
function H.count(name)
 local n=0
 for s=1,16 do local d=turtle.getItemDetail(s)
  if d and canon(d.name)==canon(name) then n=n+d.count end end
 return n
end
local function empty()
 for s=1,16 do if turtle.getItemCount(s)==0 then return s end end
end
function H.withdraw(name,count,bank)
 bank=bank or cfg.ITEM_BANK[name] or "misc"
 local st=cfg.STORAGE[bank]
 if not st then
  print("HUB: no "..bank.." chest configured yet.")
  return 0
 end
 if not H.gotoPos(st) then return 0 end
 local before=H.count(name)
 for tries=1,54 do
  if H.count(name)>=before+count then break end
  local s=empty();if not s then break end
  turtle.select(s)
  if not turtle.suck() then break end
  local d=turtle.getItemDetail(s)
  if not d or canon(d.name)~=canon(name) then turtle.drop() end
 end
 local got=H.count(name)-before
 print("HUB "..bank..": got "..got.." "..name)
 return got
end
function H.depositSlot(s)
 local d=turtle.getItemDetail(s);if not d then return true end
 local bank=cfg.ITEM_BANK[d.name] or cfg.ITEM_BANK[canon(d.name)] or "misc"
 local st=cfg.STORAGE[bank]
 if not st then return true end -- retain until that bank exists
 if not H.gotoPos(st) then return false end
 turtle.select(s);return turtle.drop()
end
function H.depositAll(keep)
 keep=keep or {}
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and not keep[d.name] and not keep[canon(d.name)] then
   if not H.depositSlot(s) then return false end
  end
 end
 return true
end
function H.provision(req)
 local missing={}
 print("Checking HUB resources...")
 for name,count in pairs(req) do
  local have=H.count(name)
  if have<count then H.withdraw(name,count-have);have=H.count(name) end
  print(" "..name..": "..have.." / "..count)
  if have<count then missing[name]=count-have end
 end
 return missing
end
H.config=cfg
return H
