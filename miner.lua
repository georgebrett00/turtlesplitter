-- Hub Miner v1
local hub=require("hub")
hub.setRole("miner1")
if not hub.ensureFuel(80) then error("Need fuel") end -- change to miner2 for second miner

local cfg=hub.config
local gate=cfg.GATES.mining
local DEPTH=54
local LENGTH=32

print("Hub Miner starting")
while true do
  if not hub.gotoPos(gate) then error("Cannot reach mining gate") end
  hub.face("north")
  if not hub.forward(false) then error("Mining gate exit blocked") end

  -- Outside hub: descend and mine a simple out-and-back branch.
  for i=1,DEPTH do if not hub.down(true) then error("Shaft blocked") end end
  hub.face("north")
  local moved=0
  for i=1,LENGTH do
    if not hub.forward(true) then break end
    moved=moved+1
    turtle.digUp(); turtle.digDown()
  end
  hub.face("south")
  for i=1,moved do if not hub.forward(false) then error("Return tunnel blocked") end end
  for i=1,DEPTH do if not hub.up(false) then error("Return shaft blocked") end end

  -- Re-enter protected hub without digging and bank the haul.
  hub.face("south")
  if not hub.forward(false) then error("Hub entrance blocked") end
  hub.depositAll({["minecraft:coal"]=true,["minecraft:charcoal"]=true})
  hub.home()
  sleep(2)
end
