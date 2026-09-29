-- get.lua - install/update complete turtle hub suite
local BASE="https://raw.githubusercontent.com/georgebrett00/turtlesplitter/main/"
local files={
 {"hub.lua","hub.lua"},
 {"hubcfg.lua","hubcfg.lua"},
 {"miner.lua","miner.lua"},
 {"wood.lua","wood.lua"},
 {"reeds.lua","reeds.lua"},
 {"birth.lua","birth.lua"},
 {"genesis.lua","genesis.lua"},
 {"workshop.lua","workshop.lua"},
}
print("Updating complete turtle hub suite...")
for i=1,#files do
 local remote=files[i][1]
 local localName=files[i][2]
 write("["..i.."/"..#files.."] "..localName.." ... ")
 if fs.exists(localName) then fs.delete(localName) end
 local ok=shell.run("wget",BASE..remote,localName)
 if ok and fs.exists(localName) then
  print("OK")
 else
  print("FAILED")
  error("Failed to download "..remote)
 end
end
print("")
print("All hub programs installed.")
