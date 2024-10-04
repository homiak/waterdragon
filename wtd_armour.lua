-- Water Dragon Armour --

waterdragon = waterdragon or {}

local S = waterdragon.S

waterdragon.register_mob_armour = function(name, def, staticdata, self)
    local itemname = "waterdragon:armour_" .. name



    -- Ensure protection level is within valid range
    def.protection = math.max(1, math.min(10, def.protection or 1))

    -- Register armour item
    minetest.register_craftitem(itemname, {
        description = def.description or ("Water Dragon Armour: " .. name .. " (Protection: " .. def.protection .. ")"),
        inventory_image = def.inventory_image,
        groups = {water_dragon_armour = 1},
        
        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing.type == "object" then
                local obj = pointed_thing.ref
                local ent = obj:get_luaentity()
                if ent and ent.name == def.mob_name then
                    ent.armour = {name = name, protection = def.protection}
                    local props = obj:get_properties()
                    local new_textures = table.copy(props.textures)
                    new_textures[1] = def.texture .. "^" .. new_textures[1]
                    props.textures = new_textures
                    obj:set_properties(props)
                    itemstack:take_item()
                    return itemstack
                end
            end
        end
    })
  

    -- Register command for removing armour
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
                    new_textures[1] = new_textures[1]:gsub("^" .. def.texture .. "%^", "")
                    props.textures = new_textures
                    obj:set_properties(props)
                    local removed_armour = ent.armour
                    ent.armour = nil

                    -- Create and add the armour item to player's inventory
                    local armour_item = ItemStack(itemname)
                    local inv = player:get_inventory()
                    if inv:room_for_item("main", armour_item) then
                        inv:add_item("main", armour_item)
                        return true, "Armour successfully removed from " .. def.mob_name .. " (Protection was: " .. removed_armour.protection .. ") and added to your inventory"
                    else
                        minetest.add_item(player:get_pos(), armour_item)
                        return true, "Armour successfully removed from " .. def.mob_name .. " (Protection was: " .. removed_armour.protection .. ") and dropped near you"
                    end
                end
            end
            
            return false, "No Water Dragons with armour found nearby"
        end,
    })

    minetest.register_chatcommand("set_armour", {
        params = "",
        description = "Sets armour on the nearest Water Dragon",
        func = function(name, param)
            local player = minetest.get_player_by_name(name)
            if not player then return false, "Player not found" end

            local pos = player:get_pos()
            local radius = 20
            local objects = minetest.get_objects_inside_radius(pos, radius)
            
            for _, obj in ipairs(objects) do
                local ent = obj:get_luaentity()
                if ent and ent.name == def.mob_name then
                    local stack = player:get_wielded_item()
                    if stack:get_name() == itemname then
                        ent.armour = {name = name, protection = def.protection}
                        local props = obj:get_properties()
                        local new_textures = table.copy(props.textures)
                        new_textures[1] = def.texture .. "^" .. new_textures[1]
                        props.textures = new_textures
                        obj:set_properties(props)
                        stack:take_item()
                        player:set_wielded_item(stack)
                        return true, "Armour successfully set on " .. def.mob_name .. " (Protection: " .. def.protection .. ")"
                    end
                end
            end
            
            return false, "No suitable Water Dragons found nearby or no suitable armour in hand"
        end,
    })



    -- Register command for checking armour
    minetest.register_chatcommand("check_wtd_armour", {
        params = "",
        description = "Checks armour on the nearest Water Dragon",
        func = function(name, param)
            local player = minetest.get_player_by_name(name)
            if not player then return false, "Player not found" end

            local pos = player:get_pos()
            local radius = 20
            local objects = minetest.get_objects_inside_radius(pos, radius)
            
            for _, obj in ipairs(objects) do
                local ent = obj:get_luaentity()
                if ent and ent.name == def.mob_name then
                    if ent.armour then
                        return true, def.mob_name .. " is wearing " .. ent.armour.name .. " armour (Protection: " .. ent.armour.protection .. ")"
                    else
                        return true, def.mob_name .. " is not wearing any armour"
                    end
                end
            end
            
            return false, "No Water Dragons found nearby"
        end,
    })
end

waterdragon.register_mob_armour("scottish", {
    description = "Scottish Dragon Armour",
    inventory_image = "waterdragon_scottish_armour_inv.png",
    texture = "waterdragon_scottish_armour.png",
    mob_name = "waterdragon:scottish_dragon",
    protection = 8  -- Protection level from 1 to 10
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
    description = "Pure Water Dragon Armour",
    inventory_image = "waterdragon_pure_water_armour_inv.png",
    texture = "waterdragon_pure_water_armour.png",
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
    description = "Rare Water Dragon Armour",
    inventory_image = "waterdragon_rare_water_armour_inv.png",
    texture = "waterdragon_rare_water_armour.png",
    mob_name = "waterdragon:rare_water_dragon",
    protection = 8  -- Protection level from 1 to 10
})

minetest.register_craft({
	output = "waterdragon:armour_rare_water",
	recipe = {
		{ "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water" },
		{ "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water" },
		{ "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water", "waterdragon:draconic_steel_ingot_rare_water" },
	}
})