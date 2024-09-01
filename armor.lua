-------------
--- Armour ---
-------------


local S = waterdragon.S

-- Pure Water-Forged Armour --

armor:register_armor("waterdragon:helmet_pure_water_draconic_steel", {
    description = S("Pure Water-Forged Draconic Steel Helmet"),
    inventory_image = "waterdragon_inv_helmet_pure_water_draconic_steel.png",
    groups = {armor_head=1, armor_heal=30, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=130},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
})
armor:register_armor("waterdragon:chestplate_pure_water_draconic_steel", {
    description = S("Pure Water-Forged Draconic Steel Chestplate"),
    inventory_image = "waterdragon_inv_chestplate_pure_water_draconic_steel.png",
    groups = {armor_torso=1, armor_heal=30, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=130},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
})
armor:register_armor("waterdragon:leggings_pure_water_draconic_steel", {
    description = S("Pure Water-Forged Draconic Steel Leggings"),
    inventory_image = "waterdragon_inv_leggings_pure_water_draconic_steel.png",
    groups = {armor_legs=1, armor_heal=30, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=130},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
})
armor:register_armor("waterdragon:boots_pure_water_draconic_steel", {
    description = S("Pure Water-Forged Draconic Steel Boots"),
    inventory_image = "waterdragon_inv_boots_pure_water_draconic_steel.png",
    groups = {armor_feet=1, armor_heal=30, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=130},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
})

-- Rare Water-Forged Armour --

armor:register_armor("waterdragon:helmet_rare_water_draconic_steel", {
    description = S("Rare Water-Forged Draconic Steel Helmet"),
    inventory_image = "waterdragon_inv_helmet_rare_water_draconic_steel.png",
    groups = {armor_head=1, armor_heal=40, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=150},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
})
armor:register_armor("waterdragon:chestplate_rare_water_draconic_steel", {
    description = S("Rare Water-Forged Draconic Steel Chestplate"),
    inventory_image = "waterdragon_inv_chestplate_rare_water_draconic_steel.png",
    groups = {armor_torso=1, armor_heal=40, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=150},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
})
armor:register_armor("waterdragon:leggings_rare_water_draconic_steel", {
    description = S("Rare Water-Forged Draconic Steel Leggings"),
    inventory_image = "waterdragon_inv_leggings_rare_water_draconic_steel.png",
    groups = {armor_legs=1, armor_heal=40, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=150},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
})
armor:register_armor("waterdragon:boots_rare_water_draconic_steel", {
    description = S("Rare Water-Forged Draconic Steel Boots"),
    inventory_image = "waterdragon_inv_boots_rare_water_draconic_steel.png",
    groups = {armor_feet=1, armor_heal=40, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=150},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
})

-- Pure Water Draconic Scale Armour

armor:register_armor("waterdragon:leggings_pure_water_draconic", {
    description = S("Pure Water Draconic Scale Leggings"),
    inventory_image = "waterdragon_leggings_pure_water_draconic_inv.png",
    groups = {armor_legs=1, armor_heal=20, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=80},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=10},
})

armor:register_armor("waterdragon:chestplate_pure_water_draconic", {
    description = S("Pure Water Draconic Scale Chestplate"),
    inventory_image = "waterdragon_chestplate_pure_water_draconic_inv.png",
    groups = {armor_torso=1, armor_heal=20, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=80},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=10},
})

armor:register_armor("waterdragon:helmet_pure_water_draconic", {
    description = S("Pure Water Draconic Scale Helmet"),
    inventory_image = "waterdragon_helmet_pure_water_draconic_inv.png",
    groups = {armor_head=1, armor_heal=20, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=70},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=10},
})

armor:register_armor("waterdragon:boots_pure_water_draconic", {
    description = S("Pure Water Draconic Scale Boots"),
    inventory_image = "waterdragon_boots_pure_water_draconic_inv.png",
    groups = {armor_feet=1, armor_heal=20, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=65},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=10},
})

-- Rare Water Draconic Scale Armour 

armor:register_armor("waterdragon:chestplate_rare_water_draconic", {
    description = S("Rare Water Draconic Scale Chestplate"),
    inventory_image = "waterdragon_chestplate_rare_water_draconic_inv.png",
    groups = {armor_torso=1, armor_heal=20, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=90},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=15},
})

