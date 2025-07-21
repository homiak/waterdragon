-----------
-- Nodes --
-----------

-- Local Utilities --

local S = waterdragon.S

local stair_queue = {}

local function register_node(name, def, register_stair)
    minetest.register_node(name, def)
    if register_stair then
        table.insert(stair_queue, name)
    end
end

-- Logs --

register_node("waterdragon:log_wet", {
    description = S("Wet Log"),
    tiles = { "waterdragon_log_wet_top.png", "waterdragon_log_wet_top.png", "waterdragon_log_wet.png" },
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = { tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2 },
    sounds = waterdragon.sounds.wood,
    on_place = minetest.rotate_node
}, true)

-- Stone --

register_node("waterdragon:stone_wet", {
    description = S("Wet Stone"),
    tiles = { "waterdragon_stone_wet.png" },
    paramtype2 = "facedir",
    place_param2 = 0,
    is_ground_content = false,
    groups = { cracky = 1, level = 3 },
    sounds = waterdragon.sounds.stone
}, true)

-- Dragonstone Blocks

register_node("waterdragon:dragonstone_block_rare_water", {
    description = S("Rare Water Dragonstone Block"),
    tiles = { "waterdragon_dragonstone_block_rare_water.png" },
    paramtype2 = "facedir",
    place_param2 = 0,
    is_ground_content = false,
    groups = { cracky = 1, level = 3 },
    sounds = waterdragon.sounds.stone
}, true)

register_node("waterdragon:dragonstone_block_pure_water", {
    description = S("Pure Water Dragonstone Block"),
    tiles = { "waterdragon_dragonstone_block_pure_water.png" },
    paramtype2 = "facedir",
    place_param2 = 0,
    is_ground_content = false,
    groups = { cracky = 1, level = 3 },
    sounds = waterdragon.sounds.stone
}, true)

-- Soil --

register_node("waterdragon:soil_wet", {
    description = S("Wet Soil"),
    tiles = { "waterdragon_soil_wet.png" },
    groups = { crumbly = 3, soil = 1 },
    sounds = waterdragon.sounds.dirt
})

-- Wood Planks

register_node("waterdragon:wood_planks_wet", {
    description = S("Wet Wood Planks"),
    tiles = { "waterdragon_wood_planks_wet.png" },
    is_ground_content = false,
    groups = { tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2 },
    sounds = waterdragon.sounds.wood,
}, true)


-- Stone Bricks --

register_node("waterdragon:dragonstone_bricks_pure_water", {
    description = S("Pure Water Dragonstone Bricks"),
    tiles = { "waterdragon_dragonstone_bricks_pure_water.png" },
    paramtype2 = "facedir",
    place_param2 = 0,
    is_ground_content = false,
    groups = { cracky = 1, level = 2 },
    sounds = waterdragon.sounds.stone
}, true)

register_node("waterdragon:dragonstone_bricks_rare_water", {
    description = S("Rare Water Dragonstone Bricks"),
    tiles = { "waterdragon_dragonstone_bricks_rare_water.png" },
    paramtype2 = "facedir",
    place_param2 = 0,
    is_ground_content = false,
    groups = { cracky = 1, level = 2 },
    sounds = waterdragon.sounds.stone
}, true)


register_node("waterdragon:stone_bricks_wet", {
    description = S("Wet Stone Brick"),
    tiles = { "waterdragon_stone_brick_wet.png" },
    paramtype2 = "facedir",
    place_param2 = 0,
    is_ground_content = false,
    groups = { cracky = 1, level = 3 },
    sounds = waterdragon.sounds.stone
}, true)

------------------
-- Scale Blocks --
------------------

