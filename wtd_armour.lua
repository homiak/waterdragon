-- Water Dragon Armour --

waterdragon = waterdragon or {}

local S = waterdragon.S

waterdragon.get_armour_texture = function(armour_name)
    local armour_defs = {
        scottish = "waterdragon_scottish_armour_mesh.png",
        rare_water = "waterdragon_rare_water_armour_mesh.png",
        pure_water = "waterdragon_pure_water_armour_mesh.png",
    }
    return armour_defs[armour_name] or ""
end

local player_armor_state = {}

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    local pos = player:get_pos()
    local radius = 20
    local objects = minetest.get_objects_inside_radius(pos, radius)

    for _, obj in ipairs(objects) do
        local ent = obj:get_luaentity()
        if ent and ent.name:find("waterdragon:") and ent.armour then
            player_armor_state[name] = {
                dragon_name = ent.name,
                armor_name = ent.armour.name,
                protection = ent.armour.protection,
                texture = ent.armour.texture
            }
            break
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if player_armor_state[name] then
        minetest.after(1, function()
            local pos = player:get_pos()
            local radius = 20
            local objects = minetest.get_objects_inside_radius(pos, radius)

            for _, obj in ipairs(objects) do
                local ent = obj:get_luaentity()
                if ent and ent.name == player_armor_state[name].dragon_name then
                    -- Re-apply the armour to the Dragon
                    local props = obj:get_properties()
                    
                    -- Set up the armour
                    ent.armour = {
                        name = player_armor_state[name].armor_name,
                        protection = player_armor_state[name].protection,
                        texture = player_armor_state[name].texture
                    }
                    
                    -- Apply the armour texture over the base
                    props.textures[1] = ent.original_texture .. "^" .. ent.armour.texture
                    obj:set_properties(props)
                    
                    -- Save in memory
                    ent:memorize("armour", ent.armour)
                    ent:memorize("original_texture", ent.original_texture)
                    
                    player_armor_state[name] = nil
                    break
                end
            end
        end)
    end
end)


minetest.register_chatcommand("rem_wtd_armour", {
    params = "",
    description = S("Removes armour from the nearest Dragon"),
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        local pos = player:get_pos()
        local radius = 70
        local found = false

        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
            local ent = obj:get_luaentity()
            -- Look for any Dragon with armour
            if ent and ent.name and ent.name:find("waterdragon:") and ent.armour then
                -- Restore the original texture from memory
                local props = obj:get_properties()
                if props and props.textures then
                    local original_texture = ent:recall("original_texture")
                    if original_texture then
                        props.textures[1] = original_texture
                    else
                        -- Determine the type of Dragon and select the base texture
                        if ent.name == "waterdragon:scottish_dragon" then
                            props.textures[1] = "waterdragon_scottish_dragon.png^waterdragon_baked_in_shading.png"
                        elseif ent.name == "waterdragon:rare_water_dragon" then
                            props.textures[1] = "waterdragon_rare_water_dragon.png^waterdragon_baked_in_shading.png"
                        elseif ent.name == "waterdragon:pure_water_dragon" then
                            props.textures[1] = "waterdragon_pure_water_dragon.png^waterdragon_baked_in_shading.png"
                        end
                    end
                    obj:set_properties(props)
                end

                -- Save information about the removed armour for item return
                local removed_armour = ent.armour.name

                -- Remove armour information
                ent.armour = nil
                ent.original_texture = nil
                ent:memorize("armour", nil)
                ent:memorize("original_texture", nil)

                -- Return the armour item to the player
                local armour_item = ItemStack("waterdragon:armour_" .. removed_armour)
                local inv = player:get_inventory()
                if inv:room_for_item("main", armour_item) then
                    inv:add_item("main", armour_item)
                    found = true
                    return true, S("The armour has been removed from the Dragon and added to your inventory.")
                else
                    minetest.add_item(pos, armour_item)
                    found = true
                    return true, S("Armour has been removed from the Dragon, but your inventory is full. The item has been dropped nearby.")
                end
            end
        end

        if not found then
            return false, S("No Dragons with armour found nearby.")
        end
    end
})

