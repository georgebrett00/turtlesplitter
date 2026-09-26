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
local QUARRY_BACK_OFFSET = 4 -- shaft is 4 blocks behind original start (3 behind chest)
local constructionStarted = false
local quarryDepth = 0

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
        if turtle.detect() then
            local ok,d=turtle.inspect()
            if ok and d and isChestName(d.name) then
                error("Refusing to destroy protected chest")
            end
            turtle.dig()
        else turtle.attack() end
        sleep(0.1)
    end
    logForward()
end

local function digDownMove()
    while not turtle.down() do
        if turtle.detectDown() then
            local ok,d=turtle.inspectDown()
            if ok and d and isChestName(d.name) then
                error("Refusing to destroy protected chest")
            end
            turtle.digDown()
        else turtle.attackDown() end
        sleep(0.1)
    end
    y=y-1
end

local function up()
    while not turtle.up() do
        if turtle.detectUp() then
            local ok,d=turtle.inspectUp()
            if ok and d and isChestName(d.name) then
                error("Refusing to destroy protected chest")
            end
            turtle.digUp()
        else turtle.attackUp() end
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

local function isChestName(name)
    return name=="minecraft:chest" or name=="minecraft:trapped_chest"
end

local function safeForwardNoDig()
    while not turtle.forward() do
        if turtle.detect() then
            local ok,d=turtle.inspect()
            if ok and d and isChestName(d.name) then
                error("Protected depot chest blocks route; refusing to dig")
            end
            error("Protected surface/tower route blocked; refusing to dig")
        end
        turtle.attack()
        sleep(0.2)
    end
    logForward()
end

local function safeUpNoDig()
    while not turtle.up() do
        if turtle.detectUp() then
            local ok,d=turtle.inspectUp()
            if ok and d and isChestName(d.name) then
                error("Protected chest above; refusing to dig")
            end
            error("Protected tower/service route blocked above; refusing to dig")
        end
        turtle.attackUp()
        sleep(0.2)
    end
    y=y+1
end

local function safeDownNoDig()
    while not turtle.down() do
        if turtle.detectDown() then
            local ok,d=turtle.inspectDown()
            if ok and d and isChestName(d.name) then
                return false,"chest"
            end
            return false,"blocked"
        end
        turtle.attackDown()
        sleep(0.2)
    end
    y=y-1
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
    -- A detected block is not the same as a successfully placed building
    -- block. Clear whatever is occupying the target cell (grass, dirt,
    -- stone, etc.) and then place the selected construction material.
    if turtle.detectDown() then
        local ok, data = turtle.inspectDown()

        -- If the correct selected block is already there, leave it alone.
        local selected = turtle.getItemDetail(turtle.getSelectedSlot())
        if ok and data and selected and data.name == selected.name then
            return true
        end

        -- Otherwise remove the obstruction.
        if not turtle.digDown() then
            return false
        end
        sleep(0.1)
    end

    -- Retry briefly in case falling gravel/sand occupies the cell.
    for attempt=1,5 do
        if turtle.placeDown() then
            return true
        end
        if turtle.detectDown() then
            if not turtle.digDown() then
                return false
            end
        end
        sleep(0.1)
    end
    return false
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

local function scanExistingDepotCobble()
    -- A normal chest and a double chest both inspect as minecraft:chest.
    -- When this ComputerCraft version exposes the chest as an inventory
    -- peripheral, list() sees the ENTIRE inventory (27 or 54 slots).
    local oldFacing = facing
    face((startFacing + 2) % 4)

    if peripheral and peripheral.wrap then
        local chest = peripheral.wrap("front")
        if chest and chest.list then
            local total = 0
            local items = chest.list()
            for slot,item in pairs(items) do
                if item and item.name == COBBLE_NAME then
                    total = total + item.count
                end
            end
            face(oldFacing)
            return total
        end
    end

    -- Legacy fallback: rotate chest contents through the turtle. This is less
    -- elegant, but keeps compatibility with older ComputerCraft versions.
    local total = 0
    local held = {}

    for tries=1,16 do
        local empty = nil
        for s=1,16 do
            if turtle.getItemCount(s)==0 then
                empty=s
                break
            end
        end
        if not empty then break end

        turtle.select(empty)
        if not turtle.suck() then break end

        local d=turtle.getItemDetail(empty)
        if d then
            table.insert(held, empty)
            if d.name == COBBLE_NAME then
                total = total + d.count
            end
        end
    end

    for i=1,#held do
        turtle.select(held[i])
        turtle.drop()
    end

    face(oldFacing)
    turtle.select(1)
    return total
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

