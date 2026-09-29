-- hub.lua v10 - nursery/birth-station support
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
function H.isProtected(x,y,z)
 if H.inside(x,y,z) then return true,"hub" end
 if cfg.PROTECTED_ZONES then
  for i=1,#cfg.PROTECTED_ZONES do
   local a=cfg.PROTECTED_ZONES[i]
   if x>=a.minX and x<=a.maxX and y>=a.minY and y<=a.maxY and z>=a.minZ and z<=a.maxZ then
    return true,a.name
   end
  end
 end
 return false,nil
end
local function blocked(x,z,tx,tz)
 local key=tostring(x)..","..tostring(z)

 -- Physical storage blocks are always walls.
 if cfg.CHEST_BLOCKS[key]==true then return true end

 -- Parking/birth squares are reserved lanes: never use another turtle's
 -- starting point as a shortcut. The route's own destination is allowed so
 -- a worker can return to its own bay when H.home() is called.
 if not (x==tx and z==tz) then
  if cfg.BIRTH_STATION and x==cfg.BIRTH_STATION.x and z==cfg.BIRTH_STATION.z then
   return true
  end

  if cfg.REPLICATOR_BAYS then
   for i=1,#cfg.REPLICATOR_BAYS do
    local b=cfg.REPLICATOR_BAYS[i]
    if x==b.x and z==b.z then return true end
   end
  end

  if cfg.BAYS then
   for _,b in pairs(cfg.BAYS) do
    if x==b.x and z==b.z then return true end
   end
  end
  if cfg.NURSERY then
   for i=1,#cfg.NURSERY do
    local b=cfg.NURSERY[i]
    if x==b.x and z==b.z then return true end
   end
  end
 end

 return false
end
function H.setRole(role)
 local b=cfg.BAYS[role]; if not b then error("Unknown role "..tostring(role)) end
 H.role=role; H.x=b.x; H.y=b.y; H.z=b.z; H.facing=b.facing; H.initialised=true

 -- Every hub worker calls setRole() at startup, so fuel checking belongs here.
 -- This makes zero-fuel handling automatic even for older worker programs.
 if H.ensureFuel and not H.ensureFuel(80) then
  error("Unable to obtain startup fuel")
 end
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
local function waitForward()
 local d=step[H.facing]; local nx,nz=H.x+d[1],H.z+d[2]
 for i=1,120 do
  if turtle.forward() then H.x=nx;H.z=nz;return true end
  -- Never dig/attack inside hub airspace. A turtle or entity can clear.
  sleep(.5)
 end
 print("HUB traffic timeout.")
 return false
end

local function waitUp()
 for i=1,120 do
  if turtle.up() then H.y=H.y+1;return true end
  sleep(.5)
 end
 print("HUB lift blocked.")
 return false
end

local function machineBelow()
 local ok,d=turtle.inspectDown()
 if not ok or not d or not d.name then return false end
 return string.find(d.name,"computercraft:turtle",1,true)~=nil or
        string.find(d.name,"computercraft:computer",1,true)~=nil
end

local function waitDown()
 for i=1,120 do
  if turtle.down() then H.y=H.y-1;return true end

  -- Vertical service shafts are shared. If a turtle is directly below us,
  -- yield UP one block instead of sitting on top of it. The lower turtle can
  -- then rise/leave; afterwards we return to our original height and retry.
  if machineBelow() and H.y<cfg.HUB.maxY then
   local oldY=H.y
   print("HUB turtle below - yielding UP")
   if turtle.up() then
    H.y=H.y+1
    local clear=0
    for w=1,120 do
     if not machineBelow() then
      clear=clear+1
      if clear>=2 then break end
     else
      clear=0
     end
     sleep(.25)
    end

    -- Return to the level where the conflict occurred. If another turtle is
    -- still there, remain yielded and retry rather than forcing the descent.
    for r=1,120 do
     if turtle.down() then
      H.y=oldY
      break
     end
     sleep(.25)
    end
   end
  else
   sleep(.5)
  end
 end
 print("HUB descent blocked.")
 return false
end

-- Elevated hub transport:
-- y=0 = bays/storage/service floor
-- y=1 = vertical access
-- y=2..8 = role-specific private transport decks.
-- miner1=2, miner2=3, miner3=4, miner4=5, wood=6, reeds=7, genesis=8.
-- Every journey rises at its CURRENT x,z, travels horizontally only on
-- its own deck, then descends at the destination. This removes horizontal
-- head-on/crossing collisions between worker roles.
-- Dedicated air deck per worker role. Opposing workers therefore never
-- share a horizontal flight level inside the hub.
local ROLE_Y={
 miner1=2,
 miner2=3,
 miner3=4,
 miner4=5,
 wood=6,
 reeds=7,
 genesis=8,
 birth=9,
}

