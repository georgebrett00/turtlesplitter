-- cobbletower.lua
-- Standalone ComputerCraft/CC:Tweaked turtle program.
--
-- Place the turtle on the surface, facing the side which should contain
-- the tower entrance. Give it fuel. It will mine an 8x8 quarry beneath
-- its starting point, return to the surface, and build a 12x12 modular tower.
--
-- BUILD SUPPLIES:
--   Cobblestone is mined automatically.
--   Glass panes must be supplied by the player before building windows.
--
-- Defaults can be changed below.
local QUARRY_SIZE = 8
local QUARRY_DEPTH = 24
local TOWER_SIZE = 12
local FLOOR_HEIGHT = 4          -- cobble sill, 2-high panes, cobble ring/ceiling
local TOWER_FLOORS = 3          -- change this to desired number of modules
local COBBLE_NAME = "minecraft:cobblestone"
local PANE_NAMES = {
    ["minecraft:glass_pane"] = true,
    ["minecraft:stained_glass_pane"] = true,
}

local startFacing = 0 -- 0=forward/north, 1=right/east, 2=back/south, 3=left/west
local x,y,z = 0,0,0
local facing = startFacing
local storedCobble = 0 -- cobble deposited by this run

local function turnRight()
    turtle.turnRight()
    facing = (facing + 1) % 4
end
local function turnLeft()
    turtle.turnLeft()
    facing = (facing + 3) % 4
end
local function turnAround()
    turnRight()
    turnRight()
end

local function logForward()
    if facing==0 then z=z-1
    elseif facing==1 then x=x+1
    elseif facing==2 then z=z+1
    else x=x-1 end
end
local function logBack()
    if facing==0 then z=z+1
    elseif facing==1 then x=x-1
    elseif facing==2 then z=z-1
    else x=x+1 end
end

local function digForwardMove()
    while not turtle.forward() do
        if turtle.detect() then turtle.dig() else turtle.attack() end
        sleep(0.1)
    end
    logForward()
end

local function digDownMove()
    while not turtle.down() do
        if turtle.detectDown() then turtle.digDown() else turtle.attackDown() end
        sleep(0.1)
    end
    y=y-1
end

local function up()
    while not turtle.up() do
        if turtle.detectUp() then turtle.digUp() else turtle.attackUp() end
        sleep(0.1)
    end
    y=y+1
end

local function back()
    if turtle.back() then
        logBack()
        return true
    end
    turnAround()
    digForwardMove()
    turnAround()
    return true
end

local function countItem(predicate)
    local n=0
    for i=1,16 do
        local d=turtle.getItemDetail(i)
        if d and predicate(d.name) then n=n+d.count end
    end
    return n
end

local function countCobble()
    return countItem(function(n) return n==COBBLE_NAME end)
end

local function countPanes()
    return countItem(function(n) return PANE_NAMES[n] == true end)
end

local function selectNamed(predicate)
    for i=1,16 do
        local d=turtle.getItemDetail(i)
        if d and predicate(d.name) then
            turtle.select(i)
            return true
        end
    end
    return false
end

local function selectCobble()
    return selectNamed(function(n) return n==COBBLE_NAME end)
end

local function selectPane()
    return selectNamed(function(n) return PANE_NAMES[n] == true end)
end

local function placeDownSelected()
    if turtle.detectDown() then return true end
    return turtle.placeDown()
end

local function refuelIfNeeded()
    if turtle.getFuelLevel()=="unlimited" then return true end
    if turtle.getFuelLevel() > 500 then return true end
    for i=1,16 do
        local d=turtle.getItemDetail(i)
        if d and (d.name=="minecraft:coal" or d.name=="minecraft:charcoal") then
            turtle.select(i)
            while turtle.getItemCount(i)>0 and turtle.getFuelLevel()<1500 do
                turtle.refuel(1)
            end
        end
    end
    return turtle.getFuelLevel()>200
end

local function isUsefulQuarryLoot(name)
    if name == COBBLE_NAME then return true end
    if name == "minecraft:coal" or name == "minecraft:charcoal" then return true end

    -- Keep ores and common valuable drops. Everything else found while
    -- quarrying (dirt, gravel, seeds, flowers, saplings, etc.) is waste.
    if string.find(name, "_ore") then return true end
    if name == "minecraft:diamond"
        or name == "minecraft:emerald"
        or name == "minecraft:redstone"
        or name == "minecraft:dye"
        or name == "minecraft:lapis_lazuli"
        or name == "minecraft:quartz" then
        return true
    end
    return false
