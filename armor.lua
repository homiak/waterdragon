-------------
--- Armour ---
-------------


local S = waterdragon.S

-- Pure Water-Forged Armour --

armor:register_armor("waterdragon:helmet_pure_water_draconic_steel", {
    description = S("Pure Water-Forged Draconic Steel Helmet"),
    inventory_image = "waterdragon_inv_helmet_pure_water_draconic_steel.png",
    groups = {
        armor_head = 1,
        armor_heal = 30,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 130 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:chestplate_pure_water_draconic_steel", {
    description = S("Pure Water-Forged Draconic Steel Chestplate"),
    inventory_image = "waterdragon_inv_chestplate_pure_water_draconic_steel.png",
    groups = {
        armor_torso = 1,
        armor_heal = 30,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 130 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:leggings_pure_water_draconic_steel", {
    description = S("Pure Water-Forged Draconic Steel Leggings"),
    inventory_image = "waterdragon_inv_leggings_pure_water_draconic_steel.png",
    groups = {
        armor_legs = 1,
        armor_heal = 30,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 130 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:boots_pure_water_draconic_steel", {
    description = S("Pure Water-Forged Draconic Steel Boots"),
    inventory_image = "waterdragon_inv_boots_pure_water_draconic_steel.png",
    groups = {
        armor_feet = 1,
        armor_heal = 30,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 130 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})

-- Rare Water-Forged Armour --

armor:register_armor("waterdragon:helmet_rare_water_draconic_steel", {
    description = S("Rare Water-Forged Draconic Steel Helmet"),
    inventory_image = "waterdragon_inv_helmet_rare_water_draconic_steel.png",
    groups = {
        armor_head = 1,
        armor_heal = 40,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 150 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:chestplate_rare_water_draconic_steel", {
    description = S("Rare Water-Forged Draconic Steel Chestplate"),
    inventory_image = "waterdragon_inv_chestplate_rare_water_draconic_steel.png",
    groups = {
        armor_torso = 1,
        armor_heal = 40,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 150 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:leggings_rare_water_draconic_steel", {
    description = S("Rare Water-Forged Draconic Steel Leggings"),
    inventory_image = "waterdragon_inv_leggings_rare_water_draconic_steel.png",
    groups = {
        armor_legs = 1,
        armor_heal = 40,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 150 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:boots_rare_water_draconic_steel", {
    description = S("Rare Water-Forged Draconic Steel Boots"),
    inventory_image = "waterdragon_inv_boots_rare_water_draconic_steel.png",
    groups = {
        armor_feet = 1,
        armor_heal = 40,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 150 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})

-- Scottish Armour

armor:register_armor("waterdragon:helmet_scottish_draconic_steel", {
    description = S("Scottish Water-Forged Draconic Steel Helmet"),
    inventory_image = "waterdragon_scottish_dragon_draconic_helmet.png",
    groups = {
        armor_head = 1,
        armor_heal = 30,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 130 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:chestplate_scottish_draconic_steel", {
    description = S("Scottish Water-Forged Draconic Steel Chestplate"),
    inventory_image = "waterdragon_scottish_dragon_draconic_chestplate.png",
    groups = {
        armor_torso = 1,
        armor_heal = 30,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 130 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:leggings_scottish_draconic_steel", {
    description = S("Scottish Water-Forged Draconic Steel Leggings"),
    inventory_image = "waterdragon_scottish_dragon_draconic_leggings.png",
    groups = {
        armor_legs = 1,
        armor_heal = 30,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 130 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})
armor:register_armor("waterdragon:boots_scottish_draconic_steel", {
    description = S("Scottish Water-Forged Draconic Steel Boots"),
    inventory_image = "waterdragon_scottish_dragon_draconic_boots.png",
    groups = {
        armor_feet = 1,
        armor_heal = 30,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 130 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
})

-- Pure Water Draconic Scale Armour

armor:register_armor("waterdragon:leggings_pure_water_draconic", {
    description = S("Pure Water Draconic Scale Leggings"),
    inventory_image = "waterdragon_leggings_pure_water_draconic_inv.png",
    groups = {
        armor_legs = 1,
        armor_heal = 20,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 80 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 10 },
})

armor:register_armor("waterdragon:chestplate_pure_water_draconic", {
    description = S("Pure Water Draconic Scale Chestplate"),
    inventory_image = "waterdragon_chestplate_pure_water_draconic_inv.png",
    groups = {
        armor_torso = 1,
        armor_heal = 20,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 80 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 10 },
})

armor:register_armor("waterdragon:helmet_pure_water_draconic", {
    description = S("Pure Water Draconic Scale Helmet"),
    inventory_image = "waterdragon_helmet_pure_water_draconic_inv.png",
    groups = {
        armor_head = 1,
        armor_heal = 20,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 70 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 10 },
})

armor:register_armor("waterdragon:boots_pure_water_draconic", {
    description = S("Pure Water Draconic Scale Boots"),
    inventory_image = "waterdragon_boots_pure_water_draconic_inv.png",
    groups = {
        armor_feet = 1,
        armor_heal = 20,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 65 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 10 },
})

-- Rare Water Draconic Scale Armour

armor:register_armor("waterdragon:chestplate_rare_water_draconic", {
    description = S("Rare Water Draconic Scale Chestplate"),
    inventory_image = "waterdragon_chestplate_rare_water_draconic_inv.png",
    groups = {
        armor_torso = 1,
        armor_heal = 20,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 90 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 15 },
})

armor:register_armor("waterdragon:helmet_rare_water_draconic", {
    description = S("Rare Water Draconic Scale Helmet"),
    inventory_image = "waterdragon_helmet_rare_water_draconic_inv.png",
    groups = {
        armor_head = 1,
        armor_heal = 20,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 80 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 15 },
})

armor:register_armor("waterdragon:leggings_rare_water_draconic", {
    description = S("Rare Water Draconic Scale Leggings"),
    inventory_image = "waterdragon_leggings_rare_water_draconic_inv.png",
    groups = {
        armor_legs = 1,
        armor_heal = 20,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 85 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 15 },
})

armor:register_armor("waterdragon:boots_rare_water_draconic", {
    description = S("Rare Water Draconic Scale Boots"),
    inventory_image = "waterdragon_boots_rare_water_draconic_inv.png",
    groups = {
        armor_feet = 1,
        armor_heal = 20,
        armor_use = 100,
        physics_speed = 0.5,
        physics_gravity = 0.05,
        physics_jump = 0.15,
        armor_fire = 1
    },
    armor_groups = { fleshy = 75 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 15 },
})

-------------
-- Shields --
-------------

local function reflect_damage(player, damage)
    local attacker = player:get_meta():get_string("last_attacker")
    if attacker and attacker ~= "" then
        local attacker_obj = minetest.get_player_by_name(attacker)
        if attacker_obj then
            -- Отражаем 80% урона обратно атакующему
            local reflected_damage = damage * 0.8
            attacker_obj:set_hp(attacker_obj:get_hp() - reflected_damage)
            -- Игрок получает только 20% от изначального урона
            return damage * 0.2
        end
    end
    -- Если атакующий не найден, игрок получает весь урон
    return damage
end

-- Регистрируем обработчик на урон
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change >= 0 or not player then
        return hp_change -- Игнорируем положительные изменения HP
    end

    -- Проверяем, есть ли у игрока щит в слоте
    local inv = player:get_inventory()
    local shield_stack = inv:get_stack("armor_shield", 1)
    if shield_stack:get_name() == "waterdragon:shield_pure_water_draconic_steel" then
        -- Применяем отражение урона
        return reflect_damage(player, math.abs(hp_change)) * -1
    end

    return hp_change -- Если щита нет, возвращаем исходный урон
end)

-- Draconic Steel Shields

armor:register_armor("waterdragon:shield_pure_water_draconic_steel", {
    description = S("Pure Water Draconic Steel Shield"),
    inventory_image = "waterdragon_inv_shield_pure_water_draconic_steel.png",
    groups = { armor_shield = 1, armor_heal = 30, armor_use = 100 },
    armor_groups = { fleshy = 100 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 },
    on_damage_taken = function(player, index, stack, use, damage)
        return reflect_damage(player, damage)
    end,
})

armor:register_armor("waterdragon:shield_rare_water_draconic_steel", {
    description = S("Rare Water Draconic Steel Shield"),
    inventory_image = "waterdragon_inv_shield_rare_water_draconic_steel.png",
    groups = { armor_shield = 1, armor_heal = 40, armor_use = 100 },
    armor_groups = { fleshy = 120 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 30 }
})

-- Scale Shields

armor:register_armor("waterdragon:shield_pure_water_scales", {
    description = S("Pure Water Draconic Scale Shield"),
    inventory_image = "waterdragon_inv_shield_pure_water_scales.png",
    groups = { armor_shield = 1, armor_heal = 30, armor_use = 100 },
    armor_groups = { fleshy = 100 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 10 },
    on_damage_taken = function(player, index, stack, use, damage)
        return reflect_damage(player, damage)
    end,
})

armor:register_armor("waterdragon:shield_rare_water_scales", {
    description = S("Rare Water Draconic Scale Shield"),
    inventory_image = "waterdragon_inv_shield_rare_water_scales.png",
    groups = { armor_shield = 1, armor_heal = 40, armor_use = 100 },
    armor_groups = { fleshy = 120 },
    damage_groups = { cracky = 1, snappy = 3, choppy = 2, crumbly = 1, level = 15 },
    on_damage_taken = function(player, index, stack, use, damage)
        return reflect_damage(player, damage)
    end,
})