waterdragon.register_mob_armour = function(name, def)
    local itemname = "waterdragon:armour_" .. name

    def.protection = math.max(1, math.min(10, def.protection or 1))

    minetest.register_craftitem(itemname, {
        description = def.description or ("Water Dragon Armour"),
        inventory_image = def.inventory_image,
        groups = { wtd_armour = 1 },

        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing.type == "object" then
                local obj = pointed_thing.ref
                local ent = obj:get_luaentity()

                if ent and ent.name == def.mob_name then
                    if ent.armour then
                        minetest.chat_send_player(user:get_player_name(), "This Dragon already has armour.")
                        return itemstack
                    end

                    -- Save the base texture before adding the armour
                    local props = obj:get_properties()
                    if not props or not props.textures or not props.textures[1] then return itemstack end

                    ent.original_texture = props.textures[1]

                    -- Save information about the armour
                    ent.armour = {
                        name = name,
                        protection = def.protection,
                        texture = def.dragon_armour_texture
                    }

                    -- Save the values using memorize
                    ent:memorize("armour", ent.armour)
                    ent:memorize("original_texture", ent.original_texture)

                    props.textures[1] = ent.original_texture .. "^" .. def.dragon_armour_texture
                    obj:set_properties(props)
                    -- Debug messages
                    minetest.chat_send_player(user:get_player_name(), "Armour has been put on the Dragon.")

                    -- Decrease the item stack count
                    itemstack:take_item()
                    return itemstack
                end
            end
            return itemstack
        end
    })
end

waterdragon.register_mob_armour("scottish", {
    description = S("Scottish Dragon Armour"),
    inventory_image = "waterdragon_scottish_armour_inv.png",
    dragon_armour_texture = "waterdragon_scottish_armour_mesh.png",
    mob_name = "waterdragon:scottish_dragon",
    protection = 8 -- Protection level from 1 to 10
})

minetest.register_craft({
    output = "waterdragon:armour_scottish",
    recipe = {
        { "waterdragon:draconic_steel_ingot_scottish", "waterdragon:draconic_steel_ingot_scottish", "waterdragon:draconic_steel_ingot_scottish" },
        { "waterdragon:draconic_steel_ingot_scottish", "waterdragon:draconic_steel_ingot_scottish", "waterdragon:draconic_steel_ingot_scottish" },
        { "waterdragon:draconic_steel_ingot_scottish", "waterdragon:draconic_steel_ingot_scottish", "waterdragon:draconic_steel_ingot_scottish" },
    }
})

waterdragon.register_mob_armour("pure_water", {
    description = S("Pure Water Dragon Armour"),
    inventory_image = "waterdragon_pure_water_armour_inv.png",
    dragon_armour_texture = "waterdragon_pure_water_armour_mesh.png",
    mob_name = "waterdragon:pure_water_dragon",
    protection = 8 -- Protection level from 1 to 10
})

minetest.register_craft({
    output = "waterdragon:armour_pure_water",
    recipe = {
        { "waterdragon:draconic_steel_ingot_pure_water", "waterdragon:draconic_steel_ingot_pure_water", "waterdragon:draconic_steel_ingot_pure_water" },
        { "waterdragon:draconic_steel_ingot_pure_water", "waterdragon:draconic_steel_ingot_pure_water", "waterdragon:draconic_steel_ingot_pure_water" },
        { "waterdragon:draconic_steel_ingot_pure_water", "waterdragon:draconic_steel_ingot_pure_water", "waterdragon:draconic_steel_ingot_pure_water" },
    }
})

waterdragon.register_mob_armour("rare_water", {
    description = S("Rare Water Dragon Armour"),
    inventory_image = "waterdragon_rare_water_armour_inv.png",
    dragon_armour_texture = "waterdragon_rare_water_armour_mesh.png",
    mob_name = "waterdragon:rare_water_dragon",
    protection = 8 -- Protection level from 1 to 10
})

minetest.register_craft({
    output = "waterdragon:armour_rare_water",
    recipe = {
        { "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water" },
        { "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water" },
        { "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water" },
    }
})