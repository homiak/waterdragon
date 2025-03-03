---------------
-- Mount API --
---------------
local S = waterdragon.S

waterdragon.mounted_player_data = {}

local abs = math.abs
local ceil = math.ceil

-- Special fire abilities

local function create_fire_sphere(pos, radius)
    if not minetest.get_modpath("pegasus") then return end
    minetest.sound_play("waterdragon_fireball_crash", {
        pos = pos,
        gain = 1.0,
        max_hear_distance = 20,
        loop = false
    })
    -- Remove blocks in sphere shape
    for x = -radius, radius do
        for y = -radius, radius do
            for z = -radius, radius do
                local check_pos = vector.add(pos, { x = x, y = y, z = z })
                if vector.distance(pos, check_pos) <= radius then
                    local node = minetest.get_node(check_pos)
                    if node.name ~= "air" and node.name ~= "ignore" and
                        not minetest.is_protected(check_pos, "") then
                        minetest.set_node(check_pos, { name = "air" })
                    end
                end
            end
        end
    end
end

-- Add this function to create the traveling fireball
local function launch_fire_sphere(start_pos, direction)
    if not minetest.get_modpath("pegasus") then return end
    local pos = vector.new(start_pos)
    local distance = 0
    local sphere_radius = 20

    -- Create traveling fireball particles
    local function spawn_fire_trail()
        minetest.add_particlespawner({
            amount = 20,
            time = 0.002,
            minpos = pos,
            maxpos = pos,
            minvel = { x = -0.5, y = -0.5, z = -0.5 },
            maxvel = { x = 0.5, y = 0.5, z = 0.5 },
            minacc = { x = 0, y = 0, z = 0 },
            minexptime = 0.5,
            maxexptime = 1,
            minsize = 3,
            maxsize = 5,
            texture = "waterdragon_fireball_particle.png",
            glow = 14
        })
    end

    -- Move the fireball and check for collisions
    local function move_sphere()
        if distance >= 40 then
            create_fire_sphere(pos, sphere_radius)
            return
        end

        local next_pos = vector.add(pos, vector.multiply(direction, 4))
        local node = minetest.get_node(next_pos)

        if node.name ~= "air" then
            create_fire_sphere(pos, sphere_radius)
            return
        end

        pos = next_pos
        distance = distance + 1
        spawn_fire_trail()
        minetest.after(0.001, move_sphere)
    end

    move_sphere()
end

function breathe_pegasus_fire(self)
    if not minetest.get_modpath("pegasus") then return end
    if not self.fire_breathing then return end
    if not self.fire or self.fire <= 0 then
        self.fire_breathing = false
        return
    end
    self.fire_timer = self.fire_timer or 0

    local pos = self.object:get_pos()
    if not pos then return end

    local dir
    if self.rider then
        -- Если есть всадник, используем направление его взгляда
        local look_dir = self.rider:get_look_dir()
        dir = vector.new(
            look_dir.x,
            look_dir.y,
            look_dir.z
        )
    else
        -- Если всадника нет, используем поворот дракона
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
    for i = 1, 20 do
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
        if node.name ~= "air" and node.name ~= "waterdragon:fire_animated" then
            minetest.set_node(check_pos, { name = "waterdragon:fire_animated" })
        end

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

    -- Decrease fire charge every second
    if self.fire_timer >= 1 then
        self.fire = self.fire - 1
        self.fire_timer = 0
        self:memorize("fire", self.fire)
        if self.fire <= 0 then
            self.fire_breathing = false
            return
        end
    end

    -- Schedule the next fire breath
    minetest.after(0.1, function()
        breathe_pegasus_fire(self)
    end)
end

-------------------
-- Player Visual --
-------------------

minetest.register_entity("waterdragon:mounted_player_visual", {
    initial_properties = {
        mesh = "character.b3d",
        visual = "mesh",
        collisionbox = { 0, 0, 0, 0, 0, 0 },
        stepheight = 0,
        physical = false,
        collide_with_objects = false
    },
    on_activate = function(self, static)
        static = minetest.deserialize(static) or {}

        if not static.player then
            self.object:remove()
            return
        end

        self.player = static.player
        local player = minetest.get_player_by_name(self.player)

        if not player then
            self.object:remove()
            return
        end

        self.object:set_properties({
            textures = player:get_properties().textures,
            nametag = self.player
        })
        self.object:set_armor_groups({ immortal = 1 })
        self.object:set_yaw(player:get_look_horizontal())
    end,
    get_staticdata = function() return "" end,
    on_step = function(self) self.object:set_velocity(vector.new()) end
})