end

local function cleanQuarryInventory()
    -- Throw away only low-value quarry waste. Cobble, ores, panes and fuel
    -- are retained until the turtle returns to the depot chest.
    for slot=1,16 do
        local d=turtle.getItemDetail(slot)
        if d and not isUsefulQuarryLoot(d.name) and not PANE_NAMES[d.name] then
            turtle.select(slot)
            turtle.drop()
        end
    end

    -- Merge identical retained stacks to maximise free inventory slots.
    for a=1,16 do
        local da=turtle.getItemDetail(a)
        if da then
            for b=a+1,16 do
                local db=turtle.getItemDetail(b)
                if db and db.name==da.name then
                    turtle.select(b)
                    turtle.transferTo(a)
                end
            end
        end
    end
    turtle.select(1)
end

local function inventoryFull()
    for i=1,16 do if turtle.getItemCount(i)==0 then return false end end
    return true
end

-- DEPOT CHEST
-- Place a chest immediately BEHIND the turtle's starting position.
-- It remains the permanent warehouse for cobblestone, panes, fuel and ores.
local function face(dir)
    while facing ~= dir do turnRight() end
end

local function atStartXZ()
    return x == 0 and z == 0
end

local function goToStartXZ()
    -- Quarry layers always return to x/z 0, but keep this as a safety route.
    while x ~= 0 do
        if x > 0 then face(3) else face(1) end
        digForwardMove()
    end
    while z ~= 0 do
        if z > 0 then face(0) else face(2) end
        digForwardMove()
    end
end

local function returnToSurfaceDepot()
    goToStartXZ()
    while y < 0 do up() end
    face(startFacing)
end

local function chestBehindPresent()
    face((startFacing + 2) % 4)
    local ok, d = turtle.inspect()
    face(startFacing)
    return ok and d and (d.name == "minecraft:chest" or d.name == "minecraft:trapped_chest")
end

local function withDepotFacing(fn)
    local old = facing
    face((startFacing + 2) % 4)
    local result = fn()
    face(old)
    return result
end

local function depositQuarryLoot()
    -- Warehouse cobble and valuable mining products only.
    -- Junk such as seeds, flowers, dirt and gravel is discarded forward
    -- before we turn toward the depot.
    cleanQuarryInventory()

    return withDepotFacing(function()
        for slot=1,16 do
            local d=turtle.getItemDetail(slot)
            if d then
                local keepFuel = false
                if d.name=="minecraft:coal" or d.name=="minecraft:charcoal" then
                    keepFuel = turtle.getFuelLevel() ~= "unlimited"
                        and turtle.getFuelLevel() < 800
                end

                if not keepFuel and isUsefulQuarryLoot(d.name) then
                    local amount = d.count
                    turtle.select(slot)
                    if turtle.drop() and d.name == COBBLE_NAME then
                        storedCobble = storedCobble + amount
                    end
                end
            end
        end
        turtle.select(1)
        return true
    end)
end

local function suckFromDepot(predicate, wanted)
    local got = 0
    local rejected = {}

    withDepotFacing(function()
        -- IMPORTANT: do not immediately put a rejected stack back in the chest.
        -- Doing that makes turtle.suck() repeatedly take the same first stack
        -- forever (for example 64 coal). Hold rejected stacks temporarily.
        for tries=1,16 do
            if got >= wanted then break end

            local empty=nil
            for s=1,16 do
                if turtle.getItemCount(s)==0 then
                    empty=s
                    break
                end
            end
            if not empty then break end

            turtle.select(empty)
            if not turtle.suck(math.min(64, wanted-got)) then break end

            local d=turtle.getItemDetail(empty)
            if d and predicate(d.name) then
                got = got + d.count
            else
                table.insert(rejected, empty)
            end
        end

        -- Now return non-matching supplies to the depot.
        for i=1,#rejected do
            turtle.select(rejected[i])
            turtle.drop()
        end
    end)

    turtle.select(1)
    return got
end

local function withdrawCobble(wanted)
    local got = suckFromDepot(function(n) return n==COBBLE_NAME end, wanted)
    storedCobble = math.max(0, storedCobble - got)
    return got
end

local function withdrawPanes(wanted)
    return suckFromDepot(function(n) return PANE_NAMES[n]==true end, wanted)
end

local function refuelFromDepot()
    if turtle.getFuelLevel()=="unlimited" or turtle.getFuelLevel()>=500 then return true end
    suckFromDepot(function(n) return n=="minecraft:coal" or n=="minecraft:charcoal" end, 16)
    return refuelIfNeeded()
