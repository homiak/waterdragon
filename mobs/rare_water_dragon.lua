-----------------------
-- Rare Water Dragon --
-----------------------

local S = waterdragon.S

local creative = minetest.settings:get_bool("creative_mode")

local function is_value_in_table(tbl, val)
	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
	return false
end

-- Bonuses

local special_dragon_names = {
    ["Avalon"] = {
        health_bonus = 150,
        damage_bonus = 10,
        speed_bonus = 5,
        effect = "powerful"
    },
    ["Tarlochan"] = {
        health_bonus = 250,
        damage_bonus = 8,
        speed_bonus = 7,
        effect = "powerful"
    },
    ["Calleach"] = {
        health_bonus = 180,
        damage_bonus = 12,
        speed_bonus = 4,
        effect = "powerful"
    },
    ["Kilgara"] = {
        health_bonus = 250,
        damage_bonus = 15,
        speed_bonus = 4,
        effect = "powerful"
    },
    ["Cridheach-Uisge"] = {
        health_bonus = 200,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Leacach"] = {
        health_bonus = 170,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Albannach"] = {
        health_bonus = 200,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Loch Nis"] = {
        health_bonus = 200,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Loch Ness"] = {
        health_bonus = 180,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Uisge"] = {
        health_bonus = 150,
        damage_bonus = 5,
        speed_bonus = 4,
        effect = "powerful"
    },
    ["Loch Rannoch"] = {
        health_bonus = 190,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Kelpie"] = {
        health_bonus = 190,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Leviathan"] = {
        health_bonus = 180,
        damage_bonus = 4,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Kerran"] = {
        health_bonus = 210,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Dealanach"] = {
        health_bonus = 220,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },
    ["Deaglan"] = {
        health_bonus = 200,
        damage_bonus = 10,
        speed_bonus = 8,
        effect = "powerful"
    },

    -- Not very powerful names ..
    ["Suzie"] = {
        health_multiplier = 0.3,    -- 30% от обычного здоровья
        damage_multiplier = 0.2,    -- 20% от обычного урона
        speed_multiplier = 0.4,
        effect = "cute"
    },
    ["Susie"] = {
        health_multiplier = 0.3,    -- 30% от обычного здоровья
        damage_multiplier = 0.2,    -- 20% от обычного урона
        speed_multiplier = 0.4,
        effect = "cute"
    },
    ["suzie"] = {
        health_multiplier = 0.3,    -- 30% от обычного здоровья
        damage_multiplier = 0.2,    -- 20% от обычного урона
        speed_multiplier = 0.4,
        effect = "cute"
    },
    ["susie"] = {
        health_multiplier = 0.3,    -- 30% от обычного здоровья
        damage_multiplier = 0.2,    -- 20% от обычного урона
        speed_multiplier = 0.4,
        effect = "cute"
    },
    ["Bubbles"] = {
        health_multiplier = 0.35,
        damage_multiplier = 0.25,
        speed_multiplier = 0.45,
        effect = "cute"
    },
    ["Fishy"] = {
        health_multiplier = 0.25,
        damage_multiplier = 0.3,
        speed_multiplier = 0.35,
        effect = "cute"
    },
    ["Splashy"] = {
        health_multiplier = 0.4,
        damage_multiplier = 0.15,
        speed_multiplier = 0.5,
        effect = "cute"
    },
    ["Nemo"] = {
        health_multiplier = 0.3,
        damage_multiplier = 0.2,
        speed_multiplier = 0.45,
        effect = "cute"
    }
}