function waterdragon.set_fake_player(self, player, passenger)
    if not player
        or not player:get_look_horizontal()
        or not player:is_player() then
        return
    end
    local player_name = player:get_player_name()
    if waterdragon.mounted_player_data[player_name]
        and waterdragon.mounted_player_data[player_name].fake_player
        and waterdragon.mounted_player_data[player_name].fake_player:get_pos() then
        waterdragon.unset_fake_player(player)
        return
    end
    local player_pos = player:get_pos()
    local fake_player = minetest.add_entity(
        player_pos,
        "waterdragon:mounted_player_visual",
        minetest.serialize({ player = player_name })
    )
    -- Cache Player Data
    waterdragon.mounted_player_data[player_name] = {
        collision = table.copy(player:get_properties().collisionbox),
        textures = table.copy(player:get_properties().textures),
        visual_size = table.copy(player:get_properties().visual_size),
        mesh = player:get_properties().mesh,
        eye_offset_first = player:get_eye_offset().offset_first,
        eye_offset_third = player:get_eye_offset().offset_third,
        vertical = player:get_look_vertical(),
        horizontal = player:get_look_horizontal(),
        inventory = player:get_inventory():get_lists(),
        formspec = player:get_inventory_formspec(),
        hotbar = player:hud_get_hotbar_itemcount(),
        nametag = player:get_nametag_attributes(),
        wtd = self,
        fake_player = fake_player
    }
    -- Set Players Data
    player:set_properties({
        visual_size = { x = 0, y = 0, z = 0 },
        textures = {}
    })
    player:set_nametag_attributes({ text = " ", bgcolor = false })
    -- Attach Fake Player
    if passenger then
        fake_player:set_attach(self.object, "Torso.2", { x = 0, y = -0.3, z = 0.2 }, { x = 90, y = 0, z = 180 })
    else
        fake_player:set_attach(self.object, "Torso.2", { x = 0, y = 0.75, z = 0.2 }, { x = 90, y = 0, z = 180 })
    end
    fake_player:set_animation({ x = 81, y = 160 }, 30, 0)
    local player_size = fake_player:get_properties().visual_size
    local dragon_size = self.object:get_properties().visual_size
    fake_player:set_properties({
        visual_size = {
            x = player_size.x / dragon_size.x,
            y = player_size.y / dragon_size.y
        },
        mesh = waterdragon.mounted_player_data[player_name].mesh,
        pointable = false
    })
    player:set_properties({
        collisionbox = { 0, 0, 0, 0, 0, 0 }
    })
end

function waterdragon.unset_fake_player(player)
    if not player
        or not player:get_look_horizontal()
        or not player:is_player() then
        return
    end
    local player_name = player:get_player_name()
    if not waterdragon.mounted_player_data[player_name]
        or not waterdragon.mounted_player_data[player_name].fake_player
        or not waterdragon.mounted_player_data[player_name].fake_player:get_pos() then
        return
    end
    -- Cache Player Data
    local data = waterdragon.mounted_player_data[player_name]
    local fake_player = data.fake_player
    -- Set Players Data
    player:set_properties({
        collisionbox = data.collision,
        visual_size = data.visual_size,
        textures = data.textures
    })
    player:set_nametag_attributes(data.nametag)
    player:set_eye_offset(data.eye_offset_first, data.eye_offset_third)
    -- Unset Data
    waterdragon.mounted_player_data[player_name] = nil
    -- Remove Fake Player
    fake_player:remove()
end

----------------
-- Attachment --
----------------

local function set_hud(player, def)
    local hud = {
        hud_elem_type = "image",
        position = def.position,
        text = def.text,
        scale = { x = 3, y = 3 },
        alignment = { x = 1, y = -1 },
        offset = { x = 0, y = -5 }
    }
    return player:hud_add(hud)
end