local function moveBehindNoDig(blocks)
    face((startFacing+2)%4)
    for i=1,blocks do safeForwardNoDig() end
end

local function moveForwardNoDig(blocks)
    face(startFacing)
    for i=1,blocks do safeForwardNoDig() end
end

local function goSurfaceStartToQuarry()
    -- Chest is 1 behind start; step around it using the turtle's right side.
    -- Route: right 1, back 4, left 1 => quarry entrance at offset 4 behind.
    face((startFacing+1)%4); safeForwardNoDig()
    face((startFacing+2)%4)
    for i=1,QUARRY_BACK_OFFSET do safeForwardNoDig() end
    face((startFacing+3)%4); safeForwardNoDig()
    face(startFacing)
end

local function goQuarryToSurfaceStart()
    -- Reverse the protected service-yard route.
    face((startFacing+1)%4); safeForwardNoDig()
    face(startFacing)
    for i=1,QUARRY_BACK_OFFSET do safeForwardNoDig() end
    face((startFacing+3)%4); safeForwardNoDig()
    face(startFacing)
end

local function descendQuarryToDepth(depth)
    while y > -depth do digDownMove() end
end

local function climbQuarryToSurface()
    while y < 0 do safeUpNoDig() end
end

local function mineCobble(target)
    print("Using protected quarry behind depot...")
    goSurfaceStartToQuarry()

    while quarryDepth<QUARRY_DEPTH do
        if not refuelIfNeeded() then
            climbQuarryToSurface()
            goQuarryToSurfaceStart()
            if not refuelFromDepot() then error("Not enough fuel in depot") end
            goSurfaceStartToQuarry()
            descendQuarryToDepth(quarryDepth)
        end

        digDownMove()
        quarryDepth=quarryDepth+1
        quarryLayer()
        returnAcrossLayer()
        cleanQuarryInventory()

        -- Return via the dedicated shaft and protected service route.
        climbQuarryToSurface()
        goQuarryToSurfaceStart()
        depositQuarryLoot()

        local stored=depotCobbleCount()
        print("Depot cobble: "..stored.." / "..target)
        if stored>=target then return end

        goSurfaceStartToQuarry()
        descendQuarryToDepth(quarryDepth)
    end

    climbQuarryToSurface()
    goQuarryToSurfaceStart()
end

local function doorwayCell(px,pz)
    -- Entrance is centered on the front (z=0) side of a 12x12 footprint.
    -- Two cells wide: x=5 and x=6 (0-indexed).
    return pz==0 and (px==5 or px==6)
end

local function perimeterCell(px,pz)
    return px==0 or pz==0 or px==TOWER_SIZE-1 or pz==TOWER_SIZE-1
end

-- Build a layer by walking ONLY around the 12x12 perimeter.
-- The old builder reused the quarry's serpentine 12x12 sweep, which made the
-- turtle zig-zag left/right across the whole footprint. Tower walls should
-- instead be traced as a square ring.
local function buildPerimeterLayer(placeFn, selector)
    -- Build relative to the turtle's ORIGINAL facing.
    -- The chest is behind the turtle, so the tower always extends FORWARD,
    -- away from the depot.
    local px, pz = 0, 0

    local function placeHere()
        if placeFn(px,pz) then
            if not selector() then return false, "Out of building material" end
            if not placeDownSelected() then return false, "Could not place block" end
        end
        return true
    end

    local function moveOne(dx,dz)
        digForwardMove()
        px = px + dx
        pz = pz + dz
    end

    -- FRONT EDGE: move to the turtle's right from the starting/front-left corner.
    face((startFacing + 1) % 4)
    for i=1,TOWER_SIZE-1 do
        local ok,err=placeHere()
        if not ok then return false,err end
        moveOne(1,0)
    end

    -- RIGHT EDGE: extend FORWARD, away from the chest.
    face(startFacing)
    for i=1,TOWER_SIZE-1 do
        local ok,err=placeHere()
        if not ok then return false,err end
        moveOne(0,1)
    end

    -- BACK EDGE.
    face((startFacing + 3) % 4)
    for i=1,TOWER_SIZE-1 do
        local ok,err=placeHere()
        if not ok then return false,err end
        moveOne(-1,0)
    end

    -- LEFT EDGE: return toward the front.
    face((startFacing + 2) % 4)
    for i=1,TOWER_SIZE-1 do
        local ok,err=placeHere()
        if not ok then return false,err end
        moveOne(0,-1)
    end

    local ok,err=placeHere()
    if not ok then return false,err end

    face(startFacing)
    return true
