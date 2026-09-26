-- MerlinLikeTheWizard

TITLE = {
    '  ##### ## ## ##### ##### ###   #####',
    '  ##### ## ## ##### ##### ###   #####',
    '   ###  ## ## ## ##  ###  ###   ## ##',
    '   ###  ##### ####   ###  ##### #####',
    '   ###  ##### ## ##  ###  ##### #####',
    '',
    '##### ##### #  ## ##### ##### ### #####',
    '##### ##    ## ## ##    ##        ##',
    '##    ####  ##### ####  ##### ### #####',
    '## ## ##    ## ## ##       ## ###    ##',
    '##### ##### ##  # ##### ##### ### #####',
}

-------------------------------------------+

VEIN_MAX = 64
FUEL_BAR = 20
START_FUEL = 640
TRAVEL_FUEL = 1280
TRAVEL_FUEL_MIN = 400
HOUSEKEEP_FREQUENCY = 10

-------------------------------------------+

local pretty = require "cc.pretty"
pprint = pretty.pretty_print

CRAFTING_SLOTS = {1, 2, 3, 5, 6, 7, 9, 10, 11}
NON_CRAFTING_SLOTS = {4, 8, 12, 13, 14, 15, 16}

CRAFTING_RECIPES = {
    ['minecraft:crafting_table'] = {
        'planks', 'planks', nil,
        'planks', 'planks', 
    },
    ['minecraft:stick'] = {
        'planks', nil, nil,
        'planks', 
    },
    ['minecraft:furnace'] = {
        'minecraft:cobblestone', 'minecraft:cobblestone', 'minecraft:cobblestone',
        'minecraft:cobblestone',                     nil, 'minecraft:cobblestone',
        'minecraft:cobblestone', 'minecraft:cobblestone', 'minecraft:cobblestone',
    },
    ['minecraft:chest'] = {
        'planks', 'planks', 'planks', 
        'planks',      nil, 'planks', 
        'planks', 'planks', 'planks', 
    },
    ['minecraft:diamond_pickaxe'] = {
        'minecraft:diamond', 'minecraft:diamond', 'minecraft:diamond',
                        nil,   'minecraft:stick',                 nil,
                        nil,   'minecraft:stick',
    },
    ['minecraft:glass_pane'] = {
        'minecraft:glass', 'minecraft:glass', 'minecraft:glass', 
        'minecraft:glass', 'minecraft:glass', 'minecraft:glass',
    },
    ['minecraft:paper'] = {
        'minecraft:reeds', 'minecraft:reeds', 'minecraft:reeds',
    },
    ['computercraft:disk_drive'] = {
        'minecraft:stone',    'minecraft:stone', 'minecraft:stone', 
        'minecraft:stone', 'minecraft:redstone', 'minecraft:stone', 
        'minecraft:stone', 'minecraft:redstone', 'minecraft:stone', 
    },
    ['computercraft:turtle_expanded'] = {
        'minecraft:iron_ingot',          'minecraft:iron_ingot', 'minecraft:iron_ingot', 
        'minecraft:iron_ingot', 'computercraft:computer_normal', 'minecraft:iron_ingot',  
        'minecraft:iron_ingot',               'minecraft:chest', 'minecraft:iron_ingot', 
    },
    ['computercraft:computer_normal'] = {
        'minecraft:stone',      'minecraft:stone', 'minecraft:stone', 
        'minecraft:stone',   'minecraft:redstone', 'minecraft:stone', 
        'minecraft:stone', 'minecraft:glass_pane', 'minecraft:stone', 
    },
    ['computercraft:disk'] = {
        'minecraft:paper', 'minecraft:redstone',
    },
    ['mining_crafty_turtle'] = {
        'minecraft:diamond_pickaxe', 'computercraft:turtle_expanded', 'minecraft:crafting_table',
    },
    ['planks'] = {
        'log'
    }
}

CRAFTING_TREE = {
    ['computercraft:turtle_expanded'] = {count = 1, components = {
        ['computercraft:computer_normal'] = {count = 1, components = {
            ['minecraft:stone'] = {count = 7, components = {
                ['minecraft:cobblestone'] = {count = 1, subterranean = true},
            }},
            ['minecraft:redstone'] = {count = 1, components = {
                ['minecraft:redstone_ore'] = {count = 1, subterranean = true},
            }},
            ['minecraft:glass_pane'] = {count = 1, components = {
                ['minecraft:glass'] = {count = 6, components = {
                    ['minecraft:sand'] = {count = 1, subterranean = false},
                }},
            }},
        }},
        ['minecraft:iron_ingot'] = {count = 7, components = {
            ['minecraft:raw_iron'] = {count = 1, components = {
                ['minecraft:iron_ore'] = {count = 1, subterranean = true},
            }},
        }},
        ['minecraft:chest'] = {count = 1, components = {
            ['planks'] = {count = 8, components = {
                ['log'] = {count = 0.25, subterranean = false},
            }},
        }},
    }},
    ['minecraft:diamond_pickaxe'] = {count = 1, components = {
        ['minecraft:diamond'] = {count = 3, components = {
            ['minecraft:diamond_ore'] = {count = 1, subterranean = true},
        }},
        ['minecraft:stick'] = {count = 2, components = {
            ['planks'] = {count = 1, components = {
                ['log'] = {count = 0.25, subterranean = false},
            }},
        }},
    }},
    ['minecraft:crafting_table'] = {count = 1, components = {
        ['planks'] = {count = 4, components = {
            ['log'] = {count = 0.25, subterranean = false},
        }},
    }},
    ['computercraft:disk_drive'] = {count = 1, components = {
        ['minecraft:stone'] = {count = 7, components = {
            ['minecraft:cobblestone'] = {count = 1, subterranean = true},
        }},
        ['minecraft:redstone'] = {count = 2, components = {
            ['minecraft:redstone_ore'] = {count = 1, subterranean = true},
        }},
    }},
    ['computercraft:disk'] = {count = 1, components = {
        ['minecraft:redstone'] = {count = 1, components = {
            ['minecraft:redstone_ore'] = {count = 1, subterranean = true},
        }},
        ['minecraft:paper'] = {count = 1, components = {
            ['minecraft:dirt'] = {count = 1, subterranean = false},
            ['minecraft:reeds'] = {count = 1, subterranean = false},
        }},
    }},
    -- Includes one additional chest reserved for the newborn child.
    ['minecraft:chest'] = {count = 3, components = {
        ['planks'] = {count = 8, components = {
            ['log'] = {count = 0.25, subterranean = false},
        }},
    }},
    ['minecraft:furnace'] = {count = 3, components = {
        ['minecraft:cobblestone'] = {count = 8, subterranean = true},
    }},
    -- 16 for this genesis + 8 reserved as the newborn child's startup fuel.
    ['minecraft:coal'] = {count = 24, components = {
        ['minecraft:coal_ore'] = {count = 1, subterranean = true},
    }},

    -- Bootstrap reserve handed directly to the newborn. Keeping it in the
    -- resource tree prevents genesis from starting until it is available.
    ['minecraft:reeds'] = {count = 5, subterranean = false},
}

ORE_PRIORITY = {
    'minecraft:diamond_ore',
    'minecraft:redstone_ore',
    'minecraft:iron_ore',
    'minecraft:coal_ore',
    'minecraft:cobblestone'
}

ORE_DEPTH = {
    ['minecraft:diamond_ore'] = -57,
    ['minecraft:redstone_ore'] = -57,
    ['minecraft:iron_ore'] = 15,
    ['minecraft:coal_ore'] = 30,
    ['minecraft:cobblestone'] = 15
}

ORE_ITEMS = {
    ['minecraft:deepslate_diamond_ore'] = 'minecraft:diamond_ore',
    ['minecraft:deepslate_redstone_ore'] = 'minecraft:redstone_ore',
    ['minecraft:deepslate_iron_ore'] = 'minecraft:iron_ore',
    ['minecraft:deepslate_coal_ore'] = 'minecraft:coal_ore',
    ['minecraft:deepslate_cobblestone'] = 'minecraft:cobblestone'
}

NEEDED_ITEMS = {}
function flattenTree(tree, items)
    for item_name, item_details in pairs(tree) do
        items[item_name] = true
        if item_details.components then
            flattenTree(item_details.components, items)
        end
    end
end
flattenTree(CRAFTING_TREE, NEEDED_ITEMS)

LOG_ITEMS = {
    ['minecraft:log'] = true,
    ['minecraft:oak_log'] = true,
    ['minecraft:spruce_log'] = true,
    ['minecraft:birch_log'] = true,
    ['minecraft:jungle_log'] = true,
    ['minecraft:acacia_log'] = true,
    ['minecraft:dark_oak_log'] = true,
}

PLANKS_ITEMS = {
    -- Legacy Minecraft/modpack item ID. This world also uses minecraft:log
    -- and minecraft:reeds, so wooden planks may use the old generic ID.
    ['minecraft:planks'] = true,
    ['minecraft:oak_planks'] = true,
    ['minecraft:spruce_planks'] = true,
    ['minecraft:birch_planks'] = true,
    ['minecraft:jungle_planks'] = true,
    ['minecraft:acacia_planks'] = true,
    ['minecraft:dark_oak_planks'] = true,
}

LEAVES_ITEMS = {
    ['minecraft:oak_leaves'] = true,
    ['minecraft:spruce_leaves'] = true,
    ['minecraft:birch_leaves'] = true,
    ['minecraft:jungle_leaves'] = true,
    ['minecraft:acacia_leaves'] = true,
    ['minecraft:dark_oak_leaves'] = true,
}

BUMPS = {
    north = { 0,  0, -1},
    south = { 0,  0,  1},
    east  = { 1,  0,  0},
    west  = {-1,  0,  0},
}

LEFT_SHIFT = {
    north = 'west',
    south = 'east',
    east  = 'north',
    west  = 'south',
}

RIGHT_SHIFT = {
    north = 'east',
    south = 'west',
    east  = 'south',
    west  = 'north',
}

REVERSE_SHIFT = {
    north = 'south',
    south = 'north',
    east  = 'west',
    west  = 'east',
}

MOVE = {
    forward = turtle.forward,
    up      = turtle.up,
    down    = turtle.down,
    back    = turtle.back,
    left    = turtle.turnLeft,
    right   = turtle.turnRight
}

DETECT = {
    forward = turtle.detect,
    up      = turtle.detectUp,
    down    = turtle.detectDown
}

INSPECT = {
    forward = turtle.inspect,
    up      = turtle.inspectUp,
    down    = turtle.inspectDown
}

DIG = {
    forward = turtle.dig,
    up      = turtle.digUp,
    down    = turtle.digDown
}

PLACE = {
    forward = turtle.place,
    up      = turtle.placeUp,
    down    = turtle.placeDown
}

ATTACK = {
    forward = turtle.attack,
    up      = turtle.attackUp,
    down    = turtle.attackDown
}

