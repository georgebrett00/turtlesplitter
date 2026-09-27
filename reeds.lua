-- Hub Reeds Worker v1
-- Build a cane row directly EAST of the reeds gate. The turtle patrols the
-- outside edge and harvests upper cane blocks only, leaving planted bases.
local hub=require("hub")
hub.setRole("reeds")
local gate=hub.config.GATES.reeds
local ROW=8

print("Hub Reeds Worker starting")
while true do
  hub.gotoPos(gate); hub.face("east")
  if not hub.forward(false) then error("Reed farm gate blocked") end

  -- Patrol along outside row. Cane should be on the turtle's LEFT (north).
  for i=1,ROW do
    hub.face("north")
    local ok,d=turtle.inspectUp()
    -- If farm geometry exposes upper cane above, harvest it. Also harvest
    -- a cane directly north only when there is cane below it (base survives).
    local f,fd=turtle.inspect()
    if f and fd and fd.name=="minecraft:reeds" then
      -- V1 farm should position worker level with the second cane segment.
      turtle.dig()
    end
    hub.face("east")
    if i<ROW then hub.forward(false) end
  end

  -- Return along same outside lane.
  hub.face("west")
  for i=2,ROW do hub.forward(false) end
  hub.face("west"); -- back toward gate is west from the external first square
  hub.forward(false)
  hub.depositAll()
  hub.home()
  print("Reed cycle complete.")
  sleep(20)
end
