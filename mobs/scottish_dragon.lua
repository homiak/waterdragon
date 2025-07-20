---------------------
-- Scottish Dragon --
---------------------

local S = waterdragon.S

local scottish_spawn_rate = tonumber(minetest.settings:get("scottish_dragon_spawn_rate")) or 300

local colors = { "blue" }

waterdragon.register_mob("waterdragon:scottish_dragon", {
	-- Stats
	max_health = 700,
	max_hunger = 500,
	armor_groups = { fleshy = 100 },
	damage = 10,
	turn_rate = 6,
	speed = 32,
	tracking_range = 64,
	despawn_after = false,
	-- Entity Physics
	stepheight = 1.51,
	max_fall = 0,
	-- Visuals
	mesh = "waterdragon_scottish_dragon.b3d",
	hitbox = {
		width = 1.5,
		height = 2
	},
	visual_size = { x = 10, y = 10 },
	backface_culling = false,
	use_texture_alpha = false,
	textures = {
		"waterdragon_scottish_dragon.png"
	},
	animations = {
		stand = { range = { x = 1, y = 59 }, speed = 20, frame_blend = 0.3, loop = true },
		bite = { range = { x = 61, y = 89 }, speed = 30, frame_blend = 0.3, loop = false },
		walk = { range = { x = 91, y = 119 }, speed = 30, frame_blend = 0.3, loop = true },
		takeoff = { range = { x = 121, y = 149 }, speed = 30, frame_blend = 0.3, loop = false },
		hover = { range = { x = 151, y = 179 }, speed = 30, frame_blend = 0.3, loop = true },
		fly = { range = { x = 181, y = 209 }, speed = 30, frame_blend = 0.3, loop = true },
		dive = { range = { x = 211, y = 239 }, speed = 30, frame_blend = 0.3, loop = true },
		fly_punch = { range = { x = 241, y = 279 }, speed = 30, frame_blend = 0.3, loop = false },
		land = { range = { x = 281, y = 299 }, speed = 30, frame_blend = 1, loop = false }
	},
	-- Misc
	sounds = {
		random = {
			name = "waterdragon_scottish_dragon",
			gain = 1,
			distance = 64,
			length = 1
		},
		bite = {
			name = "waterdragon_scottish_dragon_bite",
			gain = 1,
			distance = 64,
			length = 1
		}
	},
	drops = {}, -- Set in on_activate
	follow = {
		"group:meat"
	},
	dynamic_anim_data = {
		yaw_factor = 0.35,
		swing_factor = -0.4,
		pivot_h = 0.5,
		pivot_v = 0.75,
		tail = {
			{ -- Segment 1
				pos = {
					x = 0,
					y = -0.06,
					z = 0.75
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
					y = 1.25,
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
					y = 0.85,
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
				y = 0,
				z = -0.25
			}
		}
	},
	-- Function
	utility_stack = waterdragon.scottish_dragon_behavior,
	activate_func = function(self)
		waterdragon.scottish_dragon_activate(self)
		apply_name_bonuses(self)
		self.has_pegasus_fire = self.has_pegasus_fire or false
		self.fire = self.fire or 10
		self.fire_breathing = self.fire_breathing or false
		self.fire_timer = 10
		local random = math.random
		if not self.scottish_eye_colour then
			local scottish_eye_textures = {
				"blue",
				"orange",
				"red",
				"yellow"
			}
			self.scottish_eye_colour = scottish_eye_textures[random(4)]
			self:memorize("scottish_eye_colour", self.scottish_eye_colour)
		end
		self.scottish_eye_colour = self:recall("scottish_eye_colour") or "blue"
		-- Set initial texture with eye color
		if self.object:get_properties() then
			local base_texture = "waterdragon_scottish_dragon.png"
			local eyes_texture = "waterdragon_scottish_eyes_" .. self.scottish_eye_colour .. ".png"
			self.object:set_properties({
				textures = { base_texture .. "^" .. eyes_texture }
			})
		end
	end,
	on_activate = function(self, staticdata, dtime_s)

		local data = {}
		if self.staticdata and type(self.staticdata) == "string" then
			data = minetest.deserialize(self.staticdata) or {}
		end

		if data.armour then
			self.armour = data.armour
			self.original_texture = data.original_texture

			local props = self.object:get_properties()
			if props and props.textures and props.textures[1] and self.armour.texture then
				local base_texture = props.textures[1]:gsub("%^.*", "")

				props.textures[1] = base_texture .. "^" .. self.armour.texture
				self.object:set_properties(props)

			end
			if data.armour then
				self.armour = data.armour
				self.original_texture = data.original_texture
				
				if not self.original_texture then
					self.original_texture = "waterdragon_scottish_dragon.png^waterdragon_baked_in_shading.png"
					
					local props = self.object:get_properties()
					if props and props.textures and props.textures[1] then
						local current_texture = props.textures[1]
						if current_texture:match("^waterdragon_") then
							self.original_texture = current_texture:gsub("%^.*", "")
						end
					end
				end
				
				if self.armour.texture and self.original_texture then
					local props = self.object:get_properties()
					if props and props.textures then
						props.textures[1] = self.original_texture .. "^" .. self.armour.texture
						self.object:set_properties(props)
						
						
					end
				end
			end
		end

		if self.scottish_dragon_activate then
			self.scottish_dragon_activate(self)
		end
	end,
	step_func = function(self, dtime)
		waterdragon.scottish_dragon_step(self, dtime)
		waterdragon.eat_dropped_item(self, item)
		if self.has_pegasus_fire then
			self.fire_timer = (self.fire_timer or 0) + dtime

			-- Check if we should breathe fire
			if self.fire_breathing then
				breathe_fire(self)
			end
		end
		self:memorize("fire", self.fire)
		if self:timer(1) then                            -- Check every second
            local scale = self.growth_scale or 1
            local hunger_threshold = (self.max_health * 0.2) * scale -- Hungry at 20% hunger

            if self.hunger and self.hunger < hunger_threshold then
                local pos = self.object:get_pos()
                if self.owner then
                    local found_meat = false
                    if pos then
                        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 20)) do
                            local luaentity = obj:get_luaentity()
                            if luaentity and luaentity.name ~= self.name and luaentity.groups and luaentity.groups.meat then
                                -- Teleport meat to the Dragon
                                obj:set_pos(vector.add(pos, { x = 0, y = 1, z = 0 }))
                                found_meat = true
                                break
                            end
                        end
                    end

                    -- If meat is not found, check the nearest player
                    if not found_meat then
                        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 60)) do
                            if obj:is_player() then
                                local inv = obj:get_inventory()
                                if inv then
                                    for _, stack in ipairs(inv:get_list("main")) do
                                        if minetest.get_item_group(stack:get_name(), "meat") > 0 then
                                            -- Remove meat from the player's inventory and create its object near the Dragon
                                            inv:remove_item("main", stack:get_name())
                                            minetest.add_item(vector.add(pos, { x = 0, y = 1, z = 0 }), stack:get_name())
                                            found_meat = true
                                            break
                                        end
                                    end
                                end
                            end
                            if found_meat then break end
                        end
                    end

                    -- If meat is not found, check the nearest chests
                    if not found_meat then
                        local node_pos = minetest.find_node_near(pos, 60, { "default:chest" })
                        if node_pos then
                            local meta = minetest.get_meta(node_pos)
                            local inv = meta:get_inventory()
                            if inv then
                                for _, stack in ipairs(inv:get_list("main")) do
                                    if minetest.get_item_group(stack:get_name(), "meat") > 0 then
                                        -- Remove meat from the chest and create its object near the Dragon
                                        inv:remove_item("main", stack:get_name())
                                        minetest.add_item(vector.add(pos, { x = 4, y = 1, z = 0 }), stack:get_name())
                                        found_meat = true
                                        break
                                    end
                                end
                            end
                        end
                    end

                    -- If food is still not found, warn the owner
                    if not found_meat and not self.hunger_warning_time then
                        self.hunger_warning_time = minetest.get_gametime()
                    elseif not found_meat and minetest.get_gametime() - self.hunger_warning_time > 30 then
                        self.hunger_warning_time = nil
                        -- Attack the nearest target
                        for _, obj in pairs(minetest.get_objects_inside_radius(pos, 80)) do
                            if (obj:get_luaentity() and obj:get_luaentity().name ~= self.name) and not obj:is_player() then
                                self._target = obj
                                break
                            end
                        end
                    end
                else
                    -- Wild Dragon
                    if pos then
                        for _, obj in pairs(minetest.get_objects_inside_radius(pos, 80)) do
                            if obj:is_player() or (obj:get_luaentity() and obj:get_luaentity().name ~= self.name) then
                                self._target = obj
                                break
                            end
                        end
                    end
                end
            else
                self.hunger_warning_time = nil
            end
		end
	end,
	get_staticdata = function(self)
		local data = {
			armour = self.armour
		}
		return minetest.serialize(data)
	end,
	death_func = function(self)
		if self:get_utility() ~= "waterdragon:die" then
			self:initiate_utility("waterdragon:die", self)
		end
	end,
	on_rightclick = function(self, clicker)
		waterdragon.scottish_dragon_rightclick(self, clicker)
		local item = clicker:get_wielded_item()
		local item_name = item:get_name()
		if minetest.get_item_group(item_name, "wtd_armour") > 0 then
			local armour_def = minetest.registered_items[item_name]
			if armour_def and armour_def.on_use then
				return armour_def.on_use(item, clicker, { type = "object", ref = self.object })
			end
		end
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
		-- Initialize punch tracking
		if not self.punch_data then
			self.punch_data = { count = 0, last_punch_time = 0, attacker = nil }
		end
		local puncher_name = puncher:get_player_name() or puncher:get_luaentity().name
		local current_time = minetest.get_gametime()
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
			if puncher == self.owner then
				if self.rider then
				waterdragon.detach_player(self, puncher)
				end
				if self.passenger then
					waterdragon.detach_passenger(self, self.passenger)
				end
				self.fly_allowed = true
			end
			

			-- Make the Dragon attack the puncher

			self._target = puncher
			self:initiate_utility("waterdragon:scottish_dragon_attack", puncher)
			-- Reset the counter
			self.punch_data.count = 0
		end
		waterdragon.basic_punch_func(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
		if not self.is_landed then
			self.flight_stamina = self:memorize("flight_stamina", self.flight_stamina - 10)
		end
		self.alert_timer = self:memorize("alert_timer", 15)
	end,
	deactivate_func = function(self)
		if waterdragon.scottish_dragons[self.object] then
			waterdragon.scottish_dragons[self.object] = nil
		end
	end
})

waterdragon.register_spawn_item("waterdragon:scottish_dragon", {
	description = S("Creative Scottish Dragon Egg"),
	inventory_image = "waterdragon_creative_egg_scottish.png"
})

local biomes = {}

minetest.register_on_mods_loaded(function()
	for name, def in ipairs(minetest.registered_biomes) do
		if name:find("jungle")
			or name:find("rainforest")
			and (def.y_max or 1) > 0 then
			table.insert(biomes, name)
		end
	end
end)

waterdragon.register_mob_spawn("waterdragon:scottish_dragon", {
	chance = scottish_spawn_rate,
	min_group = 1,
	max_group = 2,
	biomes = biomes,
	nodes = { "group:snow" }
})


minetest.register_craftitem("waterdragon:scales_scottish_dragon", {
	description = S("Scottish Dragon Scales"),
	inventory_image = "waterdragon_scottish_dragon_scales.png",
})

minetest.register_globalstep(function(dtime)
	if not minetest.get_modpath("pegasus") then return end
	if not _G.pegasus_rescue_initialized then
		_G.pegasus_rescue_initialized = true
		_G.rescue_pegasus = rescue_pegasus
	end
end)
