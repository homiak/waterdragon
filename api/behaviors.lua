---------------
-- Behaviors --
---------------

local S = waterdragon.S

-- Defend owner

local function has_tamed_dragons(player_name)
    for _, obj in pairs(minetest.luaentities) do
        -- Check if object exists before getting entity
        if obj and obj.get_luaentity then
            local ent = obj:get_luaentity()
            if ent and (ent.name == "waterdragon:scottish_dragon" or 
                       ent.name == "waterdragon:pure_water_dragon" or
                       ent.name == "waterdragon:rare_water_dragon") and
               ent.owner == player_name then
                return true
            end
        end
    end
    return false
end

-- Add this function to behaviors.lua
local function defend_owner(attacker, target)
    if not target:is_player() then return false end
    
    local target_name = target:get_player_name()
    if not has_tamed_dragons(target_name) then return false end
    
    -- Get all tamed Dragons of the target player
    for _, obj in pairs(minetest.luaentities) do
        local ent = obj:get_luaentity()
        if ent and (ent.name == "waterdragon:scottish_dragon" or 
                   ent.name == "waterdragon:pure_water_dragon" or
                   ent.name == "waterdragon:rare_water_dragon") and
           ent.owner == target_name then
            -- Perform repel action
            waterdragon.action_repel(ent)
        end
    end
    
    -- Make attacker choose new target
    if attacker and attacker:get_luaentity() then
        attacker:get_luaentity()._target = nil
    end
    
    return true
end

-- Slam

local function new_water_dragon_on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	if self.original_on_punch then
		self.original_on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	end

	if self.object:get_hp() > 0 and not self.rider and not self._target and not self.is_flying then
		-- Initialize slam_count if it doesn't exist
		self.slam_count = self.slam_count or 0

		if self.slam_count < 3 then
			if self.is_landed then
				minetest.after(0.5, function()
					if self.object:get_pos() and not self.rider and self.is_landed then
						waterdragon.action_slam(self)
						self.slam_count = self.slam_count + 1
					end
				end)
			else
				self.pending_slam = true
			end
		end
	end
end

function reset_slam_count(self)
	minetest.after(10, function()
		if self.object:get_pos() then
			self.slam_count = 0
		end
	end)
end

minetest.register_on_mods_loaded(function()
	local dragon_types = { "waterdragon:pure_water_dragon", "waterdragon:rare_water_dragon" }
	for _, dragon_type in ipairs(dragon_types) do
		local entity_def = minetest.registered_entities[dragon_type]
		if entity_def then
			entity_def.original_on_punch = entity_def.on_punch
			entity_def.on_punch = new_water_dragon_on_punch

			local original_on_step = entity_def.on_step
			on_step = function(self, dtime)
				if original_on_step then
					original_on_step(self, dtime)
				end

				if self.pending_slam and self.is_landed and not self.rider then
					self.pending_slam = false
					if self.slam_count < 3 then
						waterdragon.action_slam(self)
						self.slam_count = self.slam_count + 1
					end
				end
			end

			local original_on_activate = entity_def.on_activate or function() end
			entity_def.on_activate = function(self, staticdata, dtime_s)
				original_on_activate(self, staticdata, dtime_s)
				self.slam_count = 0
			end

			minetest.register_entity(":" .. dragon_type, entity_def)
		end
	end
end)

local function new_scottish_dragon_on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	waterdragon.basic_punch_func(self, puncher, time_from_last_punch, tool_capabilities, dir)

	if self.hp > 0 and not self.rider and not self._target and not self.is_flying then
		-- Initialize punch_count if it doesn't exist
		self.punch_count = self.punch_count or 0

		if self.punch_count < 3 then
			if math.random() < 1 then
				minetest.after(1, function()
					if self.object:get_pos() then
						waterdragon.action_punch(self)
						self.punch_count = self.punch_count + 1

						-- Reset punch count after 30 seconds
						minetest.after(10, function()
							if self.object:get_pos() then
								self.punch_count = 0
							end
						end)
					end
				end)
			end
		end
	end
end

minetest.register_on_mods_loaded(function()
	local dragon_type = "waterdragon:scottish_dragon"
	local entity_def = minetest.registered_entities[dragon_type]
	if entity_def then
		entity_def.on_punch = new_scottish_dragon_on_punch

		local original_on_activate = entity_def.on_activate or function() end
		entity_def.on_activate = function(self, staticdata, dtime_s)
			original_on_activate(self, staticdata, dtime_s)
			self.punch_count = 0
		end

		minetest.register_entity(":" .. dragon_type, entity_def)
	end
end)

waterdragon.pure_water_dragon_targets = {}

waterdragon.rare_water_dragon_targets = {}

waterdragon.scottish_dragon_targets = {}

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_entities) do
		local is_mobkit = (def.logic ~= nil or def.brainfuc ~= nil)
		local is_waterdragon = def._waterdragon_mob
		if is_mobkit
			or is_waterdragon
			or def._cmi_is_mob then
			if name ~= "waterdragon:pure_water_dragon" then
				table.insert(waterdragon.pure_water_dragon_targets, name)
			end
			if name ~= "waterdragon:rare_water_dragon" then
				table.insert(waterdragon.rare_water_dragon_targets, name)
			end
			local hp = def.max_health or def.max_hp or 21
			if hp < 21 then
				table.insert(waterdragon.scottish_dragon_targets, name)
			end
		end
	end
end)

-- Local Math --

local abs = math.abs
local atan2 = math.atan2
local ceil = math.ceil
local cos = math.cos
local rad = math.rad
local random = math.random
local sin = math.sin

local function clamp(val, _min, _max)
	if val < _min then
		val = _min
	elseif _max < val then
		val = _max
	end
	return val
end

local function diff(a, b) -- Get difference between 2 angles
	return atan2(sin(b - a), cos(b - a))
end

local function vec_raise(v, n)
	return { x = v.x, y = v.y + n, z = v.z }
end

local vec_normal = vector.normalize
local vec_dir = vector.direction
local vec_dist = vector.distance
local vec_multi = vector.multiply
local vec_sub = vector.subtract
local vec_add = vector.add
local yaw2dir = minetest.yaw_to_dir
local dir2yaw = minetest.dir_to_yaw

---------------------
-- Local Utilities --
---------------------

local is_night = false

local function check_time()
	local time = (minetest.get_timeofday() or 0) * 24000
	is_night = time > 19500 or time < 4500
	minetest.after(10, check_time)
end

check_time()

local moveable = waterdragon.is_pos_moveable
function is_target_flying(target)
	if not target or not target:get_pos() then return end
	local pos = target:get_pos()
	if not pos then return end
	local node = minetest.get_node(pos)
	if not node then return false end
	if minetest.get_item_group(node.name, "igniter") > 0
		or waterdragon.get_node_def(node.name).drawtype == "liquid"
		or waterdragon.get_node_def(vec_raise(pos, -1)).drawtype == "liquid" then
		return false
	end
	local flying = true
	for i = 1, 8 do
		local fly_pos = {
			x = pos.x,
			y = pos.y - i,
			z = pos.z
		}
		if waterdragon.get_node_def(fly_pos).walkable then
			flying = false
			break
		end
	end
	return flying
end

local function shared_owner(obj1, obj2)
	if not obj1 or not obj2 then return false end
	obj1 = waterdragon.is_valid(obj1)
	obj2 = waterdragon.is_valid(obj2)
	if obj1
		and obj2
		and obj1:get_luaentity()
		and obj2:get_luaentity() then
		obj1 = obj1:get_luaentity()
		obj2 = obj2:get_luaentity()
		return obj1.owner and obj2.owner and obj1.owner == obj2.owner
	end
	return false
end