end

local function depotCobbleCount()
    -- Count what THIS run has deposited instead of repeatedly sucking items
    -- out of the chest to inspect them. This avoids chest item ping-pong.
    return storedCobble
end


-- Quarry a single 8x8 layer in a serpentine pattern.
local function quarryLayer()
    for row=1,QUARRY_SIZE do
        for col=1,QUARRY_SIZE-1 do
            digForwardMove()
        end
        if row<QUARRY_SIZE then
            if row%2==1 then
                turnRight(); digForwardMove(); turnRight()
            else
                turnLeft(); digForwardMove(); turnLeft()
            end
        end
    end
end

local function returnAcrossLayer()
    -- With an even-width serpentine quarry (8x8), the turtle finishes on the
    -- opposite SIDE of the layer, not the diagonally opposite corner.
    --
    -- Starting at (0,0), the 8 rows finish at (7,0), facing backwards.
    -- Therefore only one 7-block edge traversal is needed to return to the
    -- layer origin. The previous version incorrectly travelled a second
    -- 7-block edge, which shifted every following quarry layer sideways.
    turnRight()
    for i=1,QUARRY_SIZE-1 do
        digForwardMove()
    end
    turnRight()
    -- We are now back at the exact X/Z layer origin and facing the same
    -- direction as when this quarry layer began.
end

local function mineCobble(target)
    print("Mining 8x8 cobblestone quarry...")
    local depth=0

    while depth<QUARRY_DEPTH do
        if not refuelIfNeeded() then
            returnToSurfaceDepot()
            if not refuelFromDepot() then error("Not enough fuel in turtle/depot") end
            while y > -depth do digDownMove() end
        end

        cleanQuarryInventory()

        -- If useful loot has filled the turtle, unload it and resume at the
        -- next quarry layer. Layers always finish back at the shaft origin.
        if inventoryFull() then
            returnToSurfaceDepot()
            depositQuarryLoot()
            local stored=depotCobbleCount()
            print("Depot cobble: "..stored.." / "..target)
            if stored>=target then return end
            while y > -depth do digDownMove() end
        end

        digDownMove()
        depth=depth+1
        quarryLayer()
        returnAcrossLayer()
        cleanQuarryInventory()

        -- Deposit after every layer. This makes the chest the source of truth
        -- and avoids the turtle's 16-slot capacity limiting tower size.
        returnToSurfaceDepot()
        depositQuarryLoot()
        local stored=depotCobbleCount()
        print("Depot cobble: "..stored.." / "..target)
        if stored>=target then return end

        -- Descend the already-open shaft to the current quarry depth.
        while y > -depth do digDownMove() end
    end

    returnToSurfaceDepot()
end

local function doorwayCell(px,pz)
    -- Entrance is centered on the front (z=0) side of a 12x12 footprint.
    -- Two cells wide: x=5 and x=6 (0-indexed).
    return pz==0 and (px==5 or px==6)
end

local function perimeterCell(px,pz)
    return px==0 or pz==0 or px==TOWER_SIZE-1 or pz==TOWER_SIZE-1
end

-- Walk every cell in a 12x12 layer, placing a block beneath where requested.
local function buildLayer(placeFn, selector)
    for row=0,TOWER_SIZE-1 do
        for col=0,TOWER_SIZE-1 do
            local px = (row%2==0) and col or (TOWER_SIZE-1-col)
            local pz = row
            if placeFn(px,pz) then
                if not selector() then return false, "Out of building material" end
                if not placeDownSelected() then return false, "Could not place block" end
            end
            if col<TOWER_SIZE-1 then digForwardMove() end
        end
        if row<TOWER_SIZE-1 then
            if row%2==0 then turnRight(); digForwardMove(); turnRight()
            else turnLeft(); digForwardMove(); turnLeft() end
        end
    end
    -- Return to footprint origin.
    turnRight()
    for i=1,TOWER_SIZE-1 do digForwardMove() end
    turnRight()
    for i=1,TOWER_SIZE-1 do digForwardMove() end
    turnAround()
    return true
end