armor:register_armor("waterdragon:helmet_rare_water_draconic", {
    description = S("Rare Water Draconic Scale Helmet"),
    inventory_image = "waterdragon_helmet_rare_water_draconic_inv.png",
    groups = {armor_head=1, armor_heal=20, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=80},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=15},
})

armor:register_armor("waterdragon:leggings_rare_water_draconic", {
    description = S("Rare Water Draconic Scale Leggings"),
    inventory_image = "waterdragon_leggings_rare_water_draconic_inv.png",
    groups = {armor_legs=1, armor_heal=20, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=85},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=15},
})

armor:register_armor("waterdragon:boots_rare_water_draconic", {
    description = S("Rare Water Draconic Scale Boots"),
    inventory_image = "waterdragon_boots_rare_water_draconic_inv.png",
    groups = {armor_feet=1, armor_heal=20, armor_use=100,
        physics_speed=0.5, physics_gravity=0.05, physics_jump=0.15, armor_fire=1},
    armor_groups = {fleshy=75},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=15},
})

-------------
-- Shields --
-------------

local REFLECTION_RANGE = 25  -- Damage reflection range in blocks

local function reflect_damage(player, damage)
    local hitter_name = player:get_meta():get_string("last_attacker")
    local hitter = minetest.get_player_by_name(hitter_name)
    
    if player and hitter then
        local player_pos = player:get_pos()
        local hitter_pos = hitter:get_pos()
        local distance = vector.distance(player_pos, hitter_pos)
        
        if distance <= REFLECTION_RANGE then
            local reflected_damage = damage * 0.8
            hitter:set_hp(hitter:get_hp() - reflected_damage)
            return damage * 0.2  -- Player receives only 20% of the original damage
        end
    end
    return damage  -- If attacker is out of range or not found, player receives full damage
end

-- Draconic Steel --

-- Pure Water

armor:register_armor("waterdragon:shield_pure_water_draconic_steel", {
    description = S("Pure Water Draconic Steel Shield"),
    inventory_image = "waterdragon_inv_shield_pure_water_draconic_steel.png",
    groups = {armor_shield=1, armor_heal=30, armor_use=100,
        physics_speed=0.1, physics_gravity=0.01, physics_jump=0.05, armor_fire=1},
    armor_groups = {fleshy=100},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
    reciprocate_damage = true,
    on_damage_taken = function(player, index, stack, use, damage)
        return reflect_damage(player, damage)
    end,
})

-- Rare Water
armor:register_armor("waterdragon:shield_rare_water_draconic_steel", {
    description = S("Rare Water Draconic Steel Shield"),
    inventory_image = "waterdragon_inv_shield_rare_water_draconic_steel.png",
    groups = {armor_shield=1, armor_heal=40, armor_use=100,
        physics_speed=0.15, physics_gravity=0.02, physics_jump=0.07, armor_fire=1},
    armor_groups = {fleshy=120},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=30},
    reciprocate_damage = true,
    on_damage_taken = function(player, index, stack, use, damage)
        return reflect_damage(player, damage)
    end,
})

-- Scale Shields --

-- Pure Water

armor:register_armor("waterdragon:shield_pure_water_scales", {
    description = S("Pure Water Draconic Scale Shield"),
    inventory_image = "waterdragon_inv_shield_pure_water_scales.png",
    groups = {armor_shield=1, armor_heal=30, armor_use=100,
        physics_speed=0.1, physics_gravity=0.01, physics_jump=0.05, armor_fire=1},
    armor_groups = {fleshy=100},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=10},
    reciprocate_damage = true,
    on_damage_taken = function(player, index, stack, use, damage)
        return reflect_damage(player, damage)
    end,
})

-- Rare Water

armor:register_armor("waterdragon:shield_rare_water_scales", {
    description = S("Rare Water Draconic Scale Shield"),
    inventory_image = "waterdragon_inv_shield_rare_water_scales.png",
    groups = {armor_shield=1, armor_heal=40, armor_use=100,
        physics_speed=0.15, physics_gravity=0.02, physics_jump=0.07, armor_fire=1},
    armor_groups = {fleshy=120},
    damage_groups = {cracky=1, snappy=3, choppy=2, crumbly=1, level=15},
    reciprocate_damage = true,
    on_damage_taken = function(player, index, stack, use, damage)
        return reflect_damage(player, damage)
    end,
})