---------
-- API --
---------

local S = waterdragon.S

-- Bowing

local bow_players = {}
local bow_timers = {}

local function start_bow(player_name, dragon)
	bow_timers[player_name] = {
		start_time = minetest.get_us_time(),
		dragon = dragon
	}
end

local function finish_bow(player_name, dragon)
	if not bow_players[player_name] then
		bow_players[player_name] = {}
	end
	bow_players[player_name][dragon.wtd_id] = true
	minetest.chat_send_player(player_name, S("You bow to the Water Dragon"))
	minetest.sound_play("waterdragon_on_bowed", {
		object = dragon.object,
		gain = 1,
		max_hear_distance = 20,
		loop = false
	})
end

function has_bowed_to_dragon(player_name, dragon)
	return bow_players[player_name] and bow_players[player_name][dragon.wtd_id]
end

minetest.register_globalstep(function()
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local control = player:get_player_control()

		if control.sneak then
			if not bow_timers[player_name] then
				local pos = player:get_pos()
				local nearest_dragon = nil
				local nearest_dist = 15

				for _, obj in pairs(minetest.get_objects_inside_radius(pos, nearest_dist)) do
					local ent = obj:get_luaentity()
					if ent and (ent.name == "waterdragon:pure_water_dragon" or ent.name == "waterdragon:rare_water_dragon") then
						local dist = vector.distance(pos, obj:get_pos())
						if not nearest_dragon or dist < nearest_dist then
							nearest_dragon = ent
							nearest_dist = dist
						end
					end
				end

				if nearest_dragon then
					start_bow(player_name, nearest_dragon)
				end
			else
				local bow_data = bow_timers[player_name]
				local current_time = minetest.get_us_time()
				if (current_time - bow_data.start_time) >= 1000000 then
					if not has_bowed_to_dragon(player_name, bow_data.dragon) then
						finish_bow(player_name, bow_data.dragon)
					end
				end
			end
		else
			bow_timers[player_name] = nil
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	bow_players[name] = nil
	bow_timers[name] = nil
end)

-- Scottish bow

local scottish_bow_players = {}
local scottish_bow_timers = {}

local function start_scottish_bow(player_name, dragon)
	scottish_bow_timers[player_name] = {
		start_time = minetest.get_us_time(),
		dragon = dragon
	}
end

local function finish_scottish_bow(player_name, dragon)
	scottish_bow_players[player_name] = dragon
	minetest.chat_send_player(player_name, S("You bow to the Scottish Dragon"))
	minetest.sound_play("waterdragon_on_bowed", {
		object = dragon.object,
		gain = 1,
		max_hear_distance = 20,
		loop = false
	})
end

function has_bowed_to_scottish_dragon(player_name, dragon)
	return scottish_bow_players[player_name] == dragon
end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local control = player:get_player_control()

		if control.sneak then
			if not scottish_bow_timers[player_name] then
				local pos = player:get_pos()
				local nearest_dragon = nil
				local nearest_dist = 15

				for _, obj in pairs(minetest.get_objects_inside_radius(pos, nearest_dist)) do
					local ent = obj:get_luaentity()
					if ent and ent.name == "waterdragon:scottish_dragon" then
						local dist = vector.distance(pos, obj:get_pos())
						if not nearest_dragon or dist < nearest_dist then
							nearest_dragon = ent
							nearest_dist = dist
						end
					end
				end

				if nearest_dragon then
					start_scottish_bow(player_name, nearest_dragon)
				end
			else
				local bow_data = scottish_bow_timers[player_name]
				local current_time = minetest.get_us_time()
				if (current_time - bow_data.start_time) >= 1000000 then
					if not has_bowed_to_scottish_dragon(player_name, bow_data.dragon) then
						finish_scottish_bow(player_name, bow_data.dragon)
					end
				end
			end
		else
			scottish_bow_timers[player_name] = nil
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	scottish_bow_players[name] = nil
	scottish_bow_timers[name] = nil
end)

-- Math --

local pi = math.pi
local pi2 = pi * 2
local abs = math.abs
local deg = math.deg
local min = math.min
local random = math.random
local ceil = math.ceil
local floor = math.floor
local sqrt = math.sqrt
local rad = math.rad
local pi = math.pi
local atan2 = math.atan2
local sin = math.sin
local cos = math.cos

local function diff(a, b)
	if type(a) ~= "number" or type(b) ~= "number" then
		return 0
	end

	return atan2(sin(b - a), cos(b - a))
end

local function interp_angle(a, b, w)
	if a == nil or b == nil or w == nil then
		return 0
	end

	if type(a) ~= "number" or type(b) ~= "number" then
		return 0
	end


	if type(w) ~= "number" or w < 0 or w > 1 then
		return 0
	end

	local cs = (1 - w) * cos(a) + w * cos(b)
	local sn = (1 - w) * sin(a) + w * sin(b)
	return atan2(sn, cs)
end

local function clamp(val, _min, _max)
	if val < _min then
		val = _min
	elseif _max < val then
		val = _max
	end
	return val
end

-- Vector Math --

local vec_dir = vector.direction
local vec_dist = vector.distance
local vec_sub = vector.subtract
local vec_add = vector.add
local vec_multi = vector.multiply
local vec_new = vector.new
local vec_normal = vector.normalize
local vec_round = vector.round

local dir2yaw = minetest.dir_to_yaw
local yaw2dir = minetest.yaw_to_dir


--------------
-- Settings --
--------------

local terrain_destruction = minetest.settings:get_bool("water_dragon_terrain_destruction", true)

---------------------
-- Local Utilities --
---------------------

local function activate_nametag(self)
	self.nametag = self:recall("nametag") or nil
	if not self.nametag then return end
	self.object:set_properties({
		nametag = self.nametag,
		nametag_color = "#bdd9ff"
	})
end

local function is_value_in_table(tbl, val)
	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
	return false
end

local function get_pointed_mob(a, b)
	local steps = ceil(vec_dist(a, b))

	for i = 1, steps do
		local pos

		if steps > 0 then
			pos = {
				x = a.x + (b.x - a.x) * (i / steps),
				y = a.y + (b.y - a.y) * (i / steps),
				z = a.z + (b.z - a.z) * (i / steps)
			}
		else
			pos = a
		end
		if waterdragon.get_node_def(pos).walkable then
			break
		end
		local objects = minetest.get_objects_in_area(vec_sub(pos, 6), vec_add(pos, 6))
		for _, object in pairs(objects) do
			if object
				and object:get_luaentity() then
				local ent = object:get_luaentity()
				if ent.name:match("^waterdragon:") then
					return object, ent
				end
			end
		end
	end
end

------------------
-- Local Tables --
------------------

local walkable_nodes = {}

local wet_conversions = {}

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if name ~= "air" and name ~= "ignore" then
			if def.walkable then
				table.insert(walkable_nodes, name)
				if minetest.get_item_group(name, "stone") > 0 then
					wet_conversions[name] = "waterdragon:stone_wet" -- Wet Stone
				elseif minetest.get_item_group(name, "soil") > 0 then
					wet_conversions[name] = "waterdragon:soil_wet" -- Wet Soil
				elseif minetest.get_item_group(name, "tree") > 0 then
					wet_conversions[name] = "waterdragon:log_wet" -- Wet Log
				elseif minetest.get_item_group(name, "flora") > 0
					or minetest.get_item_group(name, "leaves") > 0
					or minetest.get_item_group(name, "snowy") > 0
					or minetest.get_item_group(name, "fire") > 0 then
					wet_conversions[name] = "default:water_flowing"
				end
			elseif def.drawtype == "liquid"
				and minetest.get_item_group(name, "water") > 0 then
				wet_conversions[name] = waterdragon.global_nodes["rare_water"]
			end
		end
	end
end)

minetest.after(0.1, function()
	flame_node = waterdragon.global_nodes["flame"]
end)

local water_eye_textures = {
	"blue",
	"orange",
	"red",
	"yellow"
}

local water_horn_textures = {
	"blue",
	"green",
	"white",
}

----------------------
-- Global Utilities --
----------------------

function waterdragon.spawn_dragon(pos, mob, mapgen, age)
	if not pos then return false end
	local wtd = minetest.add_entity(pos, mob)
	if wtd then
		local ent = wtd:get_luaentity()
		ent._mem = ent:memorize("_mem", true)
		ent.age = ent:memorize("age", age)
		ent.growth_scale = ent:memorize("growth_scale", age * 0.01)
		ent.mapgen_spawn = ent:memorize("mapgen_spawn", mapgen)
		if age <= 25 then
			ent.child = ent:memorize("child", true)
			ent.growth_stage = ent:memorize("growth_stage", 1)
		end
		if age <= 50 then
			ent.growth_stage = ent:memorize("growth_stage", 2)
		end
		if age <= 75 then
			ent.growth_stage = ent:memorize("growth_stage", 3)
		end
		if age > 75 then
			ent.growth_stage = ent:memorize("growth_stage", 4)
		end
		if random(3) < 2 then
			ent.gender = ent:memorize("gender", "male")
		else
			ent.gender = ent:memorize("gender", "female")
		end
		ent:set_scale(ent.growth_scale)
	end
end

function waterdragon.generate_id()
	local idst = ""
	for _ = 0, 5 do idst = idst .. (random(0, 9)) end
	if waterdragon.waterdragons[idst] then
		local fail_safe = 20
		while waterdragon.waterdragons[idst]
			and fail_safe > 0 do
			for _ = 0, 5 do idst = idst .. (random(0, 9)) end
			fail_safe = fail_safe - 1
		end
	end
	return idst
end

-------------------
-- Mob Functions --
-------------------

local function get_head_pos(self, pos2)
	local pos = self.object:get_pos()
	if not pos then return end
	local scale = self.growth_scale or 1
	pos.y = pos.y + 4.5 * scale
	local yaw = self.object:get_yaw()
	local dir = vec_dir(pos, pos2)
	local yaw_diff = diff(yaw, minetest.dir_to_yaw(dir))
	if yaw_diff > 1 then
		local look_dir = minetest.yaw_to_dir(yaw + 1)
		dir.x = look_dir.x
		dir.z = look_dir.z
	elseif yaw_diff < -1 then
		local look_dir = minetest.yaw_to_dir(yaw - 1)
		dir.x = look_dir.x
		dir.z = look_dir.z
	end
	local head_yaw = yaw + (yaw_diff * 0.33)
	return vec_add(pos, vec_multi(minetest.yaw_to_dir(head_yaw), (7 - abs(yaw_diff)) * scale)), dir
end

waterdragon.get_head_pos = get_head_pos

local wing_colors = {
	-- Pure Water
	pure_water = {
		"#d20000", -- Red
		"#d92e00", -- Orange
		"#edad00", -- Yellow
		"#07084f", -- Dark Blue
		"#2deded" -- Cyan
	},
	-- Rare Water
	rare_water = {
		"#d20000", -- Red
		"#d92e00", -- Orange
		"#edad00", -- Yellow
		"#07084f", -- Dark Blue
		"#2deded" -- Cyan
	},
}

function waterdragon.safe_set_texture(self, texture_name)
	-- Base texture
	local new_texture = texture_name

	-- If there is armor, add its texture
	if self.armour and self.armour.texture then
		new_texture = new_texture .. "^" .. self.armour.texture
	end

	-- Apply the textures
	local props = self.object:get_properties()
	if props and props.textures then
		props.textures[1] = new_texture
		self.object:set_properties(props)
	end
end

