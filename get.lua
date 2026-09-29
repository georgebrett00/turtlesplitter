-- get.lua - Turtle Hub installer
-- georgebrett00/turtlesplitter

local BASE = "https://raw.githubusercontent.com/georgebrett00/turtlesplitter/main/"

local function download(remote, localName)
    if fs.exists(localName) then fs.delete(localName) end
    print("Getting "..localName.."...")
    local ok, err = pcall(function()
        shell.run("wget", BASE..remote, localName)
    end)
    if not ok or not fs.exists(localName) then
        print("FAILED: "..localName)
        if err then print(tostring(err)) end
        return false
    end
    return true
end

local function install(files)
    for _, f in ipairs(files) do
        if not download(f[1], f[2]) then
            print("")
            print("Install stopped.")
            return false
        end
    end
    print("")
    print("Install complete.")
    return true
end

term.clear()
term.setCursorPos(1,1)
print("TURTLE HUB INSTALLER")
print("--------------------")
print("1. Miner")
print("2. Wood worker")
print("3. Reed worker")
print("4. Genesis")
print("5. Shared hub files")
print("")
write("> ")
local choice = read()

if choice == "1" then
    install({
        {"hub.lua","hub.lua"},
        {"hubcfg.lua","hubcfg.lua"},
        {"miner.lua","miner.lua"},
    })
elseif choice == "2" then
    install({
        {"hub.lua","hub.lua"},
        {"hubcfg.lua","hubcfg.lua"},
        {"wood.lua","wood.lua"},
    })
elseif choice == "3" then
    install({
        {"hub.lua","hub.lua"},
        {"hubcfg.lua","hubcfg.lua"},
        {"reeds.lua","reeds.lua"},
    })
elseif choice == "4" then
    -- Genesis needs all four support files locally because it writes them
    -- onto the newborn's floppy at the birth station.
    install({
        {"hub.lua","hub.lua"},
        {"hubcfg.lua","hubcfg.lua"},
        {"miner.lua","miner.lua"},
        {"birth.lua","birth.lua"},
        {"genesis.lua","genesis.lua"},
    })
elseif choice == "5" then
    install({
        {"hub.lua","hub.lua"},
        {"hubcfg.lua","hubcfg.lua"},
    })
else
    print("Unknown option.")
end
