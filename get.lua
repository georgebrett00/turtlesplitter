-- get.lua - install/update complete turtle hub
local BASE = "https://raw.githubusercontent.com/georgebrett00/turtlesplitter/main/"

local files = {
    {"hub.lua", "hub.lua"},
    {"hubcfg.lua", "hubcfg.lua"},
    {"miner.lua", "miner.lua"},
    {"wood.lua", "wood.lua"},
    {"reeds.lua", "reeds.lua"},
    {"birth.lua", "birth.lua"},
    {"genesis.lua", "genesis.lua"},
}

print("TURTLE HUB INSTALLER")
print("--------------------")
print("Installing all hub programs...")

for i = 1, #files do
    local remote = files[i][1]
    local localName = files[i][2]
    write("[" .. i .. "/" .. #files .. "] " .. localName .. "... ")
    if fs.exists(localName) then
        fs.delete(localName)
    end
    local ok = shell.run("wget", BASE .. remote, localName)
    if not ok or not fs.exists(localName) then
        print("FAILED")
        error("Could not install " .. remote)
    end
    print("OK")
end

print("")
print("Install complete.")
