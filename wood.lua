-- Hub Wood Worker v1
-- V1 expects a simple tree lane immediately NORTH of the wood gate.
local hub=require("hub")
hub.setRole("wood")
local gate=hub.config.GATES.wood

local function isLog(n)
  return n=="minecraft:log" or n=="minecraft:oak_log" or n=="minecraft:spruce_log" or
         n=="minecraft:birch_log" or n=="minecraft:jungle_log"
end

print("Hub Wood Worker starting")
while true do
  hub.gotoPos(gate); hub.face("north")
  -- Tree trunk is one block outside the hub gate.
  local ok,d=turtle.inspect()
  if ok and d and isLog(d.name) then
    turtle.dig()
    if hub.forward(false) then
      -- Climb through trunk, harvesting logs above.
      while true do
        local u,ud=turtle.inspectUp()
        if not (u and ud and isLog(ud.name)) then break end
        turtle.digUp()
        if not hub.up(false) then break end
      end
      while hub.y>0 do hub.down(false) end
      hub.face("south"); hub.forward(false)
    end
  end
  hub.depositAll()
  hub.home()
  print("Wood cycle complete; waiting for next tree.")
  sleep(20)
end
