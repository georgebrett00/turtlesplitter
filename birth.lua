-- birth.lua - safe newborn nursery controller
-- Starts ONLY at the hub birth station (2,0,2), facing NORTH.
-- It never digs, attacks, mines or replicates.

local hub=require("hub")
local cfg=require("hubcfg")

local function isMachine(d)
 if not d or not d.name then return false end
 return string.find(d.name,"computercraft:turtle",1,true)~=nil or
        string.find(d.name,"computercraft:computer",1,true)~=nil
end

term.clear();term.setCursorPos(1,1)
print("HUB NEWBORN")
print("-----------")
print("Safe nursery mode")
print("No digging / no attacking")

-- Parent deliberately places every newborn facing NORTH.
hub.setPosition(cfg.BIRTH_STATION.x,0,cfg.BIRTH_STATION.z,"north")
hub.role="birth"

-- Burn carried coal before attempting hub flight.
hub.burnCarriedFuel(120)

local parked=false
for i=1,#cfg.NURSERY do
 local p=cfg.NURSERY[i]
 print("Checking nursery "..i)

 -- Stop one block ABOVE the parking square so an existing parked turtle
 -- can be inspected without ever trying to enter/damage its block.
 if hub.gotoPos({x=p.x,y=1,z=p.z,facing="north"}) then
  local occupied,d=turtle.inspectDown()
  if not occupied then
   if turtle.down() then
    hub.setPosition(p.x,0,p.z,p.facing)
    hub.role="birth"
    parked=true
    print("Parked in nursery "..i)
    break
   end
  elseif isMachine(d) then
   print("Nursery "..i.." occupied")
  else
   print("Nursery "..i.." blocked by "..tostring(d and d.name))
  end
 end
end

if not parked then
 print("")
 print("NO NURSERY SPACE")
 print("Holding safely above hub.")
 print("Do not reboot/move me manually")
 while true do sleep(30) end
end

print("")
print("Awaiting role assignment.")
print("Newborn will NOT self-start")
print("mining or replication.")
while true do sleep(30) end