end

-- Solid ceiling/floor still needs a full 12x12 serpentine fill.
local function buildSolidLayer(selector)
    for row=0,TOWER_SIZE-1 do
        for col=0,TOWER_SIZE-1 do
            if not selector() then return false, "Out of building material" end
            if not placeDownSelected() then return false, "Could not place block" end
            if col<TOWER_SIZE-1 then digForwardMove() end
        end
        if row<TOWER_SIZE-1 then
            if row%2==0 then
                turnRight()
                digForwardMove()
                turnRight()
            else
                turnLeft()
                digForwardMove()
                turnLeft()
            end
        end
    end

    -- For even-sized grids the sweep ends on the opposite side at the same
    -- front/back coordinate. Return along that edge to the origin.
    turnRight()
    for i=1,TOWER_SIZE-1 do digForwardMove() end
    turnRight()
    face(startFacing)
    return true
end

local function floorRequirements(floor)
    local perimeter = TOWER_SIZE*4-4
    local wall = perimeter
    if floor == 1 then wall = wall - 2 end
    return wall + TOWER_SIZE*TOWER_SIZE, wall*2
end

local function clearInventoryToDepot()
    -- At depot: return construction materials/loot, but keep enough fuel.
    withDepotFacing(function()
        for slot=1,16 do
            local d=turtle.getItemDetail(slot)
            if d then
                local keep=false
                if d.name=="minecraft:coal" or d.name=="minecraft:charcoal" then
                    keep = turtle.getFuelLevel()=="unlimited" or turtle.getFuelLevel()<1000
                end
                if not keep then
                    turtle.select(slot)
                    turtle.drop()
                end
            end
        end
    end)
    turtle.select(1)
end

local function goToDepotFromTower()
    -- Builder always ends a layer/floor at the tower origin X/Z.
    -- Do NOT descend through the original starting cell: construction may now
    -- occupy it. Rise above the completed tower, move one block BACKWARD so
    -- we are directly over the depot chest, then descend onto the chest.
    face(startFacing)
    -- Move backward without digging into tower infrastructure.
    turnAround()
    safeForwardNoDig()
    turnAround()

    while true do
        local ok,data=turtle.inspectDown()
        if ok and data and (data.name=="minecraft:chest" or data.name=="minecraft:trapped_chest") then
            break
        end
        local moved,why=safeDownNoDig()
        if not moved then
            if why=="chest" then break end
            error("Could not descend safely to depot chest")
        end
    end

    -- We are now directly above the chest. Turn so the chest is below us;
    -- inventory access uses dropDown/suckDown here.
end

local function depotBelowTransfer(predicate, wanted)
    local got=0
    local rejected={}
    for tries=1,16 do
        if got>=wanted then break end
        local empty=nil
        for s=1,16 do
            if turtle.getItemCount(s)==0 then empty=s break end
        end
        if not empty then break end
        turtle.select(empty)
        if not turtle.suckDown(math.min(64,wanted-got)) then break end
        local d=turtle.getItemDetail(empty)
        if d and predicate(d.name) then
            got=got+d.count
        else
            table.insert(rejected,empty)
        end
    end
    for i=1,#rejected do
        turtle.select(rejected[i])
        turtle.dropDown()
    end
    turtle.select(1)
    return got
end

