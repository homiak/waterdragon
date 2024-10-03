-- Water Dragon Armour --

waterdragon = waterdragon or {}

waterdragon.register_mob_armour = function(name, def)
    local itemname = "waterdragon:armour_" .. name

    minetest.register_craftitem(itemname, {
        description = def.description or ("Water Dragon Armour: " .. name),
        inventory_image = def.inventory_image,
        groups = {water_dragon_armour = 1},
        
        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing.type == "object" then
                local obj = pointed_thing.ref
                local ent = obj:get_luaentity()
                if ent and ent.name == def.mob_name then
                    ent.armour = name
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

    -- Register command for setting armour
    minetest.register_chatcommand("set_wtd_armour", {
        params = "",
        description = "Sets armour on the nearest Water Dragon by holding armour in hand and using the command",
        func = function(name, param)
            local player = minetest.get_player_by_name(name)
            if not player then return false, "Player not found" end

            local pos = player:get_pos()
            local radius = 5
            local objects = minetest.get_objects_inside_radius(pos, radius)
            
            for _, obj in ipairs(objects) do
                local ent = obj:get_luaentity()
                if ent and ent.name == def.mob_name then
                    local stack = player:get_wielded_item()
                    if stack:get_name() == itemname then
                        ent.armour = name
                        local props = obj:get_properties()
                        local new_textures = table.copy(props.textures)
                        new_textures[1] = def.texture .. "^" .. new_textures[1]
                        props.textures = new_textures
                        obj:set_properties(props)
                        stack:take_item()
                        player:set_wielded_item(stack)
                        return true, "Armour successfully set on " .. def.mob_name
                    end
                end
            end
            
            return false, "No suitable found nearby or no suitable armour in hand"
        end,
    })
end

waterdragon.register_mob_armour("scottish", {
    description = "Scottish Dragon Draconic Steel Armour",
    inventory_image = "waterdragon_scottish_armour_inv.png",
    texture = "waterdragon_scottish_armour.png",
    mob_name = "waterdragon:scottish_dragon"
})