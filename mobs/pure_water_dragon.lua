-----------------------
-- Pure Water Dragon --
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

local light_blocks = {}

function waterdragon.register_node(name, def)
    minetest.register_node(name, def)
end

waterdragon.register_node("waterdragon:light_source", {
    description = "Light Source (from Waterdragon mod)",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = "",
    light_source = 14,
    groups = {not_in_creative_inventory = 1},
})

local function set_node_light(pos, light_level)
    local node = minetest.get_node(pos)
    if node.name == "air" then
        minetest.set_node(pos, {name = "waterdragon:light_source", param2 = light_level})
        table.insert(light_blocks, pos)
    elseif node.name == "waterdragon:light_source" then
        minetest.set_node(pos, {name = "waterdragon:light_source", param2 = light_level})
    end
end

local function remove_light_blocks(keep_radius, center_pos)
    local new_light_blocks = {}
    for _, pos in ipairs(light_blocks) do
        if vector.distance(center_pos, pos) > keep_radius then
            local node = minetest.get_node(pos)
            if node.name == "waterdragon:light_source" then
                minetest.set_node(pos, {name = "air"})
            end
        else
            table.insert(new_light_blocks, pos)
        end
    end
    light_blocks = new_light_blocks
end

local function update_dragon_lighting(dragon, is_night)
    local pos = dragon.object:get_pos()
    local radius = 5
    local light_level = is_night and 14 or 0

    for x = -radius, radius do
        for y = -radius, radius do
            for z = -radius, radius do
                local block_pos = {x = math.floor(pos.x + x), y = math.floor(pos.y + y), z = math.floor(pos.z + z)}
                if vector.distance(pos, block_pos) <= radius then
                    set_node_light(block_pos, light_level)
                end
            end
        end
    end

    remove_light_blocks(radius, pos)
end

local function on_dragon_step(self, dtime)
    local time_of_day = minetest.get_timeofday()
    local is_night = time_of_day >= 0.5 and time_of_day < 1

    if is_night then
        self.object:set_properties({glow = 14})
    else
        self.object:set_properties({glow = 7})
    end

    update_dragon_lighting(self, is_night)
    
    waterdragon.dragon_step(self, dtime)
end

local colors = {"pure_water"}