local function find_target(self, list)
	local owner = self.owner and minetest.get_player_by_name(self.owner)
	local targets = waterdragon.get_nearby_players(self)
	if #targets > 0 then -- If there are players nearby
		local target = targets[random(#targets)]
		local is_creative = target:is_player() and minetest.is_creative_enabled(target)
		local is_owner = owner and target == owner
		if is_creative or is_owner then targets = {} end
	end
	targets = (#targets < 1 and list and waterdragon.get_nearby_objects(self, list)) or targets
	if #targets < 1 then return end
	return targets[random(#targets)]
end

-- Movement Methods --

waterdragon.register_movement_method("waterdragon:fly_pathfind", function(self)
	if not self.fly_allowed then
		return
	end
	local path = {}
	local steer_to
	local steer_timer = 0.01
	local width = self.width
	local wayp_threshold = width + (width / self.turn_rate)

	self:set_gravity(0)
	local function func(_self, goal, speed_x)
		local pos = _self.object:get_pos()
		if not pos then return end
		steer_timer = (steer_timer > 0 and steer_timer - _self.dtime) or 0.25
		if #path > 0 then steer_timer = 1 end
		steer_to = (steer_timer <= 0 and waterdragon.get_context_steering(self, goal, 8)) or steer_to
		-- Return true when goal is reached
		if vec_dist(pos, goal) < wayp_threshold then
			_self:halt()
			return true
		end
		-- Get movement direction
		local goal_dir = steer_to or vec_dir(pos, goal)
		if steer_to then
			if #path < 2 then
				path = waterdragon.find_path(_self, pos, goal, _self.width, _self.height, 200, false, true) or {}
			end
		end
		if #path > 1 then
			goal_dir = vec_dir(pos, path[2])
			if vec_dist(pos, path[1]) < _self.width then
				table.remove(path, 1)
			end
		end
		local goal_yaw = dir2yaw(goal_dir)
		local speed = (_self.speed or 24) * speed_x
		_self:tilt_to(goal_yaw, _self.turn_rate or 7)
		-- Set Velocity
		_self:set_forward_velocity(speed)
		_self:set_vertical_velocity(speed * goal_dir.y)
	end
	return func
end)

waterdragon.register_movement_method("waterdragon:fly_simple", function(self)
	local steer_to
	local steer_timer = 0.25
	local width = self.width
	local wayp_threshold = width + ((width / self.turn_rate or 7))

	self:set_gravity(0)
	local function func(_self, goal, speed_factor)
		local pos = _self.object:get_pos()
		if not pos then return end
		local dist = vec_dist(pos, goal)
		if dist < wayp_threshold then
			_self:halt()
			return true
		end
		-- Calculate Movement
		steer_timer = (steer_timer > 0 and steer_timer - self.dtime) or 0.25
		steer_to = (steer_timer <= 0 and waterdragon.get_context_steering(self, goal, 4)) or steer_to
		local speed = abs(_self.speed or 2) * speed_factor or 0.5
		local turn_rate = abs(_self.turn_rate or 7)
		-- Apply Movement
		local dir = (steer_to or vec_dir(pos, goal))
		_self:set_forward_velocity(speed)
		_self:set_vertical_velocity(speed * dir.y)
		_self:tilt_to(dir2yaw(dir), turn_rate)
	end
	return func
end)


-- Action tame by Scottii

local TAMER_NAME = "Scottii"
local taming_ability_enabled = false

local function waterdragon_action_tame_by_scottii(player, wtd)
	if not wtd.owner then
		wtd.owner = player:get_player_name()
	end
end

minetest.register_globalstep(function(dtime)
	if not taming_ability_enabled then
		return
	end

	local player = minetest.get_player_by_name(TAMER_NAME)
	if player then
		local player_pos = player:get_pos()
		local objs = minetest.get_objects_inside_radius(player_pos, 10)

		for _, obj in ipairs(objs) do
			local entity = obj:get_luaentity()
			if entity and entity.name and string.match(entity.name, "^waterdragon:") then
				waterdragon_action_tame_by_scottii(player, entity)
			end
		end
	end
end)

local function toggle_taming_ability(name)
	taming_ability_enabled = not taming_ability_enabled
	local status = taming_ability_enabled and " already " or " airedy "
	minetest.chat_send_player(name, "You" .. status .. "can interact with the Water Dragons")
end

for color, hex in pairs(waterdragon.colors_pure_water) do
	minetest.register_craftitem("waterdragon:scales_pure_water_dragon", {
		description = S("Pure Water Dragon Scales"),
		inventory_image = "waterdragon_wtd_scales.png^[multiply:#" .. hex,
		on_use = function(itemstack, user)
			local name = user:get_player_name()
			toggle_taming_ability(name)
			return itemstack
		end,
		groups = { wtd_scales = 1 }
	})
end

function waterdragon.is_taming_ability_enabled()
	return taming_ability_enabled
end

function waterdragon.action_flight_pure_water(self, target, timeout)
	if not self.fly_allowed then
		-- Use a walking attack instead
		return
	end

	local timer = timeout or 12
	local goal
	local function func(_self)
		local pos = _self.stand_pos
		if timer <= 0 then return true end
		local target_alive, los, tgt_pos = _self:get_target(target)
		if not target_alive then return true end
		self.head_tracking = target
		if not goal or _self:timer(4) then
			goal = _self:get_wander_pos_3d(6, 8, vec_dir(pos, tgt_pos))
		end
		if _self:move_to(goal, "waterdragon:fly_simple", 0.5) then
			goal = nil
		end
		if los then
			_self:breath_attack(tgt_pos)
			_self:animate("fly_water")
		else
			_self:animate("fly")
		end
		timer = timer - _self.dtime
	end
	self:set_action(func)
end

function waterdragon.action_flight_attack(self, target, timeout)
	local anim = self.animations["fly_punch"]
	local anim_len = (anim.range.y - anim.range.x) / anim.speed
	local anim_time = 0
	local timer = timeout or 12
	local cooldown = 0
	local goal
	local function func(_self)
		local pos = _self.stand_pos
		if timer <= 0 then return true end
		local target_alive, _, tgt_pos = _self:get_target(target)
		if not target_alive then return true end
		local dist = vec_dist(pos, tgt_pos)

		if dist > 32 then return true end

		if anim_time > 0 then
			_self:animate("fly_punch")
			anim_time = anim_time - _self.dtime
		else
			_self:animate("fly")
		end

		if cooldown > 0 then
			goal = goal or _self:get_wander_pos_3d(3, 6, nil, 1)
			cooldown = cooldown - _self.dtime
		else
			goal = nil
			cooldown = 0
		end

		if goal
			and _self:move_to(goal, "waterdragon:fly_simple", 0.25) then
			goal = nil
		end

		if not goal
			and _self:move_to(tgt_pos, "waterdragon:fly_simple", 0.5) then
			if dist < _self.width + 4 then
				_self:punch_target(target)
				cooldown = timeout / 3
				anim_time = anim_len
			end
		end

		timer = timer - _self.dtime
	end
	self:set_action(func)
end

function waterdragon.action_pursue(self, target, timeout, method, speed_factor, anim)
	local timer = timeout or 4
	local goal
	local function func(_self)
		local target_alive, line_of_sight, tgt_pos = _self:get_target(target)
		if not target_alive then
			return true
		end
		self.head_tracking = target
		local pos = _self.object:get_pos()
		if not pos then return end
		timer = timer - _self.dtime
		if timer <= 0 then return true end
		if not goal
			or (line_of_sight
				and vec_dist(goal, tgt_pos) > 3) then
			goal = tgt_pos
		end
		if timer <= 0
			or _self:move_to(goal, method or "waterdragon:obstacle_avoidance", speed_factor or 0.5) then
			_self:halt()
			return true
		end
		_self:animate(anim or "walk")
	end
	self:set_action(func)
end

function waterdragon.action_fly(self, pos2, timeout, method, speed_factor, anim)
	local timer = timeout or 4
	local function func2(_self)
		timer = timer - _self.dtime
		if timer <= 0
			or _self:move_to(pos2, method or "waterdragon:fly_simple", speed_factor) then
			return true
		end
		_self:animate(anim or "fly")
	end
	self:set_action(func2)
end

function waterdragon.action_hover(self, time)
	local timer = time or 3
	local function func(_self)
		_self:set_gravity(0)
		_self:set_forward_velocity(0)
		_self:set_vertical_velocity(0)
		play_wing_sound(_self)
		_self:animate("hover")
		timer = timer - _self.dtime
		if timer <= 0 then
			return true
		end
	end
	self:set_action(func)
end

function waterdragon.action_idle_pure_water(self, target, time)
	local timer = time
	local start_angle = rad(45)
	local end_angle = rad(-45)
	if random(2) < 2 then
		start_angle = rad(-45)
		end_angle = rad(45)
	end
	local function func(_self)
		_self.head_tracking = nil
		local pos = _self.object:get_pos()
		if not pos then return true end
		local tgt_pos = target:get_pos()
		if not tgt_pos then return true end
		local dir = vec_dir(pos, tgt_pos)
		local dist = vec_dist(pos, tgt_pos)
		local yaw = _self.object:get_yaw()
		local yaw_to_tgt = minetest.dir_to_yaw(dir) + start_angle
		start_angle = start_angle + (end_angle - start_angle) * _self.dtime
		if abs(diff(yaw, yaw_to_tgt)) > 0.5 then
			_self:turn_to(minetest.dir_to_yaw(dir), 4)
		end
		local aim_dir = yaw2dir(yaw_to_tgt)
		aim_dir.y = dir.y
		tgt_pos = vec_add(pos, vec_multi(aim_dir, dist + 10))
		_self:move_head(yaw_to_tgt, aim_dir.y)
		_self:set_gravity(-9.8)
		_self:halt()
		_self:animate("stand_water")
		_self:breath_attack(tgt_pos)
		timer = timer - _self.dtime
		if timer <= 0
			or math.abs(end_angle - start_angle) < 0.1 then
			return true
		end
	end
	self:set_action(func)
end

function waterdragon.action_hover_water(self, target, time)
	local timer = time
	local start_angle = rad(45)
	local end_angle = rad(-45)
	if random(2) < 2 then
		start_angle = rad(-45)
		end_angle = rad(45)
	end
	local function func(_self)
		_self.head_tracking = nil
		local pos = _self.object:get_pos()
		if not pos then return end
		local tgt_pos = target:get_pos()
		if not tgt_pos then return true end
		local dir = vec_dir(pos, tgt_pos)
		local dist = vec_dist(pos, tgt_pos)
		local yaw = _self.object:get_yaw()
		local yaw_to_tgt = minetest.dir_to_yaw(dir) + start_angle
		start_angle = start_angle + (end_angle - start_angle) * _self.dtime
		if abs(diff(yaw, yaw_to_tgt)) > 0.5 then
			_self:turn_to(minetest.dir_to_yaw(dir), 4)
		end
		local aim_dir = yaw2dir(yaw_to_tgt)
		aim_dir.y = dir.y
		tgt_pos = vec_add(pos, vec_multi(aim_dir, dist + 10))
		_self:move_head(yaw_to_tgt, aim_dir.y)
		_self:set_gravity(0)
		_self:set_forward_velocity(-2)
		_self:set_vertical_velocity(0.5)
		_self:animate("hover_water")
		_self:breath_attack(tgt_pos)
		timer = timer - _self.dtime
		if timer <= 0
			or math.abs(end_angle - start_angle) < 0.1 then
			return true
		end
	end
	self:set_action(func)
end

function can_takeoff(self, pos)
	local height = self.height
	local pos2 = {
		x = pos.x,
		y = pos.y + height + 0.5,
		z = pos.z
	}
	if not moveable(pos2, self.width, height) then
		return false
	end
	return true
end

function waterdragon.action_takeoff(self, tgt_height)
	local init = false
	local height
	local anim = self.animations["takeoff"]
	local anim_time = (anim.range.y - anim.range.x) / anim.speed
	local timer = anim_time
	tgt_height = tgt_height or 4
	local function func(_self)
		local pos = _self.object:get_pos()
		if not pos then return end
		timer = timer - _self.dtime
		if timer <= 0 then
			_self:animate("hover")
			_self:set_vertical_velocity(0)
			return true
		end
		if not init then
			height = pos.y
			init = true
			_self:animate("takeoff")
		end
		local height_diff = pos.y - height
		if height_diff < tgt_height
			and timer < anim_time * 0.5 then
			_self:set_forward_velocity(0)
			_self:set_vertical_velocity(anim_time * tgt_height)
			_self:set_gravity(0)
		end
	end
	self:set_action(func)
end

function waterdragon.action_land(self)
	local init = false
	local anim = self.animations["land"]
	local anim_time = (anim.range.y - anim.range.x) / anim.speed
	local timer = anim_time * 0.5
	local function func(_self)
		if not init then
			-- Apply gravity
			_self:set_gravity(-9.8)
			-- Begin Animation
			_self.object:set_yaw(_self.object:get_yaw())
			_self:animate("land")
			init = true
		end
		timer = timer - _self.dtime
		if timer <= 0 then
			return true
		end
	end
	self:set_action(func)
end

-- Close-range Attacks

function waterdragon.action_slam(self)
	local anim = self.animations["slam"]
	local anim_time = (anim.range.y - anim.range.x) / anim.speed
	local timeout = anim_time
	local damage_init = false
	local scale = self.growth_scale
	self:set_gravity(-9.8)
	self:halt()
	local function func(_self)
		local yaw = _self.object:get_yaw()
		local pos = _self.object:get_pos()
		if not pos then return end
		_self:animate("slam")
		timeout = timeout - _self.dtime
		if timeout < anim_time * 0.5
			and not damage_init then
			_self.alert_timer = 15
			local terrain_dir
			local aoe_center = vec_add(pos, vec_multi(yaw2dir(yaw), _self.width))
			local affected_objs = minetest.get_objects_inside_radius(aoe_center, 8 * scale)
			for _, object in ipairs(affected_objs) do
				local tgt_pos = object and object ~= self.object and object:get_pos()
				if tgt_pos then
					local ent = object:get_luaentity()
					local is_player = object:is_player()
					if (waterdragon.is_alive(ent)
							and not ent._ignore)
						or is_player then
						local dir = vec_dir(pos, tgt_pos)
						terrain_dir = terrain_dir or dir
						local vel = {
							x = dir.x * _self.damage,
							y = dir.y * _self.damage * 0.5,
							z = dir.z * _self.damage
						}
						object:add_velocity(vel)
						_self:punch_target(object, _self.damage)
					end
				end
			end
			if terrain_dir then
				self:destroy_terrain(terrain_dir)
			end
			minetest.sound_play("waterdragon_slam", {
				object = _self.object,
				gain = 1.0,
				max_hear_distance = 64,
				loop = false,
			})
			damage_init = true
		end
		if timeout <= 0 then
			self:animate("stand")
			return true
		end
	end
	self:set_action(func)
end

function waterdragon.action_repel(self)
	local anim = self.animations["repel"]
	local anim_time = (anim.range.y - anim.range.x) / anim.speed
	local timeout = anim_time
	local damage_init = false
	local scale = self.growth_scale
	self:set_gravity(-9.8)
	self:halt()

	minetest.sound_play("waterdragon_repel", {
		object = self.object,
		gain = 1.0,
		max_hear_distance = 64,
		loop = false,
	})

	local function func(_self)
		local yaw = _self.object:get_yaw()
		local pos = _self.object:get_pos()
		if not pos then return end

		_self:animate("repel")
		timeout = timeout - _self.dtime

		if timeout < anim_time * 0.7 and not damage_init then
			_self.alert_timer = 15
			local aoe_center = vec_add(pos, vec_multi(yaw2dir(yaw), _self.width))
			local affected_objs = minetest.get_objects_inside_radius(aoe_center, 20 * scale)

			for _, object in ipairs(affected_objs) do
				if object and object ~= self.object then
					local is_player = object:is_player()
					local ent = object:get_luaentity()

					if is_player or (ent and waterdragon.is_alive(ent) and not ent._ignore) then
						local obj_pos = object:get_pos()
						local dir = vec_dir(pos, obj_pos)

						-- Strong horizontal wind blast
						local wind_force = {
							x = dir.x * 100, -- Big horizontal blast
							y = 12, -- Minimum lift for realism
							z = dir.z * 100 -- Strong horizontal push
						}

						object:add_velocity(wind_force)
						-- Inflict damage
						if is_player then
							object:set_hp(object:get_hp() - 3)
						elseif ent and ent.health then
							ent.health = ent.health - 3
						elseif ent and ent.hp then
							ent.hp = ent.hp - 3
						end
					end
				end
			end
			damage_init = true
		end

		if timeout <= 0 then
			self:animate("stand")
			return true
		end
	end
	self:set_action(func)
end

function waterdragon.action_punch(self)
	local anim = self.animations["bite"]
	local anim_time = (anim.range.y - anim.range.x) / anim.speed
	local timeout = anim_time
	local damage_init = false
	self:set_gravity(-9.8)
	self:halt()
	local function func(_self)
		local yaw = _self.object:get_yaw()
		local pos = _self.object:get_pos()
		if not pos then return end
		_self:animate("bite")
		timeout = timeout - _self.dtime
		if timeout < anim_time * 0.5
			and not damage_init then
			_self.alert_timer = 15
			local aoe_center = vec_add(pos, vec_multi(yaw2dir(yaw), _self.width))
			local affected_objs = minetest.get_objects_inside_radius(aoe_center, 1.49)
			for _, object in ipairs(affected_objs) do
				local tgt_pos = object and object ~= self.object and object:get_pos()
				if tgt_pos then
					local ent = object:get_luaentity()
					local is_player = object:is_player()
					if (waterdragon.is_alive(ent)
							and not ent._ignore)
						or is_player then
						_self:punch_target(object, _self.damage)
					end
				end
			end
			minetest.sound_play("waterdragon_scottish_dragon_bite", {
				object = _self.object,
				gain = 1.0,
				max_hear_distance = 16,
				loop = false,
			})
			damage_init = true
		end
		if timeout <= 0 then
			self:animate("stand")
			return true
		end
	end
	self:set_action(func)
end

--------------
-- Behavior --
--------------

-- Sleep

waterdragon.register_utility("waterdragon:sleep", function(self)
    local function func(_self)
        -- Check time of day
        local time = (minetest.get_timeofday() or 0) * 24000
        local is_night = time > 19500 or time < 4500

        -- Set eyes state based on time
        if is_night then
            self.eyes_open = false
        else
            self.eyes_open = true
        end
        self:memorize("eyes_open", self.eyes_open)

        if not _self:get_action() then
            _self.object:set_yaw(_self.object:get_yaw())
            waterdragon.action_idle(_self, 3, "sleep")
        end
        
        minetest.after(1, function()
            if _self.flight_stamina < 300 then
                _self.flight_stamina = math.min(_self.flight_stamina + (_self.flight_stamina * 0.2), 300)
                func(_self) 
            end
        end)
    end
    self:set_utility(func)
end)

-- Wander

waterdragon.register_utility("waterdragon:wander", function(self)
	local center = self.object:get_pos()
	if not center then return end
	local function func(_self)
		if not _self:get_action() then
			local move = random(5) < 2
			if move then
				local pos2 = _self:get_wander_pos(3, 6)
				if vec_dist(pos2, center) > 16 then
					waterdragon.action_idle(_self, random(2, 5))
				else
					waterdragon.action_move(_self, pos2, 4, "waterdragon:obstacle_avoidance", 0.5)
				end
			else
				waterdragon.action_idle(_self, random(2, 5))
			end
		end
	end
	self:set_utility(func)
end)

waterdragon.register_utility("waterdragon:die", function(self)
	local timer = 4
	local init = false
	local die = "waterdragon_death"
	local function func(_self)
		if not init then
			minetest.sound_play({
				name = die,
				gain = 1.0,
				max_hear_distance = 20,
				loop = false
			})
			waterdragon.action_fallover(_self)
			init = true
		end
		timer = timer - _self.dtime
		if timer <= 0 then
			local pos = _self.object:get_pos()
			if not pos then return end
			minetest.add_particlespawner({
				amount = 8,
				time = 0.25,
				minpos = { x = pos.x - 0.1, y = pos.y, z = pos.z - 0.1 },
				maxpos = { x = pos.x + 0.1, y = pos.y + 0.1, z = pos.z + 0.1 },
				minacc = { x = 0, y = 2, z = 0 },
				maxacc = { x = 0, y = 3, z = 0 },
				minvel = { x = random(-1, 1), y = -0.25, z = random(-1, 1) },
				maxvel = { x = random(-2, 2), y = -0.25, z = random(-2, 2) },
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

			waterdragon.drop_items(_self)
			_self.object:remove()
			minetest.add_item(pos, "waterdragon:draconic_tooth 5")
			minetest.add_item(pos, "waterdragon:wing_horn 2")
			minetest.add_item(pos, "waterdragon:scales_scottish_dragon 12")
			minetest.add_item(pos, "waterdragon:dragon_horn 2")
			return true
		end
	end
	self:set_utility(func)
end)

-- Wander Flight

waterdragon.register_utility("waterdragon:aerial_wander", function(self, speed_x)
	if not self.fly_allowed then
		-- If the Water Dragon is not allowed to fly
		return
	end
	local center = self.object:get_pos()
	if not center then return end
	local height_timer = 0
	local function func(_self)
		local pos = _self.object:get_pos()
		if not pos then return end
		height_timer = height_timer - self.dtime
		if height_timer <= 0 then
			local dist2floor = waterdragon.sensor_floor(_self, 10, true)
			center.y = center.y + (10 - dist2floor)
			height_timer = 4
		end
		if _self.nest_pos
			and vec_dist(pos, _self.nest_pos) > 128 then
			center = _self.nest_pos
		end
		if not _self:get_action() then
			local move_dir = (vec_dist(pos, center) > 56 * speed_x and vec_dir(pos, center)) or nil
			local pos2 = _self:get_wander_pos_3d(ceil(8 * speed_x), ceil(12 * speed_x), move_dir)
			waterdragon.action_move(_self, pos2, 3, "waterdragon:fly_simple", speed_x or 0.5, "fly")
		end
	end
	self:set_utility(func)
end)

waterdragon.register_utility("waterdragon:fly_and_roost", function(self, speed_x)
	if not self.fly_allowed then
		-- If the Water Dragon is not allowed to fly
		return
	end
	local center = self.nest_position or self.object:get_pos()
	if not center then return end
	local center_fly = { x = center.x, y = center.y + 12, z = center.z }
	local dist2floor = waterdragon.sensor_floor(self, 10, true)
	center.y = center.y - dist2floor
	local is_landed = true
	local landing = (dist2floor > 4 and true) or false
	local state_timer = random(10, 120)
	speed_x = speed_x or 0.75
	local function func(_self)
		local pos = self.object:get_pos()
		if not pos then return end
		state_timer = state_timer - _self.dtime
		if not self:get_action() then
			-- Change States
			if state_timer <= 0 then
				state_timer = random(10, 120)
				is_landed = not is_landed
				if is_landed then
					landing = true
				else
					waterdragon.action_takeoff(self, 3)
					return
				end
			end
			-- Land
			if landing then
				local pos2 = _self:get_wander_pos_3d(3, 6)
				if _self.touching_ground then
					waterdragon.action_land(self)
					landing = false
				else
					dist2floor = waterdragon.sensor_floor(_self, 10, true)
					pos2.y = pos2.y - dist2floor
					waterdragon.action_move(_self, pos2, 3, "waterdragon:fly_simple", 0.6, "fly")
					_self:animate("fly")
				end
				return
			end
			-- Wander
			if is_landed then
				if random(5) < 2 then
					local pos2 = _self:get_wander_pos(3, 6)
					if vec_dist(pos2, center) > 16 then
						waterdragon.action_idle(_self, random(2, 5))
					else
						waterdragon.action_move(_self, pos2, 4, "waterdragon:obstacle_avoidance", 0.5)
					end
				else
					waterdragon.action_idle(_self, random(2, 5))
				end
			else
				local pos2 = _self:get_wander_pos_3d(ceil(8 * speed_x), ceil(12 * speed_x), vec_dir(pos, center_fly))
				waterdragon.action_move(_self, pos2, 3, "waterdragon:fly_simple", speed_x or 0.5, "fly")
			end
		end
	end
	self:set_utility(func)
end)

waterdragon.register_utility("waterdragon:fly_to_land", function(self)
	local landed = false
	local function func(_self)
		if not _self:get_action() then
			if landed then return true end
			if _self.touching_ground then
				waterdragon.action_land(_self)
				landed = true
			else
				local pos2 = _self:get_wander_pos_3d(3, 6)
				if pos2 then
					local dist2floor = waterdragon.sensor_floor(_self, 10, true)
					pos2.y = pos2.y - dist2floor
					waterdragon.action_move(_self, pos2, 3, "waterdragon:fly_simple", 0.6, "fly")
					_self:animate("fly")
				end
			end
		end
	end
	self:set_utility(func)
end)

-- Scottish Dragon Breaking

waterdragon.register_utility("waterdragon:scottish_dragon_breaking", function(self, player)
	self.fly_allowed = true
	local center = self.object:get_pos()
	if not center then return end
	local taming = 0
	local feed_timer = 10
	local throw_timer = 5 -- Timer for throwing the player

	local function func(_self)
		if not player or not player:get_pos() then
			return true
		end

		local name = player:get_player_name()
		local item = player:get_wielded_item()
		local item_name = item:get_name()
		local def = minetest.registered_items[item_name]
		local has_meat = minetest.get_item_group(item_name, "meat") == 1 or
			minetest.get_item_group(item_name, "food_meat") == 1 or minetest.get_item_group(item_name, "cooked") == 1

		-- Check if player has bowed and has meat
		if not has_bowed_to_scottish_dragon(name, self) or not has_meat then
			throw_timer = throw_timer - _self.dtime
			if throw_timer <= 0 then
				minetest.chat_send_player(name,
					S("The Scottish Dragon has thrown you off because you must or bow to it or hold meat in hand"))
				waterdragon.detach_player(_self, player)
				return true
			end
		end

		local pos = _self.object:get_pos()
		if not pos then return end

		-- Player Interaction
		if player:get_player_control().sneak then
			waterdragon.detach_player(_self, player)
			return true
		end

		feed_timer = feed_timer - _self.dtime
		if feed_timer <= 0 then
			if has_meat then
				if not minetest.is_creative_enabled(player) then
					item:take_item()
					player:set_wielded_item(item)
				end
				-- Add particle effects
				local particle_pos = vector.add(pos, vector.multiply(vector.normalize(self.object:get_velocity()), 12))
				minetest.add_particlespawner({
					amount = 3,
					time = 0.1,
					minpos = particle_pos,
					maxpos = particle_pos,
					minvel = { x = -1, y = 1, z = -1 },
					maxvel = { x = 1, y = 2, z = 1 },
					minacc = { x = 0, y = -5, z = 0 },
					maxacc = { x = 0, y = -9, z = 0 },
					minexptime = 1,
					maxexptime = 1,
					minsize = 4,
					maxsize = 6,
					collisiondetection = true,
					vertical = false,
					texture = def.inventory_image,
				})

				taming = taming + 10
				minetest.chat_send_player(name,
					S("The Scottish Dragon ate some ") .. def.description .. "! Taming progress: " .. taming .. "%")

				if taming >= 100 then
					minetest.chat_send_player(name, S("The Scottish Dragon has been tamed!"))
					_self.owner = _self:memorize("owner", player:get_player_name())
					return true
				end
			end
			feed_timer = 10
		end

		-- Flying behavior while taming
		if not _self:get_action() then
			if _self.touching_ground then
				waterdragon.action_takeoff(_self)
			else
				local pos2 = _self:get_wander_pos_3d(6, 9)
				waterdragon.action_fly(_self, pos2, 3, "waterdragon:fly_simple", 0.6)
			end
		end
	end
	self:set_utility(func)
end)


-- Water Dragon breaking


waterdragon.register_utility("waterdragon:wtd_breaking", function(self, player)
	self.fly_allowed = true
	local center = self.object:get_pos()
	if not center then return end
	local taming = 0
	local feed_timer = 15
	local throw_timer = 3 -- Timer for throwing the player

	local function func(_self)
		if not player or not player:get_pos() then
			return true
		end

		local name = player:get_player_name()
		local item = player:get_wielded_item()
		local item_name = item:get_name()
		local def = minetest.registered_items[item_name]
		local has_meat = minetest.get_item_group(item_name, "meat") == 1 or
			minetest.get_item_group(item_name, "food_meat") == 1 or minetest.get_item_group(item_name, "cooked") == 1

		-- Check if player has bowed and has meat
		if not has_bowed_to_dragon(name, self) or not has_meat then
			throw_timer = throw_timer - _self.dtime
			if throw_timer <= 0 then
				minetest.chat_send_player(name,
					S("The Water Dragon has thrown you off because you must or bow to it or hold meat in hand"))
				waterdragon.detach_player(_self, player)
				return true
			end
		end

		local pos = _self.object:get_pos()
		if not pos then return end

		-- Player Interaction
		if player:get_player_control().sneak then
			waterdragon.detach_player(_self, player)
			return true
		end

		feed_timer = feed_timer - _self.dtime
		if feed_timer <= 0 then
			if has_meat then
				if not minetest.is_creative_enabled(player) then
					item:take_item()
					player:set_wielded_item(item)
				end
				-- Add particle effects
				local particle_pos = vector.add(pos, vector.multiply(vector.normalize(self.object:get_velocity()), 12))
				minetest.add_particlespawner({
					amount = 3,
					time = 0.1,
					minpos = particle_pos,
					maxpos = particle_pos,
					minvel = { x = -1, y = 1, z = -1 },
					maxvel = { x = 1, y = 2, z = 1 },
					minacc = { x = 0, y = -5, z = 0 },
					maxacc = { x = 0, y = -9, z = 0 },
					minexptime = 1,
					maxexptime = 1,
					minsize = 4,
					maxsize = 6,
					collisiondetection = true,
					vertical = false,
					texture = def.inventory_image,
				})

				taming = taming + 10
				minetest.chat_send_player(name,
					S("The Water Dragon ate some ") .. def.description .. "! Taming progress: " .. taming .. "%")

				if taming >= 100 then
					minetest.chat_send_player(name, S("The Water Dragon has been tamed!"))
					_self.owner = _self:memorize("owner", player:get_player_name())
					return true
				end
			end
			feed_timer = 10
		end

		-- Flying behavior while taming
		if not _self:get_action() then
			if _self.touching_ground then
				waterdragon.action_takeoff(_self)
			else
				local pos2 = _self:get_wander_pos_3d(6, 9)
				waterdragon.action_fly(_self, pos2, 3, "waterdragon:fly_simple", 0.6)
			end
		end
	end
	self:set_utility(func)
end)


-- Attack


local function vec_dist(a, b)
	local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z
	return math.sqrt(x * x + y * y + z * z)
end

local function vec_dir(a, b)
	local x, y, z = b.x - a.x, b.y - a.y, b.z - a.z
	local length = vec_dist(a, b)
	if length == 0 then
		return { x = 0, y = 0, z = 0 }
	end
	return { x = x / length, y = y / length, z = z / length }
end

local function dir2yaw(dir)
	return math.atan2(dir.z, dir.x)
end

local function diff(a, b)
	return math.atan2(math.sin(b - a), math.cos(b - a))
end


local function throw_wing_horn(self, target)
	local pos = self.object:get_pos()
	if not pos then return end
	local tgt_pos = target:get_pos()
	if not tgt_pos then return end
	local dir = vec_dir(pos, tgt_pos)
	local obj = minetest.add_entity(pos, "waterdragon:wing_horn")
	if obj then
		local ent = obj:get_luaentity()
		if ent then
			ent.owner = self.object
		end
		obj:set_velocity({ x = dir.x * 15, y = dir.y * 15, z = dir.z * 15 })
		obj:set_acceleration({ x = 0, y = -9.8, z = 0 })
		minetest.after(10, function()
			if obj and obj:get_luaentity() then
				obj:remove()
			end
		end)
	end
end

function waterdragon.is_target_flying(target)
	if not target then
		return false
	end

	local pos = target:get_pos()
	if not pos then
		return false
	end


	for i = 0, 4 do
		local check_pos = { x = pos.x, y = pos.y - i, z = pos.z }
		local node = minetest.get_node_or_nil(check_pos)
		if not node then
			return false
		end

		local node_def = minetest.registered_nodes[node.name]
		if node_def and (node_def.walkable or (node_def.drawtype == "liquid" and node_def.liquidtype ~= "none")) then
			return i > 1
		end
	end

	return true
end

minetest.register_craftitem("waterdragon:wing_horn", {
	description = S("Wing Horn"),
	inventory_image = "waterdragon_wing_horn.png",

	on_use = function(itemstack, user, pointed_thing)
		if not user then return end

		local pos = user:get_pos()
		pos.y = pos.y + 1.5
		local dir = user:get_look_dir()
		local obj = minetest.add_entity(pos, "waterdragon:wing_horn")

		if obj then
			obj:set_velocity({
				x = dir.x * 15,
				y = dir.y * 15,
				z = dir.z * 15
			})
			obj:set_acceleration({ x = 0, y = -9.8, z = 0 })

			local ent = obj:get_luaentity()
			if ent then
				ent.owner = user
			end

			itemstack:take_item(1)
		end

		return itemstack
	end
})

-- Entity for thrown horns
minetest.register_entity("waterdragon:wing_horn", {
	initial_properties = {
		visual = "sprite",
		textures = { "waterdragon_wing_horn.png" },
		physical = true,
		collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
	},
	owner = nil,

	on_step = function(self, dtime)
		local pos = self.object:get_pos()
		if not pos then return end

		-- Check for collisions with entities
		for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			if obj ~= self.object and obj ~= self.owner then
				if obj:is_player() then
					obj:set_hp(math.max(1, obj:get_hp() * 0.5)) -- Reduce HP by 50%, but leave at least 1 HP
					self.object:remove()
					return
				elseif obj:get_luaentity() then
					local ent = obj:get_luaentity()
					local hp_field = ent.hp or ent.health -- Check both `hp` and `health` fields

					if hp_field then
						ent.hp = hp_field * 0.5 -- Reduce HP by 50%
						ent.health = hp_field * 0.5
						self.object:remove()
						return
					end
				end
			end
		end

		-- Check for node collision
		local node = minetest.get_node_or_nil(pos)
		if node and node.name ~= "air" and node.name ~= "ignore" then
			minetest.add_item(pos, "waterdragon:wing_horn")
			self.object:remove()
			return
		end
	end
})



waterdragon.register_utility("waterdragon:attack", function(self, target)
	if not self.fly_allowed then
		-- If the Water Dragon is not allowed to fly
		return
	end
	if self.target == self.object then return end
	local is_landed = true
	local init = false
	local takeoff_init = false
	local land_init = false
	local fov_timer = 0
	local switch_timer = 20

	local function func(_self)

		local target_alive, _, tgt_pos = _self:get_target(target)
		if not target_alive then
			_self._target = nil
			return true
		end

		if target:get_luaentity() and (target:get_luaentity().name == "waterdragon:pure_water_dragon" or target:get_luaentity().name == "waterdragon:rare_water_dragon" or target:get_luaentity().name == "pegasus:pegasus" or target:get_luaentity().name == "waterdragon:scottish_dragon" or target:get_luaentity().name == "winddragon:winddragon") then
			_self._target = nil
			return true
		end

		local target_alive, _, tgt_pos = _self:get_target(target)
		if not target_alive then
			_self._target = nil
			return true
		end

		local pos = _self.object:get_pos()
		local yaw = _self.object:get_yaw()
		if not pos then return end

		local yaw2tgt = dir2yaw(vec_dir(pos, tgt_pos))
		if math.abs(diff(yaw, yaw2tgt)) > 0.3 then
			fov_timer = fov_timer + _self.dtime
		end

		switch_timer = switch_timer - _self.dtime

		if not _self:get_action() then
			if not init then
				local dist2floor = waterdragon.sensor_floor(_self, 7, true)
				if dist2floor > 6 or waterdragon.is_target_flying(target) then
					is_landed = false
				end
				init = true
			elseif switch_timer <= 0 then
				local switch_chance = (is_landed and 6) or 3
				is_landed = math.random(switch_chance) > 1
				takeoff_init = not is_landed
				land_init = is_landed
				switch_timer = 20
			end

			if land_init then
				if not _self.touching_ground then
					local pos2 = tgt_pos
					if waterdragon.is_target_flying(target) then
						pos2 = { x = pos.x, y = pos.y - 7, z = pos.z }
					end
					waterdragon.action_move(_self, pos2, 3, "waterdragon:fly_simple", 1, "fly")
				else
					waterdragon.action_land(_self)
					land_init = false
				end
				return
			end

			if takeoff_init and _self.touching_ground then
				waterdragon.action_takeoff(_self)
				takeoff_init = false
				return
			end

			local dist = vec_dist(pos, tgt_pos)
			local attack_range = (is_landed and 8) or 16

			if dist <= attack_range then
				if math.random() < 0.3 then
				else
					if is_landed then
						if fov_timer < 1 and target:is_player() then
							waterdragon.action_repel(_self, target)
						else
							waterdragon.action_slam(_self, target)
							is_landed = false
							fov_timer = 0
						end
					else
						if math.random(3) < 2 then
							waterdragon.action_flight_pure_water(_self, target, 12)
						else
							waterdragon.action_hover_water(_self, target, 3)
						end
					end
				end
			else
				if is_landed then
					waterdragon.action_pursue(_self, target, 2, "waterdragon:obstacle_avoidance", 0.75, "walk_slow")
				else
					tgt_pos.y = tgt_pos.y + 14
					waterdragon.action_move(_self, tgt_pos, 5, "waterdragon:fly_simple", 1, "fly")
				end
			end
		end
	end
	self:set_utility(func)
end)

local function breathe_fire(self)
	local pos = self.object:get_pos()
	if not pos then return end

	local dir
	if self.rider then
		-- If the Dragon has a rider, use the rider's look direction
		local look_dir = self.rider:get_look_dir()
		dir = vector.new(
			look_dir.x,
			look_dir.y,
			look_dir.z
		)
	else
		-- If there is no rider, use the Dragon's rotation
		local yaw = self.object:get_yaw()
		local pitch = self.object:get_rotation().x
		dir = vector.new(
			-math.sin(yaw) * math.cos(pitch),
			-math.sin(pitch),
			math.cos(yaw) * math.cos(pitch)
		)
	end

	local start_pos = vector.add(pos, vector.new(0, 1.2, 0))

	local particle_types = {
		{
			texture = "waterdragon_fire_1.png",
			size = { min = 2, max = 4 },
			velocity = { min = 15, max = 20 },
			acceleration = { y = { min = 2, max = 4 } },
			exptime = { min = 0.8, max = 1.2 },
			glow = 14
		},
		{
			texture = "waterdragon_fire_2.png",
			size = { min = 2, max = 4 },
			velocity = { min = 15, max = 20 },
			acceleration = { y = { min = 2, max = 4 } },
			exptime = { min = 0.8, max = 1.2 },
			glow = 14
		},
		{
			texture = "waterdragon_fire_3.png",
			size = { min = 2, max = 4 },
			velocity = { min = 15, max = 20 },
			acceleration = { y = { min = 2, max = 4 } },
			exptime = { min = 0.8, max = 1.2 },
			glow = 14
		},
	}

	-- Spawn particles
	for i = 1, 10 do
		local particle = particle_types[math.random(#particle_types)]

		minetest.add_particle({
			pos = vector.add(start_pos, vector.new(
				math.random(-5, 5) / 10,
				math.random(-5, 5) / 10,
				math.random(-5, 5) / 10
			)),
			velocity = vector.multiply(vector.add(dir, vector.new(
				math.random(-2, 2) / 10,
				math.random(-2, 2) / 10,
				math.random(-2, 2) / 10
			)), math.random(particle.velocity.min, particle.velocity.max)),
			acceleration = { x = 0, y = math.random(particle.acceleration.y.min, particle.acceleration.y.max), z = 0 },
			expirationtime = math.random(particle.exptime.min, particle.exptime.max),
			size = math.random(particle.size.min, particle.size.max),
			collisiondetection = true,
			collision_removal = true,
			vertical = false,
			texture = particle.texture,
			glow = particle.glow
		})
	end

	-- Check for block collisions and ignite blocks
	local step = 1
	for i = 0, 20, step do
		local check_pos = vector.add(start_pos, vector.multiply(dir, i))
		local node = minetest.get_node(check_pos)

		-- Check for entities at each step
		local objects = minetest.get_objects_inside_radius(check_pos, 1)
		for _, obj in ipairs(objects) do
			if obj ~= self.object then
				local ent = obj:get_luaentity()
				if ent and ent.name ~= self.name then
					obj:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = { fleshy = 6 },
					}, nil)
				end
			end
		end

		-- Stop if we hit a non-air block
		if node.name ~= "air" and node.name ~= "waterdragon:fire_animated" then
			break
		end
	end
end

minetest.register_entity("waterdragon:fire_dragon", {
	initial_properties = {
		health = 500,
		visual = "mesh",
		mesh = "waterdragon_scottish_dragon.b3d",
		textures = { "waterdragon_fire_dragon.png" },
		visual_size = { x = 5, y = 5 },
		collisionbox = { -0.75, -1, -0.75, 0.75, 1, 0.75 },
		stepheight = 0.6,
		physical = true,
	},

	-- Animation definitions
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

	-- Target handling
	target = nil,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({ fleshy = 100 })
	end,

	on_step = function(self, dtime)
		if not self._target or not self._target:get_pos() then
			self.object:remove()
			return
		end

		local pos = self.object:get_pos()
		local target_pos = self._target:get_pos()


		-- Face target
		local dir = vector.direction(pos, target_pos)
		local yaw = minetest.dir_to_yaw(dir)
		self.object:set_yaw(yaw)

		-- Breathe fire at target
		breathe_fire(self)
	end
})

function summon_fire_dragon(self)
	if not self._target or not self._target:get_pos() then return end
	if self.hp > 100 or self.fire < 3 then return end

	-- First hover and breathe fire
	waterdragon.action_idle(self, 3, "hover")
	self.fire_breathing = true
	breathe_fire(self)

	-- After 3 seconds, summon the Fire Dragon
	minetest.after(3, function()
		if not self.object:get_pos() then return end

		-- Create Fire Dragon
		local pos = self.object:get_pos()
		pos.y = pos.y + 4 -- Spawn above the Scottish Dragon

		local fire_dragon_obj = minetest.add_entity(pos, "waterdragon:fire_dragon")
		if fire_dragon_obj then
			local fire_dragon = fire_dragon_obj:get_luaentity()
			if fire_dragon then
				fire_dragon._target = self._target -- Set target for Fire Dragon entity
				minetest.add_entity(pos, "waterdragon:fire_dragon")
				-- Add particle effects
				minetest.add_particlespawner({
					amount = 2,
					time = 0.5,
					minpos = vector.subtract(pos, 2),
					maxpos = vector.add(pos, 2),
					minvel = { x = -1, y = 0, z = -1 },
					maxvel = { x = 1, y = 2, z = 1 },
					minacc = { x = 0, y = 0, z = 0 },
					maxacc = { x = 0, y = 1, z = 0 },
					minexptime = 1,
					maxexptime = 2,
					minsize = 2,
					maxsize = 4,
					texture = "waterdragon_fire_1.png",
					glow = 14
				})
			end
		end

		-- Land after summoning
		self:set_gravity(0)
		waterdragon.action_land(self)
	end)
end

waterdragon.register_utility("waterdragon:scottish_dragon_attack", function(self, target)
	if target:get_luaentity() and (target:get_luaentity().name == "waterdragon:pure_water_dragon" or target:get_luaentity().name == "waterdragon:rare_water_dragon" or target:get_luaentity().name == "pegasus:pegasus" or target:get_luaentity().name == "waterdragon:scottish_dragon") then
		self._target = nil
		return true
	end
	local fire_attack_timer = 0
	local is_fire_attack = true

	local function func(_self)
		local pos = _self.object:get_pos()
		if not pos then return end

		local target_alive = target and target:get_pos()
		local tgt_pos = target and target:get_pos()

		if not target_alive then
			_self._target = nil
			return true
		end

		if not _self:get_action() then
			local dist = vector.distance(pos, tgt_pos)

			if _self.has_pegasus_fire and _self.fire and _self.fire > 0 and is_fire_attack then
				-- Calculate direction to target
				local dir = {
					x = tgt_pos.x - pos.x,
					y = tgt_pos.y - pos.y,
					z = tgt_pos.z - pos.z
				}

				-- Normalize vector
				local length = math.sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * dir.z)
				if length > 0 then
					dir.x = dir.x / length
					dir.y = dir.y / length
					dir.z = dir.z / length
				end

				-- Set yaw and pitch
				local yaw = math.atan2(dir.z, dir.x) - math.pi / 2
				local pitch = -math.asin(dir.y)
				_self.object:set_rotation({ x = pitch, y = yaw, z = 0 })

				-- Fire attack
				_self:animate("hover")
				_self:set_forward_velocity(-2)
				_self.fire_breathing = true
				breathe_pegasus_fire(_self)

				fire_attack_timer = fire_attack_timer + _self.dtime
				if fire_attack_timer >= 5 then
					is_fire_attack = false
					_self.fire_breathing = false
				end
			else
				if dist > 14 then
					_self:animate("fly")
					_self:move_to(tgt_pos, "waterdragon:obstacle_avoidance", 4)
				else
					waterdragon.action_flight_attack(_self, target, 12)
				end
			end
		end
		summon_fire_dragon(self)
		return false
	end

	self:set_utility(func)
end)

-- Tamed Behavior --

waterdragon.register_utility("waterdragon:stay", function(self)
	local function func(_self)
		local order = _self.order
		if not order or order ~= "stay" then
			return true
		end

		local vel = _self.object:get_velocity()
		local pos = _self.object:get_pos()
		local node_below = minetest.get_node({ x = pos.x, y = pos.y - 1, z = pos.z })

		if vel.y < -0.5 and minetest.get_item_group(node_below.name, "liquid") == 0 then
			if self.rider then return end
			_self.object:set_velocity({ x = 0, y = 0, z = 0 })
			_self.object:set_acceleration({ x = 0, y = 0, z = 0 })
			if not _self:get_action() then
				waterdragon.action_idle(_self, 2, "hover")
			end
		else
			_self.object:set_acceleration({ x = 0, y = -9.81, z = 0 })
			if not _self:get_action() then
				waterdragon.action_idle(_self, 2, "stand")
			end
		end
	end
	self:set_utility(func)
end)

waterdragon.register_utility("waterdragon:follow_player", function(self, player)
	local function func(_self)
		local order = _self.order
		if not order
			or order ~= "follow" then
			return true
		end
		if not player then
			return true
		end
		local scale = _self.growth_scale or 1
		local pos = _self.object:get_pos()
		if not pos then return end
		local tgt_pos = player:get_pos()
		if not tgt_pos then
			_self.order = "stay"
			return true
		end
		local dist = vec_dist(pos, tgt_pos)
		local dist_to_ground = waterdragon.sensor_floor(_self, 8, true)
		if not _self:get_action() then
			if dist < clamp(8 * scale, 5, 12) then
				if dist_to_ground > 2 then
					waterdragon.action_hover(_self, 2, "hover")
				else
					waterdragon.action_idle(_self, 2, "stand")
				end
			else
				local height_diff = tgt_pos.y - pos.y
				if ((height_diff > 8 or dist_to_ground > 2) and self.fly_allowed) then
					waterdragon.action_move(_self, tgt_pos, 2, "waterdragon:fly_simple", 1, "fly")
				else
					waterdragon.action_move(_self, tgt_pos, 3, "waterdragon:context_based_steering", 1, "walk")
				end
			end
		end
	end
	self:set_utility(func)
end)

local function check_owner_falling(player)
	if not player or not player:get_pos() then return false end
	local pos = player:get_pos()

	-- Check player's downward velocity
	local velocity = player:get_velocity()
	if not velocity or velocity.y > -3 then -- Only rescue if falling faster than -3
		return false
	end

	-- Check if there's air below the player
	for i = 1, 15 do
		local check_pos = { x = pos.x, y = pos.y - i, z = pos.z }
		local node = minetest.get_node(check_pos)
		if node.name ~= "air" then
			return false
		end
	end
	return true
end

-- Utility Stack --

waterdragon.dragon_behavior = {
	{ -- Wander
		utility = "waterdragon:fly_and_roost",
		get_score = function(self)
			return 0.1, { self }
		end
	},
	{ -- Attack
		utility = "waterdragon:attack",
		get_score = function(self)
			
			local pos = self.object:get_pos()
			if not pos then return end
			local stance = (self.owner and self.stance) or "aggressive"
			local skip = self.age < 15 or stance == "passive"
			if skip then return 0 end -- Young/Passive Water Dragons don't attack
			local target = self._target
			if not target then
				if stance ~= "aggressive" then return 0 end -- Neutral Water Dragons with no set target
				local target_list = waterdragon[self.name:split(":")[2] .. "_targets"]
				target = find_target(self, target_list)
				if not target or not target:get_pos() then return 0 end
				local is_far = self.nest_pos and vec_dist(target:get_pos(), self.nest_pos) > 192
				if is_far
					or self._ignore_obj[target]
					or shared_owner(self, target) then
					self._target = nil
					return 0
				end
			end
			if target and target:is_player() then
				if defend_owner(self.object, target) then
					return 0 -- Stop attack if target is protected
				end
			end
			local scale = self.growth_scale
			local dist2floor = waterdragon.sensor_floor(self, 3, true)
			if not self.owner
				and dist2floor < 3
				and target:get_pos()
				and vec_dist(pos, target:get_pos()) > 48 * scale
				and self.alert_timer <= 0 then
				-- Wild Water Dragons sleep until approached
				self._target = nil
				return 0
			end
			local name = target:is_player() and target:get_player_name()
			if name then
				local inv = minetest.get_inventory({ type = "player", name = name })
				if waterdragon.contains_book(inv) then
					waterdragon.add_page(inv, "waterdragons")
				end
			end
			self._target = target
			return 0.9, { self, target }
		end
	},
	{ -- Sleep
		utility = "waterdragon:sleep",
		get_score = function(self)
			-- Don't sleep if transporting or has rider
			if self.transport_rider or self.rider then
				return 0
			end

			if self.owner then
				if is_night then
					return 0.2, { self }
				end
				return 0
			end
			if self.alert_timer > 0 then return 0 end
			if self.touching_ground
				and not self._target then
				return 0.7, { self }
			end
			return 0
		end
	},
	{ -- Stay (Order)
		utility = "waterdragon:stay",
		get_score = function(self)
			if not self.owner then return 0 end
			local order = self.order
			if order == "stay" then
				return 1, { self }
			end
			if self.order == "stay" then
				local vel = self.object:get_velocity()
				local pos = self.object:get_pos()
				local node_below = minetest.get_node({ x = pos.x, y = pos.y - 1, z = pos.z })

				if vel.y < -0.5 and minetest.get_item_group(node_below.name, "liquid") == 0 then
					self.object:set_velocity({ x = 0, y = 0, z = 0 })
					self.object:set_acceleration({ x = 0, y = 0, z = 0 })
					self:animate("hover")
				else
					self.object:set_acceleration({ x = 0, y = -9.81, z = 0 })
				end
			end
			return 0
		end
	},
	{ -- Follow (Order)
		utility = "waterdragon:follow_player",
		get_score = function(self)
			if not self.owner then return 0 end
			local owner = minetest.get_player_by_name(self.owner)
			if not owner then return 0 end
			local order = self.order
			if order == "follow" then
				local stance = self.stance
				local score = 1
				if stance == "aggressive"
					or stance == "neutral"
					and self.owner_target then
					score = 0.8
				end
				return score, { self, owner }
			end
			return 0
		end
	},
	{ -- Rescue owner if falling
		utility = "waterdragon:guardian_dive",
		get_score = function(self)
			if not self.owner then return 0 end
			if not self.fly_allowed then return 0 end

			local owner = minetest.get_player_by_name(self.owner)
			if not owner then return 0 end

			if check_owner_falling(owner) then
				return 1.0, { self } -- Highest priority when owner is falling
			end

			return 0
		end
	},
	{ -- Taming
		utility = "waterdragon:wtd_breaking",
		get_score = function(self)
			if self.rider
				and not self.owner then
				return 0.9, { self, self.rider }
			end
			return 0
		end
	},
	{ -- Water rescue behavior
		utility = "waterdragon:water_dive",
		get_score = function(self)
			if not self.owner then return 0 end
			local owner = minetest.get_player_by_name(self.owner)
			if not owner or not owner:get_pos() then return 0 end

			for _, entity in pairs(minetest.luaentities) do
				if entity.name == "waterdragon:rare_water_dragon" or entity.name == "waterdragon:pure_water_dragon" and
					entity.rider and
					entity.rider:get_player_name() == self.owner then
					return 0 -- Owner already mounted, don't attempt rescue
				end
			end

			local pos = owner:get_pos()
			local node = minetest.get_node(pos)

			-- Check if owner is in water
			if minetest.get_item_group(node.name, "water") == 0 then
				return 0
			end

			-- Check distance to nearest air block
			for i = 1, 30 do
				local check_pos = {
					x = pos.x,
					y = pos.y + i,
					z = pos.z
				}
				if minetest.get_node(check_pos).name == "air" then
					return 0
				end
			end

			return 1, { self, owner }
		end
	},
	{ -- Mounted
		utility = "waterdragon:mount",
		get_score = function(self)
			if not self.owner
				or not self.rider
				or not self.rider:get_look_horizontal() then
				return 0
			end
			return 1, { self }
		end
	}
}

waterdragon.scottish_dragon_behavior = {
	{ -- Wander
		utility = "waterdragon:wander",
		step_delay = 0.3,
		get_score = function(self)
			return 0.1, { self }
		end
	},
	{ -- Wander (Flight)
		utility = "waterdragon:aerial_wander",
		get_score = function(self)
			if self.owner and not self.fly_allowed then return 0 end
			if self.in_liquid then
				if self._target then
					self._ignore_obj[self._target] = true
				end
				self.flight_stamina = self:memorize("flight_stamina", self.flight_stamina + 200)
				self.is_landed = self:memorize("is_landed", false)
				return 0.4, { self, 0.3 }
			end
			if not self.is_landed then
				return 0.2, { self, 0.3 }
			end
			return 0
		end,
	},

	{ -- Stay (Order)
		utility = "waterdragon:stay",
		get_score = function(self)
			if not self.owner then return 0 end
			local order = self.order
			if order == "stay" then
				return 1, { self }
			end
			return 0
		end
	},
	{ -- Follow (Order)
		utility = "waterdragon:follow_player",
		get_score = function(self)
			local owner = self.owner and minetest.get_player_by_name(self.owner)
			if not owner then return 0 end
			local order = self.order
			if order == "follow" then
				local stance = self.stance
				if stance == "aggressive"
					or (stance == "neutral"
						and self.owner_target) then
					return 0.8, { self, owner }
				end
				return 1, { self, owner }
			end
			return 0
		end
	},
	{ -- Rescue owner if falling
		utility = "waterdragon:guardian_dive",
		get_score = function(self)
			if not self.owner then return 0 end
			if not self.fly_allowed then return 0 end

			local owner = minetest.get_player_by_name(self.owner)
			if not owner then return 0 end

			if check_owner_falling(owner) then
				return 1.0, { self } -- Highest priority when owner is falling
			end

			return 0
		end
	},
	{ -- Water rescue behavior
		utility = "waterdragon:water_dive",
		get_score = function(self)
			if not self.owner then return 0 end
			local owner = minetest.get_player_by_name(self.owner)
			if not owner or not owner:get_pos() then return 0 end

			-- Check if owner is already mounted on another Scottish Dragon
			for _, entity in pairs(minetest.luaentities) do
				if entity.name == "waterdragon:scottish_dragon" and
					entity.rider and
					entity.rider:get_player_name() == self.owner then
					return 0 -- Owner already mounted, don't attempt rescue
				end
			end

			local pos = owner:get_pos()
			local node = minetest.get_node(pos)

			-- Check if owner is in water
			if minetest.get_item_group(node.name, "water") == 0 then
				return 0
			end

			-- Check distance to nearest air block
			for i = 1, 30 do
				local check_pos = {
					x = pos.x,
					y = pos.y + i,
					z = pos.z
				}
				if minetest.get_node(check_pos).name == "air" then
					return 0
				end
			end

			return 1, { self, owner }
		end
	},
	{ -- Attack
		utility = "waterdragon:scottish_dragon_attack",
		get_score = function(self)
			local pos = self.object:get_pos()
			if not pos then return end
			local stance = (self.owner and self.stance) or "neutral"
			if stance == "passive" then return 0 end
			local target = self._target
			if not target then
				target = find_target(self, waterdragon.scottish_dragon_targets)
				if not target or not target:get_pos() then return 0 end
				if shared_owner(self, target) then
					self._target = nil
					return 0
				end
			end
			local name = target:is_player() and target:get_player_name()
			if name then
				local inv = minetest.get_inventory({ type = "player", name = target:get_player_name() })
			end
			self._target = target
			return 0.9, { self, target }
		end
	},
	{ -- Taming
		utility = "waterdragon:scottish_dragon_breaking",
		get_score = function(self)
			if self.rider
				and not self.owner then
				return 0.9, { self, self.rider }
			end
			return 0
		end
	},
	{ -- Mounted
		utility = "waterdragon:scottish_dragon_mount",
		get_score = function(self)
			if self.rider
				and self.owner then
				return 1, { self }
			end
			return 0
		end
	},
	{ -- Fly to Land
		utility = "waterdragon:fly_to_land",
		get_score = function(self)
			local util = self:get_utility() or ""
			local attacking_tgt = self._target and waterdragon.is_alive(self._target)
			if attacking_tgt or util == "waterdragon:scottish_dragon_breaking" then return 0 end
			local dist2floor = waterdragon.sensor_floor(self, 5, true)
			if dist2floor > 4 then
				local is_landed = self.is_landed
				local is_grounded = (self.owner and not self.fly_allowed) or self.order == "stay"
				if is_landed
					or is_grounded then
					if self.flight_stamina < 15 then
						return 1, { self }
					else
						return 0.3, { self }
					end
				end
			end
			return 0
		end
	}
}

waterdragon.register_utility("waterdragon:water_dive", function(self, player)
	local function func(_self)
		if not player or not player:get_pos() then return true end

		-- Check if player is already mounted on ANY Scottish Dragon
		for _, entity in pairs(minetest.luaentities) do
			if entity.name == "waterdragon:scottish_dragon" and
				entity.rider and
				entity.rider:get_player_name() == player:get_player_name() then
				return true -- Exit utility if player is mounted anywhere
			end
		end

		if self.rider then return true end

		local pos = _self.object:get_pos()
		if not pos then return end
		local player_pos = player:get_pos()

		if not _self:get_action() then
			local target_pos = {
				x = player_pos.x,
				y = player_pos.y + 2,
				z = player_pos.z
			}

			local dist = vector.distance(pos, player_pos)
			if dist < 3 then
				-- Double check again before mounting
				for _, entity in pairs(minetest.luaentities) do
					if entity.name == "waterdragon:scottish_dragon" and
						entity.rider and
						entity.rider:get_player_name() == player:get_player_name() then
						return true
					end
				end
				waterdragon.attach_player(self, player)
				return true
			end

			waterdragon.action_fly(self, target_pos, 2, "waterdragon:fly_simple", 1, "dive")
		end
	end
	self:set_utility(func)
end)

waterdragon.register_utility("waterdragon:guardian_dive", function(self)
	local function func(_self)
		if _self.rider then return true end

		-- Get owner
		local owner = _self.owner and minetest.get_player_by_name(_self.owner)
		if not owner then return true end

		-- Check if owner is still falling
		if not check_owner_falling(owner) then
			return true
		end

		local pos = _self.object:get_pos()
		if not pos then return true end

		local owner_pos = owner:get_pos()
		local dist = vector.distance(pos, owner_pos)

		-- If close enough, mount owner
		if dist <= 10 then
			waterdragon.attach_player(_self, owner)
			return true
		end

		-- Move to falling owner

		local target_pos = {
			x = owner_pos.x,
			y = owner_pos.y,
			z = owner_pos.z
		}
		self.fly_allowed = true
		waterdragon.action_fly(_self, target_pos, 3, "waterdragon:fly_simple", 1, "fly")
		if dist <= 8 then
			waterdragon.attach_player(_self, owner)
			return true
		end
	end

	self:set_utility(func)
end)
