--等级属性计算公式  multiplier1 * (level-1)^ exponential + multiplier2 * (level-1) + base

local config = 
{
	[1] = {name = "弓手", base_hp=100, multiplier1_hp=1, multiplier2_hp=20, exponential_hp=2, base_mp=80, multiplier1_mp=1, multiplier2_mp=1, exponential_mp=2, move_speed=6},
    [2] = {name = "战士", base_hp=150, multiplier1_hp=1, multiplier2_hp=30, exponential_hp=3, base_mp=60, multiplier1_mp=1, multiplier2_mp=1, exponential_mp=2, move_speed=6},
}

return config