local function buildFloor(floor)
    print("Building floor "..floor)

    -- Turtle stands one block above each layer and places downward.
    -- Bottom cobble perimeter. Ground floor leaves 2-wide doorway.
    local ok,err=buildLayer(function(px,pz)
        return perimeterCell(px,pz) and not (floor==1 and doorwayCell(px,pz))
    end, selectCobble)
    if not ok then error(err) end
    up()

    -- First window layer.
    ok,err=buildLayer(function(px,pz)
        return perimeterCell(px,pz) and not (floor==1 and doorwayCell(px,pz))
    end, selectPane)
    if not ok then error(err) end
    up()

    -- Second window layer.
    ok,err=buildLayer(function(px,pz)
        return perimeterCell(px,pz) and not (floor==1 and doorwayCell(px,pz))
    end, selectPane)
    if not ok then error(err) end
    up()

    -- Cobblestone ring plus solid ceiling/floor for next module.
    ok,err=buildLayer(function(px,pz) return true end, selectCobble)
    if not ok then error(err) end
    up()
end

local function requiredMaterials()
    local perimeter = TOWER_SIZE*4-4
    local doorway = 2
    local groundWall = perimeter-doorway
    local upperWall = perimeter

    -- Each module: bottom perimeter + two pane perimeter layers + solid ceiling.
    local cobble = groundWall + TOWER_SIZE*TOWER_SIZE
    local panes = groundWall*2
    if TOWER_FLOORS>1 then
        cobble = cobble + (TOWER_FLOORS-1)*(upperWall + TOWER_SIZE*TOWER_SIZE)
        panes = panes + (TOWER_FLOORS-1)*(upperWall*2)
    end
    return cobble,panes
end

local cobbleNeeded, panesNeeded = requiredMaterials()
print("COBBLE TOWER")
print("Floors: "..TOWER_FLOORS)
print("Cobble target: "..cobbleNeeded)
print("Glass panes required: "..panesNeeded)
print("Place a chest directly BEHIND the turtle.")
print("Put glass panes and extra fuel in that chest.")
print("The turtle will mine and warehouse its own cobblestone.")
print("Press Enter to begin.")
read()

if not chestBehindPresent() then
    error("No depot chest found directly behind starting position")
end
if not refuelIfNeeded() then
    if not refuelFromDepot() then error("Insufficient fuel") end
end

mineCobble(cobbleNeeded)
returnToSurfaceDepot()

local storedCobble=depotCobbleCount()
if storedCobble<cobbleNeeded then
    error("Not enough cobblestone in depot: "..storedCobble.."/"..cobbleNeeded)
end

-- Load an initial working batch. The builder will replenish at each floor.
withdrawCobble(cobbleNeeded)
withdrawPanes(panesNeeded)

print("Materials ready. Building tower...")
-- Move up one so layer 0 can be placed beneath without filling the quarry opening.
up()

local floorsBuilt = 0
for floor=1,TOWER_FLOORS do
    buildFloor(floor)
    floorsBuilt = floorsBuilt + 1
end

local function extraFloorRequirements(count)
    local perimeter = TOWER_SIZE*4-4
    local cobblePerFloor = perimeter + TOWER_SIZE*TOWER_SIZE
    local panesPerFloor = perimeter*2
    return cobblePerFloor*count, panesPerFloor*count
end

local function requestMoreFloors()
    while true do
        print("")
        print("Tower currently has "..floorsBuilt.." floor(s).")
        print("Add more floors? Enter number, or 0 to finish:")
        local requested = tonumber(read())

        if not requested then
            print("Please enter a number.")
        elseif requested <= 0 then
            print("Tower construction complete.")
            return
        else
            requested = math.floor(requested)
            local needCobble, needPanes = extraFloorRequirements(requested)

            print("Additional "..requested.." floor(s) require:")
            print("Cobblestone: "..needCobble)
            print("Glass panes: "..needPanes)

            -- At this point the turtle is parked at the tower's construction
            -- origin on top of the most recently completed ceiling. The player
            -- can add supplies directly to its inventory before continuing.
            print("Current cobble: "..countCobble())
            print("Current panes: "..countPanes())

            if countCobble() < needCobble or countPanes() < needPanes then
                print("Add the missing materials to the turtle.")
                print("Press Enter when ready, or type cancel.")
                local response = read()
                if string.lower(response or "") ~= "cancel" then
                    if countCobble() < needCobble then
                        print("Still short of cobblestone.")
                    elseif countPanes() < needPanes then
                        print("Still short of glass panes.")
                    else
                        for i=1,requested do
                            buildFloor(floorsBuilt + 1)
                            floorsBuilt = floorsBuilt + 1
                        end
                    end
                end
            else
                for i=1,requested do
                    buildFloor(floorsBuilt + 1)
                    floorsBuilt = floorsBuilt + 1
                end
            end
        end
    end
end

print("Initial tower complete.")
requestMoreFloors()