VOWELS = {
    'a', 'a', 'a', 'a', 'a',
    'e', 'e', 'e', 'e', 'e', 'e',
    'i', 'i', 'i',
    'o', 'o', 'o',
    'u', 'u',
    'y',
}
CONSONANTS = {
    'b', 'b', 'b', 'b', 'b', 'b', 'b',
    'c', 'c', 'c', 'c', 'c', 'c', 'c',
    'd', 'd', 'd', 'd', 'd',
    'f', 'f', 'f', 'f', 'f',
    'g', 'g', 'g', 'g',
    'h', 'h', 'h',
    'j',
    'k', 'k',
    'l', 'l', 'l', 'l', 'l',
    'm', 'm', 'm', 'm', 'm', 'm', 'm',
    'n', 'n', 'n', 'n', 'n', 'n', 'n',
    'p', 'p', 'p', 'p', 'p',
    'r', 'r', 'r', 'r', 'r', 'r', 'r',
    's', 's', 's', 's', 's', 's', 's', 's', 's',
    't', 't', 't', 't', 't', 't', 't',
    'v',
    'w',
    'x',
    'y',
    'z', 'z', 'z',
}
DOUBLES = {
    'bl', 'br', 'bw', 
    'cr', 'cl',
    'dr', 'dw',
    'fr', 'fl', 'fw',
    'gr', 'gl', 'gw', 'gh',
    'kr', 'kl', 'kw',
    'mw',
    'ng',
    'pr', 'pl',
    'qu',
    'sr', 'sl', 'sw', 'st', 'sh',
    'tr', 'tl', 'tw', 'th',
    'vr', 'vl',
    'wr',
}
CONS_DOUB = {}
for _, c in pairs(CONSONANTS) do
    table.insert(CONS_DOUB, c)
end
for _, c in pairs(DOUBLES) do
    table.insert(CONS_DOUB, c)
end