local function countDepotBelow(predicate)
    -- Prefer direct inventory access so every slot in a normal/double chest is
    -- visible without pulling unrelated stacks through the turtle.
    if peripheral and peripheral.wrap then
        local chest=peripheral.wrap("bottom")
        if chest and chest.list then
            local total=0
            local items=chest.list()
            for slot,item in pairs(items) do
                if item and predicate(item.name) then
                    total=total+item.count
                end
            end
            return total
        end
    end
    return nil
end

local function mineMoreCobbleFromDepot(requiredCobble)
    -- We are directly ABOVE the depot chest. Climb above the tower first,
    -- then use a protected outside route to the dedicated quarry shaft.
    print("Depot short of cobblestone; mining more safely...")

    local savedY=y
    local clearance=FLOOR_HEIGHT*TOWER_FLOORS+8
    while y<clearance do safeUpNoDig() end

    -- From over chest, sidestep right, travel 3 farther back to shaft, left.
    face((startFacing+1)%4); safeForwardNoDig()
    face((startFacing+2)%4)
    for i=1,QUARRY_BACK_OFFSET-1 do safeForwardNoDig() end
    face((startFacing+3)%4); safeForwardNoDig()

    -- Descend the known quarry shaft without digging through surface/tower.
    while y>0 do
        local moved=safeDownNoDig()
        if not moved then error("Protected route to quarry is blocked") end
    end
    descendQuarryToDepth(quarryDepth)

    -- Mine complete layers until enough new cobble is collected for the shortage.
    local gathered=0
    while quarryDepth<QUARRY_DEPTH and gathered<requiredCobble do
        digDownMove()
        quarryDepth=quarryDepth+1
        quarryLayer()
        returnAcrossLayer()
        cleanQuarryInventory()
        gathered=countCobble()
    end

    climbQuarryToSurface()

    -- Return to directly above depot using the reverse outside route.
    face((startFacing+1)%4); safeForwardNoDig()
    face(startFacing)
    for i=1,QUARRY_BACK_OFFSET-1 do safeForwardNoDig() end
    face((startFacing+3)%4); safeForwardNoDig()

    while y>savedY do
        local moved=safeDownNoDig()
        if not moved then break end
    end

    -- Chest is below. Deposit mined loot downward.
    cleanQuarryInventory()
    for slot=1,16 do
        local d=turtle.getItemDetail(slot)
        if d and isUsefulQuarryLoot(d.name) then
            turtle.select(slot)
            turtle.dropDown()
        end
    end
    turtle.select(1)
end

local function restockAtDepot(cobbleWanted, panesWanted)
    while true do
        -- Put construction leftovers back first, retaining fuel.
        for slot=1,16 do
            local d=turtle.getItemDetail(slot)
            if d and d.name~="minecraft:coal" and d.name~="minecraft:charcoal" then
                turtle.select(slot)
                turtle.dropDown()
            end
        end
        turtle.select(1)

        local paneAvailable=countDepotBelow(function(n) return PANE_NAMES[n]==true end)
        local cobbleAvailable=countDepotBelow(function(n) return n==COBBLE_NAME end)

        if paneAvailable and cobbleAvailable then
            print("Depot cobble: "..cobbleAvailable.." / "..cobbleWanted)
            print("Depot panes: "..paneAvailable.." / "..panesWanted)

            local missingPanes=math.max(0,panesWanted-paneAvailable)
            local missingCobble=math.max(0,cobbleWanted-cobbleAvailable)

            if missingPanes>0 then
                print("Waiting for depot supplies:")
                print("  "..missingPanes.." more glass panes")
                print("Add materials, then press Enter.")
                read()
            elseif missingCobble>0 then
                mineMoreCobbleFromDepot(missingCobble)
            else
                -- PANES FIRST so cobble can never consume their inventory space.
                local panes=depotBelowTransfer(function(n) return PANE_NAMES[n]==true end,panesWanted)
                local cobble=depotBelowTransfer(function(n) return n==COBBLE_NAME end,cobbleWanted)

                if panes>=panesWanted and cobble>=cobbleWanted then
                    if not refuelIfNeeded() then
                        depotBelowTransfer(function(n)
                            return n=="minecraft:coal" or n=="minecraft:charcoal"
                        end,16)
                        if not refuelIfNeeded() then
                            print("Add coal/charcoal to depot, then press Enter.")
                            read()
                        else
                            return
                        end
                    else
                        return
                    end
                else
                    -- This should be rare, but don't crash if the chest changed
                    -- while we were withdrawing.
                    print("Depot contents changed while loading; checking again.")
                end
            end
        else
            -- Older ComputerCraft fallback. Pull panes first; if insufficient,
            -- put them back and wait instead of terminating the program.
            local panes=depotBelowTransfer(function(n) return PANE_NAMES[n]==true end,panesWanted)
            if panes<panesWanted then
                local missing=panesWanted-panes
                for slot=1,16 do
                    local d=turtle.getItemDetail(slot)
                    if d and PANE_NAMES[d.name] then
                        turtle.select(slot)
                        turtle.dropDown()
                    end
                end
                print("Need at least "..missing.." more glass panes.")
                print("Add panes to depot, then press Enter.")
                read()
            else
                local cobble=depotBelowTransfer(function(n) return n==COBBLE_NAME end,cobbleWanted)
                if cobble<cobbleWanted then
                    print("Need at least "..(cobbleWanted-cobble).." more cobblestone.")
                    print("Add cobble to depot, then press Enter.")
                    read()
                else
                    return
                end
            end
        end
    end
