local proto = {}

proto.gate_proto = {}
proto.gate_proto.client2server = [[
.package {
	type 0 : integer
	session 1 : integer
}

.server {
	id 0 : integer
	ip 1 : string
	port 2 : integer
	name 3 : string
}

get_servers 1 {
	request {
		name 0 : string
		password 1 : string
	}
	response {
		servers 0 : *server(id)
		auto_select 1 : integer
		user_id 2 : integer
	}
}

]]

proto.gate_proto.server2client = [[
.package {
	type 0 : integer
	session 1 : integer
}
]]


proto.game_proto = {}
proto.game_proto.client2server = [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {
	request {}
	response {}
}

.player_outline {
	id 0 : integer
	user_id 1 : integer
	server_id 2 : integer
	name 3 : string
}

get_player 2 {
	request {
		name 0 : string
		password 1 : string
	}
	response {
		player 0 : player_outline
	}
}

create_player 3 {
	request {
		name 0 : string
		carrer 1 : integer
	}
	response {
		error 0 : string
	}
}

.player {
	entity_id 0 : integer
	carrer 1 : integer
	name 2 : string
	level 3 : integer
	experience 4 : integer
	max_hp 5 : integer
	max_mp 6 : integer
	hp 7 : integer
	mp 8 : integer
	x 9 : integer(2)
	y 10 : integer(2)
	move_speed 11 : integer(2)
}

.monster {
	entity_id 0 : integer
	monster_id 1 : integer
	name 2 : string
	level 3 : integer
	max_hp 4 : integer
	max_mp 5 : integer
	x 6 : integer(2)
	y 7 : integer(2)
}

.npc {
	entity_id 0 : integer
	npc_id 1 : integer
	name 2 : string
	x 3 : integer
	y 4 : integer
}

.map {
	width 0 : integer
	height 1 : integer
	cs_scale 2 : integer(2)
}

enter_scene 4 {
	request {}
	response {
		scene_id 0 : integer
		map 1 : map
		player 2 : player
		monsters 3 : *monster
		npcs 4 : *npc
	}
}

.vector2 {
	x 0 : integer
	y 1 : integer
}

move 5 {
	request {
		x 0 : integer
		y 1 : integer
	}
	response {
		path 0 : *vector2
	}
}

.combat_unit {
	unit_id 0 : integer
	pos_index 1 : integer
	team 2 : integer
	kind_id 3 : integer
	unit_type 4 : integer
}

combat_enter_room 6 {
	request {
		monster_id 0 : integer
	}
	response {
		unit_list 0 : *combat_unit
	}
}

combat_client_ready 7 {
	request {}
	response {}
}

combat_client_timeout 8 {
	request {}
	response {}
}

combat_skill_cast 9 {
	request {
		skill_index 0 : integer
		target_id 1 : integer
	}
	response {}
}

combat_client_play_end 10 {
	request {}
	response {}
}

.mail {
	mail_id 0 : integer
	sender 1 : string
	validity_time 2 : string
	title 3 : string
	message 4 : string
	item1_id 5 : integer
	item1_num 6 : integer
}

mail 11 {
	request {}
	response {
		mail_list 0 : *mail
	}
}

mail_read 12 {
	request {
		mail_id 0 : integer
	}
	response {}
}

mail_receive 13 {
	request {
		mail_id 0 : integer
	}
	response {}
}

mail_delete 14 {
	request {
		mail_id 0 : integer
	}
	response {}
}

.item {
	item_id 0 : integer
	type 1 : integer
	sub_type 2 : integer
	quality 3 : integer
	value 4 : integer
}

bag 15 {
	request {}
	response {
		max_number 0 : integer
		unlock_number 1 : integer
		items 2 : *item
	}
}

]]

proto.game_proto.server2client = [[
.package {
	type 0 : integer
	session 1 : integer
}

server_stop 1 {
	request {}
	response {}
}

.player {
	entity_id 0 : integer
	carrer 1 : integer
	name 2 : string
	level 3 : integer
	experience 4 : integer
	max_hp 5 : integer
	max_mp 6 : integer
	hp 7 : integer
	mp 8 : integer
	x 9 : integer(2)
	y 10 : integer(2)
}

.monster {
	entity_id 0 : integer
	monster_id 1 : integer
	name 2 : string
	level 3 : integer
	max_hp 4 : integer
	max_mp 5 : integer
	x 6 : integer(2)
	y 7 : integer(2)
}

.npc {
	entity_id 0 : integer
	npc_id 1 : integer
	name 2 : string
	x 3 : integer
	y 4 : integer
}

entity_enter_aoi 2 {
	request {
		monsters 0 : *monster
		npcs 1 : *npc
		players 2 : *player
	}
	response {}
}

entity_leave_aoi 3 {
	request {
		monsters 0 : *monster
		npcs 1 : *npc
		players 2 : *player
	}
	response {}
}

move 4 {
	request {
		entity_id 0 : integer
		x 1 : integer
		y 2 : integer
	}
	response {}
}

combat_turn_start 5 {
	request {
		turn_count 0 : integer
	}
	response {}
}

.attribute_change_action {
	target_id 0 : integer
	hp_change 1 : integer
	mp_change 2 : integer
}

.secondary_action {
	attribute_change_action_list 0 : *attribute_change_action
}

.major_action {
	caster_id 0 : integer
	skill_id 1 : integer
	skill_level 2 : integer
	secondary_action_list 3 : *secondary_action
}

.combat_unit_attribute {
	unit_id 0 : integer
	max_hp 1 : integer
	hp 2 : integer
	max_mp 3 : integer
	mp 4 : integer
}

combat_turn_play 6 {
	request {
		combat_unit_attribute_list 0 : *combat_unit_attribute
		major_action_list 1 : *major_action
	}
	response {}
}

combat_turn_end 7 {
	request {
		win_team 0 : integer
	}
	response {}
}

]]

return proto