for color in pairs(waterdragon.colors_pure_water) do
    register_node("waterdragon:dragonhide_block_pure_water", {
        description = S("Pure Water Dragonhide Block"),
        tiles = {
            "waterdragon_dragonhide_block_pure_water_top.png",
            "waterdragon_dragonhide_block_pure_water_top.png",
            "waterdragon_dragonhide_block_pure_water.png"
        },
        paramtype2 = "facedir",
        place_param2 = 0,
        is_ground_content = false,
        groups = { cracky = 1, level = 3, pure_water_dragonhide_block = 1 },
        sounds = waterdragon.sounds.stone
    })
end

for color in pairs(waterdragon.colors_rare_water) do
    register_node("waterdragon:dragonhide_block_rare_water", {
        description = S("Pure Water Dragonhide Block"),
        tiles = {
            "waterdragon_dragonhide_block_rare_water_top.png",
            "waterdragon_dragonhide_block_rare_water_top.png",
            "waterdragon_dragonhide_block_rare_water.png"
        },
        paramtype2 = "facedir",
        place_param2 = 0,
        is_ground_content = false,
        groups = { cracky = 1, level = 3, rare_water_dragonhide_block = 1 },
        sounds = waterdragon.sounds.stone
    })
end

-- Bone Pile --

register_node("waterdragon:bone_pile_wet", {
    description = S("Wet Bone Pile"),
    tiles = {
        "waterdragon_bone_pile_wet.png",
    },
    paramtype2 = "facedir",
    place_param2 = 0,
    is_ground_content = false,
    groups = { cracky = 3, level = 1, flammable = 1 },
    sounds = waterdragon.sounds.wood
})

local random = math.random

local steel_ingot = "default:steel_ingot"

local function update_forge_form(meta, forge_type)
    local melt_perc = meta:get_int("melt_perc") or 0
    local cool_perc = meta:get_int("cool_perc") or 0
    local formspec = table.concat({
        "formspec_version[3]",
        "size[11,10]",
        "image[0,0;11,10;waterdragon_form_forge_bg.png]",
        "image[3.475,1.3;1.56,0.39;waterdragon_form_pure_water_empty.png^[transformR270]",
        "image[6.35,1.325;1.95,0.39;waterdragon_form_pure_water_elbow_up_empty.png^[transformR270]",
        "image[7.91,1.7;0.39,1.69;waterdragon_form_pure_water_elbow_down_empty.png^[transformFY]]",
        "list[current_player;main;0.65,5;8,4;]",
        "list[context;input;2.325,1.05;1,1;]",
        "list[context;crucible;5.175,1.05;1,1;]",
        "list[context;output;7.65,3.5;1,1;]",
        "listring[current_player;main]",
        "listring[context;input]",
        "listring[current_player;main]",
        "listring[context;crucible]",
        "listring[current_player;main]",
        "listring[context;output]",
        "listring[current_player;main]"
    }, "")

    if melt_perc > 0 and melt_perc <= 100 then
        formspec = formspec .. "image[3.475,1.3;1.56,0.39;waterdragon_form_pure_water_empty.png^[lowpart:" ..
            melt_perc .. ":waterdragon_form_pure_water_full.png^[transformR270]]"
    end

    if cool_perc > 0 and cool_perc <= 100 then
        local elbow_p1 = math.min(cool_perc * 2, 100)
        local elbow_p2 = math.max(cool_perc * 2 - 100, 0)
        formspec = formspec .. "image[6.35,1.325;1.95,0.39;waterdragon_form_pure_water_elbow_up_empty.png^[lowpart:" ..
            elbow_p1 .. ":waterdragon_form_pure_water_elbow_up_full.png^[transformR270]]"
        if elbow_p2 > 0 then
            formspec = formspec ..
                "image[7.91,1.7;0.39,1.69;waterdragon_form_pure_water_elbow_down_empty.png^[lowpart:" ..
                elbow_p2 .. ":waterdragon_form_pure_water_elbow_down_full.png^[transformFY]]"
        end
    end

    meta:set_string("formspec", formspec)
end

local function get_forge_structure(pos)
    -- Implement structure check here
    return true -- For testing, always return true
