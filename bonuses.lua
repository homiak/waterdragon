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

function apply_name_bonuses(self)
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