local function apply_name_bonuses(self)
    if not self.nametag then return end
    
    -- Проверяем, есть ли имя в списке особых
    local modifiers = special_dragon_names[self.nametag]
    if modifiers then
        if modifiers.effect == "powerful" then
            -- Для сильных драконов используем бонусы
            self.max_health = self.max_health + modifiers.health_bonus
            self.hp = self.max_health
            self.damage = self.damage + modifiers.damage_bonus
            self.speed = self.speed + modifiers.speed_bonus
        elseif modifiers.effect == "cute" then
            -- Для милых драконов используем множители
            self.max_health = math.floor(1600 * modifiers.health_multiplier)  -- 1600 - базовое здоровье
            self.hp = self.max_health
            self.damage = math.floor(40 * modifiers.damage_multiplier)        -- 40 - базовый урон
            self.speed = math.floor(50 * modifiers.speed_multiplier)          -- 50 - базовая скорость
            -- Уменьшаем размер для милых драконов
            self.growth_scale = (self.growth_scale or 1) * 0.7
            self:set_scale(self.growth_scale)
        end
        
        -- Визуальные эффекты
        minetest.after(0.1, function()
            if self and self.object then
                local pos = self.object:get_pos()
                if modifiers.effect == "powerful" then
                    minetest.add_particlespawner({
                        amount = 50,
                        time = 1,
                        minpos = vector.subtract(pos, 2),
                        maxpos = vector.add(pos, 2),
                        minvel = {x=-1, y=0, z=-1},
                        maxvel = {x=1, y=2, z=1},
                        minacc = {x=0, y=0.5, z=0},
                        maxacc = {x=0, y=1, z=0},
                        minexptime = 1,
                        maxexptime = 2,
                        minsize = 3,
                        maxsize = 5,
                        texture = "waterdragon_rare_water_particle_1.png",
                        glow = 14
                    })
                elseif modifiers.effect == "cute" then
                    minetest.add_particlespawner({
                        amount = 30,
                        time = 1,
                        minpos = vector.subtract(pos, 1),
                        maxpos = vector.add(pos, 1),
                        minvel = {x=-0.5, y=0, z=-0.5},
                        maxvel = {x=0.5, y=1, z=0.5},
                        minacc = {x=0, y=0.2, z=0},
                        maxacc = {x=0, y=0.5, z=0},
                        minexptime = 1,
                        maxexptime = 2,
                        minsize = 2,
                        maxsize = 3,
                        texture = "heart.png",
                        glow = 8
                    })
                end
                
                -- Сообщение владельцу
                local owner = self.owner or ""
                if modifiers.effect == "powerful" then
                    minetest.chat_send_player(owner, "Your Dragon " .. self.nametag .. " feels powerful!")
                elseif modifiers.effect == "cute" then
                    minetest.chat_send_player(owner, "Your Dragon " .. self.nametag .. " is adorable but very weak! You can better give him a more powerful name such as Kilgara or Avalon")
                end
            end
        end)
        
        -- Изменяем звуки для милых драконов
        if modifiers.effect == "cute" then
            self.sounds.random = {
                {name = "waterdragon_water_dragon_child_1", gain = 0.7, distance = 32},
                {name = "waterdragon_water_dragon_child_2", gain = 0.7, distance = 32}
            }
        end
    end
end

function dragon_stay_behavior(self)
    if self.order ~= "stay" then return end
    if self.rider then return end
    local vel = self.object:get_velocity()
    local pos = self.object:get_pos()
    local node_below = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})

    if vel.y < -0.5 and minetest.get_item_group(node_below.name, "liquid") == 0 then
        self.object:set_velocity({x=0, y=0, z=0})
        self:set_forward_velocity(0)
        self:set_vertical_velocity(0)
        self.object:set_acceleration({x=0, y=0, z=0})
        self:animate("hover")
    else
        self.object:set_acceleration({x=0, y=-9.81, z=0})
    end
end


local colors = {"rare_water"}