end

local function returnFromDepotToTower(topY)
    -- From directly above the chest, rise above the tower, move FORWARD one
    -- block back over the tower origin, then descend to the saved build height.
    while y <= topY do safeUpNoDig() end
    face(startFacing)
    safeForwardNoDig()
    while y > topY do
        local moved=safeDownNoDig()
        if not moved then error("Could not return safely to tower build height") end
    end
    face(startFacing)
end

local function ensureFloorSupplies(floor)
    local needCobble,needPanes=floorRequirements(floor)
    if countCobble()>=needCobble and countPanes()>=needPanes then return end

    local buildY=y
    print("Restocking floor "..floor.." from depot...")
    goToDepotFromTower()
    restockAtDepot(needCobble,needPanes)
    returnFromDepotToTower(buildY)
end

local function buildFloor(floor)
    ensureFloorSupplies(floor)
    print("Building floor "..floor)

    -- Turtle stands one block above each layer and places downward.
    -- Bottom cobble perimeter. Ground floor leaves 2-wide doorway.
    local ok,err=buildPerimeterLayer(function(px,pz)
        return perimeterCell(px,pz) and not (floor==1 and doorwayCell(px,pz))
    end, selectCobble)
    if not ok then error(err) end
    up()

    -- First window layer.
    ok,err=buildPerimeterLayer(function(px,pz)
        return perimeterCell(px,pz) and not (floor==1 and doorwayCell(px,pz))
    end, selectPane)
    if not ok then error(err) end
    up()

    -- Second window layer.
    ok,err=buildPerimeterLayer(function(px,pz)
        return perimeterCell(px,pz) and not (floor==1 and doorwayCell(px,pz))
    end, selectPane)
    if not ok then error(err) end
    up()

    -- Cobblestone ring plus solid ceiling/floor for next module.
    ok,err=buildSolidLayer(selectCobble)
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
print("Place a chest or double chest directly BEHIND the turtle.")
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

storedCobble = scanExistingDepotCobble()
print("Existing depot cobble: "..storedCobble.." / "..cobbleNeeded)

if storedCobble < cobbleNeeded then
    mineCobble(cobbleNeeded)
else
    print("Depot already contains enough cobblestone; skipping quarry.")
end

returnToSurfaceDepot()

local storedCobble=depotCobbleCount()
if storedCobble<cobbleNeeded then
    error("Not enough cobblestone in depot: "..storedCobble.."/"..cobbleNeeded)
end

print("Materials ready. Building tower...")
constructionStarted = true
-- Construction now loads only one floor at a time. This guarantees inventory
-- space for panes and fuel instead of filling all 16 slots with cobblestone.
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

            print("Additional floors will automatically restock from the depot.")
            print("Make sure the depot contains the required panes/cobble/fuel.")
            for i=1,requested do
                buildFloor(floorsBuilt + 1)
                floorsBuilt = floorsBuilt + 1
            end
        end
    end
end

print("Initial tower complete.")
requestMoreFloors()