function genRandName()
    local name = ''
    local count = math.random(3, 6)

    for i = 0, count - 1 do
        if i % 2 == 1 then
            name = name .. VOWELS[math.random(#VOWELS)]
        else
            if (i == count-1) then
                name = name .. CONSONANTS[math.random(#CONSONANTS)]
            else
                name = name .. CONS_DOUB[math.random(#CONS_DOUB)]
            end
        end
    end

    return string.upper(name:sub(1, 1)) .. name:sub(2, -1)
end


function nameTurtle()
    if not os.getComputerLabel() then
        os.setComputerLabel(genRandName())
    end
end


-- Autonomous mining worker configuration
AUTONOMOUS_MINING = true
MINER_MIN_FUEL = 200
MINER_MAX_FUEL = 1000
MINER_RETURN_FUEL = 250
MINER_MAX_INVENTORY_SLOTS = 14
MINER_TUNNEL_LENGTH = 32
MINER_DEPTH = -58
REPLICATION_MINING_DEPTH = -54 -- stay underground while gathering replication ores
MINER_BRANCH_SPACING = 3
MINER_MAX_RUNS = 0 -- 0 = run forever
HOME_TRAVEL_DEPTH = -54
HOME_DETOUR_MAX = 48
HOME_DETOUR_STEP = 4

-- Blocks the worker treats as valuable when encountered.
MINER_ORES = {
    ['minecraft:coal_ore'] = true,
    ['minecraft:deepslate_coal_ore'] = true,
    ['minecraft:iron_ore'] = true,
    ['minecraft:deepslate_iron_ore'] = true,
    ['minecraft:copper_ore'] = true,
    ['minecraft:deepslate_copper_ore'] = true,
    ['minecraft:gold_ore'] = true,
    ['minecraft:deepslate_gold_ore'] = true,
    ['minecraft:redstone_ore'] = true,
    ['minecraft:deepslate_redstone_ore'] = true,
    ['minecraft:lapis_ore'] = true,
    ['minecraft:deepslate_lapis_ore'] = true,
    ['minecraft:diamond_ore'] = true,
    ['minecraft:deepslate_diamond_ore'] = true,
    ['minecraft:emerald_ore'] = true,
    ['minecraft:deepslate_emerald_ore'] = true,
    ['minecraft:ancient_debris'] = true,
}

function minerInventoryFull()
    local empty = 0
    for slot = 1, 16 do
        if turtle.getItemCount(slot) == 0 then empty = empty + 1 end
    end
    return empty <= (16 - MINER_MAX_INVENTORY_SLOTS)
end

function minerRefuel()
    if turtle.getFuelLevel() >= MINER_MIN_FUEL then return true end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and (item.name == 'minecraft:coal' or item.name == 'minecraft:charcoal') then
            turtle.select(slot)
            turtle.refuel()
            if turtle.getFuelLevel() >= MINER_MIN_FUEL then
                turtle.select(1)
                return true
            end
        end
    end

    turtle.select(1)
    return turtle.getFuelLevel() >= MINER_MIN_FUEL
end

function minerDig(direction)
    local inspect = INSPECT[direction]
    local dig = DIG[direction]
    if inspect and dig then
        local ok, block = inspect()
        if ok and block and block.name then
            dig()
        end
    end
end

function minerCollectOre(direction)
    local inspect = INSPECT[direction]
    if not inspect then return false end
    local ok, block = inspect()
    if not ok or not block or not block.name then return false end

    if MINER_ORES[block.name] then
        minerDig(direction)
        return true
    end
    return false
end

function minerStripBranch()
    -- Mine a straight branch and expose the blocks around it.
    for i = 1, MINER_TUNNEL_LENGTH do
        if minerInventoryFull() then return false end
        if turtle.getFuelLevel() < MINER_RETURN_FUEL then return false end

        if not safeTunnelForward() then
            if not turtle.detect() then
                print('Mining path occupied; waiting before retrying...')
                local resumed = false
                for retry=1,6 do
                    sleep(2)
                    if safeTunnelForward() then
                        resumed = true
                        break
                    end
                end
                if not resumed then
                    print('Path remained occupied; ending this branch safely.')
                    return false
                end
            else
                print('Protected/impassable block in mining branch; abandoning branch.')
                return false
            end
        end

        minerCollectOre('up')
        minerCollectOre('down')
        minerCollectOre('left')
        minerCollectOre('right')
    end
    return true
end

function minerMoveToCoordinate(target)
    -- Return to a known coordinate using deterministic movement.
    -- This intentionally does not use fastestRoute(), because the worker
    -- does not have a complete map of the world.
    local function move_axis(direction, distance)
        for i = 1, math.abs(distance) do
            if turtle.getFuelLevel() < MINER_RETURN_FUEL then
                return false
            end
            if not go(direction) then
                return false
            end
        end
        return true
    end

    local dx = target.x - location.x
    local dy = target.y - location.y
    local dz = target.z - location.z

    -- Move vertically first, then north/south, then east/west.
    if dy > 0 then
        if not move_axis('up', dy) then return false end
    elseif dy < 0 then
        if not move_axis('down', -dy) then return false end
    end

    if dz < 0 then
        if not face('north') then return false end
        if not move_axis('forward', -dz) then return false end
    elseif dz > 0 then
        if not face('south') then return false end
        if not move_axis('forward', dz) then return false end
    end

    if dx > 0 then
        if not face('east') then return false end
        if not move_axis('forward', dx) then return false end
    elseif dx < 0 then
        if not face('west') then return false end
        if not move_axis('forward', -dx) then return false end
    end

    return strXYZ(location) == strXYZ(target)
end

function minerReturnToBase(base)
    return minerMoveToCoordinate(base)
end


-- Multiplayer-safe navigation: a block which remains after a dig attempt is
-- treated as protected/unbreakable instead of being attacked forever.
function safeTunnelForward()
    if turtle.forward() then logMovement('forward'); return true end

    if turtle.detect() then
        turtle.dig()
        sleep(0.15)
        if turtle.forward() then logMovement('forward'); return true end
        return false
    end

    -- No block detected means the destination is probably occupied by a
    -- player, mob, item/entity or another turtle. Wait instead of declaring
    -- the route permanently blocked.
    print('Path temporarily occupied; waiting...')
    for attempt=1,20 do
        sleep(0.5)
        if turtle.forward() then logMovement('forward'); return true end
        if turtle.detect() then
            turtle.dig()
            sleep(0.15)
            if turtle.forward() then logMovement('forward'); return true end
            return false
        end
    end

    turtle.attack()
    sleep(0.25)
    if turtle.forward() then logMovement('forward'); return true end
    print('Path still occupied.')
    return false
end

function safeVerticalStep(direction)
    local move = direction == 'up' and turtle.up or turtle.down
    local detect = direction == 'up' and turtle.detectUp or turtle.detectDown
    local dig = direction == 'up' and turtle.digUp or turtle.digDown
    if move() then logMovement(direction); return true end
    if detect() then
        dig(); sleep(0.15)
        if move() then logMovement(direction); return true end
    end
    return false
end

-- Bounded wall bypass. It tries progressively wider left/right offsets, then
-- resumes coordinate navigation once it has got around the obstruction.
function navigateHorizontalWithDetours(target)
    local guard = 0
    while (location.x ~= target.x or location.z ~= target.z) and guard < 4096 do
        guard = guard + 1
        local dx, dz = target.x-location.x, target.z-location.z
        local wanted
        if math.abs(dx) >= math.abs(dz) and dx ~= 0 then
            wanted = dx > 0 and 'east' or 'west'
        else
            wanted = dz > 0 and 'south' or 'north'
        end
        face(wanted)

        if not safeTunnelForward() then
            local bypassed = false
            for width=HOME_DETOUR_STEP,HOME_DETOUR_MAX,HOME_DETOUR_STEP do
                for _,side in ipairs({'left','right'}) do
                    face(wanted)
                    if side=='left' then go('left',true) else go('right',true) end
                    local side_steps=0
                    while side_steps<width and safeTunnelForward() do
                        side_steps=side_steps+1
                    end
                    if side_steps==width then
                        if side=='left' then go('right',true) else go('left',true) end
                        -- Move parallel to the blocked route until we can make
                        -- progress past its edge.
                        local parallel=0
                        while parallel<(width*2+8) do
                            if safeTunnelForward() then
                                parallel=parallel+1
                                bypassed=true
                                break
                            else
                                break
                            end
                        end
                    end
                    if bypassed then break end
                    -- If this probe failed, coordinate navigation below will
                    -- re-aim from the position actually reached.
                end
                if bypassed then break end
            end
            if not bypassed then
                print('Protected area could not be bypassed safely.')
                return false
            end
        end
    end
    return location.x==target.x and location.z==target.z
end

function returnHomeSafely()
    print('Returning to TRUE HOME...')
    print('Home offset: x=' .. tostring(home_location.x) ..
          ' y=' .. tostring(home_location.y) ..
          ' z=' .. tostring(home_location.z))

    local guard = 0

    -- First correct horizontal displacement. Use the same protected-area-aware
    -- tunnelling primitive, but make decisions from home_location rather than
    -- the recalibrated mining coordinates.
    while (home_location.x ~= 0 or home_location.z ~= 0) and guard < 4096 do
        guard = guard + 1

        local dx = -home_location.x
        local dz = -home_location.z
        local wanted
        if math.abs(dx) >= math.abs(dz) and dx ~= 0 then
            wanted = dx > 0 and 'east' or 'west'
        else
            wanted = dz > 0 and 'south' or 'north'
        end

        face(wanted)

        if not safeTunnelForward() then
            -- Simple bounded side-step detour. After every successful detour,
            -- re-evaluate the TRUE HOME vector.
            local bypassed = false
            for _, side in ipairs({'left','right'}) do
                face(wanted)
                if side == 'left' then go('left', true) else go('right', true) end

                local moved_side = 0
                while moved_side < HOME_DETOUR_MAX and safeTunnelForward() do
                    moved_side = moved_side + 1

                    if side == 'left' then go('right', true) else go('left', true) end
                    if safeTunnelForward() then
                        bypassed = true
                        break
                    end
                    if side == 'left' then go('left', true) else go('right', true) end
                end
                if bypassed then break end
            end

            if not bypassed then
                print('Could not bypass protected area on route HOME.')
                return false
            end
        end
    end

    if home_location.x ~= 0 or home_location.z ~= 0 then
        return false
    end

    -- Finally restore the exact startup height. No world-Y assumption is used.
    while home_location.y < 0 do
        if not safeVerticalStep('up') then
            print('TRUE HOME vertical route blocked.')
            return false
        end
    end
    while home_location.y > 0 do
        if not safeVerticalStep('down') then
            print('TRUE HOME vertical route blocked.')
            return false
        end
    end

    face('north')
    print('TRUE HOME reached.')
    return home_location.x == 0 and home_location.y == 0 and home_location.z == 0
end

function autonomousMine()
    print('Autonomous mining mode')
    sleep(1)

    -- Each turtle's permanent home is its OWN startup/spawn coordinate.
    local base = {x = 0, y = 0, z = 0}
    local base_orientation = 'north'

    -- Genesis has already completed. Return this turtle to its own
    -- spawn/start point before doing any autonomous mining.
    print('Returning to spawn/base')
    if not returnHomeSafely() then
        print('Could not return to spawn/base - stopping')
        return
    end
    face(base_orientation)

    local run = 0
    while MINER_MAX_RUNS == 0 or run < MINER_MAX_RUNS do
        run = run + 1

        if not minerRefuel() then
            print('Low fuel - returning to base')
            break
        end

        -- Always leave the surface through the same vertical shaft and
        -- perform the actual mining at the configured underground level.
        print('Travelling to mining level y=' .. tostring(MINER_DEPTH))
        if not minerMoveToCoordinate({x = base.x, y = MINER_DEPTH, z = base.z}) then
            print('Could not reach mining level - stopping')
            break
        end
        if not face('north') then break end

        -- Parallel branches are spaced apart so each run explores fresh rock.
        -- IMPORTANT: do not use minerMoveToCoordinate() for the sideways
        -- branch offset. That helper treats any failed step as fatal. At
        -- mining depth the route is normally solid rock, so run 2 used to
        -- stop immediately with "Could not reach branch start".
        --
        -- Instead, deliberately tunnel east to the next branch start.
        local branch_offset = (run - 1) * MINER_BRANCH_SPACING
        if branch_offset > 0 then
            if not face('east') then break end

            print('Tunnelling to branch start x=' ..
                  tostring(base.x + branch_offset))

            local branch_ok = true
            while location.x < base.x + branch_offset do
                if turtle.getFuelLevel() < MINER_RETURN_FUEL then
                    branch_ok = false
                    break
                end

                -- go() digs the block in front before moving, which is what
                -- we want for a new underground branch corridor.
                if not go('forward') then
                    branch_ok = false
                    break
                end
            end

            if not branch_ok then
                print('Could not tunnel to branch start - stopping')
                break
            end

            if not face('north') then break end
        end

        local branch_start = {x = location.x, y = location.y, z = location.z}
        local branch_orientation = orientation

        print('Mining run ' .. tostring(run))
        local completed = minerStripBranch()

        -- Return from the branch to its starting point, then to the shaft.
        if not minerMoveToCoordinate(branch_start) then
            print('Could not return from branch - stopping')
            break
        end
        if not minerReturnToBase({x = base.x, y = MINER_DEPTH, z = base.z}) then
            print('Could not return to shaft - stopping')
            break
        end
        face(branch_orientation)

        -- Return HOME using protected-area-aware navigation.
        if not returnHomeSafely() then
            print('Could not return to base - stopping')
            break
        end
        face(base_orientation)

        -- Leave the shaft entrance and return to the learned storage point
        -- before depositing. Never place/use the storage chest in the shaft.
        if not goToStorageHome() then
            print('Could not reach storage HOME - stopping')
            break
        end
        ensureChestBelow()
        itemsBeared(true)

        if not minerRefuel() then
            print('No fuel available - stopping')
            break
        end

        if not completed then
            sleep(2)
        end
    end

    turtle.select(1)
    print('Autonomous mining stopped.')
end

location = {x = 0, y = 0, z = 0}
-- Never recalibrated: exact displacement from this turtle's physical startup.
home_location = {x = 0, y = 0, z = 0}

-- Storage/genesis position is deliberately separate from the shaft/start block.
-- This is learned once after returning HOME and then reused by the parent.
storage_home = nil

-- Aggressive inventory cleanup is ONLY active before genesis. Autonomous
-- miners keep their loot so it can be returned to storage.
replication_mode = true

orientation = 'north'
calibrated = false


function go(direction, nodig)
    if not nodig then
        if DETECT[direction] then
            if DETECT[direction]() then
                DIG[direction]()
            end
        end
    end
    if not MOVE[direction] then
        return false
    end
    if not MOVE[direction]() then
        if ATTACK[direction] then
            ATTACK[direction]()
        end
        return false
    end
    logMovement(direction)
    return true
end


function goAbsolute(direction)
    while not go(direction) do end
end


function logMovement(direction)
    if direction == 'up' then
        location.y = location.y + 1
        home_location.y = home_location.y + 1
    elseif direction == 'down' then
        location.y = location.y - 1
        home_location.y = home_location.y - 1
    elseif direction == 'forward' then
        bump = BUMPS[orientation]
        location = {x = location.x + bump[1], y = location.y + bump[2], z = location.z + bump[3]}
        home_location = {x = home_location.x + bump[1], y = home_location.y + bump[2], z = home_location.z + bump[3]}
    elseif direction == 'back' then
        bump = BUMPS[orientation]
        location = {x = location.x - bump[1], y = location.y - bump[2], z = location.z - bump[3]}
        home_location = {x = home_location.x - bump[1], y = home_location.y - bump[2], z = home_location.z - bump[3]}
    elseif direction == 'left' then
        orientation = LEFT_SHIFT[orientation]
    elseif direction == 'right' then
        orientation = RIGHT_SHIFT[orientation]
    end
    return true
end


function followRoute(route)
    for step in route:gmatch'.' do
        if step == 'u' then
            goAbsolute('up')
        elseif step == 'f' then
            goAbsolute('forward')
        elseif step == 'd' then
            goAbsolute('down')
        elseif step == 'b' then
            goAbsolute('back')
        elseif step == 'l' then
            goAbsolute('left')
        elseif step == 'r' then
            goAbsolute('right')
        end
    end
    return true
end
                    
                    
function face(new_orientation)
    if orientation == new_orientation then
        return true
    elseif RIGHT_SHIFT[orientation] == new_orientation then
        if not go('right') then return false end
    elseif LEFT_SHIFT[orientation] == new_orientation then
        if not go('left') then return false end
    elseif RIGHT_SHIFT[RIGHT_SHIFT[orientation]] == new_orientation then
        if not go('right') then return false end
        if not go('right') then return false end
    else
        return false
    end
    return true
end


function getAdjacentBlock(direction, loc, ori)
    if not loc then loc = location end
    if not ori then ori = orientation end
    if direction == 'up' then
        return {x = loc.x, y = loc.y + 1, z = loc.z}
    elseif direction == 'down' then
        return {x = loc.x, y = loc.y - 1, z = loc.z}
    elseif direction == 'forward' then
        local bump = BUMPS[ori]
        return {x = loc.x + bump[1], y = loc.y + bump[2], z = loc.z + bump[3]}
    elseif direction == 'back' then
        local bump = BUMPS[ori]
        return {x = loc.x - bump[1], y = loc.y - bump[2], z = loc.z - bump[3]}
    elseif direction == 'left' then
        local bump = BUMPS[LEFT_SHIFT[ori]]
        return {x = loc.x + bump[1], y = loc.y + bump[2], z = loc.z + bump[3]}
    elseif direction == 'right' then
        local bump = BUMPS[RIGHT_SHIFT[ori]]
        return {x = loc.x + bump[1], y = loc.y + bump[2], z = loc.z + bump[3]}
    end
end


function getFromChest(items_wanted)
    local function isWanted(detail)
        if not detail then return false end
        local interpreted = interpretItemName(detail.name)
        return items_wanted[detail.name] ~= nil or
               items_wanted[interpreted] ~= nil
    end

    local function findEmptySlot()
        for slot = 1, 16 do
            if turtle.getItemCount(slot) == 0 then
                return slot
            end
        end
        return nil
    end

    -- Scan an entire chest even when it contains more than 16 occupied slots.
    -- The previous scanner filled the turtle's 16 slots and then stopped, so
    -- an ingredient deeper in a large chest could remain unseen.
    --
    -- While scanning the lower chest, unwanted stacks are shuttled into the
    -- front proxy chest immediately. While scanning the front chest, unwanted
    -- stacks are shuttled into the lower chest. Wanted stacks remain in the
    -- turtle. This frees the scan slot after every unwanted stack.
    local function scanChest(direction)
        local attempts = 0
        local max_attempts = 128

        while attempts < max_attempts do
            attempts = attempts + 1

            local slot = findEmptySlot()
            if not slot then
                -- Inventory contains wanted ingredients; no safe scan slot.
                break
            end

            turtle.select(slot)

            local sucked
            if direction == 'down' then
                sucked = turtle.suckDown()
            else
                sucked = turtle.suck()
            end
            if not sucked then
                break
            end

            local detail = turtle.getItemDetail(slot)
            if detail and not isWanted(detail) then
                -- Move the unwanted stack OUT of the chest currently being
                -- scanned so the next chest slot can become accessible.
                if direction == 'down' then
                    local front_ok, front_data = turtle.inspect()
                    if not (front_ok and front_data and front_data.name == 'minecraft:chest') then
                        error("Cannot scan lower chest: proxy chest missing in front")
                    end
                    if not turtle.drop() then
                        error("Proxy chest full while scanning lower chest")
                    end
                else
                    local down_ok, down_data = turtle.inspectDown()
                    if not (down_ok and down_data and down_data.name == 'minecraft:chest') then
                        error("Cannot scan proxy chest: storage chest missing below")
                    end
                    if not turtle.dropDown() then
                        error("Storage chest full while scanning proxy chest")
                    end
                end
            end
        end
    end

    scanChest('down')

    -- If anything is still missing, scan the front proxy chest as well.
    local function allPresent()
        for wanted_name, wanted_count in pairs(items_wanted) do
            local required = wanted_count
            if required == true then required = 1 end

            local have = 0
            for slot = 1, 16 do
                local detail = turtle.getItemDetail(slot)
                if detail then
                    local interpreted = interpretItemName(detail.name)
                    if detail.name == wanted_name or interpreted == wanted_name then
                        have = have + detail.count
                    end
                end
            end

            if have < required then return false end
        end
        return true
    end

    if not allPresent() then
        scanChest('front')
    end

    return allPresent()
end

function itemsLackedToCraft(craft_item_name, count)
    craft_item_name = interpretItemName(craft_item_name)
    local items = itemsBeared(true)
    local recipe = CRAFTING_RECIPES[craft_item_name]

    if not recipe then
        error('No crafting recipe registered for "' .. tostring(craft_item_name) .. '"')
    end

    -- Recipes may contain legacy physical item IDs while itemsBeared() stores
    -- their interpreted/canonical names. Always normalize BOTH sides before
    -- comparing them. This is especially important in this installation where
    -- computercraft:computer is interpreted as computercraft:computer_normal.
    local available = {}
    for item_name, item_data in pairs(items) do
        local canonical = interpretItemName(item_name)
        available[canonical] = (available[canonical] or 0) + item_data.count
    end

    local lacked = {}

    for _, raw_item_name in pairs(recipe) do
        local item_name = interpretItemName(raw_item_name)

        for i = 1, count do
            if (available[item_name] or 0) > 0 then
                available[item_name] = available[item_name] - 1
            else
                lacked[item_name] = (lacked[item_name] or 0) + 1
            end
        end
    end

    return lacked
end


function craft(craft_item_name, count)
    craft_item_name = interpretItemName(craft_item_name)
    if not count then count = 1 end

    local recipe = CRAFTING_RECIPES[craft_item_name]
    local required_items = {}

    for i, item_name in pairs(recipe) do
        if required_items[item_name] then
            required_items[item_name] = required_items[item_name] + count
        else
            required_items[item_name] = count
        end
    end

    -- Check that the correct items are being used
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            local name = interpretItemName(item.name)
            if not required_items[name] then
                error('Item "' .. name .. '" not used in recipe for "' .. craft_item_name .. '"')
            end
            if item.count < required_items[name] then
                error('Not enough "' .. name .. '" in stack as per recipe')
            end
        end
    end

    -- Move all items out of the crafting area
    for _, stack_slot in pairs(CRAFTING_SLOTS) do
        if turtle.getItemDetail(stack_slot) then
            turtle.select(stack_slot)
            for _, tranfer_slot in pairs(NON_CRAFTING_SLOTS) do
                if not turtle.getItemDetail(tranfer_slot) then
                    turtle.transferTo(tranfer_slot)
                    break
                end
            end
            if turtle.getItemDetail(stack_slot) then
                error('Too many stacks (crafting recipes with more than 7 unique ingredients not supported)')
            end
        end
    end

    -- Move items back into the crafting area and into the correct positions
    for _, stack_slot in pairs(NON_CRAFTING_SLOTS) do
        local item = turtle.getItemDetail(stack_slot)
        if item then
            local name = interpretItemName(item.name)

            local place_slots = {}
            for i, item_name in pairs(recipe) do
                if item_name == name then
                    table.insert(place_slots, CRAFTING_SLOTS[i])
                end
            end

            for i, place_slot in pairs(place_slots) do
                if i == 1 then
                    turtle.select(stack_slot)
                    turtle.transferTo(place_slot)
                else
                    turtle.select(place_slots[1])
                    turtle.transferTo(place_slot, count)
                end
            end
        end
    end

    -- Craft!
    if not turtle.craft(count) then
        error('Crafting failed')
    end
end


function craftAsNeeded(craft_item_name, count, original_items)
    craft_item_name = interpretItemName(craft_item_name)
    local needed_count = count
    local beared = original_items[craft_item_name]
    if beared then
        needed_count = count - beared.count
    end

    if needed_count > 0 then
        local recipe = CRAFTING_RECIPES[craft_item_name]
        local required_items = {}
        for _, item_name in pairs(recipe) do
            required_items[interpretItemName(item_name)] = true
        end

        dumpExcept(required_items)

        if not getFromChest(itemsLackedToCraft(craft_item_name, count)) then
            -- Diagnose exactly what crafting expected to retrieve.
        local missing = itemsLackedToCraft(craft_item_name, count)
        print("")
        print("CRAFTING ERROR")
        print("Trying to craft: " .. tostring(craft_item_name) .. " x" .. tostring(count))
        print("Needed from chest:")
        for needed_name, needed_count in pairs(missing) do
            print("  " .. tostring(needed_name) .. " x" .. tostring(needed_count))
        end
        print("Items currently in turtle:")
        for slot = 1, 16 do
            local d = turtle.getItemDetail(slot)
            if d then
                print("  " .. tostring(d.name) .. " x" .. tostring(d.count))
            end
        end
        error('Needed items not found in chest - see diagnostic above')
        end

        itemsBeared(true)

        craft(craft_item_name, needed_count)
    end

    if beared then
        getFromChest({[craft_item_name] = true})
        itemsBeared(true)
    end
end



function cleanReplicationInventory()
    if not replication_mode then return end

    -- Work out what the current replication tree still needs. This uses the
    -- same recipe/dependency logic as gathering, rather than a hard-coded
    -- whitelist which could become stale when recipes change.
    local needed = itemsLacked(nil)

    -- Always retain operational fuel. Coal may also be part of the replication
    -- requirements/child reserve, but keeping it here prevents stranding.
    local always_keep = {
        ['minecraft:coal'] = true,
        ['minecraft:charcoal'] = true
    }

    -- First merge identical physical stacks to free slots without losing items.
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

    -- Anything which contributes to the crafting tree is kept, even when the
    -- immediate deficit has just been satisfied. NEEDED_ITEMS contains those
    -- recipe/resource categories used by the existing program.
    for slot=1,16 do
        local item=turtle.getItemDetail(slot)
        if item then
            local canonical=interpretItemName(item.name)
            local keep = always_keep[item.name] or
                         NEEDED_ITEMS[canonical] or
                         needed[canonical]

            if not keep then
                -- Prefer storage if a verified chest happens to be underneath;
                -- otherwise discard the irrelevant stack to preserve slots for
                -- replication resources such as logs, sand and reeds.
                turtle.select(slot)
                if chestBelow and chestBelow() then
                    turtle.dropDown()
                else
                    turtle.drop()
                end
            end
        end
    end

    turtle.select(1)
end

function itemsBeared(drop)
    local item_data = {}

    -- itemsBeared(true) is used during mining/exploration as well as at base.
    -- Only physically drop items when a real chest is directly underneath.
    -- Otherwise keep everything safely in the turtle inventory.
    local can_drop = false
    if drop then
        local chest_ok, chest_data = turtle.inspectDown()
        can_drop = chest_ok and chest_data and chest_data.name == 'minecraft:chest'
    end


    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            local name = interpretItemName(item.name)
            if NEEDED_ITEMS[name] then
                if not item_data[name] then
                    item_data[name] = {count = item.count, slot = slot}
                elseif drop and can_drop then
                    turtle.select(slot)
                    if (item_data[name].count < 64) then
                        turtle.transferTo(item_data[name].slot)
                    end
                    if (item_data[name].count < turtle.getItemCount(slot)) then
                        turtle.select(item_data[name].slot)
                        item_data[name] = {count = item.count, slot = slot}
                    end
                    turtle.dropDown()
                end
            elseif drop and can_drop then
                turtle.select(slot)
                turtle.dropDown()
            end
        end
    end

    turtle.select(1)
    return item_data
end


function itemsLacked(subterranean, item_data, tree, lacked, count)
    if item_data == nil then item_data = itemsBeared() end
    if tree == nil then tree = CRAFTING_TREE end
    if lacked == nil then lacked = {} end
    if count == nil then count = 1 end

    for item_name, item_details in pairs(tree) do

        local need_count = count * item_details.count
        local bear_count = 0
        if item_data[item_name] then
            bear_count = item_data[item_name].count
        end
        local lack_count = need_count - bear_count

        if lack_count >= 0 then
            item_data[item_name] = nil
            if lack_count > 0 then
                if item_details.components then
                    itemsLacked(subterranean, item_data, item_details.components, lacked, lack_count)
                elseif subterranean == nil or subterranean == item_details.subterranean then
                    if lacked[item_name] then
                        lacked[item_name] = lacked[item_name] + lack_count
                    else
                        lacked[item_name] = lack_count
                    end
                end
            end
        else
            item_data[item_name].count = item_data[item_name].count - need_count
        end
    end

    return lacked
end


function calibrate()
    if not calibrated then
        print('Tunneling down to calibrate height')
        while ({INSPECT.down()})[2].name ~= 'minecraft:bedrock' do
            go('down')
        end
        location.y = 10
        location.y = -59
        calibrated = true
    end
end


function atDepth(depth)
    return location.y == depth
end


function travelToDepth(depth)
    calibrate()
    while location.y > depth do
        if ({INSPECT.down()})[2].name == 'minecraft:bedrock' then
            location.y = math.min(location.y, -59)
            break
        end
        goAbsolute('down')
    end
    while location.y < depth do
        goAbsolute('up')
    end
end


function mineVein(subterranean, skip_return, always_mine)
    if not always_mine then always_mine = {} end
    
    -- Log starting location
    local start = strXYZ(location, orientation)
    local start_orientation = orientation

    -- Begin block map
    local valid = {}
    local ores = {}
    valid[strXYZ(location)] = true
    valid[strXYZ(getAdjacentBlock('back'))] = false
    local ore_found = false
    for i = 1, VEIN_MAX do

        -- Get item types that are still lacking
        local lacking = itemsLacked(subterranean)
        for name, _ in pairs(always_mine) do
            if not lacking[name] then
                lacking[name] = 1
            end
        end

        -- Scan adjacent
        local scan_items = scan(valid, ores, lacking)

        -- Do special case 'leaves' thing (for finding logs easier)
        if scan_items['log'] and always_mine['leaves'] then
            always_mine['leaves'] = nil
            lacking['leaves'] = nil
            valid = {}
            ores = {}
            valid[strXYZ(location)] = true
            local s = scan(valid, ores, lacking)
        end

        -- Search for nearest ore
        local route = fastestRoute(valid, ores, location, orientation)

        -- Check if there is one
        if not route then
            break
        end

        -- Retrieve ore
        turtle.select(1)
        if not followRoute(route) then
            face(start_orientation)
            return false
        end
        ores[strXYZ(location)] = nil

    end

    -- Return to start
    if skip_return then
        face(start_orientation)
    else
        followRoute(fastestRoute(valid, {[start] = true}, location, orientation))
    end
    
    return true
end


function scan(valid, ores, ore_names)
    local checked_left  = false
    local checked_right = false

    local found_ore_names = {}
    
    local f = strXYZ(getAdjacentBlock('forward'))
    local u = strXYZ(getAdjacentBlock('up'))
    local d = strXYZ(getAdjacentBlock('down'))
    local l = strXYZ(getAdjacentBlock('left'))
    local r = strXYZ(getAdjacentBlock('right'))
    local b = strXYZ(getAdjacentBlock('back'))
    
    if not valid[f] and valid[f] ~= false then
        valid[f] = detectOre('forward', ore_names)
        ores[f] = valid[f]
        if ores[f] then found_ore_names[ores[f]] = true end
    end
    if not valid[u] and valid[u] ~= false then
        valid[u] = detectOre('up', ore_names)
        ores[u] = valid[u]
        if ores[u] then found_ore_names[ores[u]] = true end
    end
    if not valid[d] and valid[d] ~= false then
        valid[d] = detectOre('down', ore_names)
        ores[d] = valid[d]
        if ores[d] then found_ore_names[ores[d]] = true end
    end
    if not valid[l] and valid[l] ~= false then
        go('left')
        checked_left = true
        valid[l] = detectOre('forward', ore_names)
        ores[l] = valid[l]
        if ores[l] then found_ore_names[ores[l]] = true end
    end
    if not valid[r] and valid[r] ~= false then
        go('right')
        if checked_left then
            go('right')
        end
        checked_right = true
        valid[r] = detectOre('forward', ore_names)
        ores[r] = valid[r]
        if ores[r] then found_ore_names[ores[r]] = true end
    end
    if not valid[b] and valid[b] ~= false then
        if checked_right then
            go('right')
        elseif checked_left then
            go('left')
        else
            go('right')
            go('right')
        end
        valid[b] = detectOre('forward', ore_names)
        ores[b] = valid[b]
        if ores[b] then found_ore_names[ores[b]] = true end
    end

    return found_ore_names
end


function detectOre(direction, ore_names)
    local _, block = INSPECT[direction]()
    local name = interpretItemName(block.name)
    if ore_names[name] then
        return name
    end
    return false
end


function fastestRoute(area, end_locations, loc, ori)
    local queue = {}
    local explored = {}
    table.insert(queue,
        {
            coords = {x = loc.x, y = loc.y, z = loc.z},
            facing = ori,
            path = '',
        }
    )
    explored[strXYZ(loc, ori)] = true

    while #queue > 0 do
        local node = table.remove(queue, 1)
        if end_locations[strXYZ(node.coords)] or end_locations[strXYZ(node.coords, node.facing)] then
            return node.path
        end
        for _, step in pairs({
                {coords = node.coords,                                           facing = LEFT_SHIFT[node.facing],  path = node.path .. 'l'},
                {coords = node.coords,                                           facing = RIGHT_SHIFT[node.facing], path = node.path .. 'r'},
                {coords = getAdjacentBlock('forward', node.coords, node.facing), facing = node.facing,              path = node.path .. 'f'},
                {coords = getAdjacentBlock('up', node.coords, node.facing),      facing = node.facing,              path = node.path .. 'u'},
                {coords = getAdjacentBlock('down', node.coords, node.facing),    facing = node.facing,              path = node.path .. 'd'},
                }) do
            explore_string = strXYZ(step.coords, step.facing)
            if not explored[explore_string] and (not area or area[strXYZ(step.coords)]) then
                explored[explore_string] = true
                table.insert(queue, step)
            end
        end
    end
end


function strXYZ(coords, facing)
    if facing then
        return coords.x .. ',' .. coords.y .. ',' .. coords.z .. ':' .. facing
    else
        return coords.x .. ',' .. coords.y .. ',' .. coords.z
    end
end


function interpretItemName(item_name)
    -- Legacy ComputerCraft item ID used by this installation.
    if item_name == 'computercraft:computer' then
        return 'computercraft:computer_normal'
    end

    -- Legacy ComputerCraft disk-drive item ID used by this installation.
    if item_name == 'computercraft:peripheral' then
        return 'computercraft:disk_drive'
    end

    -- Legacy ComputerCraft floppy disk item ID used by this installation.
    if item_name == 'computercraft:disk_expanded' then
        return 'computercraft:disk'
    end

    if LOG_ITEMS[item_name] then
        return 'log'
    elseif PLANKS_ITEMS[item_name] then
        return 'planks'
    elseif LEAVES_ITEMS[item_name] then
        return 'leaves'
    elseif ORE_ITEMS[item_name] then
        return ORE_ITEMS[item_name]
    else
        return item_name
    end
end


refuel_max = false
function smartRefuel()
    if refuel_max then
        if refuelTo(TRAVEL_FUEL) then
            refuel_max = false
            return true
        end
    else
        if refuelTo(TRAVEL_FUEL_MIN) then
            return true
        else
            refuel_max = true
        end
    end
    return false
end


function refuelTo(target_level)
    local lacked_coal = math.ceil((target_level - turtle.getFuelLevel()) / 80)
    if lacked_coal <= 0 then return true end

    for slot = 1, 16 do
        local item_details = turtle.getItemDetail(slot)
        if item_details and item_details.name == 'minecraft:coal' then
            turtle.select(slot)
            turtle.refuel(lacked_coal)
            lacked_coal = math.ceil((target_level - turtle.getFuelLevel()) / 80)
            if lacked_coal <= 0 then return true end
        end
    end

    return false
end


SAND_IGNORE = {['minecraft:water'] = true}
REGULAR_IGNORE = {['minecraft:grass'] = true, ['minecraft:tall_grass'] = true}
function is_trace_block(direction, lacked)
    local is_block, block_data = INSPECT[direction]()
    if not is_block then return false end
    return not (REGULAR_IGNORE[block_data.name] or (lacked['minecraft:sand'] and SAND_IGNORE[block_data.name]))
end


function traceStep(lacked)
    lacked = lacked or {}

    local is_block_forward = is_trace_block('forward', lacked)
    local is_block_down = is_trace_block('down', lacked)

    if is_block_forward then
        go('up')
        is_block_forward = is_trace_block('forward', lacked)
        if not is_block_forward then
            go('forward')
        end
    elseif is_block_down then
        go('forward')
    else
        go('down')
    end
end


function freeInventoryForGathering()
    -- Keep several slots free while away from storage. Mining/exploration can
    -- otherwise fill all 16 slots with cobblestone/dirt/ore variants before
    -- the turtle reaches later surface resources such as logs or sand.
    local target_empty_slots = 4

    local function emptySlots()
        local n = 0
        for slot = 1, 16 do
            if turtle.getItemCount(slot) == 0 then n = n + 1 end
        end
        return n
    end

    if emptySlots() >= target_empty_slots then return true end

    -- First merge duplicate stacks wherever possible.
    for a = 1, 16 do
        local da = turtle.getItemDetail(a)
        if da then
            for b = a + 1, 16 do
                local db = turtle.getItemDetail(b)
                if db and db.name == da.name then
                    turtle.select(b)
                    turtle.transferTo(a)
                end
            end
        end
    end

    if emptySlots() >= target_empty_slots then
        turtle.select(1)
        return true
    end

    -- If a verified storage chest is below us, offload anything not currently
    -- required. This is the preferred/safe cleanup path.
    local chest_ok, chest_data = turtle.inspectDown()
    if chest_ok and chest_data and chest_data.name == 'minecraft:chest' then
        local needed_now = itemsLacked(nil)

        for slot = 1, 16 do
            if emptySlots() >= target_empty_slots then break end

            local item = turtle.getItemDetail(slot)
            if item then
                local canonical = interpretItemName(item.name)

                -- Coal is useful for mobility, so retain one stack. Everything
                -- else which is not presently lacking can be stored.
                local keep = needed_now[canonical] ~= nil
                if item.name == 'minecraft:coal' or item.name == 'minecraft:charcoal' then
                    keep = true
                end

                if not keep then
                    turtle.select(slot)
                    turtle.dropDown()
                end
            end
        end
    end

    turtle.select(1)
    return emptySlots() >= target_empty_slots
end


function explore()
    local lacked = itemsLacked(false)

    print("Exploring the surface for resources")
    print("Missing surface resources:")
    local missing_any = false
    for item_name, count in pairs(lacked) do
        local display_name = item_name
        if item_name == 'log' then
            display_name = 'wood/logs'
        end
        print("  " .. display_name .. " x" .. tostring(count))
        missing_any = true
    end
    if not missing_any then
        print("  (none)")
    end
    local i = 0
    local refuelGood = true
    while next(lacked) ~= nil and refuelGood do
        cleanReplicationInventory()
        if not freeInventoryForGathering() then
            print("Inventory nearly full; continuing carefully")
        end

        traceStep(lacked)

        local is_block_forward, data_block_forward = INSPECT.forward()
        local is_block_down, data_block_down = INSPECT.down()
        local is_block_up, data_block_up = INSPECT.up()

        local block_found =          (is_block_forward and lacked[interpretItemName(data_block_forward.name)])
        block_found = block_found or (is_block_down    and lacked[interpretItemName(data_block_down.name)])
        block_found = block_found or (is_block_up      and lacked[interpretItemName(data_block_up.name)])

        if block_found then
            if is_block_forward and data_block_forward.name == 'minecraft:reeds' then
                while is_block_forward and data_block_forward.name == 'minecraft:reeds' do
                    go('up')
                    is_block_forward, data_block_forward = INSPECT.forward()
                end
                go('forward')
            end
            if lacked['log'] then
                mineVein(false, true, {['leaves'] = true})
            else
                mineVein(false, true)
            end
        end

        lacked = itemsLacked(false)
        if lacked['log'] then
            lacked['leaves'] = true
        end
        if next(lacked) == nil or i >= HOUSEKEEP_FREQUENCY then
            i = 0
            refuelGood = smartRefuel()
            lacked = itemsLacked(false, itemsBeared(true))
        else
            i = i + 1
        end
    end
end


function printMissingResources(title, lacked)
    print(title)
    local any = false
    for item_name, count in pairs(lacked) do
        local display_name = item_name
        if item_name == 'log' then
            display_name = 'wood/logs'
        end
        print("  " .. display_name .. " x" .. tostring(count))
        any = true
    end
    if not any then
        print("  (none)")
    end
end


function mine()
    -- Absolute safety boundary: these resources must NEVER be searched for by
    -- the underground miner, regardless of how the recursive crafting tree
    -- classifies them.
    local function undergroundOnly(lacked)
        lacked['log'] = nil
        lacked['planks'] = nil
        lacked['minecraft:log'] = nil
        lacked['minecraft:planks'] = nil
        lacked['minecraft:reeds'] = nil
        lacked['minecraft:sugar_cane'] = nil
        lacked['minecraft:sand'] = nil
        return lacked
    end
    -- Always calculate what is ACTUALLY missing from the turtle/chest first.
    -- itemsLacked(true) already accounts for materials currently carried.
    local lacked = undergroundOnly(itemsLacked(true))
    -- Defensive rule: wood/logs are surface resources and must never be
    -- searched for by the underground miner.
    lacked['log'] = nil
    local refuelGood = smartRefuel()

    if not refuelGood then
        lacked['minecraft:coal_ore'] = math.max(lacked['minecraft:coal_ore'] or 0, 1)
    end

    printMissingResources("Underground resources still required:", lacked)
    print("Fuel: " .. tostring(turtle.getFuelLevel()))

    -- Do not travel to an ore-specific surface/upper-world Y level.
    -- Replication resource mining stays deep.
    if next(lacked) ~= nil or not refuelGood then
        if not atDepth(REPLICATION_MINING_DEPTH) then
            print("Staying underground.")
            print("Traveling to mining level y=" .. tostring(REPLICATION_MINING_DEPTH))
            travelToDepth(REPLICATION_MINING_DEPTH)
        end
    end

    local i = 0

    while next(lacked) ~= nil or not refuelGood do
        -- Re-check inventory BEFORE choosing/searching for an ore.
        lacked = undergroundOnly(itemsLacked(true))

        if not refuelGood then
            lacked['minecraft:coal_ore'] = math.max(lacked['minecraft:coal_ore'] or 0, 1)
        end

        -- If requirements became satisfied after collecting/depositing items,
        -- do not continue searching for iron/redstone unnecessarily.
        if next(lacked) == nil and refuelGood then
            break
        end

        local target = nil
        -- target is selected only from the filtered underground deficit set.
        if not refuelGood then
            target = 'minecraft:coal_ore'
        else
            for _, ore_name in pairs(ORE_PRIORITY) do
                if lacked[ore_name] and lacked[ore_name] > 0 then
                    target = ore_name
                    break
                end
            end
        end

        if target then
            print("Searching underground for: " .. target ..
                  " x" .. tostring(lacked[target] or 1))
            print("Mining at internal Y=" .. tostring(location.y))
        end

        -- Only mine veins containing resources which are still required.
        if detectOre('up', lacked) or
           detectOre('forward', lacked) or
           detectOre('down', lacked) then
            itemsBeared(true)
            mineVein(true, false, {['minecraft:diamond_ore'] = true})
        end

        go('forward')

        if i >= HOUSEKEEP_FREQUENCY then
            i = 0

            -- Discard irrelevant mining by-products during replication, then
            -- deposit/merge what remains and recalculate requirements.
            cleanReplicationInventory()
            local current_items = itemsBeared(true)
            lacked = itemsLacked(true, current_items)
            lacked['log'] = nil
            refuelGood = smartRefuel()

            if not refuelGood then
                lacked['minecraft:coal_ore'] = math.max(lacked['minecraft:coal_ore'] or 0, 1)
            end

            print("")
            printMissingResources("Underground resources still required:", lacked)
            print("Mining at internal Y=" .. tostring(location.y))
            print("Fuel: " .. tostring(turtle.getFuelLevel()))
        else
            i = i + 1
        end
    end

    print("")
    print("Underground requirements complete.")
    print("Checking surface requirements...")
end


function createFarm()
    print('Creating sugar cane farm')
    local items = itemsBeared(true)
    local is_block_down, data_block_down = INSPECT.down()
    local is_block_forward = INSPECT.forward()

    while is_block_forward or not (is_block_down and data_block_down.name == 'minecraft:water') do
        traceStep()
        is_block_down, data_block_down = INSPECT.down()
        is_block_forward = INSPECT.forward()
    end

    goAbsolute('forward')
    selectItem('minecraft:dirt')
    DIG.down()
    PLACE.down()
    goAbsolute('up')
    selectItem('minecraft:reeds')
    PLACE.down()
    goAbsolute('up')
end


function dumpExcept(exceptions)
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            local name = interpretItemName(item.name)
            if not exceptions[name] and not exceptions[item.name] then
                turtle.select(slot)

                -- Canonical storage is the chest below. Never scatter general
                -- resources between the lower chest and the front proxy chest.
                local down_ok, down_data = turtle.inspectDown()
                if down_ok and down_data and down_data.name == 'minecraft:chest' then
                    if not turtle.dropDown() then
                        error("Persistent storage chest is full")
                    end
                else
                    -- Some original genesis movements temporarily put the
                    -- turtle away from its storage chest. In that case only
                    -- use the verified front proxy chest; never drop to air.
                    local front_ok, front_data = turtle.inspect()
                    if front_ok and front_data and front_data.name == 'minecraft:chest' then
                        if not turtle.drop() then
                            error("Proxy crafting chest is full")
                        end
                    else
                        error("Refusing to dump items: no verified chest available")
                    end
                end
            end
        end
    end
end

function destroy(item_name)
    if selectItem(item_name) then
        turtle.dropDown()
    end
end


function selectItem(item_name)
    local items = itemsBeared()
    if not items[interpretItemName(item_name)] then
        return false
    end
    turtle.select(items[interpretItemName(item_name)].slot)
    return true
end


function genesis()
    print("Items collected, begining genesis process")

    local original_items = itemsBeared(true)
    local items = itemsBeared(true)

    -- Make sugar cane farm if needed
    local sugar_needed = 5 - original_items['minecraft:reeds'].count
    if original_items['computercraft:disk'] or original_items['minecraft:paper'] then
        sugar_needed = math.max(0, sugar_needed - 3)
    end
    if sugar_needed > 0 then
        createFarm()
    end

    -- Place chest
    print('Placing proxy chest')
    destroy('minecraft:dirt')
    items = itemsBeared(true)
    if not selectItem('minecraft:chest') then
        error("Genesis requires a chest for the proxy crafting chest")
    end
    DIG.forward()
    if not PLACE.forward() then
        error("Failed to place proxy crafting chest in front of turtle")
    end

    local proxy_ok, proxy_data = turtle.inspect()
    if not (proxy_ok and proxy_data and proxy_data.name == 'minecraft:chest') then
        error("Proxy crafting chest verification failed")
    end
    print("Proxy crafting chest placed and verified.")

    -- Craft furnaces and collect smelting items
    print('Creating smeltery')
    dumpExcept({['minecraft:cobblestone'] = true})
    craftAsNeeded('minecraft:furnace', 3, original_items)
    getFromChest({
        ['minecraft:coal'] = true,
        ['minecraft:sand'] = true,
        ['minecraft:raw_iron'] = true,
        ['minecraft:iron_ore'] = true,
    })
    goAbsolute('left')
    goAbsolute('forward')
    goAbsolute('right')
    goAbsolute('right')

    -- Place furnaces
    for i = 1, 3 do
        items = itemsBeared(true)
        selectItem('minecraft:furnace')
        DIG.up()
        PLACE.up()
        selectItem('minecraft:coal')
        turtle.dropUp(1)
        if i == 2 then
            turtle.dropUp(1)
        end
        goAbsolute('forward')
    end

    -- Place items in furnaces
    print('Smelting')
    goAbsolute('up')
    goAbsolute('left')
    goAbsolute('up')
    goAbsolute('left')
    goAbsolute('forward')
    if selectItem('minecraft:sand') then
        turtle.dropDown()
    end
    goAbsolute('forward')
    if selectItem('minecraft:cobblestone') then
        turtle.dropDown()
    end
    goAbsolute('forward')
    -- Modern Minecraft drops raw iron; older versions/modpacks drop the
    -- iron ore block itself. This world uses older IDs such as minecraft:log
    -- and minecraft:reeds, so support both forms.
    local iron_for_smelting = false
    if selectItem('minecraft:raw_iron') then
        iron_for_smelting = true
    elseif selectItem('minecraft:iron_ore') then
        iron_for_smelting = true
    end

    if iron_for_smelting then
        print("Loading iron into furnace: " .. tostring(turtle.getItemDetail().name))
        turtle.dropDown()
    else
        error("No raw iron or iron ore available for smelting")
    end
    goAbsolute('forward')
    goAbsolute('down')
    goAbsolute('right')
    goAbsolute('down')
    goAbsolute('right')
    goAbsolute('forward')
    goAbsolute('forward')
    goAbsolute('left')
    items = itemsBeared(true)

    -- Collect sugar cane if needed
    print('Collecting all necessary sugar cane')
    for i = 1, sugar_needed do
        while not INSPECT.down() do
            sleep(1)
        end
        DIG.down()
    end
    if sugar_needed > 0 then
        goAbsolute('down')
        goAbsolute('down')
        DIG.down()
        goAbsolute('up')
        goAbsolute('up')
        destroy('minecraft:dirt')
    end

    -- Collect furnace contents when ready
    print('Collecting furnace contents')
    dumpExcept({})
    turtle.select(1)
    while true do
        turtle.suckUp()
        if turtle.getItemCount() >= 14 then
            break
        end
        sleep(1)
    end
    goAbsolute('left')
    goAbsolute('forward')
    goAbsolute('right')
    goAbsolute('up')
    goAbsolute('right')
    goAbsolute('forward')
    goAbsolute('forward')
    goAbsolute('left')
    goAbsolute('down')
    goAbsolute('left')
    goAbsolute('forward')
    goAbsolute('right')
    destroy('minecraft:sand')
    destroy('minecraft:iron_ore')
    destroy('minecraft:cobblestone')
    destroy('minecraft:furnace')

    -- Consolidate the proxy chest back into persistent storage before the
    -- final crafting stage. This prevents components from being stranded in
    -- different chests (for example chest in front, computer below).
    print("Consolidating genesis storage")
    local down_ok, down_data = turtle.inspectDown()
    local front_ok, front_data = turtle.inspect()
    if down_ok and down_data and down_data.name == 'minecraft:chest' and
       front_ok and front_data and front_data.name == 'minecraft:chest' then
        for attempts = 1, 128 do
            local empty = nil
            for slot = 1, 16 do
                if turtle.getItemCount(slot) == 0 then
                    empty = slot
                    break
                end
            end
            if not empty then break end
            turtle.select(empty)
            if not turtle.suck() then break end
            if not turtle.dropDown() then
                error("Persistent storage chest full while consolidating")
            end
        end
    end

    -- Do crafting
    doCrafting(original_items)

    -- Grab final items
    dumpExcept({})
    local items_aquired = getFromChest({
        ['computercraft:turtle_expanded'] = true,
        ['computercraft:disk_drive'] = true,
        ['computercraft:disk'] = true,
        ['minecraft:coal'] = true,
        ['minecraft:reeds'] = true,
        ['minecraft:chest'] = true,
    })
    if not items_aquired then
        print("")
        print("FINAL ITEM CHECK FAILED")
        print("Expected genesis outputs:")
        local expected = {
            ['computercraft:turtle_expanded'] = true,
            ['computercraft:disk_drive'] = true,
            ['computercraft:disk'] = true,
            ['minecraft:coal'] = true,
            ['minecraft:reeds'] = true,
            ['minecraft:chest'] = true,
        }

        for name, _ in pairs(expected) do
            local have = 0
            for slot = 1, 16 do
                local detail = turtle.getItemDetail(slot)
                if detail then
                    local interpreted = interpretItemName(detail.name)
                    if detail.name == name or interpreted == name then
                        have = have + detail.count
                    end
                end
            end
            if have < 1 then
                print("MISSING: " .. name)
            else
                print("OK: " .. name .. " x" .. tostring(have))
            end
        end

        print("Items currently in turtle:")
        for slot = 1, 16 do
            local detail = turtle.getItemDetail(slot)
            if detail then
                print(tostring(slot) .. ": " .. detail.name ..
                      " x" .. tostring(detail.count))
            end
        end

        error('Final genesis items missing - see diagnostic above')
    end

    -- Place disk drive
    print('Tranferring contents of brain')
    goAbsolute('left')
    selectItem('computercraft:disk_drive')
    while not PLACE.forward() do
        DIG.forward()
    end
    selectItem('computercraft:disk')
    turtle.drop()
    populateDisk()

    -- Place the newly crafted child turtle.
    -- The original code only MOVED to the birth position; it never selected
    -- or placed the turtle item, so the child remained in the parent's
    -- inventory and peripheral.call('bottom', 'turnOn') had nothing to start.
    print('Creating turtle')
    goAbsolute('up')
    goAbsolute('forward')
    goAbsolute('forward')

    if not selectItem('computercraft:turtle_expanded') then
        error('Child turtle is missing from parent inventory')
    end

    -- The child must be directly below the parent because the next step starts
    -- the peripheral on the bottom side.
    local below_ok, below_data = turtle.inspectDown()
    if below_ok then
        error('Cannot give birth: block below is occupied by ' ..
              tostring(below_data and below_data.name or 'unknown block'))
    end

    if not PLACE.down() then
        error('Failed to place child turtle below parent')
    end

    local child_ok, child_data = turtle.inspectDown()
    if not child_ok then
        error('Child turtle placement could not be verified')
    end

    local child_name = child_data and child_data.name or ''
    if child_name ~= 'computercraft:turtle_expanded' and
       child_name ~= 'computercraft:turtle' then
        error('Unexpected block below after birth: ' .. tostring(child_name))
    end

    print('Child turtle placed: ' .. tostring(child_name))

    -- Seed the child with the minimum supplies it needs to begin its own
    -- replication cycle. The child can mine the ores itself, but without
    -- startup fuel it may be unable to move at all. Give it fuel plus the
    -- reusable/support items already produced by genesis.
    print('Supplying child turtle')

    local function giveChild(item_name, amount)
        if selectItem(item_name) then
            local ok
            if amount then
                ok = turtle.dropDown(amount)
            else
                ok = turtle.dropDown()
            end
            if not ok then
                error('Failed to give child ' .. tostring(item_name))
            end
            print('Gave child: ' .. tostring(item_name) ..
                  (amount and (' x' .. tostring(amount)) or ''))
            return true
        end
        return false
    end

    -- Enough coal to get the child moving/mining. Do not give all coal so the
    -- parent retains fuel for its own autonomous mining phase.
    if not giveChild('minecraft:coal', 8) then
        error('Reserved child coal is missing at birth')
    end

    if not giveChild('minecraft:chest', 1) then
        error('Reserved child chest is missing at birth')
    end

    if not giveChild('minecraft:reeds', 5) then
        error('Reserved child reeds are missing at birth')
    end

    -- The child starts normally and must complete its own replication cycle.
    -- Only the turtle which has just finished genesis becomes a miner.

    -- Give life
    print('Giving life')
    local started, start_error = pcall(function()
        peripheral.call('bottom', 'turnOn')
    end)
    if not started then
        error('Child turtle placed but could not be started: ' ..
              tostring(start_error))
    end
    print('Child turtle started.')

    -- Pack up
    print('Packing up')
    goAbsolute('right')
    goAbsolute('right')
    goAbsolute('forward')
    goAbsolute('down')
    goAbsolute('forward')
    goAbsolute('left')
    goAbsolute('forward')

end


function doCrafting(original_items)
    print('Do crafting of all necessary items')

    -- Craft turtle
    local chests_lacked = math.max(0, 3 - original_items['minecraft:chest'].count)
    if chests_lacked > 0 then
        craftAsNeeded('planks', chests_lacked * 2, original_items)
        craftAsNeeded('minecraft:chest', chests_lacked, {})
        destroy('planks')
    end
    craftAsNeeded('minecraft:glass_pane', 1, original_items)
    destroy('minecraft:glass')
    print("Crafting computer...")
    craftAsNeeded('computercraft:computer_normal', 1, {})
    print("Computer craft complete.")
    print("Crafting turtle...")
    craftAsNeeded('computercraft:turtle_expanded', 1, {})
    print("Turtle craft complete.")
    destroy('minecraft:iron_ingot')
    if not (original_items['minecraft:stick'] and original_items['minecraft:stick'].count >= 2) then
        craftAsNeeded('planks', 1, original_items)
        craftAsNeeded('minecraft:stick', 1, {})
        destroy('planks')
    end
    craftAsNeeded('minecraft:diamond_pickaxe', 1, {})
    destroy('minecraft:stick')
    if not original_items['minecraft:crafting_table'] then
        craftAsNeeded('planks', 1, original_items)
        craftAsNeeded('minecraft:crafting_table', 1, {})
    end
    print("Crafting mining turtle...")
    craftAsNeeded('mining_crafty_turtle', 1, {})
    print("Mining turtle craft complete.")

    -- Craft disk
    print("Crafting disk drive...")
    craftAsNeeded('computercraft:disk_drive', 1, original_items)
    print("Disk drive craft complete.")
    if not original_items['computercraft:disk'] then
        craftAsNeeded('minecraft:paper', 1, original_items)
        print("Crafting disk...")
        craftAsNeeded('computercraft:disk', 1, {})
        print("Disk craft complete.")
        destroy('minecraft:paper')
    end

    print("All crafting stages complete.")
end


function returnToSurfaceForGenesis()
    print("")
    print("Returning to surface for genesis...")

    -- Do not identify the surface by block type. Dirt is not universal, and
    -- caves can contain air above solid ground. Instead require a substantial
    -- uninterrupted vertical run through open air before accepting that we
    -- have escaped the underground.
    local required_clear_up = 10
    local extra_clearance = 3
    local max_climb = 384
    local climbed = 0
    local clear_up = 0

    print("Searching for sustained open air...")

    while climbed < max_climb and clear_up < required_clear_up do
        local blocked_up = turtle.detectUp()

        if blocked_up then
            clear_up = 0
        end

        if go('up') then
            climbed = climbed + 1

            if blocked_up then
                clear_up = 0
            else
                clear_up = clear_up + 1
                print("Open-air clearance: " ..
                      tostring(clear_up) .. "/" ..
                      tostring(required_clear_up))
            end
        else
            sleep(0.2)
        end
    end

    if clear_up < required_clear_up then
        error("Could not find sustained open air before genesis")
    end

    -- Rise farther so horizontal movement begins above the shaft rim rather
    -- than from inside a narrow opening.
    print("Sustained open air found. Clearing surface...")
    for i = 1, extra_clearance do
        if not go('up') then
            error("Unable to gain surface clearance")
        end
        climbed = climbed + 1
    end

    -- Move away from the escape shaft. Never dig horizontally here.
    print("Moving away from escape shaft...")
    local moved = 0
    local blocked_directions = 0

    while moved < 3 do
        if go('forward', true) then
            moved = moved + 1
            blocked_directions = 0
        else
            turtle.turnRight()
            logMovement('right')
            blocked_directions = blocked_directions + 1

            if blocked_directions >= 4 then
                -- Even after the sustained-air test, terrain may tower around
                -- the opening. Rise one more block and retry all directions.
                print("All horizontal directions blocked; rising...")
                if not go('up') then
                    error("Unable to clear terrain around surface opening")
                end
                climbed = climbed + 1
                blocked_directions = 0
            end
        end
    end

    -- Search horizontally for a dry landing column. No dirt requirement:
    -- grass, sand, stone, gravel, snow-supported blocks, etc. are all valid.
    print("Searching for dry landing area...")
    local dry_search = 0
    local max_dry_search = 96

    while dry_search < max_dry_search do
        local down_ok, down_data = turtle.inspectDown()
        local down_name = down_ok and down_data and down_data.name or nil

        local liquid_below =
            down_name == 'minecraft:water' or
            down_name == 'minecraft:flowing_water' or
            down_name == 'minecraft:lava' or
            down_name == 'minecraft:flowing_lava'

        if not liquid_below then
            break
        end

        if go('forward', true) then
            dry_search = dry_search + 1
        else
            turtle.turnRight()
            logMovement('right')
        end
    end

    if dry_search >= max_dry_search then
        error("Could not find dry land for genesis")
    end

    -- Descend until ANY solid non-liquid terrain is directly below. This is
    -- deliberately biome-independent.
    print("Descending to solid ground...")
    local descended = 0

    while descended < max_climb do
        local down_ok, down_data = turtle.inspectDown()

        if down_ok and down_data then
            local name = down_data.name
            if name == 'minecraft:water' or
               name == 'minecraft:flowing_water' or
               name == 'minecraft:lava' or
               name == 'minecraft:flowing_lava' then
                error("Liquid encountered at landing position")
            end

            print("Solid ground reached: " .. tostring(name))
            print("Surface return complete.")
            return true
        end

        if go('down') then
            descended = descended + 1
        else
            sleep(0.2)
        end
    end

    error("Could not find solid ground after reaching open air")
end


function isLiquidBlock(data)
    return data and (
        data.name == 'minecraft:water' or
        data.name == 'minecraft:flowing_water' or
        data.name == 'minecraft:lava' or
        data.name == 'minecraft:flowing_lava'
    )
end

function chestBelow()
    local ok, data = turtle.inspectDown()
    return ok and data and data.name == 'minecraft:chest'
end

function safeBaseStepForward()
    -- Surface/base movement must NOT dig through somebody's build or claim.
    if turtle.forward() then
        logMovement('forward')
        return true
    end
    return false
end

function moveBaseSteps(direction, count)
    face(direction)
    for i = 1, count do
        if not safeBaseStepForward() then return false end
    end
    return true
end

function returnToTrueHomeFromBase()
    -- Used only for the small surface base search. No digging.
    local guard = 0
    while (home_location.x ~= 0 or home_location.z ~= 0) and guard < 64 do
        guard = guard + 1
        local dx, dz = -home_location.x, -home_location.z
        if math.abs(dx) >= math.abs(dz) and dx ~= 0 then
            face(dx > 0 and 'east' or 'west')
        else
            face(dz > 0 and 'south' or 'north')
        end
        if not safeBaseStepForward() then return false end
    end
    return home_location.x == 0 and home_location.z == 0
end

function storageCandidateUsable()
    local ok, data = turtle.inspectDown()

    -- Existing chest is always preferred.
    if ok and data and data.name == 'minecraft:chest' then
        return true, true
    end

    -- Never build storage over liquids or open air (the shaft is open air).
    if not ok or isLiquidBlock(data) then
        return false, false
    end

    -- Bedrock and obvious ComputerCraft blocks are not suitable ground.
    if data.name == 'minecraft:bedrock' or
       data.name == 'computercraft:turtle_expanded' or
       data.name == 'computercraft:turtle_normal' then
        return false, false
    end

    return true, false
end

function findStorageHome()
    print('Finding safe storage/genesis position away from shaft...')

    -- Search positions around TRUE HOME. Forward three is preferred, then
    -- symmetric side positions and progressively wider alternatives.
    -- Coordinates assume startup orientation north, matching TRUE HOME facing.
    local candidates = {
        {x=0,  z=-3}, {x=-3, z=0}, {x=3,  z=0},
        {x=0,  z=3},  {x=-3, z=-3}, {x=3, z=-3},
        {x=-6, z=0},  {x=6,  z=0}, {x=0, z=-6}, {x=0, z=6}
    }

    face('north')

    for _, target in ipairs(candidates) do
        if not returnToTrueHomeFromBase() then
            error('Could not return to shaft/start while searching for storage')
        end

        local ok = true
        if target.x ~= 0 then
            ok = moveBaseSteps(target.x > 0 and 'east' or 'west', math.abs(target.x))
        end
        if ok and target.z ~= 0 then
            ok = moveBaseSteps(target.z > 0 and 'south' or 'north', math.abs(target.z))
        end

        if ok then
            local usable, existing = storageCandidateUsable()
            if usable then
                storage_home = {
                    x = home_location.x,
                    y = home_location.y,
                    z = home_location.z
                }
                if existing then
                    print('Existing storage chest found.')
                else
                    print('Safe storage ground found.')
                end
                print('Storage offset x=' .. tostring(storage_home.x) ..
                      ' y=' .. tostring(storage_home.y) ..
                      ' z=' .. tostring(storage_home.z))
                return true
            end
        end
    end

    returnToTrueHomeFromBase()
    return false
end

function goToStorageHome()
    if not storage_home then
        return findStorageHome()
    end

    local guard = 0
    while (home_location.x ~= storage_home.x or
           home_location.z ~= storage_home.z) and guard < 128 do
        guard = guard + 1
        local dx = storage_home.x - home_location.x
        local dz = storage_home.z - home_location.z
        if math.abs(dx) >= math.abs(dz) and dx ~= 0 then
            face(dx > 0 and 'east' or 'west')
        else
            face(dz > 0 and 'south' or 'north')
        end
        if not safeBaseStepForward() then
            -- Base changed since the position was learned. Re-discover safely.
            storage_home = nil
            if not returnToTrueHomeFromBase() then return false end
            return findStorageHome()
        end
    end
    return true
end

function ensureChestBelow()
    if not storage_home then
        error("Storage position has not been selected")
    end

    if home_location.x ~= storage_home.x or
       home_location.z ~= storage_home.z then
        error("Refusing to place chest outside selected storage position")
    end

    local ok, data = turtle.inspectDown()

    if ok and data and data.name == 'minecraft:chest' then
        print("Existing storage chest verified.")
        return true
    end

    if not ok then
        error("Unsafe storage position: open air below (possible shaft)")
    end

    if isLiquidBlock(data) then
        error("Unsafe storage position: liquid below turtle")
    end

    -- Prepare a one-block chest recess only at the selected safe base position.
    if not turtle.digDown() then
        error("Cannot prepare storage recess (possibly protected land)")
    end

    if not selectItem('minecraft:chest') then
        error("No chest available to place at storage HOME")
    end

    if not turtle.placeDown() then
        error("Failed to place storage chest")
    end

    if not chestBelow() then
        error("Storage chest verification failed")
    end

    print("Storage chest placed and verified away from shaft.")
    return true
end


function main()
    -- Every turtle follows the same lifecycle:
    --   1. gather everything required for genesis
    --   2. create and start one child turtle
    --   3. only after genesis is complete, return to THIS turtle's own
    --      startup coordinate and enter autonomous mining mode
    --
    -- The child does NOT immediately become a miner.  It starts this same
    -- program with location 0,0,0 and must first complete its own genesis.
    while true do
        cleanReplicationInventory()
        local refueled = smartRefuel()
        local underground_lacked = itemsLacked(true)
        underground_lacked['log'] = nil
        underground_lacked['planks'] = nil
        underground_lacked['minecraft:log'] = nil
        underground_lacked['minecraft:planks'] = nil
        underground_lacked['minecraft:reeds'] = nil
        underground_lacked['minecraft:sugar_cane'] = nil
        underground_lacked['minecraft:sand'] = nil
        local need_subterranian_items = next(underground_lacked) ~= nil

        if not refueled or need_subterranian_items then
            mine()
        else
            local surface_lacked = itemsLacked(false)
            local need_surface_items = next(surface_lacked) ~= nil
            if need_surface_items then
                print("")
                printMissingResources("Surface resources still required:", surface_lacked)
                print("Searching surface...")
                explore()
            else
                print("")
                print("All replication resources collected.")
                print("Returning HOME before genesis...")
                if not returnHomeSafely() then
                    error("Could not return HOME for genesis")
                end
                if not goToStorageHome() then
                    error("Could not find a safe storage/genesis position near HOME")
                end
                ensureChestBelow()
                print("Beginning genesis at STORAGE HOME...")
                genesis()
                replication_mode = false

                print('Replication complete.')
                print('Returning to this turtle\'s spawn/base, then mining.')
                autonomousMine()
                return
            end
        end
    end
end


function manualChest()
    print('\nPlease insert...')
    print('1 Chest [ ]     1 Reeds [ ]')
    sleep(0.5)

    while true do
        local aquired = 0
        for slot = 1, 16 do
            local item = turtle.getItemDetail(slot)
            if item and item.name == 'minecraft:chest' then
                aquired = bit32.bor(aquired, 1)
            end
            if item and item.name == 'minecraft:reeds' then
                aquired = bit32.bor(aquired, 2)
            end
        end
        term.setCursorPos(10, 6)
        if bit32.band(aquired, 1) ~= 0 then
            term.write('x')
        else
            term.write(' ')
        end
        term.setCursorPos(31, 6)
        if bit32.band(aquired, 2) ~= 0 then
            term.write('x')
        else
            term.write(' ')
        end
        if aquired == 3 then
            return
        end
        sleep(0.5)
    end

end


function manualRefuel(desired_level)
    print('Please insert coal...')

    local cursor_x, cursor_y = term.getCursorPos()
    local current_level = turtle.getFuelLevel()
    local slot = 1

    printFuelBar(cursor_y, current_level, desired_level)

    while current_level < desired_level do

        for i = 1, 16 do
            local item = turtle.getItemDetail(slot)
            if item and item.name == 'minecraft:coal' then
                turtle.select(slot)
                if turtle.refuel(5) then break end
            end
            slot = (slot % 16) + 1
        end

        current_level = turtle.getFuelLevel()
        printFuelBar(cursor_y, current_level, desired_level)
        sleep(0)

    end

    sleep(1)
    print('\nFueling complete.')
end


function printFuelBar(cursor_y, current_level, desired_level)
    term.setCursorPos(1, cursor_y)
    local progress = math.min(math.floor(FUEL_BAR * current_level / desired_level), FUEL_BAR)
    term.write('[')
    for i = 1, progress do
        term.write('+')
    end
    for i = 1, FUEL_BAR - progress do
        term.write('-')
    end
    term.write('] ')
    term.write(tostring(current_level))
    term.write('/')
    term.write(tostring(desired_level))
end


function printTitle()
    for y_offset, line in pairs(TITLE) do
        term.setCursorPos(1, y_offset)
        for char in line:gmatch"." do
            if char == '#' then
                term.setBackgroundColor(colors.white)
            else
                term.setBackgroundColor(colors.black)
            end
            term.write(' ')
        end
    end
    term.setBackgroundColor(colors.black)
end


function userInit()

    term.clear()
    printTitle()
    print('\n      press return to continue...')
    read()

    term.clear()
    term.setCursorPos(1, 1)
    manualRefuel(START_FUEL)

    sleep(1)
    manualChest()

    sleep(1)
    print('\nTurtle preparation complete.')
    sleep(1)
    print('\nFinal confirmation...')
    sleep(0.5)
    print('Initiate global turtle colonization?')
    term.write('(Y/N) > ')

    if string.upper(read()) ~= 'Y' then
        print('Shutdown...')
        os.shutdown()
        return
    end

    term.clear()
    term.setCursorPos(1, 1)

    print('Beginning...')
    sleep(1)
    for i = 5, 1, -1 do
        print(i)
        sleep(1)
    end
    
    term.clear()
    term.setCursorPos(1, 1)

    initiate()

end


function populateDisk()
    -- Copy this program onto the child's startup disk.
    -- The child begins as a replicator, not as an autonomous miner.
    if not fs.isDir('/disk') then
        error('Disk not inserted')
    end

    local file_contents = fs.open('startup', 'r').readAll()
    local s = 'FILE_CONTENTS = [===[' .. file_contents .. ']' .. '===]'
    s = s .. [[
    file = fs.open('/startup', 'w')
    file.write(FILE_CONTENTS)
    file.close()
    shell.run('startup')
    ]]

    local file = fs.open('/disk/startup', 'w')
    file.write(s)
    file.close()

    -- Remove a marker left by an older autonomous-miner build, if present.
    if fs.exists('/disk/autonomous_miner') then
        fs.delete('/disk/autonomous_miner')
    end
end


function initiate()
    -- debug.getinfo(...).short_src may include a leading "@", which is not
    -- part of the ComputerCraft filesystem path. Strip it before fs.open().
    local filename = debug.getinfo(2, "S").short_src
    if filename:sub(1, 1) == '@' then
        filename = filename:sub(2)
    end

    local file = fs.open(filename, 'r')

    -- Some launch methods only expose the shell program path reliably.
    if not file and shell and shell.getRunningProgram then
        filename = shell.getRunningProgram()
        file = fs.open(filename, 'r')
    end

    if not file then
        error('Unable to open running program: ' .. tostring(filename))
    end

    local file_contents = file.readAll()
    file_contents = file_contents:sub(1, -11) .. 'main()'
    file = fs.open('/startup', 'w')
    file.write(file_contents)
    file.close()
    os.reboot()
end


nameTurtle()
userInit()