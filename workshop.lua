-- workshop.lua - validate permanent Genesis workshop
-- Existing hub origin stays unchanged. This checks the west extension only.
local hub=require("hub")
local cfg=require("hubcfg")

hub.setRole("genesis")
print("Checking Genesis workshop...")
if not hub.gotoPos(cfg.GENESIS_WORKSHOP.station) then
 error("Cannot reach Genesis workshop station")
end

hub.face("west")
local ok,d=turtle.inspect()
if not ok or not d or d.name~="minecraft:chest" then
 error("Missing permanent chest at (-3,0,5)")
end

local expected={
 {dx=0,label="middle"},
}
-- From station (-2,0,5), the middle furnace is up+west. Check it by rising.
if not turtle.up() then error("Workshop air above station is blocked") end
hub.setPosition(-2,1,5,"west")
local fok,fd=turtle.inspect()
if not fok or not fd or fd.name~="minecraft:furnace" then
 print("WARNING: middle furnace missing at (-3,1,5)")
else
 print("Middle furnace OK")
end
turtle.down()
hub.setPosition(-2,0,5,"west")

print("Permanent chest OK")
print("Workshop route OK")
print("Also place furnaces at:")
print(" (-3,1,4)")
print(" (-3,1,5)")
print(" (-3,1,6)")
print("Genesis station: (-2,0,5), facing WEST")