local function generate_texture(self, force)
	waterdragon.set_color_string(self)
	local def = minetest.registered_entities[self.name]
	local textures = {
		def.textures[self.texture_no]
	}
	self.wing_overlay = self:recall("wing_overlay") or nil
	if not self.wing_overlay then
		local color = wing_colors[self.color][random(#wing_colors[self.color])]
		self.wing_overlay = "(waterdragon_wing_fade.png^[multiply:" .. color .. ")"
		self:memorize("wing_overlay", self.wing_overlay)
	end
	if self:get_props().textures[1]:find("wing_fade") and not force then return end
	textures[1] = textures[1] .. "^" .. self.wing_overlay
	self:set_texture(1, textures)
	local base_texture = texture
	self.original_texture = base_texture
	if self.armour and self.armour.texture then
		texture = base_texture .. "^" .. self.armour.texture
	end
end

waterdragon.generate_texture = generate_texture

function waterdragon.drop_items(self)
	if not waterdragon.is_valid(self)
		or not self.object:get_pos() then
		return
	end
	if not self.drop_queue then
		self.drop_queue = {}
		for i = 1, #self.drops do
			local drop_def = self.drops[i]
			local name = drop_def.name
			local min_amount = drop_def.min
			local max_amount = drop_def.max
			local chance = drop_def.chance
			local amount = random(min_amount, max_amount)
			if random(chance) < 2 then
				table.insert(self.drop_queue, { name = name, amount = amount })
			end
		end
		self:memorize("drop_queue", self.drop_queue)
	else
		local pos = self.object:get_pos()
		pos.y = pos.y + self.height * 0.5
		local minpos = {
			x = pos.x - 18 * self.growth_scale,
			y = pos.y,
			z = pos.z - 18 * self.growth_scale
		}
		local maxpos = {
			x = pos.x + 18 * self.growth_scale,
			y = pos.y,
			z = pos.z + 18 * self.growth_scale
		}
		minetest.add_particlespawner({
			amount = math.ceil(48 * self.growth_scale),
			time = 0.25,
			minpos = minpos,
			maxpos = maxpos,
			minacc = { x = 0, y = 2, z = 0 },
			maxacc = { x = 0, y = 3, z = 0 },
			minvel = { x = math.random(-1, 1), y = -0.25, z = math.random(-1, 1) },
			maxvel = { x = math.random(-2, 2), y = -0.25, z = math.random(-2, 2) },
			minexptime = 0.75,
			maxexptime = 1,
			minsize = 4,
			maxsize = 4,
			texture = "waterdragon_water_particle.png",
			animation = {
				type = 'vertical_frames',
				aspect_w = 4,
				aspect_h = 4,
				length = 1,
			},
			glow = 1
		})
		if #self.drop_queue > 0 then
			for i = #self.drop_queue, 1, -1 do
				local drop_def = self.drop_queue[i]
				if drop_def then
					local name = drop_def.name
					local amount = random(1, drop_def.amount)
					local item = minetest.add_item(pos, ItemStack(name .. " " .. amount))
					if item then
						item:add_velocity({
							x = random(-2, 2),
							y = 1.5,
							z = random(-2, 2)
						})
					end
					self.drop_queue[i].amount = drop_def.amount - amount
					if self.drop_queue[i].amount <= 0 then
						self.drop_queue[i] = nil
					end
				end
			end
			self:memorize("drop_queue", self.drop_queue)
		else
			return true
		end
	end
	return false
end

-------------
-- Visuals --
-------------

function waterdragon.set_color_string(self)
	if self.name == "waterdragon:pure_water_dragon" then
		if self.texture_no == 1 then
			self.color = "pure_water"
		end
	elseif self.name == "waterdragon:rare_water_dragon" then
		if self.texture_no == 1 then
			self.color = "rare_water"
		end
	end
end

-----------------------
-- Dynamic Animation --
-----------------------

function waterdragon.rotate_to_pitch(self, flying)
	local rot = self.object:get_rotation()
	if flying then
		local vel = vec_normal(self.object:get_velocity())
		local step = min(self.dtime * 4, abs(diff(rot.x, vel.y)) % (pi2))
		local n_rot = interp_angle(rot.x, vel.y, step)
		self.object:set_rotation({
			x = clamp(n_rot, -0.75, 0.75),
			y = rot.y,
			z = rot.z
		})
	elseif rot.x ~= 0 then
		self.object:set_rotation({
			x = 0,
			y = rot.y,
			z = 0
		})
	end
end

function waterdragon.head_tracking(self)
	if self.rider then return end
	local yaw = self.object:get_yaw()
	local pos = self.object:get_pos()
	if not pos then return end
	local anim = self._anim or "stand"
	if anim == "sleep"
		or self.hp <= 0 then
		self:move_head(yaw)
		return
	end
	-- Calculate Head Position
	local y_dir = yaw2dir(yaw)
	local scale = self.growth_scale or 1
	local offset_h, offset_v = self.width + 3 * scale, self.height + 1.5 * scale
	if anim:match("^fly_idle") then
		offset_v = self.height + 2 * scale
	end
	pos = {
		x = pos.x + y_dir.x * offset_h,
		y = pos.y + offset_v,
		z = pos.z + y_dir.z * offset_h
	}
	local player = self.head_tracking
	local plyr_pos = player and player:get_pos()
	if plyr_pos then
		plyr_pos.y = plyr_pos.y + 1.4
		local dir = vec_dir(pos, plyr_pos)
		local dist = vec_dist(pos, plyr_pos)
		if dist > 24 * scale then
			self.head_tracking = nil
			return
		end
		local tyaw = dir2yaw(dir)
		self:move_head(tyaw, dir.y)
		return
	elseif self:timer(random(4, 6)) then
		local players = waterdragon.get_nearby_players(self, 12 * scale)
		self.head_tracking = #players > 0 and players[random(#players)]
	end
	self:move_head(yaw, 0)
end

------------
-- Breath --
------------

local effect_cooldown = {}

minetest.register_entity("waterdragon:dragon_rare_water", {
	max_hp = 1600,
	physical = true,
	collisionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
	visual = "mesh",
	mesh = "waterdragon_dragon_water.obj",
	textures = {
		"waterdragon_dragon_rare_water.png^[opacity:170"
	},
	use_texture_alpha = true,
	active_time = 0,
	on_activate = function(self)
		self.object:set_armor_groups({ immortal = 1, fleshy = 0 })
		self.object:set_acceleration({ x = 0, y = -9.8, z = 0 })
	end,
	on_step = function(self, dtime)
		if self.active_time > 0
			and (not self.child
				or not self.child:get_pos()) then
			self.object:remove()
			return
		end
		self.active_time = self.active_time + dtime
		if self.active_time > 10 then
			if self.child then
				self.child:set_properties({
					visual_size = self.mob_scale,
				})
			end
			self.object:remove()
		end
	end
})

minetest.register_entity("waterdragon:dragon_pure_water", {
	max_hp = 1500,
	physical = false,
	collisionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
	visual = "mesh",
	mesh = "waterdragon_dragon_pure_water.obj",
	textures = {
		"waterdragon_pure_water_animated.png^[verticalframe:8:1"
	},
	glow = 12,
	active_time = 0,
	pure_water_time = 0.07,
	pure_water_frame = 1,
	on_activate = function(self)
		self.object:set_armor_groups({ immortal = 1, fleshy = 0 })
	end,
	on_step = function(self, dtime)
		if not self.child
			or not self.child:get_pos() then
			self.object:remove()
			return
		end
		local child_pos = self.child:get_pos()
		if waterdragon.get_node_def(child_pos).drawtype == "liquid" then
			self.object:remove()
			return
		end
		self.active_time = self.active_time + dtime
		self.pure_water_time = self.pure_water_time - dtime
		if self.pure_water_time < 0 then
			self.pure_water_time = 0.07
			self.pure_water_frame = self.pure_water_frame + 1
			if self.pure_water_frame > 6 then
				self.pure_water_frame = 1
			end
		end
		if self.active_time - math.floor(self.active_time) < 0.1
			and (self.child:get_luaentity()
				or self.child:is_player()) then
			local ent = self.child:get_luaentity()
			if ((ent and ent.hp) or 0) > 0 then
				self.child:punch(self.object, 0, { fleshy = 2 })
			end
			if ent
				and ent._waterdragon_mob
				and ((ent and ent.hp) or 0) <= 0
				and ent.drops then
				if #ent.drops
					and #ent.drops > 0 then
					local n_drops = table.copy(ent.drops)
					for n = 1, #n_drops do
						local name = n_drops[n].name
						if minetest.get_item_group(name, "food_meat") > 0 then
							local output = minetest.get_craft_result({
								method = "cooking",
								width = 1,
								items = { name }
							})
							if output.item
								and output.item:get_name()
								and output.item:get_name() ~= "" then
								local cooked_name = output.item:get_name()
								n_drops[n].name = cooked_name
							end
						end
					end
					self.child:get_luaentity().drops = n_drops
				end
			end
		end
		if self.active_time > 10 then
			self.object:remove()
		end
	end
})


local function do_cooldown()
	for k, v in pairs(effect_cooldown) do
		if v > 1 then
			effect_cooldown[k] = v - 1
		else
			effect_cooldown[k] = nil
		end
	end
	minetest.after(1, do_cooldown)
end

do_cooldown()

local function damage_objects(self, pos, radius)
	local objects = minetest.get_objects_inside_radius(pos, radius)
	for _, object in ipairs(objects) do
		local ent = object and object:get_luaentity()
		local damage = object:is_player()
		if (self.rider and object == self.rider)
			or (self.passenger and object == self.passenger) then
			damage = false
		elseif ent then
			local is_mob = ent.logic ~= nil or ent._waterdragon_mob or ent._cmi_is_mob
			damage = is_mob and (ent.hp or ent.health or 0) > 0
		end
		if damage then
			object:punch(self.object, 1.0, { damage_groups = { fleshy = math.ceil(self.damage * 0.33) } })
			self:punch_target(object, math.ceil(self.damage * 0.2))
		end
		if ent and ent.name == "__builtin:item" then
			local stack = ItemStack(ent.itemstring)
			if stack
				and stack:get_count() > 2
				and stack:get_name():match("stone") or stack:get_name():match("cobble") then
				local dragonstone_no = floor(stack:get_count() / 2)
				local leftover_no = stack:get_count() - 2 * dragonstone_no
				if self.name == "waterdragon:rare_water_dragon" then
					minetest.add_item(object:get_pos(), "waterdragon:dragonstone_block_rare_water " .. dragonstone_no)
				end
				if self.name == "waterdragon:pure_water_dragon" then
					minetest.add_item(object:get_pos(), "waterdragon:dragonstone_block_pure_water " .. dragonstone_no)
				end
				if leftover_no then
					minetest.add_item(object:get_pos(), stack:get_name() .. " " .. leftover_no)
				end
				object:remove()
			end
		end
	end
end

local function make_wet_nodes(pos, radius)
	local h_stride = radius
	local v_stride = math.ceil(radius * 0.5)
	local pos1 = {
		x = pos.x - h_stride,
		y = pos.y - v_stride,
		z = pos.z - h_stride
	}
	local pos2 = {
		x = pos.x + h_stride,
		y = pos.y + v_stride,
		z = pos.z + h_stride
	}
	local y_stride = 0
	for z = pos1.z, pos2.z do
		y_stride = y_stride + 1
		for x = pos1.x, pos2.x do
			local noise = random(5)
			if noise < 2 then
				local npos = {
					x = x,
					y = pos1.y + y_stride,
					z = z
				}
				if minetest.is_protected(npos, "") then
					return
				end
				local name = minetest.get_node(npos).name
				if name
					and not name:find("wet")
					and name ~= "air"
					and name ~= "ignore" then
					local convert_to = wet_conversions[name]
					if convert_to
						and (convert_to ~= waterdragon.global_nodes["rare_water"]
							or minetest.get_node({ x = x, y = npos.y + 1, z = z }).name == "air") then
						minetest.set_node(npos, { name = convert_to })
					end
				end
			end
		end
	end
end

local function make_nodes_wet_pure_water(pos, radius)
	local h_stride = radius
	local v_stride = math.ceil(radius * 0.5)
	local pos1 = {
		x = pos.x - h_stride,
		y = pos.y - v_stride,
		z = pos.z - h_stride
	}
	local pos2 = {
		x = pos.x + h_stride,
		y = pos.y + v_stride,
		z = pos.z + h_stride
	}
	local y_stride = 0
	for z = pos1.z, pos2.z do
		y_stride = y_stride + 1
		for x = pos1.x, pos2.x do
			local noise = random(5)
			if noise < 2 then
				local npos = {
					x = x,
					y = pos1.y + y_stride,
					z = z
				}
				if minetest.is_protected(npos, "") then
					return
				end
				local name = minetest.get_node(npos).name
				if name
					and not name:find("wet")
					and name ~= "air"
					and name ~= "ignore" then
					local convert_to = wet_conversions[name]
					if convert_to
						and (convert_to ~= waterdragon.global_nodes["pure_water"]
							or minetest.get_node({ x = x, y = npos.y + 1, z = z }).name == "air") then
						minetest.set_node(npos, { name = convert_to })
					end
				end
			end
		end
	end
end

local function do_forge(pos, node, id)
	local forge = minetest.find_nodes_in_area(vec_sub(pos, 4), vec_add(pos, 4), node)
	if forge[1] then
		local func = minetest.registered_nodes[node].on_breath
		func(forge[1], id)
	end
end

local function breath_sound(self, sound)
	self.breath_timer = (self.breath_timer or 0.1) - self.dtime
	if self.breath_timer <= 0 then
		self.breath_timer = 2
		minetest.sound_play(sound, {
			object = self.object,
			gain = 1.0,
			max_hear_distance = 64,
			loop = false,
		})
	end
end

function waterdragon.pure_water_breath(self, pos2)
	if self.attack_stamina <= 0 then
		self.attack_disabled = true
		self:memorize("attack_disabled", self.attack_disabled)
		return
	elseif self.attack_stamina > 25
		and self.attack_disabled then
		self.attack_disabled = false
		self:memorize("attack_disabled", self.attack_disabled)
	end
	breath_sound(self, "waterdragon_water_breath")
	local pos, dir = get_head_pos(self, pos2)
	dir.y = vec_dir(pos, pos2).y
	pos.y = pos.y + self.object:get_rotation().x
	local breath_delay = (self.breath_delay or 0) - 1
	if breath_delay <= 0 then
		local vel = self.object:get_velocity()
		local particle_origin = {
			x = pos.x + dir.x * (self.growth_scale * 5) + vel.x,
			y = pos.y + dir.y * (self.growth_scale * 5) + vel.y + 2,
			z = pos.z + dir.z * (self.growth_scale * 4) + vel.z
		}

		local scale = self.growth_scale
		if minetest.has_feature("particlespawner_tweenable") then
			minetest.add_particlespawner({
				amount = 200,
				time = 0.05,
				collisiondetection = true,
				collision_removal = true,
				pos = particle_origin,
				vel = { min = vec_multi(dir, 32), max = vec_multi(dir, 48) },
				acc = { min = vec_new(-20, -20, -20), max = vec_new(20, 20, 20) },
				size = { min = 8 * scale, max = 12 * scale },
				glow = 7,
				texture = {
					name = "waterdragon_water_particle.png",
					alpha_tween = { 100, 100 },
					blend = "alpha"
				}
			})
		else
			minetest.add_particlespawner({
				amount = 200,
				time = 0.05,
				minpos = particle_origin,
				maxpos = particle_origin,
				minvel = vec_multi(dir, 32),
				maxvel = vec_multi(dir, 48),
				minacc = { x = -20, y = -20, z = -20 },
				maxacc = { x = 20, y = 20, z = 20 },
				minexptime = 0.02 * 302,
				maxexptime = 0.04 * 302,
				minsize = 8 * scale,
				maxsize = 12 * scale,
				collisiondetection = true,
				collision_removal = true,
				vertical = false,
				glow = 7,
				texture = "waterdragon_water_particle.png"
			})
		end
		local spread = clamp(3 * scale, 1, 5)
		local breath_end = vec_add(pos, vec_multi(dir, 32))
		for i = 1, 32, floor(spread) do
			local pure_water_pos = vec_add(pos, vec_multi(dir, i))
			if random(5) < 2 then
				damage_objects(self, pure_water_pos, spread + 2)
			end
			local def = waterdragon.get_node_def(pure_water_pos)
			if def.walkable
				or def.drawtype == "liquid" then
				breath_end = pure_water_pos
				break
			end
		end
		do_forge(breath_end, "waterdragon:draconic_forge_pure_water", self.wtd_id)
		breath_delay = 4
	end
	self.breath_delay = breath_delay
	if self.owner then
		self.attack_stamina = self.attack_stamina - self.dtime * 4
	end
	self:memorize("attack_stamina", self.attack_stamina)
end

function waterdragon.rare_water_breath(self, pos2)
	if self.attack_stamina <= 0 then
		self.attack_disabled = true
		self:memorize("attack_disabled", self.attack_disabled)
		return
	elseif self.attack_stamina > 25
		and self.attack_disabled then
		self.attack_disabled = false
		self:memorize("attack_disabled", self.attack_disabled)
	end
	breath_sound(self, "waterdragon_water_breath")
	local pos, dir = get_head_pos(self, pos2)
	dir.y = vec_dir(pos, pos2).y
	pos.y = pos.y + self.object:get_rotation().x
	local breath_delay = (self.breath_delay or 0) - 1
	if breath_delay <= 0 then
		local vel = self.object:get_velocity()
		local particle_origin2 = {
			x = pos.x + dir.x * (self.growth_scale * 5) + vel.x,
			y = pos.y + dir.y * (self.growth_scale * 5) + vel.y + 2,
			z = pos.z + dir.z * (self.growth_scale * 5) + vel.z
		}
		local scale = self.growth_scale
		if minetest.has_feature("particlespawner_tweenable") then
			minetest.add_particlespawner({
				amount = 100,
				time = 0.0005,
				collisiondetection = true,
				collision_removal = true,
				pos = particle_origin2,
				vel = { min = vec_multi(dir, 32), max = vec_multi(dir, 48) },
				acc = { min = vec_new(-4, -4, -4), max = vec_new(4, 4, 4) },
				size = { min = 6 * scale, max = 8 * scale },
				glow = 7,
				texpool = {
					{ name = "waterdragon_rare_water_particle_1.png", alpha_tween = { 1, 0 }, blend = "alpha" },
					{ name = "waterdragon_rare_water_particle_2.png", alpha_tween = { 1, 0 }, blend = "alpha" },
					{ name = "waterdragon_rare_water_particle_3.png", alpha_tween = { 1, 0 }, blend = "alpha" },
				}
			})
		else
			minetest.add_particlespawner({
				amount = 200,
				time = 0.0005,
				minpos = particle_origin2,
				maxpos = particle_origin2,
				minvel = vec_multi(dir, 32),
				maxvel = vec_multi(dir, 48),
				minacc = { x = -4, y = -4, z = -4 },
				maxacc = { x = 4, y = 4, z = 4 },
				minexptime = 0.02 * 32,
				maxexptime = 0.04 * 32,
				minsize = 4 * scale,
				maxsize = 6 * scale,
				collisiondetection = true,
				collision_removal = true,
				vertical = false,
				glow = 7,
				texture = "waterdragon_rare_water_particle_" .. random(3) .. ".png"
			})
		end
		local spread = floor(clamp(2.5 * scale, 1, 4))
		local breath_end = vec_add(pos, vec_multi(dir, 32))

		for i = 1, 32, spread do
			local rare_water_pos = vec_add(pos, vec_multi(dir, i))
			make_wet_nodes(rare_water_pos, spread)
			if random(5) < 2 then
				damage_objects(self, rare_water_pos, spread + 2)
			end
			local pure_water_pos = vec_add(pos, vec_multi(dir, i))
			make_nodes_wet_pure_water(pure_water_pos, spread)
			if random(5) < 2 then
				damage_objects(self, pure_water_pos, spread + 2)
			end
			local def = waterdragon.get_node_def(pure_water_pos)
			if def.walkable then
				breath_end = pure_water_pos
				break
			end
			local def = waterdragon.get_node_def(rare_water_pos)
			if def.walkable then
				breath_end = rare_water_pos
				break
			end
		end
		do_forge(breath_end, "waterdragon:draconic_forge_rare_water", self.wtd_id)
		breath_delay = 4
	end
	self.breath_delay = breath_delay
	if self.owner then
		self.attack_stamina = self.attack_stamina - self.dtime * 4
	end
	self:memorize("attack_stamina", self.attack_stamina)
end

--------------------
-- Initialize API --
--------------------


waterdragon.wtd_api = {
	action_flight_to_land = function(self)
		if not self:get_action() then
			waterdragon.action_move(self, self.object:get_pos(), 3, "waterdragon:fly_to_land", 0.6, "fly")
		end
		if self.touching_ground then
			waterdragon.action_land(self)
			return true
		end
		return false
	end,
	animate = function(self, anim)
		if self.animations and self.animations[anim] then
			if self._anim == anim then return end
			local old_anim = nil
			if self._anim then
				old_anim = self._anim
			end
			self._anim = anim
			local old_prty = 1
			if old_anim
				and self.animations[old_anim].prty then
				old_prty = self.animations[old_anim].prty
			end
			local prty = 1
			if self.animations[anim].prty then
				prty = self.animations[anim].prty
			end
			local aparms
			if #self.animations[anim] > 0 then
				aparms = self.animations[anim][random(#self.animations[anim])]
			else
				aparms = self.animations[anim]
			end
			aparms.frame_blend = aparms.frame_blend or 0
			if old_prty > prty then
				aparms.frame_blend = self.animations[old_anim].frame_blend or 0
			end
			self.anim_frame = -aparms.frame_blend
			self.frame_offset = 0
			self.object:set_animation(aparms.range, aparms.speed, aparms.frame_blend, aparms.loop)
		else
			self._anim = nil
		end
	end,
	increase_age = function(self)
		self.age = self:memorize("age", self.age + 1)
		local age = self.age
		if age < 150
			or (age > 150
				and age < 1.5) then -- second check ensures pre-1.2 Water Dragons grow to new limit
			self.growth_scale = self:memorize("growth_scale", self.growth_scale + 0.0099)
			self:set_scale(self.growth_scale)
			if age <= 25 then
				self.growth_stage = 1
			elseif age <= 50 then
				self.growth_stage = 2
			elseif age <= 75 then
				self.growth_stage = 3
			elseif age <= 100 then
				self.growth_stage = 4
			elseif age <= 500 then
				self.growth_stage = 5
			end
		end
		self:memorize("growth_stage", self.growth_stage)
		self:set_drops()
	end,
	do_growth = function(self)
		self.growth_timer = self.growth_timer - 1
		if self.growth_timer <= 0 then
			self:increase_age()
			self.growth_timer = self.growth_timer + 1200
		end
		if self.hp > self.max_health * self.growth_scale then
			self.hp = self.max_health * self.growth_scale
		end
		if self.hunger > (self.max_health * 0.5) * self.growth_scale then
			self.hunger = (self.max_health * 0.5) * self.growth_scale
		end
		self:memorize("growth_timer", self.growth_timer)
		self:memorize("hunger", self.hunger)
	end,
	set_drops = function(self)
		local type = "rare_water"
		if self.name == "waterdragon:pure_water_dragon" then
			type = "pure_water"
		end
		waterdragon.set_color_string(self)
		local stage = self.growth_stage
		local drops = {
			[1] = {
				{ name = "waterdragon:scales_" .. type .. "_dragon", min = 1, max = 3, chance = 2 },
				{ name = "waterdragon:dragon_horn",                  min = 3, max = 6, chance = 1 },
				{ name = "waterdragon:dragon_bone",                  min = 1, max = 3, chance = 2 },
				{ name = "waterdragon:wing_horn",                    min = 1, max = 3, chance = 2 },
			},
			[2] = {
				{ name = "waterdragon:scales_" .. type .. "_dragon", min = 5, max = 16, chance = 2 },
				{ name = "waterdragon:dragon_bone",                  min = 1, max = 3,  chance = 3 },
				{ name = "waterdragon:dragon_horn",                  min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:draconic_tooth",               min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:dragon_water_drop",            min = 1, max = 3,  chance = 2 },
				{ name = "waterdragon:wing_horn",                    min = 1, max = 3,  chance = 2 },
			},
			[3] = {
				{ name = "waterdragon:scales_" .. type .. "_dragon", min = 5, max = 16, chance = 1 },
				{ name = "waterdragon:dragon_horn",                  min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:dragon_bone",                  min = 3, max = 8,  chance = 1 },
				{ name = "waterdragon:draconic_tooth",               min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:dragon_water_drop",            min = 1, max = 3,  chance = 2 },
				{ name = "waterdragon:wing_horn",                    min = 1, max = 3,  chance = 2 },
			},
			[4] = {
				{ name = "waterdragon:scales_" .. type .. "_dragon", min = 5, max = 16, chance = 1 },
				{ name = "waterdragon:dragon_bone",                  min = 6, max = 10, chance = 1 },
				{ name = "waterdragon:dragon_horn",                  min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:draconic_tooth",               min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:dragon_water_drop",            min = 1, max = 3,  chance = 2 },
				{ name = "waterdragon:wing_horn",                    min = 1, max = 3,  chance = 2 },
			},
			[5] = {
				{ name = "waterdragon:dragon_water_drop",            min = 1, max = 3,  chance = 2 },
				{ name = "waterdragon:dragon_horn",                  min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:draconic_tooth",               min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:dragon_bone",                  min = 3, max = 6,  chance = 1 },
				{ name = "waterdragon:scales_" .. type .. "_dragon", min = 5, max = 16, chance = 1 },
				{ name = "waterdragon:wing_horn",                    min = 1, max = 3,  chance = 2 },
			},
		}
		self.drops = drops[stage]
	end,
	play_sound = function(self, sound)
		if self.time_from_last_sound < 6 then return end
		local sounds = self.sounds
		if self.age < 15 then
			sounds = self.child_sounds
		end
		local spec = sounds and sounds[sound]
		local parameters = { object = self.object }
		if type(spec) == "table" then
			local name = spec.name
			if spec.variations then
				name = name .. "_" .. random(spec.variations)
			elseif #spec
				and #spec > 1 then
				spec = sounds[sound][random(#sounds[sound])]
				name = spec.name
			end
			local pitch = 1.0
			pitch = pitch - (random(-10, 10) * 0.005)
			parameters.gain = spec.gain or 1
			parameters.max_hear_distance = spec.distance or 8
			parameters.fade = spec.fade or 4
			parameters.pitch = pitch
			self.roar_anim_length = parameters.length or 500
			self.time_from_last_sound = 0
			self.jaw_init = true
			return minetest.sound_play(name, parameters)
		end
		return minetest.sound_play(spec, parameters)
	end,
	destroy_terrain = function(self)
		local moveresult = self.moveresult
		if not terrain_destruction
			or not moveresult
			or not moveresult.collisions then
			return
		end
		local pos = self.object:get_pos()
		if not pos then return end
		for _, collision in ipairs(moveresult.collisions) do
			if collision.type == "node" then
				local n_pos = collision.node_pos
				if n_pos.y - pos.y >= 1.5 then
					local node = minetest.get_node(n_pos)
					if minetest.get_item_group(node.name, "cracky") ~= 1
						and minetest.get_item_group(node.name, "unbreakable") < 1 then
						if random(6) < 2 then
							minetest.dig_node(n_pos)
						else
							minetest.remove_node(n_pos)
						end
					end
				end
			end
		end
	end,
	-- Textures
	update_emission = function(self, force)
		local pos = self.object:get_pos()
		local level = minetest.get_node_light(pos, minetest.get_timeofday())
		if not level then return end
		local texture = self:get_props().textures[1]
		local eyes_open = string.find(texture, "eyes")
		if self._glow_level == level
			and ((self._anim ~= "sleep" and eyes_open)
				or (self._anim == "sleep" and not eyes_open))
			and not force then
			return
		end
		local def = minetest.registered_entities[self.name]
		local textures = {
			def.textures[self.texture_no]
		}
		texture = textures[1]
		if self.wing_overlay then
			texture = texture .. "^" .. self.wing_overlay
		end
		self._glow_level = level
		local color = math.ceil(level / minetest.LIGHT_MAX * 255)
		if color > 255 then
			color = 255
		end
		local modifier = ("^[multiply:#%02X%02X%02X"):format(color, color, color)
		local dragon_type = "rare_water"
		if self.name == "waterdragon:pure_water_dragon" then
			dragon_type = "pure_water"
		end
		local eyes = "waterdragon_" .. dragon_type .. "_eyes_" .. self.eye_color .. ".png"
		if self.growth_scale < 0.25 then
			eyes = "waterdragon_" .. dragon_type .. "_eyes_child_" .. self.eye_color .. ".png"
		end
		local time = (minetest.get_timeofday() or 0) * 24000
		local is_night = time > 19500 or time < 4500
		if self:get_action("sleep") then
			local eyes_texture
			if is_night then
				eyes_texture = "waterdragon_" .. dragon_type .. "_eyes_" .. self.eye_color .. "_peeled.png"
			else
				eyes_texture = "waterdragon_" .. dragon_type .. "_eyes_" .. self.eye_color .. ".png"
			end

			self.object:set_properties({
				textures = { "(" .. texture .. modifier .. ")^" .. eyes_texture }
			})
		elseif not self:get_action("sleep") then
			local eyes_texture
			if is_night and self.eyes_peeled then
				-- If it's night and the eyes are peeled, use the peeled texture
				eyes_texture = "waterdragon_" .. dragon_type .. "_eyes_" .. self.eye_color .. "_peeled.png"
			else
				-- In all other cases, use the normal eyes texture
				eyes_texture = "waterdragon_" .. dragon_type .. "_eyes_" .. self.eye_color .. ".png"
			end

			self.object:set_properties({
				textures = { "(" .. texture .. modifier .. ")^" .. eyes_texture }
			})
		end

		if is_night and self:get_action("sleep") then
			self.eyes_peeled = true
		else
			self.eyes_peeled = false
		end
	end,
	-- Dynamic Animation Methods
	tilt_to = function(self, tyaw, rate)
		self._tyaw = tyaw
		rate = self.dtime * (rate or 5)
		local rot = self.object:get_rotation()
		if not rot then return end
		-- Calc Yaw
		local yaw = rot.y
		local y_step = math.min(rate, abs(diff(yaw, tyaw)) % (pi2))
		local n_yaw = interp_angle(yaw, tyaw, y_step)
		-- Calc Roll
		local roll = diff(tyaw, yaw) / 2
		local r_step = math.min(rate, abs(diff(rot.z, tyaw)) % (pi2))
		local n_roll = interp_angle(rot.z, roll, r_step)
		self.object:set_rotation({ x = rot.x, y = n_yaw, z = n_roll })
	end,
	set_weighted_velocity = function(self, speed, goal)
		self._tyaw = dir2yaw(goal)
		speed = speed or self._movement_data.speed
		local current_vel = self.object:get_velocity()
		local goal_vel = vec_multi(vec_normal(goal), speed)
		local vel = current_vel
		vel.x = vel.x + (goal_vel.x - vel.x) * 0.05
		vel.y = vel.y + (goal_vel.y - vel.y) * 0.05
		vel.z = vel.z + (goal_vel.z - vel.z) * 0.05
		self.object:set_velocity(vel)
	end,
	open_jaw = function(self)
		if not self._anim then return end
		local _, rot = self.object:get_bone_position("Jaw.CTRL")
		local tgt_angle
		local open_angle = pi / 4
		if self.jaw_init then
			local end_anim = self._anim:find("_water") or floor(rot.x) == deg(-open_angle)
			if end_anim
				or self.roar_anim_length <= 0 then
				self.jaw_init = false
				self.roar_anim_length = 0
				local step = math.min(self.dtime * 5, abs(diff(rad(rot.x), 0)) % (pi2))
				tgt_angle = interp_angle(rad(rot.x), 0, step)
			else
				local step = math.min(self.dtime * 5, abs(diff(rad(rot.x), -open_angle)) % (pi2))
				tgt_angle = interp_angle(rad(rot.x), -open_angle, step)
				self.roar_anim_length = self.roar_anim_length - self.dtime
			end
		else
			local step = math.min(self.dtime * 5, abs(diff(rad(rot.x), 0)) % (pi2))
			tgt_angle = interp_angle(rad(rot.x), 0, step)
		end
		if tgt_angle < -45 then tgt_angle = -45 end
		if tgt_angle > 0 then tgt_angle = 0 end
		self.object:set_bone_position("Jaw.CTRL", { x = 0, y = 0.15, z = -0.29 }, { x = deg(tgt_angle), y = 0, z = 0 })
	end,
	move_tail = function(self)
		if self._anim == "stand"
			or self._anim == "stand_water" then
			self.last_yaw = self.object:get_yaw()
		end
		local anim_data = self.dynamic_anim_data
		local yaw = self.object:get_yaw()
		for seg = 1, #anim_data.tail do
			local data = anim_data.tail[seg]
			local _, rot = self.object:get_bone_position("Tail." .. seg .. ".CTRL")
			rot = rot.z
			local y_diff = diff(yaw, self.last_yaw)
			local tgt_rot = -y_diff * 10
			if self.dtime then
				tgt_rot = clamp(tgt_rot, -0.3, 0.3)
				if abs(y_diff) < 0.01 then
					y_diff = rad(rot)
					tgt_rot = 0
				end
				rot = interp_angle(rad(rot), tgt_rot, math.min(self.dtime * 3, abs(y_diff * 10) % (pi2)))
			end
			self.object:set_bone_position("Tail." .. seg .. ".CTRL", data.pos,
				{ x = data.rot.x, y = data.rot.y, z = math.deg(rot) * (data.rot.z or 1) })
		end
	end,
	move_head = function(self, tyaw, pitch)
		local yaw = self.object:get_yaw()
		local seg_no = #self.dynamic_anim_data.head
		for seg = 1, seg_no do
			-- Data
			local data = self.dynamic_anim_data.head[seg]
			local bone_name = "Neck." .. seg .. ".CTRL"
			if seg == seg_no then
				bone_name = "Head.CTRL"
			end
			if not data then return end
			-- Calculation
			local _, rot = self.object:get_bone_position(bone_name)
			if not rot then return end
			local y_diff = diff(tyaw, yaw)
			local n_yaw = (tyaw ~= yaw and y_diff / 6) or 0
			if abs(deg(n_yaw)) > 22 then n_yaw = 0 end
			local dir = yaw2dir(n_yaw)
			dir.y = pitch or 0
			local n_pitch = -(sqrt(dir.x ^ 2 + dir.y ^ 2) / dir.z) / 4
			if abs(deg(n_pitch)) > 22 then n_pitch = 0 end
			if self.dtime then
				local rate = self.dtime * 3
				if abs(y_diff) < 0.01 then
					y_diff = rad(rot.z)
					n_yaw = 0
				end
				local yaw_w = math.min(rate, abs(y_diff) % (pi2))
				n_yaw = interp_angle(rad(rot.z), n_yaw, yaw_w)
				local pitch_w = math.min(rate, abs(diff(rad(rot.x), n_pitch)) % (pi2))
				n_pitch = interp_angle(rad(rot.x), n_pitch, pitch_w)
			end
			self.object:set_bone_position(bone_name, data.pos, { x = deg(n_pitch), y = data.rot.y, z = deg(n_yaw) })
		end
	end,
	feed = function(self, player)
		local name = player:get_player_name()
		if not self.owner
			or self.owner ~= name then
			return
		end
		local item, item_name = self:follow_wielded_item(player)
		if item_name then
			if not minetest.is_creative_enabled(player) then
				item:take_item()
				player:set_wielded_item(item)
			end
			if minetest.is_creative_enabled(player) then
				item:take_item()
				player:set_wielded_item(item)
			end
			local scale = self.growth_scale or 1
			if self.hp < (self.max_health * scale) then
				self:heal(self.max_health / 5)
			end
			if self.hunger
				and self.hunger < (self.max_health * 0.4) * scale then
				self.hunger = self.hunger + 5
				self:memorize("hunger", self.hunger)
			end
			if item_name:find("cooked") then
				self.food = (self.food or 0) + 1
			end
			if self.food
				and self.food >= 15
				and self.age then
				self.food = 0
				self:increase_age()
			end
			local pos = waterdragon.get_head_pos(self, player:get_pos())
			local minppos = vec_add(pos, 0.2 * scale)
			local maxppos = vec_sub(pos, 0.2 * scale)
			local def = minetest.registered_items[item_name]
			local texture = def.inventory_image
			if not texture or texture == "" then
				texture = def.wield_image
			end
			minetest.add_particlespawner({
				amount = 3,
				time = 0.1,
				minpos = minppos,
				maxpos = maxppos,
				minvel = { x = -1, y = 1, z = -1 },
				maxvel = { x = 1, y = 2, z = 1 },
				minacc = { x = 0, y = -5, z = 0 },
				maxacc = { x = 0, y = -9, z = 0 },
				minexptime = 1,
				maxexptime = 1,
				minsize = 4 * scale,
				maxsize = 6 * scale,
				collisiondetection = true,
				vertical = false,
				texture = texture,
			})
			return true
		end
		return false
	end,
	play_wing_sound = function(self)
		local offset = self.frame_offset or 0
		if offset > 20
			and not self.flap_sound_played then
			minetest.sound_play("waterdragon_flap", {
				object = self.object,
				gain = 2.5,
				max_hear_distance = 60,
				loop = false,
			})
			self.flap_sound_played = true
		elseif offset < 10 then
			self.flap_sound_played = false
		end
	end
}


waterdragon.scottish_wtd_api = {
	animate = function(self, anim)
		if self.animations and self.animations[anim] then
			if self._anim == anim then return end
			local old_anim = nil
			if self._anim then
				old_anim = self._anim
			end
			self._anim = anim
			local old_prty = 1
			if old_anim
				and self.animations[old_anim].prty then
				old_prty = self.animations[old_anim].prty
			end
			local prty = 1
			if self.animations[anim].prty then
				prty = self.animations[anim].prty
			end
			local aparms
			if #self.animations[anim] > 0 then
				aparms = self.animations[anim][random(#self.animations[anim])]
			else
				aparms = self.animations[anim]
			end
			aparms.frame_blend = aparms.frame_blend or 0
			if old_prty > prty then
				aparms.frame_blend = self.animations[old_anim].frame_blend or 0
			end
			self.anim_frame = -aparms.frame_blend
			self.frame_offset = 0
			self.object:set_animation(aparms.range, aparms.speed, aparms.frame_blend, aparms.loop)
		else
			self._anim = nil
		end
	end,
	open_jaw = function(self)
		if not self._anim then return end
		local _, rot = self.object:get_bone_position("Jaw.CTRL")
		local tgt_angle
		local open_angle = pi / 4
		if self.jaw_init then
			local end_anim = self._anim:find("_water") or floor(rot.x) == deg(-open_angle)
			if end_anim
				or self.roar_anim_length <= 0 then
				self.jaw_init = false
				self.roar_anim_length = 0
				local step = math.min(self.dtime * 5, abs(diff(rad(rot.x), 0)) % (pi2))
				tgt_angle = interp_angle(rad(rot.x), 0, step)
			else
				local step = math.min(self.dtime * 5, abs(diff(rad(rot.x), -open_angle)) % (pi2))
				tgt_angle = interp_angle(rad(rot.x), -open_angle, step)
				self.roar_anim_length = self.roar_anim_length - self.dtime
			end
		else
			local step = math.min(self.dtime * 5, abs(diff(rad(rot.x), 0)) % (pi2))
			tgt_angle = interp_angle(rad(rot.x), 0, step)
		end
		if tgt_angle < -45 then tgt_angle = -45 end
		if tgt_angle > 0 then tgt_angle = 0 end
		self.object:set_bone_position("Jaw.CTRL", { x = 0, y = 0.15, z = -0.29 }, { x = deg(tgt_angle), y = 0, z = 0 })
	end,
	play_sound = function(self, sound)
		if self.time_from_last_sound < 6 then return end
		local sounds = self.sounds
		if self.age < 15 then
			sounds = self.child_sounds
		end
		local spec = sounds and sounds[sound]
		local parameters = { object = self.object }
		if type(spec) == "table" then
			local name = spec.name
			if spec.variations then
				name = name .. "_" .. random(spec.variations)
			elseif #spec
				and #spec > 1 then
				spec = sounds[sound][random(#sounds[sound])]
				name = spec.name
			end
			local pitch = 1.0
			pitch = pitch - (random(-10, 10) * 0.005)
			parameters.gain = spec.gain or 1
			parameters.max_hear_distance = spec.distance or 8
			parameters.fade = spec.fade or 1
			parameters.pitch = pitch
			self.roar_anim_length = parameters.length or 1
			self.time_from_last_sound = 0
			self.jaw_init = true
			return minetest.sound_play(name, parameters)
		end
		return minetest.sound_play(spec, parameters)
	end,
	-- Dynamic Animation Methods
	tilt_to = waterdragon.wtd_api.tilt_to,
	set_weighted_velocity = function(self, speed, goal)
		self._tyaw = dir2yaw(goal)
		speed = speed or self._movement_data.speed
		local current_vel = self.object:get_velocity()
		local goal_vel = vec_multi(vec_normal(goal), speed)
		local momentum = vector.length(current_vel) * 0.003
		if momentum > 0.04 then momentum = 0.04 end
		local vel = current_vel
		vel.x = vel.x + (goal_vel.x - vel.x) * 0.05 - momentum
		vel.y = vel.y + (goal_vel.y - vel.y) * 0.05
		vel.z = vel.z + (goal_vel.z - vel.z) * 0.05 - momentum
		self.object:set_velocity(vel)
	end,
	open_jaw = function(self)
		if not self._anim then return end
		local anim_data = self.dynamic_anim_data.jaw
		local _, rot = self.object:get_bone_position("Jaw.CTRL")
		local tgt_angle
		local step = self.dtime * 5
		local open_angle = pi / 4
		if self.jaw_init then
			local end_anim = self._anim:find("fire") or floor(rot.x) == deg(-open_angle)
			if end_anim then
				self.jaw_init = false
				self.roar_anim_length = 0
				return
			end
			tgt_angle = interp_angle(rad(rot.x), -open_angle, step)
			self.roar_anim_length = self.roar_anim_length - self.dtime
		else
			tgt_angle = interp_angle(rad(rot.x), 0, step)
		end
		local offset = { x = 0, y = anim_data.pos.y, z = anim_data.pos.z }
		self.object:set_bone_position("Jaw.CTRL", offset, { x = clamp(tgt_angle, -45, 0), y = 0, z = 0 })
	end,
	move_tail = waterdragon.wtd_api.move_tail,
	move_head = waterdragon.wtd_api.move_head,
	feed = function(self, player)
		local name = player:get_player_name()
		if not self.owner
			or self.owner ~= name then
			return
		end
		local item, item_name = self:follow_wielded_item(player)
		if item_name then
			if not minetest.is_creative_enabled(player) then
				item:take_item()
				player:set_wielded_item(item)
			end
			local scale = self.growth_scale or 1
			if self.hp < (self.max_health * scale) then
				self:heal(self.max_health / 5)
			end
			if self.hunger
				and self.hunger < (self.max_health * 0.5) * scale then
				self.hunger = self.hunger + 5
				self:memorize("hunger", self.hunger)
			end
			if item_name:find("cooked") then
				self.food = (self.food or 0) + 1
			end
			if self.food
				and self.food >= 20
				and self.age then
				self.food = 0
				self:increase_age()
			end
			local pos = waterdragon.get_head_pos(self, player:get_pos())
			local minppos = vec_add(pos, 0.2 * scale)
			local maxppos = vec_sub(pos, 0.2 * scale)
			local def = minetest.registered_items[item_name]
			local texture = def.inventory_image
			if not texture or texture == "" then
				texture = def.wield_image
			end
			minetest.add_particlespawner({
				amount = 3,
				time = 0.1,
				minpos = minppos,
				maxpos = maxppos,
				minvel = { x = -1, y = 1, z = -1 },
				maxvel = { x = 1, y = 2, z = 1 },
				minacc = { x = 0, y = -5, z = 0 },
				maxacc = { x = 0, y = -9, z = 0 },
				minexptime = 1,
				maxexptime = 1,
				minsize = 4 * scale,
				maxsize = 6 * scale,
				collisiondetection = true,
				vertical = false,
				texture = texture,
			})
			return true
		end
		return false
	end,
	play_wing_sound = function(self)
		local offset = self.frame_offset or 0
		if offset > 20
			and not self.flap_sound_played then
			minetest.sound_play("waterdragon_flap", {
				object = self.object,
				gain = 3.0,
				max_hear_distance = 128,
				loop = false,
			})
			self.flap_sound_played = true
		elseif offset < 10 then
			self.flap_sound_played = false
		end
	end
}


dofile(minetest.get_modpath("waterdragon") .. "/api/forms.lua")

minetest.register_on_mods_loaded(function()
	for k, v in pairs(waterdragon.wtd_api) do
		minetest.registered_entities["waterdragon:pure_water_dragon"][k] = v
		minetest.registered_entities["waterdragon:rare_water_dragon"][k] = v
	end
	for k, v in pairs(waterdragon.scottish_wtd_api) do
		minetest.registered_entities["waterdragon:scottish_dragon"][k] = v
	end
end)

--------------
-- Commands --
--------------

minetest.register_privilege("draigh_uisge", {
	description = "Allows Player to force Water Dragons",
	give_to_singleplayer = false,
	give_to_admin = false
})


minetest.register_chatcommand("call_wtd", {
	params = "[radius]",
	description = S("Teleport your nearest Water Dragon to you within the specified radius"),
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return false, "Player not found" end

		local radius = tonumber(param) or 100 -- Default radius is 100 blocks
		local player_pos = player:get_pos()
		local nearest_dragon = nil
		local nearest_dist = radius

		-- Search for the nearest Water Dragon within the radius
		for _, obj in pairs(minetest.get_objects_inside_radius(player_pos, radius)) do
			local ent = obj:get_luaentity()
			if ent and (ent.name == "waterdragon:pure_water_dragon" or ent.name == "waterdragon:rare_water_dragon" or ent.name == "waterdragon:scottish_dragon") then
				if ent.owner == name then
					local dist = vector.distance(player_pos, obj:get_pos())
					if dist < nearest_dist then
						nearest_dragon = ent
						nearest_dist = dist
					end
				end
			end
		end

		if nearest_dragon then
			-- Teleport the Water Dragon to the player
			local teleport_pos = vector.new(player_pos.x, player_pos.y + 1, player_pos.z)
			nearest_dragon.object:set_pos(teleport_pos)

			-- Turn the Water Dragon to face the same direction as the player
			local player_look_dir = player:get_look_dir()
			local yaw = minetest.dir_to_yaw(player_look_dir)
			nearest_dragon.object:set_yaw(yaw)

			-- Set the "stand" animation if the animate method exists
			if nearest_dragon.animate then
				nearest_dragon:animate("stand")
			end

			return true, S("The nearest Water Dragon has been called and has flied to you!")
		else
			return false, "No Water Dragons found within " .. radius .. " blocks"
		end
	end,
})

minetest.register_chatcommand("set_wtd_owner", {
	description = S("Sets owner of pointed Water Dragon"),
	params = "<name>",
	privs = { draigh_uisge = true },
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		local param_name = params:match("%S+")
		if not player or not param_name then return false end
		local dir = player:get_look_dir()
		local pos = player:get_pos()
		pos.y = pos.y + player:get_properties().eye_height or 1.625
		local dest = vec_add(pos, vec_multi(dir, 40))
		local object, ent = get_pointed_mob(pos, dest)
		if object then
			local ent_pos = ent:get_center_pos()
			local particle = "waterdragon_particle_green.png"
			ent.owner = param_name
			ent:memorize("owner", ent.owner)
			minetest.chat_send_player(name, S("the Water Dragon is now owned by") .. " " .. param_name)
			minetest.add_particlespawner({
				amount = 16,
				time = 0.25,
				minpos = {
					x = ent_pos.x - ent.width,
					y = ent_pos.y - ent.width,
					z = ent_pos.z - ent.width
				},
				maxpos = {
					x = ent_pos.x + ent.width,
					y = ent_pos.y + ent.width,
					z = ent_pos.z + ent.width
				},
				minacc = { x = 0, y = 0.25, z = 0 },
				maxacc = { x = 0, y = -0.25, z = 0 },
				minexptime = 0.75,
				maxexptime = 1,
				minsize = 4,
				maxsize = 4,
				texture = particle,
				glow = 7
			})
		else
			minetest.chat_send_player(name, S("You must be pointing at a Water Dragon"))
		end
	end
})

-----------------------------------
-- Water Dragon Attack Blacklist --
-----------------------------------


local function is_player_in_attack_blacklist(owner, player_name)
	return waterdragon.wtd_attack_bl[owner] and table.indexof(waterdragon.wtd_attack_bl[owner], player_name) ~= -1
end

minetest.register_globalstep(function(dtime)
	for _, obj in pairs(minetest.luaentities) do
		if obj.name and string.match(obj.name, "^waterdragon:") and obj.owner then
			for _, player in ipairs(minetest.get_connected_players()) do
				local player_name = player:get_player_name()
				if is_player_in_attack_blacklist(obj.owner, player_name) then
					obj._target = player
					if obj.stance then
						obj.stance = "neutral"
					end
					break
				end
			end
		end
	end
end)


minetest.register_chatcommand("wtd_blacklist_add", {
	description = S("Adds player to attack blacklist of Water Dragons"),
	params = "<player_name>",
	func = function(name, param)
		local target = param:match("^(%S+)$")
		if not target then
			return false, "Invalid usage. Use: /wtd_blacklist_add <player_name>"
		end
		if not minetest.player_exists(target) then
			return false, S("Player does not exist")
		end
		waterdragon.wtd_attack_bl[name] = waterdragon.wtd_attack_bl[name] or {}
		table.insert(waterdragon.wtd_attack_bl[name], target)
		waterdragon.force_storage_save = true
		return true, S("The player has been added to the Water Dragon attack blacklist")
	end,
})

minetest.register_chatcommand("wtd_blacklist_remove", {
	description = S("Removes player from attack blacklist of the Water Dragons"),
	params = "<player_name>",
	func = function(name, param)
		local target = param:match("^(%S+)$")
		if not target then
			return false, "Invalid usage. Use: /wtd_blacklist_remove <player_name>"
		end
		if not waterdragon.wtd_attack_bl[name] then
			return false, S("You don't have any players in your attack blacklist")
		end
		local index = table.indexof(waterdragon.wtd_attack_bl[name], target)
		if index == -1 then
			return false, "The player is not in your Water Dragons' attack blacklist"
		end
		table.remove(waterdragon.wtd_attack_bl[name], index)
		waterdragon.force_storage_save = true
		return true, S("The player has been removed from the Water Dragon attack blacklist")
	end,
})

minetest.register_chatcommand("wtd_blacklist_show", {
	description = "List all players in your Water Dragons' attack blacklist",
	func = function(name)
		if not waterdragon.wtd_attack_bl[name] or #waterdragon.wtd_attack_bl[name] == 0 then
			return true, "Your Water Dragons' attack blacklist is empty."
		end

		local list = "Players in your Water Dragons' attack blacklist:\n"
		for i, player_name in ipairs(waterdragon.wtd_attack_bl[name]) do
			list = list .. i .. ". " .. player_name .. "\n"
		end

		return true, list
	end
})

----------------------
-- Target Assigning --
----------------------

local function get_wtd_by_id(wtd_id)
	for _, ent in pairs(minetest.luaentities) do
		if ent.wtd_id
			and ent.wtd_id == wtd_id then
			return ent
		end
	end
end

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_entities) do
		if (minetest.registered_entities[name].logic
				or minetest.registered_entities[name].brainfunc)
			or minetest.registered_entities[name]._cmi_is_mob
			or minetest.registered_entities[name]._waterdragon_mob then
			local old_punch = def.on_punch
			if not old_punch then
				old_punch = function() end
			end
			local on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
				old_punch(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
				local pos = self.object:get_pos()
				if not pos then return end
				if not puncher:is_player() then
					return
				end
				local player_name = puncher:get_player_name()
				if waterdragon.bonded_wtd[player_name]
					and #waterdragon.bonded_wtd[player_name] > 0 then
					for i = 1, #waterdragon.bonded_wtd[player_name] do
						local ent = get_wtd_by_id(waterdragon.bonded_wtd[player_name][i])
						if ent then
							ent._target = self.object
						end
					end
					for object, data in pairs(waterdragon.scottish_dragons) do
						if object
							and object:get_pos()
							and data.owner
							and data.owner == player_name
							and vec_dist(pos, object:get_pos()) < 64 then
							object:get_luaentity()._target = self.object
						end
					end
				end
			end
			minetest.registered_entities[name].on_punch = on_punch
		end
	end
end)
-----------------
-- On Activate --
-----------------

-- Water Dragon

function waterdragon.dragon_activate(self)
	if not self.object or not self.object:get_pos() then
		return
	end
	local dragon_type = "rare_water"
	if self.name == "waterdragon:pure_water_dragon" then
		dragon_type = "pure_water"
	end
	self.eyes_peeled = self:recall("eyes_peeled") or false
	self.pegasus_rescue_initialized = self.pegasus_rescue_initialized or false
	generate_texture(self)
	self.eye_color = self:recall("eye_color")

	if not self.eye_color then
		self.eye_color = water_eye_textures[random(4)]
		self:memorize("eye_color", self.eye_color)
	end

	self.armour = self:recall("armour") or false
	self.transport_rider = self:recall("transport_rider") or false
	self.gender = self:recall("gender") or nil
	if not self.gender then
		local genders = { "male", "female" }
		self.gender = self:memorize("gender", genders[random(2)])
	end
	if self.growth_scale then
		self:memorize("growth_scale", self.growth_scale) -- This is for spawning children
	end
	self.growth_scale = self:recall("growth_scale") or 1
	self.growth_timer = self:recall("growth_timer") or 700
	self.age = self:recall("age") or 110
	local age = self.age
	if age <= 25 then
		self.growth_stage = 1
	elseif age <= 50 then
		self.growth_stage = 2
	elseif age <= 75 then
		self.growth_stage = 3
	else
		self.growth_stage = 4
	end
	self.hunger = self:recall("hunger") or ((self.max_health * 0.3) * self.growth_scale) * 0.3
	self:set_scale(self.growth_scale)
	self:do_growth()
	self:set_drops()
	self.drop_queue = self:recall("drop_queue") or nil
	if self.growth_scale < 0.25 then
		if not self.texture_no then
			self.texture_no = random(#self.child_textures)
		end
		self.textures = self.child_textures
		self:set_texture(self.texture_no, self.child_textures)
	end
	-- Tamed Data
	self.owner = self:recall("owner") or false
	self.stance = self:recall("stance") or "neutral"
	self.order = self:recall("order") or "wander"
	self.fly_allowed = self:recall("fly_allowed") or true
	self.aux_setting = self:recall("aux_setting") or "toggle_view"
	self.pitch_fly = self:recall("pitch_fly") or false
	self.shoulder_mounted = false
	activate_nametag(self)
	-- Movement Data
	self.is_landed = self:recall("is_landed") or false
	self.attack_stamina = self:recall("attack_stamina") or 150
	self.attack_disabled = self:recall("attack_disabled") or false
	self.flight_stamina = self:recall("flight_stamina") or 300
	self.wtd_walking_mode = self:recall("wtd_walking_mode") or false

	-- Sound Data
	self.flap_sound_timer = 5.0
	self.flap_sound_played = false
	self.time_from_last_sound = 0
	-- World Data
	self.nest_pos = self:recall("nest_pos")
	self._path = {}
	self._ignore_obj = {}
	self.alert_timer = self:recall("alert_timer") or 0
	self._remove = self:recall("_remove") or nil
	self.wtd_id = self:recall("wtd_id") or 1
	if self.wtd_id == 1 then
		self.wtd_id = waterdragon.generate_id()
		self:memorize("wtd_id", self.wtd_id)
	end
	local global_data = waterdragon.waterdragons[self.wtd_id] or {}
	if global_data.removal_queue
		and #global_data.removal_queue > 0 then
		for i = #global_data.removal_queue, 1, -1 do
			if global_data.removal_queue[i]
				and vector.equals(vec_round(global_data.removal_queue[i]), vec_round(self.object:get_pos())) then
				waterdragon.waterdragons[self.wtd_id].removal_queue[i] = nil
				self.object:remove()
				return
			end
		end
	end
	waterdragon.waterdragons[self.wtd_id] = {
		last_pos = self.object:get_pos(),
		owner = self.owner or nil,
		staticdata = self:get_staticdata(),
		removal_queue = global_data.removal_queue or {},
		stored_in_item = global_data.stored_in_item or false
	}
	local owner = waterdragon.waterdragons[self.wtd_id].owner
	if owner
		and minetest.get_player_by_name(owner)
		and (not waterdragon.bonded_wtd[owner]
			or not is_value_in_table(waterdragon.bonded_wtd[owner], self.wtd_id)) then
		waterdragon.bonded_wtd[owner] = waterdragon.bonded_wtd[owner] or {}
		table.insert(waterdragon.bonded_wtd[owner], self.wtd_id)
	end
end

-------------
-- On Step --
-------------

function play_wing_sound(self)
	if not self.object or not self.object:get_pos() then
		return
	end
	if not self.is_flying then return end
	if not self._anim == "fly" or not self._anim == "hover" and self.touching_ground then return end
	-- Check if frame offset exists
	local offset = self.frame_offset or 0

	-- Play sound at specific frame point (when wings are at highest position)
	if offset > 20 and not self.flap_sound_played then
		minetest.sound_play("waterdragon_flap", {
			object = self.object,
			gain = 3.0,
			max_hear_distance = 128,
			loop = false,
		})
		self.flap_sound_played = true
		-- Reset sound flag when wings are down
	elseif offset < 10 then
		self.flap_sound_played = false
	end
end

-- Scottish Dragon

function waterdragon.scottish_dragon_activate(self)
	if not self.object or not self.object:get_pos() then
		return
	end
	self.scottish_eye_colour = self:recall("scottish_eye_colour")
	self.attack_cooldown = {}
	if self.scottish_id == 1 then
		self.scottish_id = waterdragon.generate_scottish_id()
		self:memorize("scottish_id", self.scottish_id)
	end
	-- Tamed Data
	self.rider = nil
	self.owner = self:recall("owner") or false
	self.stance = self:recall("stance") or "neutral"
	self.order = self:recall("order") or "wander"
	self.fly_allowed = self:recall("fly_allowed") or false
	self.hunger = self:recall("hunger") or self.max_hunger
	self.is_stored_in_item = self.is_stored_in_item or false
	self.armour = self:recall("armour") or false
	activate_nametag(self)
	-- Movement Data
	self.is_landed = self:recall("is_landed") or false
	-- World Data
	self._ignore_obj = {}
	self.flight_stamina = self:recall("flight_stamina") or 1600
	-- Sound Data
	self.time_from_last_sound = 0
	self.flap_sound_timer = 5.0
	self.flap_sound_played = false
	waterdragon.scottish_dragons[self.object] = { owner = self.owner }
end

-- Water Dragon

function waterdragon.dragon_step(self, dtime)
	if self.object and self.object:get_pos() then
		self:update_emission()
	end
	self:destroy_terrain()
	if not self.object or not self.object:get_pos() then
		return
	end

	-- Animation Tracking
	local current_anim = self._anim
	local is_flying = current_anim and current_anim:find("fly")
	local is_firing = current_anim and current_anim:find("pure_water")
	if current_anim then
		local aparms = self.animations[current_anim]
		if self.anim_frame ~= -1 then
			self.anim_frame = self.anim_frame + dtime
			self.frame_offset = floor(self.anim_frame * aparms.speed)
			if self.frame_offset > aparms.range.y - aparms.range.x then
				self.anim_frame = 0
				self.frame_offset = 0
			end
		end
	end
	-- Dynamic Animation
	if self.owner then
		waterdragon.head_tracking(self)
	end
	self:open_jaw()
	self:move_tail()
	waterdragon.rotate_to_pitch(self, is_flying)
	-- Shoulder Mounting
	if self.shoulder_mounted then
		self:clear_action()
		self:animate("shoulder_idle")
		local player = minetest.get_player_by_name(self.owner)
		if not player
			or player:get_player_control().sneak == true
			or self.age > 4 then
			self.object:set_detach()
			self.shoulder_mounted = self:memorize("shoulder_mounted", false)
		end
		is_flying = false
	end

	-- Dynamic Physics
	self.speed = 50 * clamp((self.growth_scale), 0.1, 1)     -- Speed increases with size
	self.turn_rate = 6 - 3 * clamp((self.growth_scale), 0.1, 1) -- Turning radius widens with size
	if not is_flying then
		self.speed = self.speed * 0.18                       -- Speed reduced when landed
		self.turn_rate = self.turn_rate * 1.5                -- Turning radius reduced when landed
	end
	-- Timers
	if self:timer(1) then
		self:do_growth()
		-- Misc
		self.time_from_last_sound = self.time_from_last_sound + 1
		self.anim_frame = -1
		self._anim = nil -- Initialize animation state as nil to be set by animate function
		if self.time_in_horn then
			self.growth_timer = self.growth_timer - self.time_in_horn / 2
			self.time_in_horn = nil
		end
		if random(16) < 2
			and not is_firing then
			self:play_sound("random")
		end
		-- Dynamic Stats
		local fly_stam = self.flight_stamina or 300
		local atk_stam = self.attack_stamina or 150
		local alert_timer = self.alert_timer or 0
		if is_flying
			and not self.in_liquid then -- Drain Stamina when flying
			fly_stam = fly_stam - 1
		else
			if fly_stam < 300 then -- Regen Stamina when landed
				fly_stam = fly_stam + self.dtime * 8
			end
		end
		if atk_stam < 100 then -- Regen Stamina constantly
			atk_stam = atk_stam + 1
		end
		if alert_timer > 0 then
			alert_timer = alert_timer - 1
		end
		self.flight_stamina = self:memorize("flight_stamina", fly_stam)
		self.attack_stamina = self:memorize("attack_stamina", atk_stam)
		self.alert_timer = self:memorize("alert_timer", alert_timer)
	end
	if self:timer(5) then
		local obj = next(self._ignore_obj)
		if obj then self._ignore_obj[obj] = nil end
	end
	if is_flying then
		self:play_wing_sound()
	end
	-- Switch Aerial/Terrestrial States
	if not self.is_landed
		and not self.fly_allowed
		and self.owner then
		self.is_landed = self:memorize("is_landed", true)
	elseif self:timer(16)
		and random(4) < 2 then
		if self.is_landed
			and self.flight_stamina > 50 then
			self.is_landed = self:memorize("is_landed", false)
		else
			self.is_landed = self:memorize("is_landed", true)
		end
	end
	-- Global Info
	if self.hp <= 0 then
		waterdragon.waterdragons[self.wtd_id] = nil
		return
	end
	local global_data = waterdragon.waterdragons[self.wtd_id] or {}
	waterdragon.waterdragons[self.wtd_id] = {
		last_pos = self.object:get_pos(),
		owner = self.owner or nil,
		name = self.nametag or nil,
		staticdata = self:get_staticdata(),
		removal_queue = global_data.removal_queue or {},
		stored_in_item = global_data.stored_in_item or false
	}
	if waterdragon.waterdragons[self.wtd_id].stored_in_item then
		self.object:remove()
	end
end

-------------------
-- On Rightclick --
-------------------

-- Scottish Dragon

function waterdragon.scottish_dragon_break_block(self, pos)
	if not minetest.settings:get_bool("water_dragon_terrain_destruction", true) then
		return
	end

	local node = minetest.get_node(pos)
	if node.name ~= "air" then
		minetest.remove_node(pos)
	end
end

function waterdragon.scottish_dragon_step(self, dtime)
	-- Animation Tracking
	local current_anim = self._anim
	local is_flying = current_anim and (current_anim == "fly" or current_anim == "dive")
	if current_anim then
		local aparms = self.animations[current_anim]
		if self.anim_frame ~= -1 then
			self.anim_frame = self.anim_frame + dtime
			self.frame_offset = floor(self.anim_frame * aparms.speed)
			if self.frame_offset > aparms.range.y - aparms.range.x then
				self.anim_frame = 0
				self.frame_offset = 0
			end
		end
	end
	-- Dynamic Animation
	if self.owner then
		waterdragon.head_tracking(self)
	end
	if not self.owner then
		self.fly_allowed = true
	end
	self:open_jaw()
	self:move_tail()
	waterdragon.rotate_to_pitch(self, is_flying)
	-- Breaking blocks
	if self._anim == "fly" or self._anim == "dive" then
		local pos = self.object:get_pos()
		local velocity = self.object:get_velocity()

		if velocity and vector.length(velocity) > 5 then
			local yaw = self.object:get_yaw()
			local dir = minetest.yaw_to_dir(yaw)
			local front_pos = vector.add(pos, vector.multiply(dir, 2))

			for y = -1, 1 do
				for x = -1, 1 do
					for z = -1, 1 do
						local check_pos = vector.add(front_pos, { x = x + 2, y = y, z = z + 2 })
						waterdragon.scottish_dragon_break_block(self, check_pos)
					end
				end
			end
		end
	end
	-- Timers
	if self:timer(1) then
		if random(16) < 2 then
			self:play_sound("random")
		end
		play_wing_sound(self)
		self.speed = 32
		self.turn_rate = 5
		-- Dynamic Stats
		local fly_stam = self.flight_stamina or 1600
		if is_flying
			and not self.in_liquid
			and fly_stam > 0 then         -- Drain Stamina when flying
			fly_stam = fly_stam - 1
			self.turn_rate = self.turn_rate * 0.75 -- Turning radius incrased when flying
		else
			self.speed = self.speed * 0.2 -- Speed reduced when landed
			if fly_stam < 1600 then       -- Regen Stamina when landed
				fly_stam = fly_stam + self.dtime * 8
			end
		end
		self.flight_stamina = self:memorize("flight_stamina", fly_stam)
		-- Attack Cooldown
		if #self.attack_cooldown > 0 then
			for obj, cooldown in pairs(self.attack_cooldown) do
				if obj
					and obj:get_pos() then
					if cooldown - 1 <= 0 then
						self.attack_cooldown[obj] = nil
					else
						self.attack_cooldown[obj] = cooldown - 1
					end
				else
					self.attack_cooldown[obj] = nil
				end
			end
		end
	end
	if self:timer(15) then
		local obj = next(self._ignore_obj)
		if obj then self._ignore_obj[obj] = nil end
	end
	if not waterdragon.scottish_dragons[self.object] then
		waterdragon.scottish_dragons[self.object] = { owner = self.owner }
	end
end

-- Scottish Dragon

function waterdragon.scottish_action_fly_and_throw(self, rider)
	self.fly_allowed = true
	local initial_pos = self.object:get_pos()
	if not initial_pos then return end

	-- First stage - fly up
	local target_pos = {
		x = initial_pos.x,
		y = initial_pos.y + 75,
		z = initial_pos.z
	}

	waterdragon.action_fly(self, target_pos, 3, "waterdragon:fly_simple", 0.8, "fly")

	-- Second stage - circular flight and throw
	minetest.after(3, function()
		if not self.object:get_luaentity() then return end

		local current_pos = self.object:get_pos()
		if not current_pos then return end

		-- Create a target position for circular flight
		local circle_pos = {
			x = current_pos.x + 15,
			y = current_pos.y,
			z = current_pos.z + 15
		}

		waterdragon.action_fly(self, circle_pos, 2, "waterdragon:fly_simple", 1, "fly")

		-- Throw rider after the flight
		minetest.after(2, function()
			if not self.object:get_luaentity() then return end
			if self.rider and self.owner then
				local rider_obj = self.rider
				waterdragon.detach_player(self, rider_obj)

				local yaw = self.object:get_yaw()
				local throw_dir = {
					x = -math.sin(yaw),
					y = 0,
					z = math.cos(yaw)
				}

				local throw_strength = 15
				rider_obj:add_velocity({
					x = throw_dir.x * throw_strength,
					y = 5,
					z = throw_dir.z * throw_strength
				})

				minetest.after(0.1, function()
					if rider_obj:get_hp() > 0 then
						rider_obj:set_hp(rider_obj:get_hp() - 5)
					end
				end)
			end
		end)
	end)
end

function waterdragon.scottish_dragon_rightclick(self, clicker)
	local name = clicker:get_player_name()
	local inv = minetest.get_inventory({ type = "player", name = name })
	if waterdragon.contains_book(inv) then
		waterdragon.add_page(inv, "scottish_dragons")
	end
	if self.hp <= 0 then return end
	local name = clicker:get_player_name()

	if self:feed(clicker) then
		return
	end
	local item_name = clicker:get_wielded_item():get_name() or ""
	if (not self.owner or name == self.owner) and not self.rider and item_name == "" then
		if self.owner and clicker:get_player_control().sneak then
			self:show_formspec(clicker)
		else
			waterdragon.attach_player(self, clicker)
			if not has_bowed_to_scottish_dragon(name, self) and self.rider and self.owner then
				minetest.after(1, function()
					if self.object:get_luaentity() then
						waterdragon.scottish_action_fly_and_throw(self)
					end
				end)
				minetest.chat_send_player(name, S("You didn't bow to the Scottish Dragon. Hold on tight!"))
			end
		end
	elseif name ~= self.owner and self.owner then
		minetest.chat_send_player(name, S("This Scottish Dragon belongs to someone else."))
	elseif not self.owner then
		minetest.chat_send_player(name, S("This is a wild Scottish Dragon"))
	end
end

-- Water Dragon

function waterdragon.action_fly_and_throw(self, rider)
	self.fly_allowed = true
	local initial_pos = self.object:get_pos()
	if not initial_pos then return end

	-- First stage - fly up
	local target_pos = {
		x = initial_pos.x,
		y = initial_pos.y + 75,
		z = initial_pos.z
	}

	waterdragon.action_fly(self, target_pos, 3, "waterdragon:fly_simple", 0.8, "fly")

	-- Second stage - circular flight and throw
	minetest.after(3, function()
		if not self.object:get_luaentity() then return end

		local current_pos = self.object:get_pos()
		if not current_pos then return end

		-- Create a target position for circular flight
		local circle_pos = {
			x = current_pos.x + 15,
			y = current_pos.y,
			z = current_pos.z + 15
		}

		waterdragon.action_fly(self, circle_pos, 2, "waterdragon:fly_simple", 1, "fly")

		-- Throw rider after the flight
		minetest.after(2, function()
			if not self.object:get_luaentity() then return end
			if self.rider and self.owner then
				local rider_obj = self.rider
				waterdragon.detach_player(self, rider_obj)

				local yaw = self.object:get_yaw()
				local throw_dir = {
					x = -math.sin(yaw),
					y = 0,
					z = math.cos(yaw)
				}

				local throw_strength = 15
				rider_obj:add_velocity({
					x = throw_dir.x * throw_strength,
					y = 5,
					z = throw_dir.z * throw_strength
				})

				minetest.after(0.1, function()
					if rider_obj:get_hp() > 0 then
						rider_obj:set_hp(rider_obj:get_hp() - 5)
					end
				end)
			end
		end)
	end)
end

function waterdragon.dragon_rightclick(self, clicker)
	if not clicker then return end
	if not self.object:get_pos() then return end
	local name = clicker:get_player_name()
	local inv = minetest.get_inventory({ type = "player", name = name })
	if waterdragon.contains_book(inv) then
		waterdragon.add_page(inv, "waterdragons")
	end
	if self.hp <= 0 then
		if waterdragon.drop_items(self) then
			waterdragon.waterdragons[self.wtd_id] = nil
			self.object:remove()
		end
		return
	end
	if self:feed(clicker) then
		return
	end
	local item_name = clicker:get_wielded_item():get_name() or ""
	if self.owner and name == self.owner and item_name == "" then
		if clicker:get_player_control().sneak then
			self:show_formspec(clicker)
		elseif not self.rider and self.age >= 20 then
			waterdragon.attach_player(self, clicker)
			if not has_bowed_to_dragon(name, self) and self.rider and self.owner then
				minetest.after(1, function()
					if self.object:get_luaentity() then
						waterdragon.action_fly_and_throw(self)
					end
				end)
				minetest.chat_send_player(name, S("You didn't bow to the Water Dragon. Hold on tight!"))
			end
		elseif self.age < 5 then
			self.shoulder_mounted = self:memorize("shoulder_mounted", true)
			self.object:set_attach(clicker, "",
				{ x = 3 - self.growth_scale, y = 11.5, z = -1.5 - (self.growth_scale * 5) }, { x = 0, y = 0, z = 0 })
		end
	end
	if self.rider and not self.passenger and name ~= self.owner and item_name == "" then
		waterdragon.send_passenger_request(self, clicker)
	end
end

------------------
-- Specialities --
------------------


minetest.register_node("waterdragon:healing_water", {
	description = "Healing Water",
	drawtype = "liquid",
	waving = 3,
	tiles = { "default_water.png^[colorize:#14a9ff:80" },
	special_tiles = {
		{ name = "default_water.png^[colorize:#14a9ff:80", backface_culling = false },
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "waterdragon:healing_water",
	liquid_alternative_source = "waterdragon:healing_water",
	liquid_viscosity = 1,
	post_effect_color = { a = 103, r = 30, g = 60, b = 90 },
	groups = { water = 3, liquid = 3, puts_out_fire = 1, cools_lava = 1, not_in_creative_inventory = 1 },
	light_source = 5,
})

-- Table to store positions of healing water
local healing_water_positions = {}

-- Function to create healing water around a position
local function create_healing_water(pos, radius)
	for x = -radius, radius do
		for y = -radius, radius do
			for z = -radius, radius do
				local water_pos = vector.add(pos, { x = x, y = y, z = z })
				if vector.distance(pos, water_pos) <= radius then
					local node = minetest.get_node(water_pos)
					if node.name == "default:water_source" then
						minetest.set_node(water_pos, { name = "waterdragon:healing_water" })

						table.insert(healing_water_positions, water_pos)
					end
				end
			end
		end
	end
end


-- Function to remove healing water
local function remove_healing_water()
	for _, pos in ipairs(healing_water_positions) do
		if minetest.get_node(pos).name == "waterdragon:healing_water" then
			minetest.set_node(pos, { name = "default:water_source" })
		end
	end
	healing_water_positions = {}
end

-- Register globalstep to manage healing water around Rare Water Dragons
minetest.register_globalstep(function()
	remove_healing_water()

	for _, obj in pairs(minetest.luaentities) do
		if obj.name == "waterdragon:rare_water_dragon" then
			local pos = obj.object:get_pos()
			if pos then
				local node = minetest.get_node(pos)
				if minetest.get_item_group(node.name, "water") ~= 0 then
					create_healing_water(pos, 8)
				end
			end
		end
	end

	-- Heal players in healing water
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_pos = player:get_pos()
		local node = minetest.get_node(player_pos)
		if node.name == "waterdragon:healing_water" then
			local hp = player:get_hp()
			local max_hp = player:get_properties().hp_max
			if hp < max_hp then
				player:set_hp(math.min(hp + 1, max_hp))
			end
		end
	end
end)

-- Register ABM to revert healing water back to regular water
minetest.register_abm({
	label = "Revert healing water",
	nodenames = { "waterdragon:healing_water" },
	interval = 1,
	chance = 2,
	action = function(pos, node)
		local objects = minetest.get_objects_inside_radius(pos, 200)
		local rare_dragon_nearby = false
		for _, obj in ipairs(objects) do
			local ent = obj:get_luaentity()
			if ent and ent.name == "waterdragon:rare_water_dragon" then
				rare_dragon_nearby = true
				break
			end
		end
		if not rare_dragon_nearby then
			minetest.set_node(pos, { name = "default:water_source" })
		end
	end,
})

function throw_rider(self)
	if self.rider and self.owner then
		local rider = self.rider
		waterdragon.detach_player(self, rider)
		local dragon_pos = self.object:get_pos()
		local throw_dir
		if self.object:get_yaw() then
			local yaw = self.object:get_yaw()
			throw_dir = {
				x = -math.sin(yaw),
				y = 0,
				z = math.cos(yaw)
			}
		else
			throw_dir = {
				x = math.random() - 0.5,
				y = 0,
				z = math.random() - 0.5
			}
			local length = math.sqrt(throw_dir.x ^ 2 + throw_dir.z ^ 2)
			throw_dir.x = throw_dir.x / length
			throw_dir.z = throw_dir.z / length
		end

		local throw_strength = 10
		rider:add_velocity({
			x = throw_dir.x * throw_strength,
			y = 5, -- Add some vertical force
			z = throw_dir.z * throw_strength
		})
		minetest.after(0.1, function()
			if rider:get_hp() > 0 then
				rider:set_hp(rider:get_hp() - 5) -- Add some damage on throw
			end
		end)
	end
end

------------------------
-- Dragon Chat System --
------------------------


-- Storage for active chat sessions and cooldowns
local active_chats = {}
local player_cooldowns = {}

-- Command cooldowns (in seconds)
local command_cooldowns = {
	attack = 10,
	fly = 5,
	fire = 8,
	roar = 20,
	transport = 20,
}

-- Utility function to check cooldowns
local function check_cooldown(player_name, command)
	if not player_cooldowns[player_name] then
		player_cooldowns[player_name] = {}
	end

	if not player_cooldowns[player_name][command] then
		player_cooldowns[player_name][command] = 0
	end

	local current_time = minetest.get_gametime()
	if current_time < player_cooldowns[player_name][command] then
		return false
	end

	player_cooldowns[player_name][command] = current_time + command_cooldowns[command]
	return true
end

-- Dragon dialogue options
local dragon_dialogue = {
	greetings = {
		"*Ancient eyes meet yours as the Dragon's consciousness touches your mind*",
		"Your soul shimmers with curiosity, mortal. Speak.",
		"The old magics stir at your approach. What brings you to me?",
		"*The Dragon's gaze focuses on you with ancient wisdom*",
		"Few dare to seek Dragon's counsel. You intrigue me."
	},

	conversations = {
		["how are you"] = {
			"My essence flows with the eternal currents of magic and time.",
			"*The Dragon's scales shimmer with otherworldly light* I am as timeless as the waters themselves.",
			"My spirit soars between realms, ever watchful, ever present."
		},

		["how much stamina do you have"] = {
			"My stamina level is:",
			"My stamina level is:",
			"My stamina level is:"
		},

		["how much breath do you have"] = {
			"My breath level is:",
			"My breath level is:",
			"My breath level is:"
		},

		["thank you"] = {
			"You are welcome."
		},
		["how much health do you have"] = {
			"My health level is:",
			"My health level is:",
			"My health level is:"
		},

		["how hungry are you"] = {
			"My hunger level is:",
			"My hunger level is:",
			"My hunger level is:"
		},

		["tell me about yourself"] = {
			"I am one of the First Born, keeper of waters both seen and unseen.",
			"My bloodline traces back to when magic first touched these waters.",
			"I guard the boundaries between realms, where water meets sky."
		},

		["what can you do"] = {
			"I possess many abilities, young one. I can take flight through the skies - simply ask me to 'fly'. If you prove worthy, you may even ride upon my back - just ask to 'ride'. When we soar together, know that I can 'land' at your word, or 'take me to' any destination you desire. Should you need my presence, ask me to 'follow', or bid me 'stay' to guard a place. And yes, I can demonstrate my voice with a mighty 'roar'. If you spot an enemy, simply tell me to 'attack' while looking at them.",
			"The powers of ancient times flow through me. I can carry you through the skies - ask me to 'fly' or to 'ride'. My water breath brings doom to our foes - command 'fire' or point me to 'attack' them. I will 'follow' your path or 'stay' at your word, and can 'land' when our flight is done. If you seek a specific place, simply tell me to 'take me to' your destination. And should you wish to hear my true voice, ask me to 'roar'.",
			"My abilities are yours to command, seeker. Bid me 'fly' and I shall soar, or ask to 'ride' upon my back. Have me 'attack' those you face. I shall 'follow' where you lead or 'stay' where you wish. If you need to reach a distant place, tell me to 'take me to' your destination. When we need return to earth, simply ask me to 'land'. And yes, I can 'roar' to shake the very skies."
		},

		["what do you think of humans"] = {
			"Your kind are like ripples on water - brief, yet capable of creating great change. Some I find worthy of respect.",
			"Humans are interesting creatures. Short-lived but ambitious, capable of both great wisdom and great foolishness.",
			"I have watched your kind grow from simple tool-users to builders of great cities. You can be worthy allies when you prove yourself."
		},
		["who are your enemies"] = {
			"Those who threaten the balance of these waters and skies are my enemies.",
			"I stand against the chaos-bringers, the despoilers of nature, and those who would harm the innocent.",
			"Enemies? I have faced shadowy creatures from other realms and mortals who dared to challenge the sanctity of my domain."
		},
		["who are you"] = {
			"I am a guardian of the waters, a spirit of the skies, and a keeper of ancient wisdom: the ",
			"I am the fire of my enemies, a being of magic and mystery, known as ",
			"I am the embodiment of the ancient waters, a spirit of the skies. My type is known as the "
		},
		["why do you help me"] = {
			"I sense potential within you. The bond between Dragon and human is rare but powerful.",
			"Not all humans earn my aid, but your actions speak louder than words. I see a kindred spirit.",
			"I help those who respect the balance of the world. You have proven yourself worthy of my trust... so far."
		},

		["how old are you"] = {
			"I was born when the first waters flowed upon this land. Time holds little meaning to me.",
			"I am as old as the winds that carry whispers across the seas. Ancient, but ever present."
		},

		["what is your name"] = {
			"My name is a fire that burns in the depths of the ocean, a whisper in the winds of the skies. I am ",
			"I am known as the Water Dragon, a guardian of the waters and skies. My name is ",
			"I am the embodiment of the ancient waters, a spirit of the skies, and my name is the echo of the elements: "
		},

		["what do you eat"] = {
			"My sustenance comes from the energies of water and the skies, though I enjoy the occasional offering of fresh meat.",
			"I feed on the vitality of my domain. A meal of wild meat is a welcome gift, but not a necessity.",
			"My kind does not require sustenance as you do, though I appreciate tributes from those I bond with."
		},

		["can you teach me magic"] = {
			"Magic is not something I can teach — it is something you must discover within yourself. Are you sure?",
			"I can guide you, but the true essence of magic lies in your connection to the world... Are you sure?",
			"Magic flows through all things. If you are attuned, you may learn by observing my actions. Are you sure?"
		},

		["do you have a family"] = {
			"My kin are scattered across realms, guardians of their own domains.",
			"Family? We Dragons are solitary by nature, but I have crossed paths with others of my lineage.",
			"The bonds of Dragonkind are different from those of humans. My family is the sky, the water, and the earth."
		},

		["what is your purpose"] = {
			"To guard the waters, to preserve the balance, and to guide those worthy of my wisdom.",
			"My purpose is to maintain the harmony of the realms I traverse.",
			"I exist to protect and to remind others of the ancient forces that shaped this world."
		},

		["where do you come from"] = {
			"I emerged from the first waters, born of magic and the elements.",
			"My origins lie in a realm where water and sky merge into endless horizons.",
			"I come from a place older than memory, where dragons first learned to fly and waters sang their songs."
		},

		["what is magic to you"] = {
			"Magic flows through all existence, like water through streams. We Dragons are part of this eternal flow.",
			"It is the essence that binds all realms together, as ancient as time itself.",
			"Magic is not merely power, but the very breath of creation that sustains all things."
		},

		["what other dragons exist"] = {
			"Many of my kin soar through different realms. Some command fire, others dance with lightning.",
			"The Scottish Dragons are our distant cousins, proud and fierce in their own way.",
			"Each Dragon race carries its own ancient wisdom and power."
		},

		["do you dream"] = {
			"Our dreams flow like deep currents, carrying visions of ages past and yet to come.",
			"When I sleep, I see the world as it was in the time of the First Dragons.",
			"My dreams are filled with the songs of ancient waters and forgotten magics."
		},

		["what makes you happy"] = {
			"The freedom of flight, the song of rushing waters, and the trust of a true companion.",
			"When harmony exists between the realms of water, earth, and sky.",
			"Seeing wisdom grow in those who seek to understand the old ways."
		}
	},

	commands = {
		["fly"] = {
			name = "fly",
			response = "*The Dragon spreads its magnificent wings*",
			action = function(dragon, player)
				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I take orders only from my chosen rider."
				end

				if not dragon.fly_allowed then
					return false, "I am not allowed to fly"
				end

				if dragon.transport_rider then
					if dragon.wtd_walking_mode and dragon.flight_stamina > 50 then
						dragon.wtd_walking_mode = false
						waterdragon.action_takeoff(dragon, 5)
						minetest.chat_send_player(player:get_player_name(),
							(dragon.nametag or "Dragon") .. ": To the skies!")
						return true, ""
					elseif not dragon.wtd_walking_mode and not (dragon.touching_ground or dragon.is_landed) then
						return false, "I am already flying."
					else
						return false, "I am too tired to fly right now."
					end
				end
				if not check_cooldown(player:get_player_name(), "fly") then
					return false, "I must rest before taking flight again."
				end
				waterdragon.action_takeoff(dragon, 5)
				local initial_pos = dragon.object:get_pos()
				if not initial_pos then return end

				-- First stage - fly up
				local target_pos = {
					x = initial_pos.x,
					y = initial_pos.y + 25,
					z = initial_pos.z
				}

				waterdragon.action_fly(dragon, target_pos, 3, "waterdragon:fly_simple", 0.8, "fly")

				minetest.after(3, function()
					if not dragon.object:get_luaentity() then return end

					local current_pos = dragon.object:get_pos()
					if not current_pos then return end

					-- Create a target position for circular flight
					local circle_pos = {
						x = current_pos.x + 15,
						y = current_pos.y,
						z = current_pos.z + 15
					}

					waterdragon.action_fly(dragon, circle_pos, 2, "waterdragon:fly_simple", 1, "fly")
				end)
				return true
			end
		},
		["bring me to"] = {
			name = "bring me to",
			response = "*The Dragon raises its head and calls to its kin*",
			action = function(dragon, player, message)
				return false, "Please tell me the name of the Dragon you wish to visit (e.g., 'bring me to Kilgara')"
			end
		},


		["attack"] = {
			name = "attack",
			response = "*The Dragon's eyes narrow, focusing on your target*",
			action = function(dragon, player)
				if not check_cooldown(player:get_player_name(), "attack") then
					return false, "I need more time to recover my strength."
				end

				if dragon.age < 25 then
					return false, "I am too young to attack."
				end

				local pos = player:get_pos()
				local look_dir = player:get_look_dir()
				local target_pos = vector.add(pos, vector.multiply(look_dir, 20))

				for _, obj in ipairs(minetest.get_objects_inside_radius(target_pos, 40)) do
					local ent = obj:get_luaentity()
					if ent and not (ent.name:match("^waterdragon:") or ent.name:match("^winddragon:") or obj:is_player()) then
						dragon._target = obj
						return true
					end
				end
				return false, "I see no worthy targets in that direction."
			end
		},


		["ride"] = {
			name = "ride",
			response = "*The Dragon lowers its head, allowing you to mount*",
			action = function(dragon, player)
				if dragon.rider then
					return false, "I already have a rider."
				end
				if not dragon.age and dragon.name == "waterdragon:scottish_dragon" then
					waterdragon.attach_player(dragon, player)
					minetest.chat_send_player(player:get_player_name(),
						(dragon.nametag or "Dragon") .. ": You are now riding me.")
					return
				end
				if dragon.age < 30 then
					return false, "I am too young to carry you."
				end
				if dragon.transport_rider then
					return false, "I already have a rider."
				end

				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I only carry my chosen rider."
				end
				if not dragon.owner then
					return false, "I only carry my chosen rider."
				end

				waterdragon.attach_player(dragon, player)
				return true
			end
		},

		["land"] = {
			name = "land",
			response = "*The Dragon begins descending gracefully*",
			action = function(dragon, player)
				if dragon.is_landed and dragon.touching_ground then
					return false, "I am already on the ground."
				end
				if dragon.transport_rider then
					if not dragon.wtd_walking_mode then
						dragon:set_vertical_velocity(-20)
						if dragon.touching_ground then
							dragon.wtd_walking_mode = true
							waterdragon.action_land(dragon, 5)
							minetest.chat_send_player(player:get_player_name(),
								(dragon.nametag or "Dragon") .. ": To the land!")
						end
						return true, ""
					elseif dragon.wtd_walking_mode and dragon.touching_ground then
						return false, "I am already walking."
					else
						return false, "I cannot do that right now."
					end
				end
				function action_flight_to_land(self)
					if not self:get_action() then
						waterdragon.action_move(self, self.object:get_pos(), 3, "waterdragon:fly_simple", 0.6, "fly")
					end
					if self.touching_ground then
						waterdragon.action_land(self)
						self.is_landed = true
						return true
					end
					return false
				end

				action_flight_to_land(dragon)

				return true
			end
		},

		["stop"] = {
			name = "stop",
			response = "*The Dragon awaits your next command*",
			action = function(dragon, player)
				local continuous_actions = {}
				if not dragon or not dragon.object then return false end

				local action_stopped = false

				-- Stop continuous breath attack if active
				if dragon.wtd_id and continuous_actions[dragon.wtd_id] then
					continuous_actions[dragon.wtd_id] = nil
					action_stopped = true
				end

				-- Stop transport if active
				if dragon.transport_rider then
					if player:get_player_name() then
						player:set_detach()
						player:set_eye_offset({ x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
					end
					dragon.transport_rider = nil
					action_stopped = true
				end

				if dragon._target then
					dragon._target = nil
					action_stopped = true
				end
				-- Return appropriate message based on if anything was stopped
				if not action_stopped then
					return false, "I am not performing any command to stop."
				end

				return true
			end
		},
		["fire"] = {
			name = "fire",
			response = "*The Dragon begins to breathe water*",
			action = function(dragon, player)
				-- Check the Dragon type
				local dragon_name = dragon.object and dragon.object:get_luaentity() and
					dragon.object:get_luaentity().name
				if dragon_name == "waterdragon:rare_water_dragon" or dragon_name == "waterdragon:pure_water_dragon" then
					local continuous_actions = {}
					local anim
					-- Check attack stamina
					if dragon.attack_stamina <= 0 then
						return false, "I must rest to regain my breath power."
					end

					if not check_cooldown(player:get_player_name(), "attack") then
						return false, "I need more time to recover my strength of water breathing."
					end

					-- Start continuous breathing
					continuous_actions[dragon.wtd_id] = function()
						if not dragon or not dragon.object then return end

						-- Check attack stamina again
						if dragon.attack_stamina <= 0 then
							continuous_actions[dragon.wtd_id] = nil
							anim = "stand" -- Reset to default animation
							if dragon.owner then
								minetest.chat_send_player(dragon.owner,
									(dragon.nametag or "Dragon") .. ": I must rest my breath")
							end
							return
						end

						local current_yaw = dragon.object:get_yaw()
						local current_dir = minetest.yaw_to_dir(current_yaw)
						local current_pos = dragon.object:get_pos()

						if not current_pos then return end

						local visual_size = dragon.object:get_properties().visual_size
						local eye_offset = {
							x = 0,
							y = 4.5 * visual_size.y,
							z = 0
						}

						local eye_correction = vector.multiply(current_dir, eye_offset.z * 0.125)
						current_pos = vector.add(current_pos, eye_correction)
						current_pos.y = current_pos.y + eye_offset.y

						local tpos = vector.add(current_pos, vector.multiply(current_dir, 64))
						if anim then dragon:animate(anim) end
						dragon:breath_attack(tpos)

						-- Reduce attack_stamina
						dragon.attack_stamina = dragon.attack_stamina - 1
						dragon:memorize("attack_stamina", dragon.attack_stamina)

						-- Continue if still have stamina
						if continuous_actions[dragon.wtd_id] then
							minetest.after(0.1, continuous_actions[dragon.wtd_id])
						end
					end

					-- Start the continuous action
					continuous_actions[dragon.wtd_id]()
					return true
				elseif dragon_name == "waterdragon:scottish_dragon" then
					dragon.fire_breathing = true
					return true
				end
			end
		},

		["follow"] = {
			name = "follow",
			response = "I shall accompany you on your journey.",
			action = function(dragon, player)
				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I follow only my chosen rider."
				end

				dragon.order = "follow"
				return true
			end
		},

		["stay"] = {
			name = "stay",
			response = "I shall guard this place.",
			action = function(dragon, player)
				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I take orders only from my chosen rider."
				end

				dragon.order = "stay"
				return true
			end
		},
		["wander"] = {
			name = "wander",
			response = "Thank you!",
			action = function(dragon, player)
				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I take orders only from my chosen rider."
				end

				dragon.order = "wander"
				return true
			end
		},
		["i allow you to fly"] = {
			name = "allow_fly",
			response = "Thank you",
			action = function(dragon, player)
				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I take orders only from my chosen rider."
				end

				dragon.fly_allowed = true
				return true
			end
		},
		["i disallow you to fly"] = {
			name = "disallow_fly",
			response = "I shall walk.",
			action = function(dragon, player)
				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I take orders only from my chosen rider."
				end

				dragon.fly_allowed = false
				return true
			end
		},
		["come here"] = {
			name = "come",
			response = "*The Dragon spreads its wings and flies towards you*",
			action = function(dragon, player)
				local function flying_to_owner(self, player)
					if not self.object or not self.object:get_pos() then return false, "I cannot find your position." end
					-- Get owner position
					local owner_pos = player:get_pos()
					if not owner_pos then return end

					-- First fly towards owner
					local pos = self.object:get_pos()
					local dist = vector.distance(pos, owner_pos)

					if dist and pos and dist > 22 then
						waterdragon.action_fly(self, owner_pos, 3, "waterdragon:fly_simple", 0.8, "fly")
					elseif dist and pos and dist <= 22 then
						if not self.is_landed then
							waterdragon.action_land(self)
						end
						waterdragon.action_move(self, owner_pos, 3, "waterdragon:obstacle_avoidance", 1, "walk")
						return true
					end
					return false
				end
				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I take orders only from my chosen rider."
				end

				flying_to_owner(dragon, player)
				return true
			end
		},

		["roar"] = {
			name = "roar",
			response = "*The Dragon rears its head back and roars*",
			action = function(dragon, player)
				if dragon.owner and dragon.owner ~= player:get_player_name() then
					return false, "I take orders only from my chosen rider."
				end
				if not check_cooldown(player:get_player_name(), "roar") then
					return false, "My voice needs rest."
				end
				local roar_sounds = {
					"waterdragon_water_dragon_random_1",
					"waterdragon_water_dragon_random_2",
					"waterdragon_water_dragon_random_3"
				}

				local child_roar_sounds = {
					"waterdragon_water_dragon_child_1",
					"waterdragon_water_dragon_child_2",
					"waterdragon_water_dragon_child_3"
				}
				local selected_child_roar = child_roar_sounds[math.random(#child_roar_sounds)]
				local selected_roar = roar_sounds[math.random(#roar_sounds)]
				if dragon.age >= 15 then
					minetest.sound_play(selected_roar, {
						object = dragon.object,
						gain = 1.0,
						max_hear_distance = 32,
						loop = false
					})
				elseif dragon.age <= 15 then
					minetest.sound_play(selected_child_roar, {
						object = dragon.object,
						gain = 1.0,
						max_hear_distance = 20,
						loop = false
					})
				end


				minetest.sound_play("waterdragon_water_dragon_random_3", {
					object = dragon.object,
					gain = 1.0,
					max_hear_distance = 32,
					loop = false
				})
				return true
			end
		}
	},

	farewell = {
		"Until our paths cross again.",
		"*The Dragon's presence fades like mist*",
		"May the ancient powers guide your path.",
		"*The Dragon bows its head gracefully*",
		"Until fate weaves our paths together once more."
	},

	unknown = {
		"*Ancient magic stirs at your words*",
		"Your question touches upon mysteries few mortals comprehend.",
		"The waters ripple with the weight of your inquiry.",
		"*The Dragon's wisdom stretches across eons*",
		"Your thoughts stir ancient memories."
	}
}

waterdragon.register_movement_method("waterdragon:fly_obstacle_avoidance", function(self)
	local box = clamp(self.width, 0.5, 1.5)
	local steer_to
	local steer_timer = 0.25
	local vertical_adjust = 0
	local last_height = nil
	local retreat_phase = nil
	local retreat_start_pos = nil
	local original_dir = nil
	local maneuver_completed = false
	local mountain_detection_range = 120

	-- Check obstacles in 3D space
	local function check_obstacles(pos, dir, range)
		local obstacles = {
			front = false,
			up = false,
			down = false,
			left = false,
			right = false
		}
		if not pos or not dir then return obstacles end

		local check_points = {
			front = vector.add(pos, vector.multiply(dir, range)),
			up = vector.add(pos, { x = 0, y = range, z = 0 }),
			left = vector.add(pos, { x = dir.z * range, y = 0, z = -dir.x * range }),
			right = vector.add(pos, { x = -dir.z * range, y = 0, z = dir.x * range })
		}

		for direction, check_pos in pairs(check_points) do
			local ray = minetest.raycast(pos, check_pos, false, true)
			for pointed_thing in ray do
				if pointed_thing.type == "node" then
					local node = minetest.get_node(pointed_thing.under)
					if minetest.registered_nodes[node.name].walkable then
						obstacles[direction] = pointed_thing.under
						break
					end
				end
			end
		end
		return obstacles
	end

	local function handle_tired_dragon(self)
		if not self.wtd_walking_mode then
			self:set_vertical_velocity(-20)
			if self.touching_ground then
				waterdragon.action_land(self)
				self.wtd_walking_mode = true
				self:set_gravity(-5)
				minetest.chat_send_player(self.owner,
					(self.nametag or "Dragon") .. ": I need to rest my wings. I'll walk for a while.")
				waterdragon.action_move(self, goal, 4000, "waterdragon:obstacle_avoidance", 1, "walk")
			end
		end

		if self.wtd_walking_mode then
			waterdragon.action_move(self, goal, 4000, "waterdragon:obstacle_avoidance", 1, "walk")
			self:set_gravity(-5)

			if self.transport_rider then
				local rider_name = self.transport_rider:get_player_name()
				if rider_name then
					minetest.chat_send_player(rider_name,
						(self.nametag or "Dragon") .. ": I need to rest my wings. I'll walk for a while.")
				end
			end
		end

		if self.flight_stamina >= 300 then
			if self.transport_rider then
				local rider_name = self.transport_rider:get_player_name()
				if rider_name then
					minetest.chat_send_player(rider_name,
						self.nametag or "Dragon" .. ": You can command me now to the skies.")
				end
			end
		end
	end

	local function get_3d_avoidance_dir(self)
		if maneuver_completed then
			local pos = self.object:get_pos()
			local current_dir = minetest.yaw_to_dir(self.object:get_yaw())

			local vertical_offsets = { 5, 15, 30, 45 }
			local hit_count = 0
			for _, offset in ipairs(vertical_offsets) do
				local start_pos = vector.add(pos, { x = 0, y = offset, z = 0 })
				local end_pos = vector.add(start_pos, vector.multiply(current_dir, mountain_detection_range))
				local ray = minetest.raycast(start_pos, end_pos, false, true)
				for pointed_thing in ray do
					if pointed_thing.type == "node" then
						local node = minetest.get_node(pointed_thing.under)
						if minetest.registered_nodes[node.name].walkable then
							hit_count = hit_count + 1
							break
						end
					end
				end
			end

			local obstacles = check_obstacles(pos, current_dir, box * 3)

			if obstacles.front then
				local escape_dirs = {
					{ x = current_dir.z,  y = 0.2, z = -current_dir.x }, -- Right and up
					{ x = -current_dir.z, y = 0.2, z = current_dir.x }, -- Left and up
					{ x = current_dir.x,  y = 1,   z = current_dir.z } -- Straight up
				}

				for _, dir in ipairs(escape_dirs) do
					local escape_pos = vector.add(pos, vector.multiply(dir, box * 3))
					local ray = minetest.raycast(pos, escape_pos, false, true)
					local blocked = false
					for pointed_thing in ray do
						if pointed_thing.type == "node" and
							minetest.registered_nodes[minetest.get_node(pointed_thing.under).name].walkable then
							blocked = true
							break
						end
					end
					if not blocked then
						return dir
					end
				end
			end
			return nil
		end

		local pos = self.object:get_pos()
		local current_dir = minetest.yaw_to_dir(self.object:get_yaw())
		local obstacles = check_obstacles(pos, current_dir, box * 3)

		if retreat_phase then
			if not retreat_start_pos then
				retreat_start_pos = vector.new(pos)
				original_dir = vector.new(current_dir)
				return vector.multiply(current_dir, -1)
			end

			local retreat_dist = vector.distance(retreat_start_pos, pos)
			if retreat_phase == "back" and retreat_dist > 20 then
				retreat_phase = "up"
				return { x = 0, y = 1, z = 0 }
			elseif retreat_phase == "up" and retreat_dist > 30 then
				retreat_phase = nil
				retreat_start_pos = nil
				maneuver_completed = true
				return vector.multiply(original_dir, -1)
			end

			if retreat_phase == "back" then
				return vector.multiply(current_dir, -1)
			elseif retreat_phase == "up" then
				return { x = 0, y = 1, z = 0 }
			end
		end

		if obstacles.front then
			retreat_phase = "back"
			retreat_start_pos = nil
			return vector.multiply(current_dir, -1)
		end

		return nil
	end

	local function func(_self, goal, speed_factor)
		if _self.flight_stamina <= 100 and not _self.wtd_walking_mode then
			handle_tired_dragon(_self, goal)
			return
		end

		local pos = _self.object:get_pos()
		if not pos then return end

		if not last_height then
			last_height = pos.y
		end

		if vector.distance(pos, goal) < box * 1.33 then
			_self:halt()
			retreat_phase = nil
			retreat_start_pos = nil
			return true
		end

		steer_timer = (steer_timer > 0 and steer_timer - _self.dtime) or 0.25
		steer_to = (steer_timer > 0 and steer_to) or (steer_timer <= 0 and get_3d_avoidance_dir(_self))
		local goal_dir = steer_to or vector.direction(pos, goal)

		if not steer_to and not retreat_phase then
			goal_dir.y = (goal.y - pos.y) * 0.1
			if math.abs(goal_dir.y) < 0.1 then
				goal_dir.y = 0
				pos.y = last_height
			end
		else
			goal_dir.y = goal_dir.y + vertical_adjust
		end

		local yaw = _self.object:get_yaw()
		local goal_yaw = minetest.dir_to_yaw(goal_dir)
		local speed = math.abs(_self.speed or 2) * (speed_factor or 0.5)
		local turn_rate = math.abs(_self.turn_rate or 5)

		local yaw_diff = math.abs(diff(yaw, goal_yaw))
		if yaw_diff < math.pi * 0.25 or steer_to or retreat_phase then
			_self:set_forward_velocity(speed)
		else
			_self:set_forward_velocity(speed * 0.33)
		end

		if not _self.wtd_walking_mode then
			_self:set_vertical_velocity(speed * goal_dir.y)
		end
		_self:turn_to(goal_yaw, turn_rate)

		last_height = pos.y
	end
	return func
end)

local function handle_transport(dragon, player, message)
	if dragon.owner and dragon.owner ~= player:get_player_name() then
		return false, "I take orders only from my chosen rider."
	end
	if not dragon.owner then return end
	-- Check cooldown
	if not check_cooldown(player:get_player_name(), "transport") then
		return false, "I need rest before such a journey."
	end
	if dragon.age < 30 then
		return false, "I am too young to carry you."
	end
	-- Take coordinates from the message
	local x, y, z
	local coords = message:match("take me to[%s]+([%-%.%d%s]+)")
	if coords then
		x, y, z = coords:match("([%-%.%d]+)[%s]+([%-%.%d]+)[%s]+([%-%.%d]+)")
	end

	-- Check the coordinates
	if not (x and y and z) then
		return false, "Tell me where to fly using: take me to X Y Z"
	end

	x, y, z = tonumber(x), tonumber(y), tonumber(z)
	if not (x and y and z) then
		return false, "Those don't look like valid coordinates."
	end

	local destination = { x = x, y = y, z = z }
	local start_pos = dragon.object:get_pos()
	if not start_pos then
		return false, "Cannot start flight."
	end
	if not dragon.object:get_pos() then
		return false, "I cannot determine my position."
	end
	-- Check the distance
	local distance = vector.distance(start_pos, destination)
	if distance > 100000 then
		return false, "That's too far for me to fly."
	end

	-- If the player is not on the dragon, attach it
	if not dragon.rider then
		local scale = dragon.growth_scale or 1
		player:set_attach(dragon.object, "Torso.2", { x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
		player:set_eye_offset({
			x = 0,
			y = 115 * scale,
			z = -280 * scale
		}, { x = 0, y = 0, z = 0 })
		dragon.transport_rider = true
	end

	-- Start the flight
	if dragon.touching_ground then
		waterdragon.action_takeoff(dragon, 5)
		minetest.after(1, function()
			if dragon and dragon.object and dragon.object:get_pos() then
				waterdragon.action_fly(dragon, destination, distance / 10, "waterdragon:fly_obstacle_avoidance", 0.5,
					"fly")
				minetest.chat_send_player(player:get_player_name(),
					(dragon.nametag or "Dragon") .. ": I feel rested now. Let's take to the skies!")
			elseif dragon and dragon.object and dragon.object:get_pos() and dragon.wtd_walking_mode then
				waterdragon.action_move(dragon, destination, distance / 10, "waterdragon:obstacle_avoidance", 1, "walk")
			end
		end)
	else
		if not dragon.wtd_walking_mode then
			waterdragon.action_fly(dragon, destination, distance / 10, "waterdragon:fly_obstacle_avoidance", 0.5, "fly")
		elseif dragon.wtd_walking_mode then
			waterdragon.action_move(dragon, destination, distance / 10, "waterdragon:obstacle_avoidance", 1, "walk")
		end
	end
	-- Add after flight starts and before arrival handler
	minetest.after(0.1, function()
		local function check_sneak()
			if not dragon or not dragon.object or not dragon.object:get_pos() then return end

			if player:get_player_control().sneak and dragon.transport_rider then
				player:set_detach()
				player:set_eye_offset({ x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
				waterdragon.action_land(dragon)
				if dragon.rider then
					waterdragon.detach_player(dragon, player)
				end
				dragon.transport_rider = false
				minetest.chat_send_player(player:get_player_name(),
					(dragon.nametag or "Dragon") .. ": Journey interrupted")
				return
			end

			if dragon.transport_rider then
				minetest.after(0.1, check_sneak)
			end
		end

		check_sneak()
	end)
	-- Upon arrival
	minetest.after(distance / 10 + 2, function()
		if dragon and dragon.object and dragon.object:get_pos() then
			if player:get_player_name() then
				player:set_detach()
				player:set_eye_offset({ x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
			end
			waterdragon.action_land(dragon)
			if dragon.rider then
				waterdragon.detach_player(dragon, player)
			end
			dragon.transport_rider = false
			minetest.chat_send_player(player:get_player_name(), (dragon.nametag or "Dragon") .. ": We have arrived")
		end
	end)
	if player:get_player_control().sneak and dragon.transport_rider then
		if player:get_player_name() then
			player:set_detach()
			player:set_eye_offset({ x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
		end
		waterdragon.action_land(dragon)
		waterdragon.detach_player(dragon, player)
		dragon.transport_rider = false
	end
	-- Check stamina every second
	local function check_stamina()
		if not dragon or not dragon.object or not dragon.object:get_pos() then
			return
		end

		if dragon.flight_stamina <= 100 then
			minetest.chat_send_player(player:get_player_name(),
				(dragon.nametag or "Dragon") .. ": I need to rest my wings. I will walk for a while.")
			dragon.wtd_walking_mode = true

			minetest.after(10, function()
				if dragon and dragon.object and dragon.object:get_pos() then
					if dragon.flight_stamina <= 100 then
						waterdragon.action_move(dragon, destination, distance / 10, "waterdragon:obstacle_avoidance", 1,
							"walk")
						dragon:set_gravity(-9.8)
					end
					if dragon.flight_stamina >= 300 then
						waterdragon.action_takeoff(dragon, 5)
						dragon.wtd_walking_mode = false
						waterdragon.action_fly(dragon, destination, distance / 10, "waterdragon:fly_obstacle_avoidance",
							0.5,
							"fly")
					end
				end
			end)
		end

		minetest.after(1, check_stamina)
	end

	check_stamina()
	return true
end

local swimming_magic_players = {}

-- Process chat messages
local function process_dragon_chat(name, message)
	local dragon = active_chats[name]
	if not dragon then return false end
	local player = minetest.get_player_by_name(name)
	if not player then return false end

	message = message:lower()

	-- Handle exit command
	if message == "bye" or message == "goodbye" or message == "farewell" then
		minetest.chat_send_player(name,
			(dragon.nametag or "Dragon") .. ": " .. dragon_dialogue.farewell[math.random(#dragon_dialogue.farewell)])
		active_chats[name] = nil
		return true
	end
	if message:find("stamina") then
		local response = dragon_dialogue.conversations["how much stamina do you have"][math.random(3)]
		response = response .. " " .. (dragon.flight_stamina or 0) .. "/300"
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)
		return true
	end
	if message:find("hungry") then
		local response = dragon_dialogue.conversations["how hungry are you"][math.random(3)]
		response = response .. " " .. (dragon.hunger or 0) .. "/" .. (dragon.max_hunger)
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)

		return true
	end

	if message:find("health") then
		local scale = dragon.growth_scale or 1
		local max_health = dragon.max_health * scale
		local response = dragon_dialogue.conversations["how much health do you have"][math.random(3)]
		response = response .. " " .. (dragon.hp or 0) .. "/" .. max_health
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)

		return true
	end
	if message:find("breath") then
		local response = dragon_dialogue.conversations["how much breath do you have"][math.random(3)]
		response = response .. " " .. (dragon.attack_stamina or 0) .. "/" .. dragon.attack_stamina
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)
		return true
	end
	if message:find("who are you") then
		local response = dragon_dialogue.conversations["who are you"][math.random(3)]
		local type
		if dragon.name == "waterdragon:rare_water_dragon" then
			type = "Rare Water Dragon."
		elseif dragon.name == "waterdragon:pure_water_dragon" then
			type = "Pure Water Dragon."
		elseif dragon.name == "waterdragon:scottish_dragon" then
			type = "Scottish Dragon."
		end
		response = response .. (type or "Water Dragon.")
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)

		return true
	end
	if message:find("what is your name") then
		local response = dragon_dialogue.conversations["what is your name"][math.random(3)]
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response .. (dragon.nametag or "Dragon"))
		if dragon.nametag == "" then
			minetest.chat_send_player(name,
				(dragon.nametag or "Dragon") .. ": My name is a secret, but you can call me 'Water Dragon'.")
		end
		return true
	end
	-- Handle transport command
	if message:find("take me to") then
		local success, error_msg = handle_transport(dragon, player, message)
		if success then
			minetest.chat_send_player(name,
				(dragon.nametag or "Dragon") .. ": *The Dragon's eyes glow as it studies the destination*")
		else
			-- Check error_msg before use
			minetest.chat_send_player(name,
				(dragon.nametag or "Dragon") .. ": " .. (error_msg or "I cannot make this journey right now."))
		end
		return true
	end
	-- Handle special commands with parameters --
	local swimming_physics = {}

	-- Handle "yes" response after magic question
	if message == "yes" and dragon.last_conversation == "can you teach me magic" then
		minetest.chat_send_player(name,
			(dragon.nametag or "Dragon") ..
			": I bestow upon you the gift of swift swimming. You shall move through water as if born to it.")

		-- Save original player physics
		if not swimming_physics[name] then
			local physics = player:get_physics_override()
			swimming_physics[name] = {
				speed = physics.speed,
				jump = physics.jump
			}
		end

		-- Add player to list of those with swimming magic
		swimming_magic_players[name] = true
		return true
	end
	if message:match("^bring%s+me%s+to%s+%S") then
		-- Extract the Dragon name with proper capitalization, allowing for spaces in the name
		local dragon_name = message:match("^bring%s+me%s+to%s+(.+)$")

		if not dragon_name then
			minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": Tell me which Dragon you wish to visit")
			return true
		end

		if dragon.owner and dragon.owner ~= player:get_player_name() then
			minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": I only respond to my chosen rider.")
			return true
		end

		if dragon_name:lower() == (dragon.nametag or ""):lower() then
			minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": I am already here.")
			return true
		end

		local target_dragon = nil

		for _, obj in pairs(minetest.luaentities) do
			if obj.name and (obj.name:match("^waterdragon:") or obj.name:match("^winddragon:")) and
				obj.nametag and obj.nametag:lower() == dragon_name:lower() then
				target_dragon = obj
				dragon_name = obj.nametag -- Get the exact capitalization from the actual Dragon
				break
			end
		end

		if target_dragon then
			-- Mount the player before flying
			if not dragon.rider and not dragon.transport_rider then
				-- Set up the player as a rider for transport
				local scale = dragon.growth_scale or 1
				player:set_attach(dragon.object, "Torso.2", { x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
				player:set_eye_offset({
					x = 0,
					y = 115 * scale,
					z = -280 * scale
				}, { x = 0, y = 0, z = 0 })

				-- Set the transport rider flag
				dragon.transport_rider = true

				-- Start takeoff if on ground
				if dragon.touching_ground then
					waterdragon.action_takeoff(dragon, 5)
					minetest.after(1, function()
						if dragon and dragon.object and dragon.object:get_pos() then
							waterdragon.action_fly(dragon, target_dragon.object:get_pos(), 3, "waterdragon:fly_simple", 1,
								"fly")
						end
					end)
				else
					waterdragon.action_fly(dragon, target_dragon.object:get_pos(), 3, "waterdragon:fly_simple", 1, "fly")
				end
			else
				waterdragon.action_fly(dragon, target_dragon.object:get_pos(), 3, "waterdragon:fly_simple", 1, "fly")
			end
			minetest.after(0.1, function()
				local function check_sneak()
					if not dragon or not dragon.object or not dragon.object:get_pos() then return end

					if player:get_player_control().sneak and dragon.transport_rider then
						player:set_detach()
						player:set_eye_offset({ x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
						waterdragon.action_land(dragon)
						if dragon.rider then
							waterdragon.detach_player(dragon, player)
						end
						dragon.transport_rider = false
						minetest.chat_send_player(player:get_player_name(),
							(dragon.nametag or "Dragon") .. ": Journey stopped")
						return
					end

					if dragon.transport_rider then
						minetest.after(0.1, check_sneak)
					end
				end
				check_sneak()
			end)
			minetest.chat_send_player(name,
				(dragon.nametag or "Dragon") .. ": *The Dragon spreads its wings and flies toward " .. dragon_name .. "*")
		else
			-- Capitalize first letter for the response
			dragon_name = dragon_name:sub(1, 1):upper() .. dragon_name:sub(2)
			minetest.chat_send_player(name,
				(dragon.nametag or "Dragon") .. ": I don't know a Dragon named " .. dragon_name)
		end
		return true
	end
	-- Handle standard commands
	for cmd_name, cmd in pairs(dragon_dialogue.commands) do
		if message == cmd_name then
			local success, error_msg = cmd.action(dragon, player)
			if success then
				minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. cmd.response)
			else
				minetest.chat_send_player(name,
					(dragon.nametag or "Dragon") .. ": " .. (error_msg or "I cannot do that now."))
			end
			return true
		end
	end

	-- Handle conversations
	for topic, responses in pairs(dragon_dialogue.conversations) do
		if message:find(topic) then
			if topic == "can you teach me magic" then
				-- Check if player already has swimming magic
				if swimming_magic_players[name] then
					minetest.chat_send_player(name,
						(dragon.nametag or "Dragon") ..
						": You already possess the gift of swift swimming, chosen one. My magic flows within you.")
					return true
				end
			end

			dragon.last_conversation = topic
			minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. responses[math.random(#responses)])
			return true
		end
	end

	-- Handle unknown input
	minetest.chat_send_player(name,
		(dragon.nametag or "Dragon") .. ": " .. dragon_dialogue.unknown[math.random(#dragon_dialogue.unknown)])
	return true
end


-- Globalstep for magic of swimming --

minetest.register_globalstep(function(dtime)
	for name, has_magic in pairs(swimming_magic_players) do
		if not has_magic then return end

		local player = minetest.get_player_by_name(name)
		if not player then
			swimming_magic_players[name] = nil
			return
		end

		-- Check if player is in water
		local pos = player:get_pos()
		local node = minetest.get_node({ x = pos.x, y = pos.y, z = pos.z })

		if minetest.get_item_group(node.name, "water") > 0 then
			-- In water - increase speed 5x
			player:set_physics_override({
				speed = (swimming_physics[name] and swimming_physics[name].speed or 1) * 5,
				jump = (swimming_physics[name] and swimming_physics[name].jump or 1) * 1.5
			})

			-- Add bubble effect under feet
			minetest.add_particlespawner({
				amount = 5,
				time = 0.5,
				minpos = { x = pos.x - 0.3, y = pos.y - 0.5, z = pos.z - 0.3 },
				maxpos = { x = pos.x + 0.3, y = pos.y, z = pos.z + 0.3 },
				minvel = { x = -0.5, y = 0.5, z = -0.5 },
				maxvel = { x = 0.5, y = 1, z = 0.5 },
				minacc = { x = 0, y = 0, z = 0 },
				maxacc = { x = 0, y = 0, z = 0 },
				minexptime = 0.5,
				maxexptime = 1,
				minsize = 0.5,
				maxsize = 1,
				collisiondetection = false,
				texture = "default_water_flowing_animated.png^[verticalframe:16:1"
			})
		else
			-- Not in water - restore normal speed
			local default = swimming_physics[name] or { speed = 1, jump = 1 }
			player:set_physics_override({
				speed = default.speed,
				jump = default.jump
			})
		end
	end
end)

-- Save and load magic data when server restarts
local storage = minetest.get_mod_storage()

minetest.register_on_shutdown(function()
	storage:set_string("swimming_magic_players", minetest.serialize(swimming_magic_players))
	storage:set_string("swimming_physics", minetest.serialize(swimming_physics))
end)

minetest.register_on_mods_loaded(function()
	local saved_players = storage:get_string("swimming_magic_players")
	local saved_physics = storage:get_string("swimming_physics")

	if saved_players and saved_players ~= "" then
		swimming_magic_players = minetest.deserialize(saved_players) or {}
	end

	if saved_physics and saved_physics ~= "" then
		swimming_physics = minetest.deserialize(saved_physics) or {}
	end
end)

-- Register chat command
minetest.register_chatcommand("talk_wtd", {
	description = S("Start a conversation with a nearby Dragon"),
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		if active_chats[name] then
			return false, "You are already in a conversation with a Dragon. Say 'bye' to end it."
		end

		-- Find nearest Dragon
		local pos = player:get_pos()
		local nearest_dragon = nil
		local min_dist = 60 -- Maximum distance to start conversation

		for _, obj in ipairs(minetest.get_objects_inside_radius(pos, min_dist)) do
			local ent = obj:get_luaentity()
			if ent and (ent.name == "waterdragon:pure_water_dragon" or
					ent.name == "waterdragon:rare_water_dragon" or
					ent.name == "waterdragon:scottish_dragon") then
				nearest_dragon = ent
				break
			end
		end

		if not nearest_dragon then
			return false, "No Dragons nearby to talk to."
		end

		active_chats[name] = nearest_dragon
		minetest.chat_send_player(name, "Dragon: " .. dragon_dialogue.greetings[math.random(#dragon_dialogue.greetings)])
		return true
	end
})

-- Register chat handler
minetest.register_on_chat_message(function(name, message)
	if active_chats[name] then
		return process_dragon_chat(name, message)
	end
	return false
end)

-- Clean up on player leave
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	active_chats[name] = nil
	player_cooldowns[name] = nil
end)