end

local function melt_ingots(pos, wtd_id)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local input = inv:get_stack("input", 1)
    local crucible = inv:get_stack("crucible", 1)
    if input:get_name() ~= steel_ingot
        or input:get_count() < 1
        or crucible:get_name() ~= "waterdragon:dragonstone_crucible" then
        minetest.get_node_timer(pos):stop()
        update_forge_form(meta, minetest.get_node(pos).name:match("_(%w+)_water"))
    else
        input:take_item(1)
        inv:set_stack("input", 1, input)
        local full_crucible = ItemStack("waterdragon:dragonstone_crucible_full")
        full_crucible:get_meta():set_string("wtd_id", wtd_id)
        inv:set_stack("crucible", 1, full_crucible)
    end
end

local function cool_crucible(pos, ingot)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local crucible = inv:get_stack("crucible", 1)
    local node = minetest.get_node(pos)
    local name = node.name
    if crucible:get_name() ~= "waterdragon:dragonstone_crucible_full" then
        minetest.get_node_timer(pos):stop()
    else
        local wtd_id = crucible:get_meta():get_string("wtd_id")
        inv:set_stack("crucible", 1, "waterdragon:dragonstone_crucible")
        local draconic_ingot = ItemStack(ingot)
        local ingot_meta = draconic_ingot:get_meta()
        local ingot_desc = minetest.registered_items[ingot].description
        local dragon_name = S("a Nameless Water Dragon")
        if waterdragon.waterdragons[wtd_id]
            and waterdragon.waterdragons[wtd_id].name then
            dragon_name = waterdragon.waterdragons[wtd_id].name
        end
        ingot_meta:set_string("wtd_id", wtd_id)
        ingot_meta:set_string("description", ingot_desc .. S("\n(Forged by" .. " " .. dragon_name .. ")"))
        inv:set_stack("output", 1, draconic_ingot)
        meta:set_int("cool_perc", 0)
    end
    update_forge_form(meta, name:match("_(%w+)_water"))
end

local function forge_particle(pos, animation)
    local flame_dir = { x = 0, y = 1, z = 0 }
    minetest.add_particlespawner({
        amount = 6,
        time = 1,
        minpos = vector.add(pos, flame_dir),
        maxpos = vector.add(pos, flame_dir),
        minvel = vector.multiply(flame_dir, 2),
        maxvel = vector.multiply(flame_dir, 3),
        minacc = { x = random(-3, 3), y = 2, z = random(-3, 3) },
        maxacc = { x = random(-3, 3), y = 6, z = random(-3, 3) },
        minexptime = 0.5,
        maxexptime = 1.5,
        minsize = 5,
        maxsize = 8,
        collisiondetection = false,
        vertical = false,
        glow = 7,
        texture = "waterdragon_water_particle.png",
        animation = animation,
    })
end

