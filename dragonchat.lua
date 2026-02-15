------------------------
-- Dragon Chat System --
------------------------


-- Storage for active chat sessions and cooldowns
local active_chats = {}
local player_cooldowns = {}
local S = waterdragon.S

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
local dragonchat = {
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
			"I come from a place older than memory, where Dragons first learned to fly and waters sang their songs."
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

	-- If the player is not on the Dragon, attach it
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
			(dragon.nametag or "Dragon") .. ": " .. dragonchat.farewell[math.random(#dragonchat.farewell)])
		active_chats[name] = nil
		return true
	end
	if message:find("stamina") then
		local response = dragonchat.conversations["how much stamina do you have"][math.random(3)]
		response = response .. " " .. (dragon.flight_stamina or 0) .. "/300"
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)
		return true
	end
	if message:find("hungry") then
		local response = dragonchat.conversations["how hungry are you"][math.random(3)]
		response = response .. " " .. (dragon.hunger or 0) .. "/" .. (dragon.max_hunger)
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)

		return true
	end

	if message:find("health") then
		local scale = dragon.growth_scale or 1
		local max_health = dragon.max_health * scale
		local response = dragonchat.conversations["how much health do you have"][math.random(3)]
		response = response .. " " .. (dragon.hp or 0) .. "/" .. max_health
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)

		return true
	end
	if message:find("breath") then
		local response = dragonchat.conversations["how much breath do you have"][math.random(3)]
		response = response .. " " .. (dragon.attack_stamina or 0) .. "/" .. dragon.attack_stamina
		minetest.chat_send_player(name, (dragon.nametag or "Dragon") .. ": " .. response)
		return true
	end
	if message:find("who are you") then
		local response = dragonchat.conversations["who are you"][math.random(3)]
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
		local response = dragonchat.conversations["what is your name"][math.random(3)]
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
	for cmd_name, cmd in pairs(dragonchat.commands) do
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
	for topic, responses in pairs(dragonchat.conversations) do
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
		(dragon.nametag or "Dragon") .. ": " .. dragonchat.unknown[math.random(#dragonchat.unknown)])
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
		minetest.chat_send_player(name, "Dragon: " .. dragonchat.greetings[math.random(#dragonchat.greetings)])
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