modding.register_mob("waterdragon:rare_water_dragon", {
    max_health = 1600,
    max_hunger = 500,
    max_breath = 0,
    fire_resistance = 1,
    armor_groups = {fleshy = 50},
    damage = 40,
    turn_rate = 7,
    speed = 50,
    tracking_range = 128,
    despawn_after = false,
    stepheight = 5.50,
    max_fall = 0,
    mesh = "waterdragon_water_dragon.b3d",
    hitbox = {
        width = 5,
        height = 10
    },
    visual_size = {x = 40, y = 40},
    glow = 12,
    backface_culling = false,
    use_texture_alpha = false,
    textures = {
        "waterdragon_rare_water_dragon.png^waterdragon_baked_in_shading.png"
    },
    child_textures = {
        "waterdragon_rare_water_dragon.png^waterdragon_baked_in_shading.png",
    },
    animations = {
        stand = {range = {x = 1, y = 59}, speed = 8, frame_blend = 0.3, loop = true},
        stand_water = {range = {x = 61, y = 119}, speed = 20, frame_blend = 0.3, loop = true},
        slam = {range = {x = 121, y = 159}, speed = 30, frame_blend = 0.3, loop = false},
        repel = {range = {x = 161, y = 209}, speed = 30, frame_blend = 0.3, loop = false},
        walk = {range = {x = 211, y = 249}, speed = 40, frame_blend = 0.3, loop = true},
        walk_slow = {range = {x = 211, y = 249}, speed = 15, frame_blend = 0.3, loop = true},
        walk_pure_water = {range = {x = 251, y = 289}, speed = 30, frame_blend = 0.3, loop = true},
        takeoff = {range = {x = 291, y = 319}, speed = 30, frame_blend = 0.3, loop = false},
        hover = {range = {x = 321, y = 359}, speed = 30, frame_blend = 0.3, loop = true},
        hover_pure_water = {range = {x = 361, y = 399}, speed = 30, frame_blend = 0.3, loop = true},
        fly = {range = {x = 401, y = 439}, speed = 30, frame_blend = 0.3, loop = true},
        fly_pure_water = {range = {x = 441, y = 479}, speed = 30, frame_blend = 0.3, loop = true},
        land = {range = {x = 481, y = 509}, speed = 30, frame_blend = 0.3, loop = false},
        sleep = {range = {x = 511, y = 569.5}, speed = 6, frame_blend = 1, prty = 2, loop = true},
        death = {range = {x = 571, y = 579}, speed = 30, frame_blend = 5, prty = 3, loop = false},
        shoulder_idle = {range = {x = 581, y = 639}, speed = 30, frame_blend = 0.6, loop = true},
    },
    sounds = {
        random = {
            {name = "waterdragon_water_dragon_random_1", gain = 1, distance = 64, length = 2},
            {name = "waterdragon_water_dragon_random_2", gain = 1, distance = 64, length = 2.5},
            {name = "waterdragon_water_dragon_random_3", gain = 1, distance = 64, length = 4}
        }
    },
    child_sounds = {
        random = {
            {name = "waterdragon_water_dragon_child_1", gain = 1, distance = 8, length = 1},
            {name = "waterdragon_water_dragon_child_2", gain = 1, distance = 8, length = 2}
        }
    },
    drops = {},
    follow = {"group:meat"},
    dynamic_anim_data = {
        yaw_factor = 0.35,
        swing_factor = -0.2,
        pivot_h = 0.5,
        pivot_v = 0.75,
        tail = {
            {pos = {x = 0, y = -0.06, z = 0.6}, rot = {x = 225, y = 180, z = 1}},
            {pos = {x = 0, y = 1.45, z = 0}, rot = {x = 0, y = 0, z = 1}},
            {pos = {x = 0, y = 1.6, z = 0}, rot = {x = 0, y = 0, z = 1}}
        },
        head = {
            {pitch_offset = 0, bite_angle = -10, pitch_factor = 0.11, pos = {x = 0, y = 1.15, z = 0}, rot = {x = 0, y = 0, z = 0}},
            {pitch_offset = -5, bite_angle = 10, pitch_factor = 0.11, pos = {x = 0, y = 0.65, z = 0}, rot = {x = 0, y = 0, z = 0}},
            {pitch_offset = -5, bite_angle = 5, pitch_factor = 0.22, pos = {x = 0, y = 0.65, z = 0.05}, rot = {x = 0, y = 0, z = 0}}
        },
        jaw = {pos = {y = 0.15, z = -0.29}}
    },
    breath_attack = waterdragon.rare_water_breath,
    utility_stack = waterdragon.dragon_behavior,
    activate_func = function(self)
        waterdragon.dragon_activate(self)
        apply_name_bonuses(self)
    end,
    step_func = function(self, dtime, moveresult)
        waterdragon.dragon_step(self, dtime, moveresult)
        dragon_stay_behavior(self)
    end,
    on_rightclick = function(self, clicker)
        waterdragon.dragon_rightclick(self, clicker)
        local item = clicker:get_wielded_item()
        local item_name = item:get_name()
        if minetest.get_item_group(item_name, "water_dragon_armour") > 0 then
            local armour_def = minetest.registered_items[item_name]
            if armour_def and armour_def.on_use then
                return armour_def.on_use(item, clicker, {type="object", ref=self.object})
            end
        end
    end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
        if time_from_last_punch < 0.66 or (self.passenger and puncher == self.passenger) or (self.rider and puncher == self.rider) then return end
        modding.basic_punch_func(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
        if not self.is_landed then
            self.flight_stamina = self:memorize("flight_stamina", self.flight_stamina - 10)
        end
        self.alert_timer = self:memorize("alert_timer", 15)
        local puncher_name = puncher:get_player_name() or puncher:get_luaentity().name
        local current_time = minetest.get_gametime()
        
        -- Initialize punch tracking
        if not self.punch_data then
            self.punch_data = { count = 0, last_punch_time = 0, attacker = nil }
        end
        
        -- If the puncher is the same and it's within 30 seconds, increment the punch count
        if self.punch_data.attacker == puncher_name and (current_time - self.punch_data.last_punch_time) <= 30 then
            self.punch_data.count = self.punch_data.count + 1
        else
            -- Reset counter if it's a new attacker or more than 30 seconds have passed
            self.punch_data.count = 1
            self.punch_data.attacker = puncher_name
        end
        
        -- Update the time of the last punch
        self.punch_data.last_punch_time = current_time
        
        -- If punched 6 times within 30 seconds, attack the puncher
        if self.punch_data.count >= 6 then
            -- Reset the counter
            self.punch_data.count = 0
        
            -- Make the dragon attack the puncher
            self.attack_target = puncher
            local tgt_pos = puncher:get_pos()
            self:breath_attack(tgt_pos)
            waterdragon.action_slam(self)
            waterdragon.action_hover_pure_water(self, puncher, 100)
            waterdragon.action_flight_pure_water(self, puncher, 100000)
        end
    end,
    deactivate_func = function(self)
        if not waterdragon.waterdragons[self.wtd_id] then return end
        local owner = waterdragon.waterdragons[self.wtd_id].owner
        if not owner then return end
        if not waterdragon.bonded_wtd then return end
        if waterdragon.bonded_wtd[owner] and is_value_in_table(waterdragon.bonded_wtd[owner], self.wtd_id) then
            for i = #waterdragon.bonded_wtd[owner], 1, -1 do
                if waterdragon.bonded_wtd[owner][i] == self.wtd_id then
                    waterdragon.bonded_wtd[owner][i] = nil
                end
            end
        end
    end,
    on_activate = function(self, staticdata, dtime_s)
		if staticdata ~= "" then
			local data = minetest.deserialize(staticdata)
			if data and data.armour then
				self.armour = data.armour
			end
		end
	
		if self.armour and self.armour.texture then
			local props = self.object:get_properties()
			props.textures[1] = self.armour.texture
			self.object:set_properties(props)
		end
	
		if self.dragon_activate then
			self.dragon_activate(self)
		end
	end,
    get_staticdata = function(self)
		local data = {
			armour = self.armour,
		}
		return minetest.serialize(data)
	end,
    death_func = function(self)
        self:clear_action()
        self:clear_utility()
        self:animate("death")
        self:set_gravity(-9.8)
        if self.rider then
            waterdragon.detach_player(self, self.rider)
        end
        if self.passenger then
            waterdragon.detach_player(self, self.passenger)
        end
        local rot = self.object:get_rotation()
        if rot.x ~= 0 or rot.z ~= 0 then
            self.object:set_rotation({x = 0, y = rot.y, z = 0})
        end
    end
})

modding.register_spawn_item("waterdragon:rare_water_dragon", {
	description = S("Creative Rare Water Dragon Egg"),
	inventory_image = "waterdragon_creative_egg_rare_water.png"
})

local spawn_egg_def = minetest.registered_items["waterdragon:spawn_rare_water_dragon"]

spawn_egg_def.on_place = function(itemstack, _, pointed_thing)
	local pos = minetest.get_pointed_thing_position(pointed_thing, true)
	waterdragon.spawn_dragon(pos, "waterdragon:rare_water_dragon", false, math.random(75, 100))
	if creative then
		itemstack:take_item()
		return itemstack
	end
	if  not creative then
		itemstack:take_item()
		return itemstack
	end
end

minetest.register_craftitem("waterdragon:spawn_rare_water_dragon", spawn_egg_def)

function rescue_pegasus(rescuer, pegasus)
    if not pegasus.needs_rescue then return end


    local start_pos = pegasus.object:get_pos()
    local max_height = start_pos.y + 50
    local rescue_pos = {
        x = start_pos.x + math.random(-20, 20),
        y = start_pos.y,
        z = start_pos.z + math.random(-20, 20)
    }
    local original_properties = pegasus.object:get_properties()
    
    pegasus.object:set_properties({
        visual_size = {x = 0.4, y = 0.4, z = 0.4},
        collisionbox = {-0.26, 0, -0.26, 0.26, 0.78, 0.26}
    })
    pegasus.object:set_attach(rescuer, "", {x=0, y=1.5, z=-2}, {x=0, y=0, z=0})

    if waterdragon and waterdragon.action_fly then
        local flight_duration = 20
        local descent_start = 15
        local function smooth_flight(t)
            if t < descent_start then
                return math.min(max_height, start_pos.y + (max_height - start_pos.y) * (t / descent_start))
            else
                local descent_progress = (t - descent_start) / (flight_duration - descent_start)
                return max_height - (max_height - rescue_pos.y) * descent_progress
            end
        end
        for t = 1, flight_duration do
            minetest.after(t, function()
                local current_pos = rescuer:get_pos()
                local progress = t / flight_duration
                local new_pos = {
                    x = start_pos.x + (rescue_pos.x - start_pos.x) * progress,
                    y = smooth_flight(t),
                    z = start_pos.z + (rescue_pos.z - start_pos.z) * progress
                }
                waterdragon.action_fly(rescuer:get_luaentity(), new_pos, 1, "waterdragon:fly_simple", 1, "fly")
            end)
        end
        minetest.after(flight_duration + 1, function()
            pegasus.object:set_detach()
            pegasus.object:set_properties(original_properties)
            
            pegasus.object:set_pos(rescue_pos)
        end)
    else
        pegasus.object:set_detach()
        pegasus.object:set_properties(original_properties)
    end

    pegasus.needs_rescue = false
    pegasus.attack_count = 0
end



minetest.register_globalstep(function(dtime)
    if not _G.pegasus_rescue_initialized then
        _G.pegasus_rescue_initialized = true
        _G.rescue_pegasus = rescue_pegasus
    end
end)