local function register_draconic_forge(water_type)
    local forge_name = "waterdragon:draconic_forge_" .. water_type
    local ingot_name = "waterdragon:draconic_steel_ingot_" .. water_type
    local particle_texture = "waterdragon_water_particle.png"

    minetest.register_node(forge_name, {
        description = S(water_type:gsub("_water", ""):gsub("^%l", string.upper) .. " Water Draconic Steel Forge"),
        tiles = {
            "waterdragon_dragonstone_block_" .. water_type .. ".png",
            "waterdragon_draconic_forge_" .. water_type .. ".png"
        },
        paramtype2 = "facedir",
        place_param2 = 0,
        is_ground_content = false,
        groups = { cracky = 1, level = 2 },
        sounds = waterdragon.sounds.stone,

        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:set_size("input", 1)
            inv:set_size("crucible", 1)
            inv:set_size("output", 1)
            update_forge_form(meta, water_type)
        end,

        can_dig = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return inv:is_empty("input") and inv:is_empty("crucible") and inv:is_empty("output")
        end,

        allow_metadata_inventory_put = function(pos, listname, _, stack, player)
            if minetest.is_protected(pos, player:get_player_name()) then
                return 0
            end
            if listname == "input" and stack:get_name() == steel_ingot then
                return stack:get_count()
            end
            if listname == "crucible" and stack:get_name():match("^waterdragon:dragonstone_crucible") then
                return 1
            end
            return 0
        end,

        allow_metadata_inventory_move = function() return 0 end,

        allow_metadata_inventory_take = function(pos, _, _, stack, player)
            if minetest.is_protected(pos, player:get_player_name()) then
                return 0
            end
            return stack:get_count()
        end,

        on_metadata_inventory_put = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local timer = minetest.get_node_timer(pos)

            if not inv:room_for_item("output", ingot_name) then
                timer:stop()
                return
            end

            local crucible = inv:get_stack("crucible", 1)
            local melt_perc = meta:get_int("melt_perc") or 0

            if melt_perc < 1 then
                update_forge_form(meta, water_type)
            end

            if crucible:get_name() == "waterdragon:dragonstone_crucible_full" then
                timer:start(1)
            end
        end,

        on_metadata_inventory_take = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local input = inv:get_stack("input", 1)
            local crucible = inv:get_stack("crucible", 1)
            local timer = minetest.get_node_timer(pos)
            local melt_perc = meta:get_int("melt_perc") or 0
            local cool_perc = meta:get_int("cool_perc") or 0

            if not crucible:get_name():match("^waterdragon:dragonstone_crucible") then
                if melt_perc > 0 then
                    meta:set_int("melt_perc", 0)
                end
                if cool_perc > 0 then
                    meta:set_int("cool_perc", 0)
                end
                timer:stop()
                update_forge_form(meta, water_type)
                return
            end

            if input:get_name() ~= steel_ingot then
                if melt_perc > 0 then
                    meta:set_int("last_perc", melt_perc)
                    meta:set_int("melt_perc", 0)
                end
                if cool_perc < 1 then
                    timer:stop()
                end
                update_forge_form(meta, water_type)
                return
            end

            if melt_perc < 1 then
                update_forge_form(meta, water_type)
            end
        end,

        on_timer = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local crucible = inv:get_stack("crucible", 1)
            local wtd_id = meta:get_string("wtd_id") ~= ""
            local melt_perc = meta:get_int("melt_perc") or 0
            local last_perc = melt_perc
            local cool_perc = meta:get_int("cool_perc") or 0

            if melt_perc >= 100 and wtd_id then
                melt_perc = 0
                melt_ingots(pos, meta:get_string("wtd_id"))
            end

            if cool_perc >= 100 then
                cool_perc = 0
                cool_crucible(pos, ingot_name)
                crucible = inv:get_stack("crucible", 1)
            end

            if wtd_id and melt_perc < 100 then
                melt_perc = melt_perc + 5
                meta:set_string("wtd_id", "")
            elseif melt_perc > 0 then
                melt_perc = melt_perc - 5
            end

            if crucible:get_name() == "waterdragon:dragonstone_crucible_full"
                and inv:room_for_item("output", ingot_name) then
                forge_particle(pos, particle_texture, {
                    type = 'vertical_frames',
                    aspect_w = 4,
                    aspect_h = 4,
                    length = 1,
                })
                cool_perc = cool_perc + 5
            end

            meta:set_int("last_perc", last_perc)
            meta:set_int("melt_perc", melt_perc)
            meta:set_int("cool_perc", cool_perc)

            update_forge_form(meta, water_type)
            return true
        end,

        on_breath = function(pos, id)
            if not get_forge_structure(pos) then return end
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local timer = minetest.get_node_timer(pos)
            local input = inv:get_stack("input", 1)
            local crucible = inv:get_stack("crucible", 1)

            if input:get_name() ~= steel_ingot
                or crucible:get_name() ~= "waterdragon:dragonstone_crucible" then
                update_forge_form(meta, water_type)
                forge_particle(pos, particle_texture, {
                    type = 'vertical_frames',
                    aspect_w = 4,
                    aspect_h = 4,
                    length = 1,
                })
                return
            end

            if not timer:is_started() and get_forge_structure(pos) then
                timer:start(1)
            end

            meta:set_string("wtd_id", id)

            forge_particle(pos, particle_texture)
        end,

        on_rightclick = function(pos, node, clicker)
            if not get_forge_structure(pos) then
                minetest.chat_send_player(clicker:get_player_name(), "The forge structure is incomplete.")
                return
            end
            local meta = minetest.get_meta(pos)
            update_forge_form(meta, water_type)
        end
    })
