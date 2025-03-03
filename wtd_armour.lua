-- Water Dragon Armour --

waterdragon = waterdragon or {}

local S = waterdragon.S

waterdragon.get_armour_texture = function(armour_name)
    local armour_defs = {
        scottish = "waterdragon_scottish_armour.png",
        pure_water = "waterdragon_pure_water_armour.png",
        rare_water = "waterdragon_rare_water_armour.png",
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
                    ent.armour = {
                        name = player_armor_state[name].armor_name,
                        protection = player_armor_state[name].protection,
                        texture = player_armor_state[name].texture
                    }
                    local props = obj:get_properties()
                    props.textures[1] = player_armor_state[name].texture
                    obj:set_properties(props)
                    player_armor_state[name] = nil
                    break
                end
            end
        end)
    end
end)


waterdragon.register_mob_armour = function(name, def)
    
    local itemname = "waterdragon:armour_" .. name

    def.protection = math.max(1, math.min(10, def.protection or 1))

    minetest.register_craftitem(itemname, {
        description = def.description or ("Water Dragon Armour: " .. name .. " (Protection: " .. def.protection .. ")"),
        inventory_image = def.inventory_image,
        groups = { wtd_armour = 1 },

        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing.type == "object" then
                local obj = pointed_thing.ref
                local ent = obj:get_luaentity()
                if ent and ent.name == def.mob_name then
                    ent.armour = {
                        name = name,
                        protection = def.protection,
                        texture = def.dragon_armour_texture
                    }
                    local props = obj:get_properties()
                    props.textures[1] = def.dragon_armour_texture
                    obj:set_properties(props)
                    itemstack:take_item()
                    ent.armour = true
                    ent:memorize("armour", ent.armour)
                    return itemstack
                end
            end
        end
    })

    minetest.register_chatcommand("remove_armour", {
        params = "",
        description = "Removes armour from the nearest Water Dragon",
        func = function(name, param)
            local player = minetest.get_player_by_name(name)
            if not player then return false, "Player not found" end

            local pos = player:get_pos()
            local radius = 20
            local objects = minetest.get_objects_inside_radius(pos, radius)

            for _, obj in ipairs(objects) do
                local ent = obj:get_luaentity()
                if ent and ent.name == def.mob_name and ent.armour then
                    local props = obj:get_properties()
                    local new_textures = table.copy(props.textures)
                    new_textures[1] = new_textures[1]:gsub("^" .. def.dragon_armour_texture .. "%^", "")
                    props.textures = new_textures
                    obj:set_properties(props)
                    local removed_armour = ent.armour
                    ent.armour = nil

                    local armour_item = ItemStack(itemname)
                    local inv = player:get_inventory()
                    if inv:room_for_item("main", armour_item) then
                        obj.armour = false

                        inv:add_item("main", armour_item)
                        
                        return true,
                            "Armour successfully removed from " ..
                            def.mob_name ..
                            " (Protection was: " .. removed_armour.protection .. ") and added to your inventory"
                    else
                        minetest.add_item(player:get_pos(), armour_item)
                        return true,
                            "Armour successfully removed from " ..
                            def.mob_name .. " (Protection was: " .. removed_armour.protection .. ") and dropped near you"
                    end
                end
            end

            return false, "No Water Dragons with armour found nearby"
        end,
    })
end

waterdragon.register_mob_armour("scottish", {
    description = S("Scottish Dragon Armour"),
    inventory_image = "waterdragon_scottish_armour_inv.png",
    dragon_armour_texture = "waterdragon_scottish_armour.png",
    mob_name = "waterdragon:scottish_dragon",
    protection = 8 -- Protection level from 1 to 10
})

minetest.register_craft({
    output = "waterdragon:armour_scottish",
    recipe = {
        { "waterdragon:scottish_dragon_steel_ingot", "waterdragon:scottish_dragon_steel_ingot", "waterdragon:scottish_dragon_steel_ingot" },
        { "waterdragon:scottish_dragon_steel_ingot", "waterdragon:scottish_dragon_steel_ingot", "waterdragon:scottish_dragon_steel_ingot" },
        { "waterdragon:scottish_dragon_steel_ingot", "waterdragon:scottish_dragon_steel_ingot", "waterdragon:scottish_dragon_steel_ingot" },
    }
})

waterdragon.register_mob_armour("pure_water", {
    description = S("Pure Water Dragon Armour"),
    inventory_image = "waterdragon_pure_water_armour_inv.png",
    dragon_armour_texture = "waterdragon_pure_water_armour.png",
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
    dragon_armour_texture = "waterdragon_rare_water_armour.png",
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
