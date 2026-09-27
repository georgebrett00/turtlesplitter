-- get.lua
-- One-file installer/updater for georgebrett00/turtlesplitter
-- Old ComputerCraft / CraftOS friendly.
local BASE="https://raw.githubusercontent.com/georgebrett00/turtlesplitter/main/"

local files={
  {"hub.lua","hub.lua"},
  {"hubcfg.lua","hubcfg.lua"},
  {"hubtest.lua","hubtest.lua"},
  {"hubbuild.lua","hubbuild.lua"},
  {"miner.lua","miner.lua"},
  {"wood.lua","wood.lua"},
  {"reeds.lua","reeds.lua"},

  -- Existing larger programs, installed under short local names:
  {"turtlogenesis_survival_recovery_reed_farm.lua","split.lua"},
  {"cobbletower_selector_scope_fixed.lua","tower.lua"},
}

local function download(remote,localName)
  print("Getting "..localName.."...")
  if fs.exists(localName) then fs.delete(localName) end
  local ok=shell.run("wget",BASE..remote,localName)
  if not ok or not fs.exists(localName) then
    print("FAILED: "..localName)
    return false
  end
  return true
end

term.clear()
term.setCursorPos(1,1)
print("TURTLE INSTALLER")
print("----------------")
print("Installs/updates:")
print("hub, hubcfg, test")
print("hubbuild, miner")
print("wood, reeds")
print("split, tower")
print("")
write("Type GET: ")
if read()~="GET" then print("Cancelled"); return end

local good=0
for i=1,#files do
  if download(files[i][1],files[i][2]) then good=good+1 end
end

print("")
print("DONE: "..good.."/"..#files)
print("")
print("Run programs with:")
print("hubtest")
print("hubbuild")
print("miner")
print("wood")
print("reeds")
print("split")
print("tower")