end

-- Register both forges
register_draconic_forge("pure_water")
register_draconic_forge("rare_water")

---------------------------
-- Scottish Dragon Forge --
---------------------------

minetest.register_node("waterdragon:scottish_dragon_forge", {
    description = S("Scottish Steel Forge"),
    tiles = {
        "waterdragon_scottish_dragon_forge_top.png",
        "waterdragon_scottish_dragon_forge_bottom.png",
        "waterdragon_scottish_dragon_forge_side.png",
    },
    paramtype2 = "facedir",
    groups = { cracky = 1, level = 2 },
    is_ground_content = false,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("crucible", 1)
        inv:set_size("output", 1)
        update_forge_form(meta, "scottish")
    end,

    can_dig = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("input") and inv:is_empty("crucible") and inv:is_empty("output")
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        if listname == "input" and stack:get_name() == "default:steel_ingot" then
            return stack:get_count()
        end
        if listname == "crucible" and stack:get_name() == "waterdragon:dragonstone_crucible" then
            return 1
        end
        return 0
    end,

    allow_metadata_inventory_move = function() return 0 end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        return stack:get_count()
    end,

    on_metadata_inventory_put = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local timer = minetest.get_node_timer(pos)

        if not inv:is_empty("input") and not inv:is_empty("crucible") then
            timer:start(1)
        end
    end,

    on_metadata_inventory_take = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local timer = minetest.get_node_timer(pos)

        if inv:is_empty("input") or inv:is_empty("crucible") then
            timer:stop()
        end
        update_forge_form(meta, "scottish")
    end,

    on_timer = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local input = inv:get_stack("input", 1)
        local crucible = inv:get_stack("crucible", 1)

        if input:get_name() == "default:steel_ingot" and input:get_count() > 0 and
            crucible:get_name() == "waterdragon:dragonstone_crucible" then
            meta:set_int("melt_perc", (meta:get_int("melt_perc") or 0) + 5)
            if meta:get_int("melt_perc") >= 100 then
                meta:set_int("melt_perc", 0)
                input:take_item(1)
                inv:set_stack("input", 1, input)
                inv:set_stack("crucible", 1, "waterdragon:dragonstone_crucible_full")
            end
        elseif crucible:get_name() == "waterdragon:dragonstone_crucible_full" then
            meta:set_int("cool_perc", (meta:get_int("cool_perc") or 0) + 1)
            if meta:get_int("cool_perc") >= 100 then
                meta:set_int("cool_perc", 0)
                local ingot = ItemStack("waterdragon:scottish_dragon_steel_ingot")
                local ingot_meta = ingot:get_meta()
                ingot_meta:set_string("scottish_id",
                    meta:get_string("last_scottish_id") or waterdragon.get_scottish_dragon_identifier())
                if inv:room_for_item("output", ingot) then
                    inv:add_item("output", ingot)
                    inv:set_stack("crucible", 1, "waterdragon:dragonstone_crucible")
                else
                    meta:set_int("cool_perc", 100)
                end
            end
        else
            meta:set_int("melt_perc", 0)
            meta:set_int("cool_perc", 0)
        end

        update_forge_form(meta, "scottish")
        return true
    end,

    on_fly = function(pos, scottish_id)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local crucible = inv:get_stack("crucible", 1)

        if crucible:get_name() == "waterdragon:dragonstone_crucible_full" then
            meta:set_int("cool_perc", math.min((meta:get_int("cool_perc") or 0) + 25, 100))
            meta:set_string("last_scottish_id", scottish_id)
        end

        minetest.add_particlespawner({
            amount = 30,
            time = 1,
            minpos = vector.subtract(pos, 0.5),
            maxpos = vector.add(pos, 0.5),
            minvel = { x = -1, y = 0, z = -1 },
            maxvel = { x = 1, y = 2, z = 1 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 1, z = 0 },
            minexptime = 1,
            maxexptime = 2,
            minsize = 1,
            maxsize = 3,
            texture = "waterdragon_water_particle.png",
        })

        update_forge_form(meta, "scottish")
    end
})