local function travelY()
 return ROLE_Y[H.role] or 9
end

-- Shared storage uses one-way vertical traffic:
-- arrive by descending directly onto the service square, interact with the
-- chest, then leave horizontally to an adjacent departure square and climb
-- there. This prevents an ascending turtle meeting a descending turtle in
-- the same service shaft.
local SERVICE_EXIT={
 ["1,7"]={x=2,z=7}, -- WOOD
 ["5,7"]={x=6,z=7}, -- FUEL
 ["1,5"]={x=2,z=5}, -- STONE
 ["5,5"]={x=6,z=5}, -- ORES
 ["8,7"]={x=9,z=7}, -- REEDS/MISC
}

local function serviceExit()
 return SERVICE_EXIT[tostring(H.x)..","..tostring(H.z)]
end

local function horizontalRoute(tx,tz)
 local q={{H.x,H.z}};local head=1
 local seen={[H.x..","..H.z]=true};local prev={}
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
   if nx>=cfg.HUB.minX and nx<=cfg.HUB.maxX and
      nz>=cfg.HUB.minZ and nz<=cfg.HUB.maxZ and not seen[k] then
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

 -- If leaving a shared service square, DO NOT climb in the arrival shaft.
 -- Move one block to its dedicated departure square first, then climb there.
 local sx=serviceExit()
 if sx and H.y==0 and not (p.x==H.x and p.z==H.z and p.y==H.y) then
  local dx,dz=sx.x-H.x,sx.z-H.z
  if dx==1 then H.face("east")
  elseif dx==-1 then H.face("west")
  elseif dz==1 then H.face("south")
  elseif dz==-1 then H.face("north")
  else
   print("Bad HUB service exit configuration.")
   return false
  end
  if not waitForward() then
   print("HUB service departure blocked.")
   return false
  end
 end

 -- Rise to this worker's PRIVATE transport deck before moving sideways.
 -- Different roles never travel horizontally at the same height.
 local ty=travelY()
 while H.y<ty do if not waitUp() then return false end end
 while H.y>ty do if not waitDown() then return false end end

 local path=horizontalRoute(p.x,p.z)
 if not path then print("No HUB air route");return false end
 for i=1,#path do
  H.face(path[i])
  if not waitForward() then return false end
 end

 -- Descend vertically onto the requested service/bay level.
 while H.y>p.y do if not waitDown() then return false end end
 while H.y<p.y do if not waitUp() then return false end end
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


-- Shared fuel policy -------------------------------------------------------
-- Workers can call fuelCheck() anywhere.  It first burns carried coal and
-- returns false before the remaining fuel falls below the caller's estimated
-- safe return requirement.  Once back inside the hub, fuelAtHub() tops up
-- from the communal FUEL chest.
local ROLE_FUEL={
 miner1=320,miner2=320,miner3=320,miner4=320,
 wood=220,reeds=180,genesis=320,
}

function H.fuelLevel()
 local n=turtle.getFuelLevel()
 if n=="unlimited" then return 999999 end
 return n
end

function H.burnCarriedFuel(target)
 target=target or (ROLE_FUEL[H.role] or 160)
 if H.fuelLevel()>=target then return true end
 local old=turtle.getSelectedSlot()
 for s=1,16 do
  local d=turtle.getItemDetail(s)
  if d and (d.name=="minecraft:coal" or d.name=="minecraft:charcoal") then
   turtle.select(s)
   while turtle.getItemCount(s)>0 and H.fuelLevel()<target do
    if not turtle.refuel(1) then break end
   end
  end
 end
 turtle.select(old)
 return H.fuelLevel()>=target
end

function H.fuelCheck(returnNeed)
 returnNeed=returnNeed or (ROLE_FUEL[H.role] or 160)
 if H.fuelLevel()>=returnNeed then return true end
 H.burnCarriedFuel(returnNeed)
 if H.fuelLevel()>=returnNeed then return true end
 print("LOW FUEL: "..tostring(H.fuelLevel()).." / "..tostring(returnNeed))
 print("Return to hub for fuel.")
 return false
end

function H.fuelAtHub(target)
 target=target or (ROLE_FUEL[H.role] or 160)
 return H.ensureFuel(target)
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
