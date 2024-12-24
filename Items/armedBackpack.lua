local sprite_item = Resources.sprite_load(NAMESPACE, "ArmedBackpack", path.combine(PATH, "Sprites/Items/armedBackpack.png"), 1, 16, 16)
local sprite_sparks1 = Resources.sprite_load(NAMESPACE, "ArmedBackpackSpark1", path.combine(PATH, "Sprites/Items/Effects/armedBackpack1.png"), 3, 0, 10)
local sprite_sparks2 = Resources.sprite_load(NAMESPACE, "ArmedBackpackSpark2", path.combine(PATH, "Sprites/Items/Effects/armedBackpack2.png"), 4, 16, 16)

local sound = Resources.sfx_load(NAMESPACE, "ArmedBackpack", path.combine(PATH, "Sounds/Items/armedBackpack.ogg"))

local tracer, tracer_info = CustomTracer.new(function(x1, y1, x2, y2)
	local offset = -7 + math.random() * 3
	y1 = y1 + offset
	y2 = y2 + offset

	local tr = gm.instance_create(x1, y1, gm.constants.oEfLineTracer)
	tr.xend = x2
	tr.yend = y2
	tr.sprite_index = gm.constants.sPilotShoo1BTracer
	tr.image_speed = 2
	tr.rate = 0.125
	tr.bm = 1 -- additive
	tr.image_blend = Color.from_rgb(170, 78, 66)

	local ef = gm.instance_create(x1, y1, gm.constants.oEfSparks)
	ef.sprite_index = sprite_sparks1
	ef.image_angle = gm.point_direction(x1, y1, x2, y2)
	ef.image_speed = 0.4
end)
tracer_info.sparks_offset_y = -5

local armedBackpack = Item.new(NAMESPACE, "armedBackpack")
armedBackpack:set_sprite(sprite_item)
armedBackpack:set_tier(Item.TIER.common)
armedBackpack:set_loot_tags(Item.LOOT_TAG.category_damage)

armedBackpack:clear_callbacks()
armedBackpack:onAttackCreateProc(function(actor, stack, attack_info)
	if math.random() <= 0.12 + (0.065 * stack) then
		local dir = actor:skill_util_facing_direction() + 180

		-- infer the direction from the attack direction if its horizontal enough
		-- this improves many cases like huntress autoaim, suppressive fire, engi turrets, etc.
		-- though it also has issues in other cases, hm.
		local attack_xvector = gm.lengthdir_x(1, attack_info.direction)
		if attack_xvector > 0.5 then
			dir = 180
		elseif attack_xvector < -0.5 then
			dir = 0
		end

		local attack = actor:fire_bullet(actor.x - gm.sign(attack_xvector) * 5, actor.y, 500, dir, 1.5, nil, sprite_sparks2, tracer, false)
		actor:sound_play_networked(sound, 0.8, 1 + math.random() * 0.2, actor.x, actor.y)
	end
end)