function update_forge_form(meta, forge_type)
    local melt_perc = meta:get_int("melt_perc") or 0
    local cool_perc = meta:get_int("cool_perc") or 0
    local formspec = table.concat({
        "formspec_version[3]",
        "size[11,10]",
        "image[0,0;11,10;waterdragon_form_forge_bg.png]",
        "image[3.475,1.3;1.56,0.39;waterdragon_form_pure_water_empty.png^[transformR270]",
        "image[6.35,1.325;1.95,0.39;waterdragon_form_pure_water_elbow_up_empty.png^[transformR270]",
        "image[7.91,1.7;0.39,1.69;waterdragon_form_pure_water_elbow_down_empty.png^[transformFY]]",
        "list[current_player;main;0.65,5;8,4;]",
        "list[context;input;2.325,1.05;1,1;]",
        "list[context;crucible;5.175,1.05;1,1;]",
        "list[context;output;7.65,3.5;1,1;]",
        "listring[current_player;main]",
        "listring[context;input]",
        "listring[current_player;main]",
        "listring[context;crucible]",
        "listring[current_player;main]",
        "listring[context;output]",
        "listring[current_player;main]"
    })

    if melt_perc > 0 and melt_perc <= 100 then
        formspec = formspec .. "image[3.475,1.3;1.56,0.39;waterdragon_form_pure_water_empty.png^[lowpart:" ..
            melt_perc .. ":waterdragon_form_pure_water_full.png^[transformR270]]"
    end

    if cool_perc > 0 and cool_perc <= 100 then
        local elbow_p1 = math.min(cool_perc * 2, 100)
        local elbow_p2 = math.max(cool_perc * 2 - 100, 0)
        formspec = formspec .. "image[6.35,1.325;1.95,0.39;waterdragon_form_pure_water_elbow_up_empty.png^[lowpart:" ..
            elbow_p1 .. ":waterdragon_form_pure_water_elbow_up_full.png^[transformR270]]"
        if elbow_p2 > 0 then
            formspec = formspec ..
                "image[7.91,1.7;0.39,1.69;waterdragon_form_pure_water_elbow_down_empty.png^[lowpart:" ..
                elbow_p2 .. ":waterdragon_form_pure_water_elbow_down_full.png^[transformFY]]"
        end
    end

    meta:set_string("formspec", formspec)
end

minetest.register_craftitem("waterdragon:scottish_dragon_steel_ingot", {
    description = S("Scottish Dragon-Forged Steel Ingot"),
    inventory_image = "waterdragon_scottish_dragon_steel_ingot.png",
})

waterdragon.on_scottish_dragon_fly = function(pos, scottish_id)
    local node = minetest.get_node(pos)
    if node.name == "waterdragon:scottish_dragon_forge" then
        local def = minetest.registered_nodes[node.name]
        if def and def.on_fly then
            def.on_fly(pos, scottish_id)
        end
    end
end
