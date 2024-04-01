local M                       = {}

local data                    = require "main.data"
local factories               = {
	['wall'] = '/factories#wall',
	['corner'] = '/factories#corner',
	['door'] = '/factories#door',
	['ground'] = '/factories#ground',
	['ground_small'] = '/factories#ground_small'
}

local tile_types              = {
	[0] = 'ground',
	[2] = 'corner',
	[3] = 'wall',
	[4] = 'door',

}

local FlippedHorizontallyFlag = 0x80000000
local FlippedVerticallyFlag   = 0x40000000
local FlippedDiagonallyFlag   = 0x20000000
local ClearFlag               = 0x1FFFFFFF

M.MAP_TILE_WIDTH              = 8
M.MAP_TILE_HEIGHT             = 8
M.MAP_SIZE                    = M.MAP_TILE_WIDTH * M.MAP_TILE_HEIGHT
M.TILE_PX_WIDTH               = 4
M.TILE_PX_HEIGHT              = 4
M.MAP_PX_WIDTH                = M.TILE_PX_WIDTH * M.MAP_TILE_WIDTH
M.MAP_PX_HEIGHT               = M.TILE_PX_HEIGHT * M.MAP_TILE_HEIGHT

function M.create_level()
	--	local height = M.MAP_SIZE / M.MAP_TILE_WIDTH
	for i, v in ipairs(data) do
		local pos_x = (i - 1) % M.MAP_TILE_WIDTH + 1
		local pos_y = (math.ceil(i / M.MAP_TILE_HEIGHT) - 1)

		local gid = v

		local flip = {}
		if gid > 1000 or gid < -1000 then
			flip.x = bit.band(gid, FlippedHorizontallyFlag) ~= 0
			flip.y = bit.band(gid, FlippedVerticallyFlag) ~= 0
			flip.xy = bit.band(gid, FlippedDiagonallyFlag) ~= 0
			gid = bit.band(gid, ClearFlag)
		end

		pos_x = pos_x * M.TILE_PX_WIDTH - (M.MAP_TILE_WIDTH * M.TILE_PX_WIDTH / 2)
		pos_y = pos_y * M.TILE_PX_HEIGHT - (M.MAP_TILE_HEIGHT * M.TILE_PX_HEIGHT / 2)
		local type = tile_types[gid]
		local rotation_quat = vmath.quat(0, 0, 0, 0)

		if v ~= 0 then
			if flip.xy == true and (flip.x == true or flip.y == true) and type ~= 'corner' then
				rotation_quat = vmath.quat_rotation_y(math.rad(90))
			end

			if flip.xy == false and flip.x and type ~= 'corner' then
				rotation_quat = vmath.quat_rotation_y(math.rad(90))
			end

			if type == 'corner' and flip.y then
				rotation_quat = vmath.quat_rotation_y(math.rad(-90))
			end

			if type == 'corner' and flip.x then
				rotation_quat = vmath.quat_rotation_y(math.rad(90))
			end

			if type == 'corner' and flip.xy then
				rotation_quat = vmath.quat_rotation_y(math.rad(180))
			end

			if type == 'corner' and flip.x and flip.y then
				rotation_quat = vmath.quat_rotation_y(math.rad(180))
			end
			local test = factory.create(factories[type], vmath.vector3(pos_x, 0, pos_y), rotation_quat)

			-- GROUND UNDER THE WALLS
			local test = factory.create(factories['ground'], vmath.vector3(pos_x, 0, pos_y))
		else
			local test = factory.create(factories[type], vmath.vector3(pos_x, 0, pos_y))
		end
	end
end

return M