modding.register_mob("waterdragon:pure_water_dragon", {
	-- Stats
	max_health = 1500,
	max_hunger = 500,
	max_breath = 0,
	fire_resistance = 1,
	armor_groups = {fleshy = 50},
	damage = 35,
	turn_rate = 7,
	speed = 50,
	tracking_range = 128,
	-- Entity Physics
	stepheight = 5.50,
	max_fall = 0,
	-- Visuals
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
		"waterdragon_pure_water_dragon.png^waterdragon_baked_in_shading.png",
	},
	child_textures = {
		"waterdragon_pure_water_dragon.png^waterdragon_baked_in_shading.png",
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
		sleep = {range = {x = 511, y = 569}, speed = 30, frame_blend = 1, prty = 2, loop = true},
		death = {range = {x = 571, y = 579}, speed = 30, frame_blend = 5, prty = 3, loop = false},
		shoulder_idle = {range = {x = 581, y = 639}, speed = 30, frame_blend = 0.6, loop = true}
	},
	-- Misc
	sounds = {
		random = {
			{
				name = "waterdragon_water_dragon_random_1",
				gain = 1,
				distance = 64,
				length = 2
			},
			{
				name = "waterdragon_water_dragon_random_2",
				gain = 1,
				distance = 64,
				length = 2.5
			},
			{
				name = "waterdragon_water_dragon_random_3",
				gain = 1,
				distance = 64,
				length = 4
			}
		}
	},
	child_sounds = {
		random = {
			{
				name = "waterdragon_water_dragon_child_1",
				gain = 1,
				distance = 8,
				length = 1
			},
			{
				name = "waterdragon_water_dragon_child_2",
				gain = 1,
				distance = 8,
				length = 2
			}
		}
	},
	drops = {}, -- Set in on_activate
	follow = {
		"group:meat"
	},
	dynamic_anim_data = {
		yaw_factor = 0.35,
		swing_factor = -0.2,
		pivot_h = 0.5,
		pivot_v = 0.75,
		tail = {
			{ -- Segment 1
				pos = {
					x = 0,
					y = -0.06,
					z = 0.6
				},
				rot = {
					x = 225,
					y = 180,
					z = 1
				}
			},
			{ -- Segment 2
				pos = {
					x = 0,
					y = 1.45,
					z = 0
				},
				rot = {
					x = 0,
					y = 0,
					z = 1
				}
			},
			{ -- Segment 3
				pos = {
					x = 0,
					y = 1.6,
					z = 0
				},
				rot = {
					x = 0,
					y = 0,
					z = 1
				}
			}
		},
		head = {
			{ -- Segment 1
				pitch_offset = 0,
				bite_angle = -10,
				pitch_factor = 0.11,
				pos = {
					x = 0,
					y = 1.15,
					z = 0
				},
				rot = {
					x = 0,
					y = 0,
					z = 0
				}
			},
			{ -- Segment 2
				pitch_offset = -5,
				bite_angle = 10,
				pitch_factor = 0.11,
				pos = {
					x = 0,
					y = 0.65,
					z = 0
				},
				rot = {
					x = 0,
					y = 0,
					z = 0
				}
			},
			{ -- Head
				pitch_offset = -5,
				bite_angle = 5,
				pitch_factor = 0.22,
				pos = {
					x = 0,
					y = 0.65,
					z = 0.05
				},
				rot = {
					x = 0,
					y = 0,
					z = 0
				}
			}
		},
		jaw = {
			pos = {
				y = 0.15,
				z = -0.29
			}
		}
	},
	-- Function
	breath_attack = waterdragon.pure_water_breath,
	utility_stack = waterdragon.dragon_behavior,
	activate_func = function(self)
		waterdragon.dragon_activate(self)
	end,
	step_func = function(self, dtime, moveresult)
		waterdragon.dragon_step(self, dtime, moveresult)
		on_dragon_step(self, dtime)
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
		if time_from_last_punch < 0.66
		or (self.passenger and puncher == self.passenger)
		or (self.rider and puncher == self.rider) then return end
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
			armour = self.armour
		}
		return minetest.serialize(data)
	end,
	deactivate_func = function(self)
		if not waterdragon.waterdragons[self.wtd_id] then return end
		local owner = waterdragon.waterdragons[self.wtd_id].owner
		if not owner then return end
		if not waterdragon.bonded_wtd then return end
		if waterdragon.bonded_wtd[owner]
		and is_value_in_table(waterdragon.bonded_wtd[owner], self.wtd_id) then
			for i = #waterdragon.bonded_wtd[owner], 1, -1 do
				if waterdragon.bonded_wtd[owner][i] == self.wtd_id then
					waterdragon.bonded_wtd[owner][i] = nil
				end
			end
		end
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
		if rot.x ~= 0
		or rot.z ~= 0 then
			self.object:set_rotation({x = 0, y = rot.y, z = 0})
		end
	end
})

modding.register_spawn_item("waterdragon:pure_water_dragon", {
	description = S("Creative Pure Water Dragon Egg"),
	inventory_image = "waterdragon_creative_egg_pure_water.png"
})

local spawn_egg_def = minetest.registered_items["waterdragon:spawn_pure_water_dragon"]

spawn_egg_def.on_place = function(itemstack, _, pointed_thing)
	local pos = minetest.get_pointed_thing_position(pointed_thing, true)
	waterdragon.spawn_dragon(pos, "waterdragon:pure_water_dragon", false, 75)
	if creative then
		itemstack:take_item()
		return itemstack
	end
	if  not creative then
		itemstack:take_item()
		return itemstack
	end
end

minetest.register_craftitem("waterdragon:spawn_pure_water_dragon", spawn_egg_def)