function waterdragon.attach_player(self, player)
    if not self.object or not self.object:get_pos() then
        return
    end
    if not player
        or not player:get_look_horizontal()
        or not player:is_player() then
        return
    end
    
    local scale = self.growth_scale or 1
    -- Attach Player
    player:set_attach(self.object, "Torso.2", { x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
    -- Set Players Eye Offset
    player:set_eye_offset({
        x = 0,
        y = 115 * scale,        -- Set eye offset
        z = -280 * scale
    }, { x = 0, y = 0, z = 0 }) -- 3rd person eye offset is limited to 15 on each axis (Fix this, devs.)
    player:set_look_horizontal(self.object:get_yaw() or 0)
    -- Set Fake Player (Using a fake player and changing 1st person eye offset works around the above issue)
    waterdragon.set_fake_player(self, player)
    -- Set Water Dragon Data
    self.rider = player
    -- Set HUD
    if not self.attack_stamina then
        return
    end
    local data = waterdragon.mounted_player_data[player:get_player_name()] or {}

    if not data.huds then
        local health = self.hp / math.ceil(self.max_health * scale) * 100
        local hunger = self.hunger / math.ceil(self.max_hunger * scale) * 500
        local stamina = self.flight_stamina / 900 * 100
        local breath = self.attack_stamina / 100 * 100
        player:hud_set_flags({ wielditem = false })
        data.huds = {
            ["health"] = set_hud(player, {
                text = "waterdragon_forms_health_bg.png^[lowpart:" .. health .. ":waterdragon_forms_health_fg.png",
                position = { x = 0, y = 0.7 }
            }),
            ["hunger"] = set_hud(player, {
                text = "waterdragon_forms_hunger_bg.png^[lowpart:" .. hunger .. ":waterdragon_forms_hunger_fg.png",
                position = { x = 0, y = 0.8 }
            }),
            ["stamina"] = set_hud(player, {
                text = "waterdragon_forms_stamina_bg.png^[lowpart:" .. stamina .. ":waterdragon_forms_stamina_fg.png",
                position = { x = 0, y = 0.9 }
            }),
            ["breath"] = set_hud(player, {
                text = "waterdragon_forms_breath_bg.png^[lowpart:" .. breath .. ":waterdragon_forms_breath_fg.png",
                position = { x = 0, y = 1 }
            })
        }
    end
end

function waterdragon.attach_passenger(self, player)
    if not self.object or not self.object:get_pos() then
        return
    end
    if not player
        or not player:get_look_horizontal()
        or not player:is_player() then
        return
    end
    local scale = self.growth_scale
    -- Attach Player
    player:set_attach(self.object, "Torso.2", { x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
    -- Set players eye offset
    player:set_eye_offset({
        x = 0,
        y = 115 * scale,        -- Set eye offset
        z = -280 * scale
    }, { x = 0, y = 0, z = 0 }) -- 3rd person eye offset is limited to 15 on each axis (Fix this, devs.)
    player:set_look_horizontal(self.object:get_yaw() or 0)
    -- Set Fake Player (Using a fake player and changing 1st person eye offset works around the above issue)
    waterdragon.set_fake_player(self, player, true)
    -- Set Water Dragon Data
    self.passenger = player
    -- Set HUD
    local data = waterdragon.mounted_player_data[player:get_player_name()]
    if not data.huds then
        local health = self.hp / math.ceil(self.max_health * scale) * 100
        local hunger = self.hunger / math.ceil(self.max_hunger * scale) * 100
        local stamina = self.flight_stamina / 300 * 1
        local breath = self.attack_stamina / 150 * 1
        player:hud_set_flags({ wielditem = false })
        waterdragon.mounted_player_data[player:get_player_name()].huds = {
            ["health"] = set_hud(player, {
                text = "waterdragon_forms_health_bg.png^[lowpart:" .. health .. ":waterdragon_forms_health_fg.png",
                position = { x = 0, y = 0.7 }
            }),
            ["hunger"] = set_hud(player, {
                text = "waterdragon_forms_hunger_bg.png^[lowpart:" .. hunger .. ":waterdragon_forms_hunger_fg.png",
                position = { x = 0, y = 0.8 }
            }),
            ["stamina"] = set_hud(player, {
                text = "waterdragon_forms_stamina_bg.png^[lowpart:" .. stamina .. ":waterdragon_forms_stamina_fg.png",
                position = { x = 0, y = 0.9 }
            }),
            ["breath"] = set_hud(player, {
                text = "waterdragon_forms_breath_bg.png^[lowpart:" .. breath .. ":waterdragon_forms_breath_fg.png",
                position = { x = 0, y = 1 }
            })
        }
    end
end

local function cleanup_scottish_dragon_hud(player)
    local name = player:get_player_name()
    if not name then return end

    -- Check if player has HUD data
    if waterdragon.mounted_player_data[name] and
        waterdragon.mounted_player_data[name].huds then
        local hud_data = waterdragon.mounted_player_data[name].huds

        -- Remove all HUD elements
        player:hud_remove(hud_data["health"])
        player:hud_remove(hud_data["hunger"])
        player:hud_remove(hud_data["stamina"])
        player:hud_remove(hud_data["breath"])

        -- Clear HUD data
        waterdragon.mounted_player_data[name].huds = nil
    end

    -- Re-enable wielding
    player:hud_set_flags({ wielditem = true })
end

function waterdragon.detach_player(self, player)
    if not player
        or not player:get_look_horizontal()
        or not player:is_player() then
        return
    end
    local player_name = player:get_player_name()
    local data = waterdragon.mounted_player_data[player_name]
    -- Detach Player
    player:set_detach()
    -- Set HUD
    if self.attack_stamina then
        player:hud_remove(data.huds["health"])
        player:hud_remove(data.huds["hunger"])
        player:hud_remove(data.huds["stamina"])
        player:hud_remove(data.huds["breath"])
    end
    cleanup_scottish_dragon_hud(player)
    player:hud_set_flags({ wielditem = true })
    -- Set Fake Player (Using a fake player and changing 1st person eye offset works around the above issue)
    waterdragon.unset_fake_player(player)
    -- Set Water Dragon data
    if player == self.rider then
        self.rider = nil
    else
        self.passenger = nil
    end
end

local requesting_passenger = {}

local function passenger_form(player)
    local name = player:get_player_name()
    local formspec = {
        "size[6,3.476]",
        "real_coordinates[true]",
        "label[0.25,1;" .. name .. " would like to ride as a passenger]",
		"button_exit[0.25,1.3;2.3,0.8;btn_accept_pssngr;Accept]",
        "button_exit[3.5,1.3;2.3,0.8;btn_decline_pssngr;Decline]",
    }
    return table.concat(formspec, "")
end

function waterdragon.send_passenger_request(self, clicker)
    if not self.rider
        or not self.rider:get_look_horizontal()
        or not clicker:get_look_horizontal() then
        return
    end
    local rider = self.rider
    minetest.show_formspec(rider:get_player_name(), "waterdragon:passenger_request", passenger_form(clicker))
    requesting_passenger[rider:get_player_name()] = {
        player = clicker,
        entity = self
    }
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "waterdragon:passenger_request" then
        if not requesting_passenger[name] then
            return
        end
        local pssngr = requesting_passenger[name].player
        local ent = requesting_passenger[name].entity
        if fields.btn_accept_pssngr
            and pssngr
            and pssngr:get_look_horizontal() then
            waterdragon.attach_passenger(ent, pssngr)
            requesting_passenger[name] = nil
            return false
        end
        if fields.btn_decline_pssngr
            or fields.quit
            or fields.key_enter then
            requesting_passenger[name] = nil
        end
    end
end)

--------------
-- Settings --
--------------

local function menu_form()
    local formspec = {
        "size[6,3.476]",
        "real_coordinates[true]",
        "button[0.25,1.3;2.3,0.8;btn_view_point;View Point]",
        "button[3.5,1.3;2.3,0.8;btn_pitch_toggle;Pitch Flight]",
    }
    return table.concat(formspec, "")
end

minetest.register_chatcommand("wtd_mount_settings", {
    privs = {
        interact = true,
    },
    func = function(name)
        minetest.show_formspec(name, "waterdragon:water_dragon_mount_settings", menu_form())
    end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "waterdragon:water_dragon_mount_settings" then
        if fields.btn_view_point then
            waterdragon.aux_key_setting[name] = "pov"
            minetest.chat_send_player(name, S("Sprint key now changes point of view"))
        end
        if fields.btn_pitch_toggle then
            waterdragon.aux_key_setting[name] = "vert_method"
            minetest.chat_send_player(name, S("Sprint key now changes vertical movement method"))
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if not waterdragon.aux_key_setting[name] then
        waterdragon.aux_key_setting[name] = "pov"
    end
end)

minetest.register_on_dieplayer(function(player)
    local name = player:get_player_name()
    if name
        and waterdragon.mounted_player_data[name] then
        waterdragon.detach_player(waterdragon.mounted_player_data[name].wtd, player)
    end
end)

-------------------
-- Data Handling --
-------------------


minetest.register_on_leaveplayer(function(player)
    waterdragon.unset_fake_player(player)
end)

local function update_scottish_dragon_hud(self, player)
    local name = player:get_player_name()
    if not name then return end

    -- Get Stats without scaling
    local health = self.hp / self.max_health * 100
    local hunger = self.hunger / self.max_hunger * 100
    local stamina = self.flight_stamina / 1600 * 100 -- Scottish Dragon has 1600 flight stamina
    local fire = (self.fire or 0) / 10 * 100         -- Calculate fire percentage from 10 max charges

    -- Initialize HUD data if it doesn't exist
    if not waterdragon.mounted_player_data[name] then
        waterdragon.mounted_player_data[name] = {}
    end

    -- Remove old HUD elements if they exist
    if waterdragon.mounted_player_data[name].huds then
        local hud_data = waterdragon.mounted_player_data[name].huds
        player:hud_remove(hud_data["health"])
        player:hud_remove(hud_data["hunger"])
        player:hud_remove(hud_data["stamina"])
        player:hud_remove(hud_data["breath"])
    end

    -- Create new HUD elements
    waterdragon.mounted_player_data[name].huds = {
        ["health"] = set_hud(player, {
            text = "waterdragon_forms_health_bg.png^[lowpart:" .. health .. ":waterdragon_forms_health_fg.png",
            position = { x = 0, y = 0.7 }
        }),
        ["hunger"] = set_hud(player, {
            text = "waterdragon_forms_hunger_bg.png^[lowpart:" .. hunger .. ":waterdragon_forms_hunger_fg.png",
            position = { x = 0, y = 0.8 }
        }),
        ["stamina"] = set_hud(player, {
            text = "waterdragon_forms_stamina_bg.png^[lowpart:" .. stamina .. ":waterdragon_forms_stamina_fg.png",
            position = { x = 0, y = 0.9 }
        }),
        ["breath"] = set_hud(player, {
            text = "waterdragon_forms_breath_bg.png^[lowpart:" .. fire .. ":waterdragon_forms_breath_fg.png",
            position = { x = 0, y = 1 }
        })
    }
end

local function update_hud(self, player)
    local name = player:get_player_name()
    if not name then return end
    -- Get Stats
    local scale = self.growth_scale
    local health = self.hp / ceil(self.max_health * scale) * 100
    local hunger = self.hunger / ceil(self.max_hunger * scale) * 100
    local stamina = self.flight_stamina / 900 * 100
    local breath = self.attack_stamina / 100 * 100
    local hud_data = waterdragon.mounted_player_data[name].huds
    -- Update Elements
    player:hud_remove(hud_data["health"])
    player:hud_remove(hud_data["hunger"])
    player:hud_remove(hud_data["stamina"])
    player:hud_remove(hud_data["breath"])
    waterdragon.mounted_player_data[name].huds = {
        ["health"] = set_hud(player, {
            text = "waterdragon_forms_health_bg.png^[lowpart:" .. health .. ":waterdragon_forms_health_fg.png",
            position = { x = 0, y = 0.7 }
        }),
        ["hunger"] = set_hud(player, {
            text = "waterdragon_forms_hunger_bg.png^[lowpart:" .. hunger .. ":waterdragon_forms_hunger_fg.png",
            position = { x = 0, y = 0.8 }
        }),
        ["stamina"] = set_hud(player, {
            text = "waterdragon_forms_stamina_bg.png^[lowpart:" .. stamina .. ":waterdragon_forms_stamina_fg.png",
            position = { x = 0, y = 0.9 }
        }),
        ["breath"] = set_hud(player, {
            text = "waterdragon_forms_breath_bg.png^[lowpart:" .. breath .. ":waterdragon_forms_breath_fg.png",
            position = { x = 0, y = 1 }
        })
    }
end

--------------
-- Behavior --
--------------

local autopilot_active = {}

minetest.register_chatcommand("autopilot", {
    description = "Toggle autopilot mode for your Water Dragon",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, S("Player not found") end

        local dragon
        for _, obj in pairs(minetest.get_objects_inside_radius(player:get_pos(), 10)) do
            local ent = obj:get_luaentity()
            if ent and ent.name:match("^waterdragon") then
                if ent.owner == name and ent.rider and ent.rider:get_player_name() == name then
                    dragon = ent
                    break
                end
            end
        end

        if not dragon then
            return false, "No owned and ridden Water Dragon found nearby"
        end

        autopilot_active[name] = not autopilot_active[name]
        local status = autopilot_active[name] and "activated" or "deactivated"
        return true, "Autopilot " .. status .. " for your Water Dragon"
    end
})

waterdragon.register_utility("waterdragon:mount", function(self)
    local is_landed = waterdragon.sensor_floor(self, 5, true) < 4
    local view_held = false
    local view_point = 3
    local first_person_height = 45
    local is_landing = false
    local is_wall_clinging = false

    self:halt()

    local pos = self.object:get_pos()
    local is_air_below = true

    for i = 1, 8 do
        local check_pos = { x = pos.x, y = pos.y - i, z = pos.z }
        local node = minetest.get_node(check_pos)
        if node.name ~= "air" then
            is_air_below = false
            break
        end
    end

    local velocity = self.object:get_velocity()
    if is_air_below and velocity and velocity.y < 0 and self._anim == "walk" or self._anim == "stand" or self._anim == "walk_water" or self._anim == "stand_water" then
        waterdragon.action_takeoff(self, 2)
        is_landed = false
        self.is_flying = true
    end
    local func = function(_self)
        local player = _self.rider
        if not player or not player:get_pos() then return true end
        local pssngr = _self.passenger

        local player_name = player:get_player_name()
        local control = player:get_player_control()

        local look_dir = player:get_look_dir()
        local look_yaw = minetest.dir_to_yaw(look_dir)

        local scale = _self.growth_scale
        local player_data = waterdragon.mounted_player_data[player_name]

        if not player_data then return true end

        update_hud(self, player)

        local player_props = player:get_properties()

        if player_props.visual_size.x ~= 0 then
            player:set_properties({
                visual_size = { x = 0, y = 0, z = 0 },
            })
        end

        if autopilot_active[player_name] then
            if _self.flight_stamina < 100 then
                autopilot_active[player_name] = false
                anim = "fly"
                _self:set_vertical_velocity(-20)
                minetest.chat_send_player(player_name, S("The Water Dragon is tired and needs to land"))
                if _self.touching_ground then
                    waterdragon.action_land(_self)
                    is_landed = true
                end
            end
            local target = _self._target
            if target and target:get_pos() then
                local target_pos = target:get_pos()
                local self_pos = _self.object:get_pos()
                local dir = vector.direction(self_pos, target_pos)
                local distance = vector.distance(self_pos, target_pos)
                if distance > 5 then
                    _self:set_forward_velocity(24)
                    _self:tilt_to(minetest.dir_to_yaw(dir), 2)
                    _self:animate("fly")
                else
                    _self:initiate_utlilty("waterdragon:attack", target)
                end
            else
                if _self.touching_ground then
                    waterdragon.action_land(_self)
                    waterdragon.action_move(_self, vector.add(_self.object:get_pos(), vector.multiply(look_dir, 50)), 5,
                        "waterdragon:obstacle_avoidance", 1)
                else
                    waterdragon.action_fly(_self, vector.add(_self.object:get_pos(), vector.multiply(look_dir, 50)), 5,
                        "waterdragon:fly_simple", 0.5)
                end
            end
            return
        end

        if not _self:get_action() then
            if control.aux1 then
                if waterdragon.aux_key_setting[player_name] == "pov" then
                    if not view_held then
                        if view_point == 3 then
                            view_point = 1
                            player_data.fake_player:set_properties({
                                visual_size = { x = 0, y = 0, z = 0 },
                            })
                            player:set_eye_offset({
                                x = 0,
                                y = 450 * scale,
                                z = 20 * scale
                            }, { x = 0, y = 0, z = 0 })
                            player:hud_set_flags({ wielditem = false })
                        elseif view_point == 1 then
                            view_point = 2
                            local dragon_size = _self.object:get_properties().visual_size
                            player_data.fake_player:set_properties({
                                visual_size = {
                                    x = 1 / dragon_size.x,
                                    y = 1 / dragon_size.y
                                }
                            })
                            player:set_eye_offset({
                                x = 115 * scale,
                                y = 170 * scale,
                                z = -290 * scale
                            }, { x = 0, y = 0, z = 0 })
                            player:hud_set_flags({ wielditem = false })
                        elseif view_point == 2 then
                            view_point = 3
                            local dragon_size = _self.object:get_properties().visual_size
                            player_data.fake_player:set_properties({
                                visual_size = {
                                    x = 1 / dragon_size.x,
                                    y = 1 / dragon_size.y
                                }
                            })
                            player:set_eye_offset({
                                x = 0,
                                y = 115 * scale,
                                z = -280 * scale
                            }, { x = 0, y = 0, z = 0 })
                            player:hud_set_flags({ wielditem = false })
                        end
                        view_held = true
                    end
                else
                    view_held = true
                    if _self.pitch_fly then
                        _self.pitch_fly = _self:memorize("pitch_fly", false)
                    else
                        _self.pitch_fly = _self:memorize("pitch_fly", true)
                    end
                end
            else
                view_held = false
            end

            local anim

            if is_landed then
                _self:set_gravity(-9.8)
                anim = "stand"
                if _self.flight_stamina <= 50 and not is_landed then
                    local rider_name = _self.rider:get_player_name()
                    if rider_name then
                        minetest.chat_send_player(rider_name, S("The Water Dragon is tired and needs to rest"))
                    end
                    if not _self.touching_ground then
                        _self:set_vertical_velocity(-20)
                        anim = "fly"
                        if _self.touching_ground then
                            waterdragon.action_land(_self)
                            anim = "stand"
                            _self:set_vertical_velocity(0)
                            _self:set_forward_velocity(0)
                            is_landed = true
                        end
                        if _self.flight_stamina >= 100 then
                            waterdragon.action_takeoff(_self, 1)
                            is_landed = false
                            return
                        end
                    end
                end
                local pos = _self.object:get_pos()
                if pos then
                    local yaw = _self.object:get_yaw()
                    local dir = minetest.yaw_to_dir(yaw)

                    _self.target_yaw = _self.target_yaw or yaw

                    if control.up then
                        local front_pos = {
                            x = pos.x + (dir.x * 16),
                            y = pos.y + 6,
                            z = pos.z
                        }
                        local minp = { x = front_pos.x - 1, y = front_pos.y, z = front_pos.z - 1 }
                        local maxp = { x = front_pos.x + 1, y = front_pos.y + 2, z = front_pos.z + 1 }
                        local has_wall = false

                        for x = minp.x, maxp.x do
                            for y = minp.y, maxp.y do
                                for z = minp.z, maxp.z do
                                    local check_pos = { x = x, y = y, z = z }
                                    local node = minetest.get_node(check_pos)
                                    local nodedef = minetest.registered_nodes[node.name]

                                    if nodedef and nodedef.walkable then
                                        has_wall = true
                                        break
                                    end
                                end
                                if has_wall then break end
                            end
                            if has_wall then break end
                        end

                        if not has_wall then
                            _self:set_forward_velocity(12)
                            _self:turn_to(look_yaw, 4)
                            anim = "walk"
                            _self.target_yaw = yaw
                        else
                            _self:set_forward_velocity(0)
                            anim = "stand"
                        end
                    elseif control.left or control.right then
                        if not _self.is_side_walking then
                            _self.target_yaw = yaw + (control.left and math.pi / 2 or -math.pi / 2)
                            _self.is_side_walking = true
                        end

                        local diff = math.abs(_self.target_yaw - yaw)
                        if diff > 0.1 then
                            _self:turn_to(_self.target_yaw, 4)
                        end
                        _self:set_forward_velocity(12)
                        anim = "walk"
                    else
                        _self.is_side_walking = false
                        _self.target_yaw = yaw
                    end
                end

                if control.jump then
                    is_landed = false
                    waterdragon.action_takeoff(_self)
                    _self.is_side_walking = false
                    _self.target_yaw = nil
                end
                if control.RMB then
                    waterdragon.action_slam(_self)
                end
                if control.RMB and control.down then
                    waterdragon.action_repel(_self)
                end
            elseif is_landing then
                anim = "fly_to_land"
            else
                _self:set_gravity(0)
                anim = "hover"
                

                if control.up and _self.moveresult and _self.moveresult.collisions and not control.down and not control.LMB then
                    for _, collision in ipairs(_self.moveresult.collisions) do
                        if collision.type == "node" then
                            local node = minetest.get_node(collision.node_pos)
                            if minetest.registered_nodes[node.name].walkable then
                                is_wall_clinging = true
                                _self:set_weighted_velocity(0, look_dir)
                                break
                            end
                        end
                    end
                end




                if is_wall_clinging then
                    local yaw = _self.object:get_yaw()
                    local dir = minetest.yaw_to_dir(yaw)
                    local pos = _self.object:get_pos()
                    local front_pos = {
                        x = pos.x + (dir.x * 2.5), -- уменьшил множитель с 4 до 2.5
                        y = pos.y + 11.9,
                        z = pos.z + (dir.z * 5.5)  -- уменьшил множитель с 5.5 до 4
                    }

                    local node_front = minetest.get_node(front_pos)
                    if minetest.get_item_group(node_front.name, "ice") > 0 or
                        minetest.get_item_group(node_front.name, "wood") > 0 or
                        minetest.get_item_group(node_front.name, "cracky") == 3 then
                        -- Скользит на блоках из групп ice, wood и cracky = 3
                        _self:set_vertical_velocity(-2)
                        anim = "shoulder_idle"
                    else
                        -- Висит на остальных блоках
                        _self:set_vertical_velocity(0)
                        anim = "shoulder_idle"
                    end

                    _self:set_forward_velocity(0)
                    local last_sound_time = 0
                    local sound_cooldown = 1 -- Интервал между воспроизведением звуков, в секундах
                    local wall_slide_sound
                    local is_playing_sound = false
                    if not is_playing_sound and (minetest.get_gametime() - last_sound_time) >= sound_cooldown then
                        wall_slide_sound = minetest.sound_play("waterdragon_wall_slide", { gain = 1 })
                        is_playing_sound = true
                        last_sound_time = minetest.get_gametime()
                    end

                    if not (minetest.get_item_group(node_front.name, "ice") > 0 or
                            minetest.get_item_group(node_front.name, "wood") > 0 or
                            minetest.get_item_group(node_front.name, "stone") > 0 or
                            minetest.get_item_group(node_front.name, "cracky") == 3) then
                        if wall_slide_sound then
                            minetest.sound_stop(wall_slide_sound)
                        end
                        is_playing_sound = false
                    end

                    if node_front.name == "default:cobble" or node_front.name == "default:stone" or node_front.name == "default:diamondblock" then
                        minetest.sound_stop(wall_slide_sound)
                        is_playing_sound = false
                        _self:set_vertical_velocity(0)
                        _self:set_forward_velocity(0)
                    end

                    if control.jump then
                        is_wall_clinging = false
                        _self:set_vertical_velocity(12)
                        _self:set_weighted_velocity(-12, look_dir)
                    end
                else
                    anim = "hover"
                    if _self.flight_stamina < 100 then
                        autopilot_active[player_name] = false
                        anim = "fly"
                        _self:set_vertical_velocity(-10)
                        minetest.chat_send_player(player_name, S("the Water Dragon is tired and needs to land"))
                        if _self.touching_ground then
                            waterdragon.action_land(_self)
                            is_landed = true
                        end
                    else
                        if control.up then
                            anim = "fly"
                            if _self.pitch_fly then
                                _self:set_vertical_velocity(12 * look_dir.y)
                            end
                            _self:set_forward_velocity(24)
                        else
                            _self:set_vertical_velocity(0)
                            _self:set_forward_velocity(0)
                        end
                        _self:tilt_to(look_yaw, 2)
                        if not _self.pitch_fly then
                            if control.jump then
                                _self:set_vertical_velocity(12)
                            elseif control.down then
                                _self:set_vertical_velocity(-12)
                            else
                                _self:set_vertical_velocity(0)
                            end
                        end

                        if not is_landed and _self.touching_ground and not control.jump then
                            is_landed = true
                            _self:set_gravity(-9.8)
                            _self:set_vertical_velocity(0)
                            _self:set_forward_velocity(0)
                            waterdragon.action_land(_self)
                            return
                        end
                    end
                end
            end

            if control.LMB then
                local start = _self.object:get_pos()
                local offset = player:get_eye_offset()
                local eye_correction = vector.multiply({ x = look_dir.x, y = 0, z = look_dir.z }, offset.z * 0.125)
                start = vector.add(start, eye_correction)
                start.y = start.y + (offset.y * 0.125)
                local tpos = vector.add(start, vector.multiply(look_dir, 64))
                local head_dir = vector.direction(start, tpos)
                look_dir.y = head_dir.y
                _self:breath_attack(tpos)
                anim = anim .. "_water"
            end

            if anim then
                _self:animate(anim)
                if view_point == 1 then
                    if anim:match("idle") or (anim:match("fly") and control.jump) then
                        first_person_height = first_person_height + (65 - first_person_height) * 0.2
                    else
                        first_person_height = first_person_height + (45 - first_person_height) * 0.2
                    end
                    player:set_eye_offset({
                        x = 0,
                        y = 125 * scale,
                        z = 30 * scale
                    }, { x = 0, y = 0, z = 0 })
                end
            end
        end

        _self:move_head(look_yaw, look_dir.y)

        if control.sneak or player:get_player_name() ~= _self.owner then
            waterdragon.detach_player(_self, player)
            if pssngr then
                waterdragon.detach_player(_self, _self.passenger)
            end
            return true
        end
        if pssngr and pssngr:get_player_control().sneak then
            waterdragon.detach_player(_self, pssngr)
        end
    end
    self:set_utility(func)
end)

waterdragon.register_utility("waterdragon:scottish_dragon_mount", function(self)
    if self.owner then
        local player = minetest.get_player_by_name(self.owner)
        if player then
            local inv = minetest.get_inventory({ type = "player", name = player:get_player_name() })
            if waterdragon.contains_book(inv) then
                waterdragon.add_page(inv, "mounting")
                waterdragon.add_page(inv, "scottish_dragons")
            end
        end
    end
    local is_landed = waterdragon.sensor_floor(self, 5, true) < 4
    local view_held = false
    local view_point = 2
    local momentum = 0
    local attack_cooldown = 0
    self:halt()
    local func = function(_self)
        local player = _self.rider
        if not player
            or not player:get_look_horizontal() then
            return true
        end
        update_scottish_dragon_hud(self, player)
        local player_name = player:get_player_name()
        local control = player:get_player_control()

        local look_dir = player:get_look_dir()
        local look_yaw = minetest.dir_to_yaw(look_dir)

        local player_data = waterdragon.mounted_player_data[player_name]

        if not player_data then return true end

        local player_props = player:get_properties()

        if player_props.visual_size.x ~= 0 then
            player:set_properties({
                visual_size = { x = 0, y = 0, z = 0 },
            })
        end
        local pos = self.object:get_pos()
        local is_air_below = true

        for i = 1, 8 do
            local check_pos = { x = pos.x, y = pos.y - i, z = pos.z }
            local node = minetest.get_node(check_pos)
            if node.name ~= "air" then
                is_air_below = false
                break
            end
        end

        local velocity = self.object:get_velocity()
        if is_air_below and velocity and velocity.y < 0 and (self._anim == "walk" or self._anim == "stand" or self._anim == "bite") then
            waterdragon.action_takeoff(self, 2)
            is_landed = false
            self.is_flying = true
        end


        local yaw = self.object:get_yaw()
        self:move_head(yaw)
        if control.aux1 then
            if not view_held then
                if view_point == 2 then
                    view_point = 1
                    player_data.fake_player:set_properties({
                        visual_size = { x = 0, y = 0, z = 0 },
                    })
                    player:hud_set_flags({ wielditem = false })
                elseif view_point == 1 then
                    view_point = 2
                    local dragon_size = _self.object:get_properties().visual_size
                    player_data.fake_player:set_properties({
                        visual_size = {
                            x = 1 / dragon_size.x,
                            y = 1 / dragon_size.y
                        }
                    })
                    player:hud_set_flags({ wielditem = false })
                end
                view_held = true
            end
        else
            view_held = false
        end

        if not _self:get_action() then
            local anim

            if is_landed then
                _self:set_gravity(-9.8)
                anim = "stand"
                if control.up then
                    _self:set_forward_velocity(12)
                    _self:turn_to(look_yaw, 4)
                    anim = "walk"
                end
                if control.jump then
                    is_landed = false
                    waterdragon.action_takeoff(_self)
                end
                if control.LMB then
                    waterdragon.action_punch(_self)
                end
            else
                _self:set_gravity(0)
                anim = "hover"
                if control.up then
                    anim = "fly"
                    _self:set_weighted_velocity(32, look_dir)
                    if look_dir.y < -0.33 then
                        if momentum < 28 then
                            momentum = momentum + (_self.dtime * 20) * abs(look_dir.y)
                        end
                    elseif momentum > 0 then
                        momentum = momentum - _self.dtime * 15
                        if momentum < 0 then momentum = 0 end
                    end
                else
                    _self:set_vertical_velocity(0)
                    _self:set_forward_velocity(0)
                end
                _self:tilt_to(look_yaw, 4)
                if _self.touching_ground and not control.jump then
                    is_landed = true
                    waterdragon.action_land(_self)
                end

                if control.LMB and attack_cooldown <= 0 then
                    local start_pos = _self.object:get_pos()
                    start_pos.y = start_pos.y + 1.5
                    local end_pos = vector.add(start_pos, vector.multiply(look_dir, 5))

                    local pos = _self.object:get_pos()
                    if pos then
                        minetest.sound_play("waterdragon_scottish_dragon_bite", {
                            pos = pos,
                            max_hear_distance = 10,
                            gain = 1.0,
                        }, true)
                    end

                    anim = "fly_punch"
                    attack_cooldown = 0.4
                    local ray = minetest.raycast(start_pos, end_pos, true, false)
                    for pointed_thing in ray do
                        if pointed_thing.type == "object" then
                            local obj = pointed_thing.ref
                            if obj ~= player and obj ~= _self.object then
                                _self:punch_target(obj)
                                break
                            end
                        end
                    end
                end
            end

            if anim == "fly"
                and momentum > 0 then
                _self:set_weighted_velocity(32 + momentum, look_dir)
                anim = "dive"
            end

            if anim then
                _self:animate(anim)
            end
        end

        attack_cooldown = math.max(0, attack_cooldown - _self.dtime)
        if control.right and minetest.get_modpath("pegasus") then
            _self.fire_breathing = true
            breathe_pegasus_fire(_self)
        elseif not control.right then
            _self.fire_breathing = false
        end
        if view_point == 2 then
            local goal_y = 0 - 60 * look_dir.y
            local goal_z = -140 + 60 * abs(look_dir.y)
            if _self._anim == "dive" then
                local accel_offset = 60 + momentum
                goal_y = 40 - accel_offset * look_dir.y
                goal_z = -160 + accel_offset * abs(look_dir.y)
            end
            local offset = player:get_eye_offset()
            if abs(goal_y - offset.y) > 0.1
                or abs(goal_z - offset.z) > 0.1 then
                local lerp_w = _self.dtime * 2
                player:set_eye_offset({
                        x = 0,
                        y = offset.y + (goal_y - offset.y) * lerp_w,
                        z = offset.z + (goal_z - offset.z) * lerp_w
                    },
                    { x = 0, y = 0, z = 0 })
            end
        else
            local goal_y = 25
            local goal_z = 10
            if _self._anim == "fly" then
                goal_y = goal_y + 15 * look_dir.y
                goal_z = goal_z - 20 * look_dir.y
            elseif _self._anim == "dive" then
                local accel_offset = momentum * 0.5
                goal_y = goal_y + accel_offset * look_dir.y
                goal_z = goal_z - accel_offset * look_dir.y
            end
            local offset = player:get_eye_offset()
            if abs(goal_y - offset.y) > 0.1
                or abs(goal_z - offset.z) > 0.1 then
                local lerp_w = _self.dtime * 4
                player:set_eye_offset({
                        x = 0,
                        y = offset.y + (goal_y - offset.y) * lerp_w,
                        z = offset.z + (goal_z - offset.z) * lerp_w
                    },
                    { x = 0, y = 0, z = 0 })
            end
        end
        if control.jump and control.left and self.has_pegasus_fire and self.fire >= 3 then
            local pos = self.object:get_pos()
            if pos then
                pos.y = pos.y + 2
                local direction = vector.normalize(look_dir)
                launch_fire_sphere(pos, direction)
                self.fire = self.fire - 3 -- Consume 3 fire charges
                self:memorize("fire", self.fire)

                -- Add visual/sound feedback
                minetest.sound_play("waterdragon_fireball", {
                    pos = pos,
                    gain = 1.0,
                    max_hear_distance = 20,
                    loop = false
                })
            end
        end
        if control.sneak or _self.hp == 0
            or player:get_player_name() ~= _self.owner then
            waterdragon.detach_player(_self, player)
            return true
        end
    end
    self:set_utility(func)
end)

-- Define the fire node

minetest.register_node("waterdragon:fire_animated", {
    description = S("Scottish Dragon Fire"),
    drawtype = "firelike",
    tiles = {
        {
            name = "waterdragon_fire_animated.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 1
            },
        },
    },
    inventory_image = "waterdragon_fire_1.png",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    floodable = true,
    damage_per_second = 4,
    groups = { igniter = 2, not_in_creative_inventory = 1 },
    drop = "",
    on_timer = function(pos, elapsed)
        -- Check for entities and damage them
        local objects = minetest.get_objects_inside_radius(pos, 1.5)
        for _, obj in ipairs(objects) do
            local ent = obj:get_luaentity()
            if obj:is_player() or (ent and ent.name ~= "waterdragon:scottish_dragon" and ent.name ~= "pegasus:pegasus" and ent.name ~= "waterdragon:rare_water_dragon" and ent.name ~= "waterdragon:pure_water_dragon") then
                obj:punch(obj, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = { fleshy = 4 },
                }, vector.new(0, 0, 0))
            end
        end

        -- Remove the fire after some time
        if math.random(1, 5) == 1 then -- 20% chance to remove each tick
            minetest.remove_node(pos)
            return false
        end
        return true
    end,
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(0.5) -- Check every 0.5 seconds
    end,
    on_flood = function(pos, oldnode, newnode)
        minetest.remove_node(pos)
        return false
    end,
})
